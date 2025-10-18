# Q:

What is the advised topology/architecture for Windows Server 
integrated with RHEL through IdM and K8s cert-manager?

# A:

Below is a reference topology and workflow for an environment where you have:

* A single Windows Server 2019 acting as your AD DS + AD CS root, and also providing DHCP/DNS.
* One or more RHEL hosts running IdM (FreeIPA/Dogtag) that must federate to AD for user/group identity and also serve as a subordinate CA.
* A Kubernetes cluster (on RHEL or other Linux nodes) that uses cert-manager to request TLS certificates from the IdM CA.

The goal is that:

1. Windows AD DS remains the authoritative directory for users and groups.
2. RHEL IdM joins (or trusts) that AD domain so that Linux machines (and Kubernetes) can authenticate the same users and leverage Kerberos SSO.
3. The IdM “Dogtag” CA is configured as an Enterprise Subordinate CA under the Windows AD CS root.
4. Kubernetes cert-manager is pointed at the IdM CA (Dogtag) so that all in-cluster workloads (Ingress controllers, webhooks, TLS certificates for services, etc.) get signed by a CA whose chain roots back to the Windows Root CA.
5. Clients (Windows, Linux, and any downstream appliances) only need to trust the Windows Root CA (which is already auto-distributed by AD) in order to validate any Issued certificate (because the subordinate chain flows through IdM → Root).

Below is a logical‐layer view, followed by a brief explanation of how each component is installed and configured.

---

## 1. Logical topology overview

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│                         Windows AD Domain (“AD.LAN”)                       │
│                                                                            │
│   ┌─────────────────────┐            ┌──────────────────────────────────┐  │
│   │  Windows Server A   │            │  RHEL Germanium (IdM Server)     │  │
│   │ (Domain Controller) │            │   (Joined or Trusting AD)        │  │
│   │  + DHCP + DNS       │◄─ LDAP  ──►│   (FreeIPA/IdM + Dogtag CA)      │  │
│   │  + AD CS Root CA    │ + Kerberos │  Role: Enterprise Subordinate CA │  │
│   └─────────────────────┘            └──────────────────────────────────┘  │
│           │                                          │                     │
│           │  1. Subordinate CSR (PKCS#10)            │                     │
│           │  2. Signed SubCA certificate (PKCS#7)    │                     │
│           ▼                                          │                     │
│ ┌─────────────────────┐                              │                     │
│ │  RHEL Kubernetes    │                              │                     │
│ │  Control Plane +    │                              │                     │
│ │  Worker Nodes       │                              │                     │
│ │  – SSSD clients     │◄──────── Identity ───────────┘                     │
│ │  – cert-manager     │◄──────── CA Issuance ─────────> Dogtag CA          │
│ └─────────────────────┘                                     │              │
│           │                                                 │              │
│           │                                                 ▼              │
│   (Other Linux hosts)⟷SSSD identity (authentication/SSO)⟷────────────────┘
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Legend:**

1. **Windows Server A** (fully patched WS2019):

   * Runs **AD DS**, **AD UAC**, **AD CS (Root CA)**, **DHCP**, **DNS**.
   * Its AD CS role is configured as an **“Enterprise Root CA.”**
   * Its Root CA certificate is auto-published into AD’s NTAuth store and automatically deployed to **Trusted Root** on all domain-joined Windows machines (and can be pushed to Linux via GPO if desired).
2. **RHEL Germanium (IdM server)**:

   * A RHEL 8/9 VM (or bare-metal) whose IdM instance (FreeIPA + Dogtag) is set up as a **domain member** (or a trusted domain) of **AD.LAN**.
   * That IdM host is installed as an **Enterprise Subordinate CA**, using a CSR which is signed by the Windows CS Root. Once imported, Dogtag becomes the “live” issuing CA for Linux/K8s.
   * This IdM host also provides **LDAP/LDAP+Kerberos** to RHEL/K8s nodes, so that all Linux boxes use a single identity & SSO realm that ultimately chains back to AD DS.
3. **RHEL Kubernetes cluster** (Control‐plane + Worker nodes):

   * Each node is joined to IdM via SSSD (so AD users can authenticate to `kubectl` if RBAC allows).
   * **cert-manager** (in-cluster) uses a Kubernetes ClusterIssuer or Issuer of type **“CA”** that points to Dogtag’s CA key & certificate (kept in a Kubernetes Secret).
   * pod workloads that need “service-TLS” get certificates from Dogtag, whose chain goes Root CA ←◄ Subordinate (Dogtag) ←◄ leaf.

By doing this, all TLS certificates in K8s are automatically trusted by any AD‐joined Windows or Linux boxes—because they already trust the Root CA built into AD CS.

See `AD-IPA.DNS` ([MD](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.DNS.md)|[HTML](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.DNS.html)) 


---

## 2. Step-by-step component breakdown

### 2.1 Windows Server A (AD DS + AD CS as Enterprise Root)

1. **Install AD DS, DNS, DHCP, UAC** as usual:

   * Promote to a domain controller (e.g. `DC1.AD.LAN`) with DNS and DHCP roles installed.
   * Create your user and group OUs, etc., per policy.

2. **Install the AD CS role** with “Enterprise Root CA”:

   * In **Server Manager → Add Roles & Features → Active Directory Certificate Services → Certification Authority**, select **“Enterprise Root CA.”**
   * Let it generate a new 4096-bit key, choose a long validity (e.g. 10 years), and publish it into AD (NTAuth).
   * Confirm that you can browse to `https://dc1.ad.lan/certsrv` and see **“Microsoft Active Directory Certificate Services – DC1-CA.”**

3. **Export the Root CA certificate** (Base-64 (.CER)) to a location you can copy to the RHEL IdM server.

   * Open **certmgr.msc** → **Trusted Root Certification Authorities → Certificates** → find your CA → Right-click → **All Tasks → Export → Base-64 X.509 (.CER)** → save as `/root/ca/root-ca.cer`.

### 2.2 RHEL Germanium (IdM/FreeIPA + Dogtag subordinate CA)

On your RHEL 8/9 host (we’ll call it `idm.ad.lan`), assume you already installed the RHEL subscriptions and updated.

#### 2.2.1 Join (or Trust) AD for identity

You have two main patterns:

* **Join IdM as a member of AD** (IdM is a domain member of `AD.LAN`)
  – Pros: AD masters all identities; IdM simply replicates AD data into its LDAP/Kerberos realm.
  – Cons: Slightly more complex DNS/ACLs.
* **Create a cross-forest trust** between IdM’s realm (IPA) and AD DS.
  – Pros: Each realm retains its own LDAP; Linux still authenticates to IdM, Windows to AD, but user accounts can cross.
  – Cons: Certificate enrollment must be explicitly configured.

Most people pick **“join IdM as an AD member”** for simplicity. In that mode:

1. **Install IdM (FreeIPA) packages**:

   ```bash
   dnf install ipa-server bind‐dns ipa‐server‐dogtag dogtag‐pki‐ca‐util
   ```
2. **Initialize IPA server** (as an AD domain member):

   ```bash
   ipa-server-install \
     --domain=ad.lan \
     --realm=AD.LAN \
     --hostname=idm.ad.lan \
     --ds-password=‘<DirectoryAdminPassword>’ \
     --krb5-realm=AD.LAN \
     --setup‐trust=ad \
     --admin-password=‘<IdMAdminPassword>’ \
     --id-trust-ou=“OU=IdMTrusted,dc=ad,dc=lan” \
     --skip-reverse-lookup
   ```

   * The `--setup-trust=ad` flag configures an AD trust.
   * During setup, IPA prompts for an AD user with rights to create a computer account in `AD.LAN`.
3. **Verify the trust**:

   ```bash
   kinit Administrator@AD.LAN
   ipa trustzone-find
   ```

   You should see the “AD Trust” listed and active.

Now, any AD user can authenticate to this IdM server via Kerberos/SSSD (Linux machines will ultimately trust both IdM and AD principals).

#### 2.2.2 Create the Dogtag subordinate CA by having AD CS sign its CSR

1. **Generate a Dogtag (subordinate) CA enrollment request**.

   * During the `ipa-server-install`, if you specify `--ca-subordinate` (instead of setting up a local Dogtag Root), IPA sets up a subordinate CSR at `/etc/pki/pki-tomcat/ca-csr/pki-subsystem-01-subca-ca.csr`.
   * Alternatively, you can reconfigure after installation:

     ```bash
     ipa-ca-install \
       --external
     ```

     This will generate a CSR in `/var/lib/pki/pki-tomcat/ca/subsystem-ca-sub-ca.csr`.

2. **Copy the CSR (`.csr` or `.req`) to your Windows AD CS host** (`DC1.AD.LAN`).

   ```bash
   scp /var/lib/pki/pki-tomcat/ca/subsystem-ca-sub-ca.csr administrator@dc1.ad.lan:/temp/
   ```

3. **Submit that CSR on the AD CS side**:

   * Open **Certification Authority** MMC.
   * Right-click on your CA (`DC1-CA`) → **All Tasks → Submit new request…** and point to `subsystem-ca-sub-ca.csr`.
   * You’ll see a pending request in **Certificate Authority → Pending Requests**.
   * Right-click the request → **Issue**.

4. **Export the signed Subordinate CA certificate (including the chain)**:

   * In **Issued Certificates**, locate the Subordinate CA certificate.
   * Right-click → **All Tasks → Export** → choose **“Base-64 X.509 (.CER)”**. Let’s say you save it as `idm-subca.cer`.
   * You also need the Root CA chain: from **Trusted Root Certification Authorities → DC1-CA**, export that Root (Base-64). Call it `root-ca.cer`.
   * Combine them into one PEM (or P7B) so Dogtag can import both at once. For example:

     ```powershell
     copy /b idm-subca.cer + root-ca.cer idm-subca-chain.cer
     ```

     (Or create a P7B using certutil if you prefer.)

5. **Copy `idm-subca-chain.cer` back to the IdM host**:

   ```bash
   scp administrator@dc1.ad.lan:/temp/idm-subca-chain.cer /root/
   ```

6. **Complete the Dogtag Subordinate CA installation**:

   ```bash
   ipa-ca-install \
     --external-signed-ca-cert=/root/idm-subca-chain.cer \
     --external-ca-name="IdM Dogtag Subordinate CA" \
     --ca-subject="CN=IPA-Subordinate-CA,OU=Dogtag,C=US" \
     --no-forwarding \
     --no-ca-tsl \
     --no-crl-publish
   ```

   * This command imports `idm-subca-chain.cer` into Dogtag. Now Dogtag is an **Enterprise Subordinate CA** that chains to AD CS Root.
   * Verify:

     ```bash
     pki -h pki.example.com cert-find "CN=IPA-Subordinate-CA"
     ```

     You should see your Subordinate CA certificate with a chain ☑.

#### 2.2.3 Verify the chain and publish trust

* The IdM host’s Dogtag CA certificate should now have a chain:

  ```
  ■ Dogtag-Subordinate-CA (CN=IPA-Subordinate-CA)
    ↳ Issued by → ■ DC1-CA (Root AD CS)
  ```
* Because the Root (`DC1-CA`) is already in AD’s NTAuth and automatically pushed to domain clients, any Linux host that trusts the IdM CA (and knows the Root) will validate leaf certificates properly.

### 2.3 RHEL Kubernetes cluster + cert-manager

On your Kubernetes control plane (which might be on RHEL VMs, or an OpenShift-flavored distro, etc.):

#### 2.3.1 Join each node to IdM for unified identity

1. **Install SSSD and the IdM client packages**:

   ```bash
   dnf install ipa-client sssd realmd oddjob-mkhomedir adcli
   ```
2. **Enroll each node into IdM** (so that AD/IdM accounts can be used for SSH, `kubectl`, etc.):

   ```bash
   ipa-client-install \
     --mkhomedir \
     --principal=administrator \
     --password \
     --domain=ad.lan \
     --realm=AD.LAN \
     --server=idm.ad.lan \
     --no-dns-updates \
     --force-join
   ```
3. **Verify SSSD works**:

   ```bash
   id administrator@ad.lan
   getent passwd someuser@ad.lan
   kinit someuser@ad.lan
   ```
4. **Configure `/etc/krb5.conf`** if needed to point at the IdM KDC (which in turn trusts AD).

Now any AD user can run `ssh node1.ad.lan` + `kinit`, and be recognized.

#### 2.3.2 Install cert-manager and configure a CA Issuer

1. **Install cert-manager** (v1.x) into the cluster:

   ```bash
   kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.12.0/cert-manager.yaml
   ```
2. **Export the Dogtag Subordinate CA key and certificate** from the IdM host into Kubernetes Secrets.

   * On `idm.ad.lan`, locate the subordinate CA’s private key and cert:

     ```bash
     ls /etc/pki/pki-tomcat/ca/*
     ```

     Typically, you have:

     ```
     /etc/pki/pki-tomcat/ca/public/ipa-subsystem-ca-sub-ca.crt
     /etc/pki/pki-tomcat/ca/private/ipa-subsystem-ca-sub-ca-key.pem
     ```
   * Combine into one secret YAML. For example, on `idm.ad.lan`:

     ```bash
     kubectl create namespace cert-manager-system --dry-run=client -o yaml > ns.yaml
     kubectl apply -f ns.yaml

     kubectl create secret tls idm-subca-tls \
       --namespace=cert-manager-system \
       --cert=/etc/pki/pki-tomcat/ca/public/ipa-subsystem-ca-sub-ca.crt \
       --key=/etc/pki/pki-tomcat/ca/private/ipa-subsystem-ca-sub-ca-key.pem \
       --dry-run=client -o yaml > subca-secret.yaml
     kubectl apply -f subca-secret.yaml
     ```
3. **Create a `ClusterIssuer` (or `Issuer`) that references the `idm-subca-tls` secret**:

   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: idm-subca-issuer
   spec:
     ca:
       secretName: idm-subca-tls
       # Optional: you can embed the root chain if needed, but usually
       # cert-manager will inject the full chain based on the CA bundle.
   ```

   Apply:

   ```bash
   kubectl apply -f - <<EOF
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: idm-subca-issuer
   spec:
     ca:
       secretName: idm-subca-tls
   EOF
   ```
4. **Test issuance**:

   ```yaml
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
     name: test-tls-cert
     namespace: default
   spec:
     secretName: test-tls-secret
     duration: 24h
     renewBefore: 12h
     privateKey:
       algorithm: RSA
       size: 2048
     commonName: test.ingress.ad.lan
     dnsNames:
       - test.ingress.ad.lan
     issuerRef:
       name: idm-subca-issuer
       kind: ClusterIssuer
   ```

   ```bash
   kubectl apply -f test-cert.yaml
   kubectl describe certificate test-tls-cert
   ```

   You should see cert-manager successfully request a cert from Dogtag, and a Kubernetes secret `test-tls-secret` containing:

   ```
   tls.crt  ← Leaf certificate (signed by Dogtag SubCA)
   tls.key  ← Private key for “test.ingress.ad.lan”
   ca.crt   ← The SubCA certificate (Dogtag)
   ```

   When you decode `tls.crt`, you’ll see:

   ```
   Issuer: CN=IPA-Subordinate-CA,OU=Dogtag,C=US
   Validity: …
   Subject: CN=test.ingress.ad.lan
   … 
   Signed by → IPA-Subordinate-CA
     Signed by → DC1-CA (Root)
   ```

   Now any client (Windows or Linux) that has already put **DC1-CA** in its Trusted Root will validate this leaf. Internally, most Linux distributions joined to IdM already trust the Dogtag SubCA (because IdM auto-distributes the SubCA cert to SSSD’s trust store).

---

## 3. Summarized data flows

| **Flow**                                             | **Description**                                                                                                                                                                                                                                                          |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1. User/group identity (K8s login, SSH, etc.)**    | • AD DS holds all users/groups. <br>• IdM trusts/joined to AD—so IdM LDAP/Kerberos can authenticate AD principals. <br>• Linux/K8s nodes run SSSD against IdM. <br>• `kubectl` uses OIDC or Kerberos (depending on your K8s auth setup) to let AD users log in.          |
| **2. Subordinate CA chain creation**                 | • IdM issues a CSR (PKCS#10) for Dogtag subordinate. <br>• Windows AD CS (Root) signs CSR. <br>• IdM imports the signed SubCA + Root chain. <br>• Dogtag is now an Enterprise SubCA.                                                                                     |
| **3. Certificate issuance in Kubernetes (cert-mgr)** | • cert-manager’s ClusterIssuer points at the Dogtag SubCA key+cert. <br>• In-cluster `Certificate` objects cause cert-manager to call Dogtag (through the CA issuer). <br>• Dogtag issues leaf TLS certs. <br>• Clients validate by trusting Root (auto-deployed by AD). |

---

## 4. Why this topology is “advised”

1. **Single source of identity (AD DS)**

   * Windows AD remains your root of truth for all users, groups, and computers.
   * RHEL IdM, by joining/trusting AD, means you do not recreate user accounts in two places or require manual LDAP synchronization.

2. **Two-tier PKI with proper security boundaries**

   * **Tier 1 (offline or well-protected):** Windows AD CS Root CA host. Its private key is highly secured (preferably offline when not in use).
   * **Tier 2 (online, domain-joined):** RHEL IdM Dogtag as a Subordinate Enterprise CA. Its signing key is on a hardened Linux host, isolated, and can be backed up by IPA’s replication.
   * Day-to-day TLS cert issuance is done by Dogtag, not by the Root, minimizing exposure of the Root’s private key.

3. **Automatic trust distribution**

   * The Root CA certificate is already in AD’s NTAuth store → automatically deployed to **“Trusted Root”** on all Windows domain-joined machines and (via GPO) to AD Member Linux boxes (so they trust the entire chain).
   * IdM’s Dogtag SubCA certificate is automatically propagated via SSSD’s trust mechanism to any Linux node (so Linux clients trust Dogtag by default, since SSSD imported that SubCA as a trusted issuer).

4. **Separation of roles**

   * Windows Server A focuses on AD DS + AD CS Root + DHCP/DNS (Windows-native tasks).
   * RHEL IdM focuses on Linux identity, Kerberos SSO, and online subordinate PKI (Dogtag).
   * Kubernetes + cert-manager sit atop IdM’s CA for issuing ephemeral certificates—your cluster never touches the Root CA directly.

5. **Scalability & future extensions**

   * If you later add more Subordinate CAs (e.g. a replica Dogtag instance for high availability or a PKI in another site), AD CS will simply sign their CSRs and they become additional SubCAs.
   * Kubernetes clusters in other network segments can also point to IdM’s Dogtag SubCA (or a replica) for consistent trust chains.

---

## 5. Other integration notes

1. **Kubernetes API authentication**

   * If you want AD users to `kubectl auth` directly, you can enable the Kubernetes API server to accept Kerberos tickets (via OpenID Connect through Keycloak or Dex), or use the **Webhook token authentication** pointing at IdM’s LDAP/Kerberos. There are multiple OIDC/Dex/Keycloak integrations; that is orthogonal to cert-manager but often desired.

2. **DHCP/DNS interplay**

   * Windows Server A (the DC) also runs DNS. When you create a reverse lookup or forward lookup zone, be sure to register both `idm.ad.lan` and `k8s-control1.ad.lan` (and any worker node) with the DC’s DNS, so that Kerberos, SSSD, and K8s node enrollment all function without manual `/etc/hosts` entries.

3. **Cross-forest trust (alternate)**

   * If IdM cannot “join” the AD domain (e.g. you must keep IdM in its own realm), you can still set up an IdM ↔ AD cross-realm trust. In that case, Kerberos can flow between them, but you’ll need to manually distribute the Root CA cert into the IdM trust store, and you cannot use `ipa-client-install --setup-trust`—you must configure trusts by importing realm keys, etc. This is more complex, so “domain-member” mode is highly recommended when you have only one AD domain.

4. **Audit & compliance**

   * Because Windows AD CS signs the subCA CSR, all events (CSR issued, CSR approved, certificate issued) are logged in the AD CS event log. Dogtag logs issuance events on the IdM side. You get a full audit trail.

5. **Certificate template best practices**

   * In AD CS, create a specific certificate template for subordinate Dogtag (e.g. “IPA-SubCA‐Template”), and limit enrollment ACL so only the IdM’s computer object can request it.
   * In Dogtag, configure certificate profiles (e.g. “k8s-ingress-TLS”) that map to K8s service names, with appropriate key sizes (2048/4096).

---

## 6. Example DNS and CA naming conventions

Below is a small table showing how you might name each DNS record and each CA, so everything is unambiguous:

| **Component**            | **DNS A Record**    | **Certificate CN (Subject)**                   | **Role in Trust Chain**                  |
| ------------------------ | ------------------- | ---------------------------------------------- | ---------------------------------------- |
| Windows AD DC/Root CA    | `dc1.ad.lan`        | CN = `DC1-CA`, O = `AD.LAN`, C = `US`          | AD CS Root CA (auto-distributed)         |
| RHEL IdM server          | `idm.ad.lan`        | CN = `IPA-Subordinate-CA`, OU = `Dogtag`, C=US | Dogtag Subordinate CA (issued by DC1-CA) |
| Kubernetes API server(s) | `k8s-api.ad.lan`    | CN = `k8s-api.ad.lan`                          | Leaf, issued by Dogtag SubCA             |
| Ingress endpoint(s)      | `app1.ad.lan`, etc. | CN = `app1.ad.lan`                             | Leaf, issued by Dogtag SubCA             |

* **AD CS Root CA** (`DC1-CA`):

  * Lives on `dc1.ad.lan` (Windows).
  * Automatically in **Trusted Root** of any AD-joined machine.

* **Dogtag Subordinate CA** (`IPA-Subordinate-CA`):

  * Lives on `idm.ad.lan` (RHEL).
  * Its certificate chain goes:

    ```
    IPA-Subordinate-CA (Dogtag, installed in /etc/pki/... on IdM) 
      signed by → 
    DC1-CA (Root) (published in AD’s NTAuth)
    ```
  * SSSD (and any `ipa-client`) automatically trusts `IPA-Subordinate-CA` in `/etc/ipa/ca.crt` so Linux machines do not need manual distribution.
  * Windows clients already trust `DC1-CA`, so they transitively trust all Dogtag‐issued leaf certs.

* **cert-manager**:

  * Configured so that any in-cluster `Certificate` object uses `issuerRef: { name: idm-subca-issuer, kind: ClusterIssuer }`.
  * The `ClusterIssuer` secret holds `tls.key` = Dogtag SubCA’s private key, and `tls.crt` = Dogtag SubCA’s certificate.
  * cert-manager issues leaf certificates for any Kubernetes Ingress, webhook server, or service.

---

## 7. Summary and final recommendations

1. **Always keep your Windows AD CS Root CA as a separate, tightly-secured host.**
   – Do not install any other CA role on that machine besides the Root.
2. **Stand up one (or more) RHEL IdM servers to act as Enterprise Subordinate CA(s).**
   – Use `ipa-server-install --setup-trust=ad` or trust methodology to join to AD.
   – Use `ipa-ca-install --external` after signing the CSR on AD CS.
3. **Distribute and verify trust properly**:

   * AD automatically pushes the Root CA to Windows domain members; use GPO to push it to Linux if you want GUI apps on Linux to trust it.
   * IdM automatically pushes the SubCA to Linux clients (via SSSD).
4. **Configure Kubernetes cert-manager with the SubCA certificate + key** (`tls.crt` + `tls.key`) as a `ClusterIssuer`.
5. **From here on out, issue all end-entity certificates from Dogtag**; the client chain validation will follow:
   ☐ Leaf (cert-manager) ← signed by Dogtag(SubCA) ← signed by AD CS(Root).

This achieves:

* A clean, auditable two-tier PKI (Root on Windows, SubCA on Linux).
* Unified identity (AD → IdM → Linux/K8s).
* Automated, cluster-wide certificate issuance for all Kubernetes services via cert-manager.
* A single trust anchor (AD CS Root) to install into any external device or appliance (for example, load balancers, IoT devices, network appliances) so they trust the same chain.

Once configured this way, you have a fully integrated Windows ↔ RHEL PKI/IdM/Kubernetes ecosystem:

* **Windows users** authenticate to K8s `kubectl` (if you set up OIDC or Kerberos-based auth).
* **Linux/RHEL servers** authenticate to AD via IdM’s cross-realm trust.
* **cert-manager** issues TLS certificates for all in-cluster workloads signed by Dogtag, chained to AD CS.
* **All clients** only need to trust the Root CA (which AD DS already pushes), so there is no further manual trust distribution.

That is the recommended, “industry-best-practice” topology when you have one Windows CA (root), one or more Linux IdM SubCA servers, and a Kubernetes cluster that must automatically obtain and rotate certificates.

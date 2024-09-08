# [Kubernetes](https://kubernetes.io/docs "Kubernetes.io") (K8s) | [Releases](https://kubernetes.io/releases/)

## TL;DR

Kubernetes is a universal control plane that is most commonly used to build platforms for managing containerized workloads.

## [Overview](https://kubernetes.io/docs/home/?path=users&persona=app-developer&level=foundational) | [Tools](https://kubernetes.io/docs/reference/tools/ "kubernetes.io/docs/...") | [GitHub](https://github.com/kubernetes "Kubernetes repo") | [Wikipedia](https://en.wikipedia.org/wiki/Kubernetes)  

## Vanilla Cluster

[Install a production-environment cluster using `kubeadm`.](https://kubernetes.io/docs/setup/production-environment/)

### Prep host 

See [`K8s.configure-kernel.sh`](K8s.configure-kernel.sh)

### Install CRI 

See [`K8s.provision-cri.sh`](K8s.provision-cri.sh)

### Install K8s tools and CNI Plugins

See [`K8s.provision-kubernetes.sh`](K8s.provision-kubernetes.sh)

## Topics of Interest

### [Local ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#local-ephemeral-storage) | [ChatGPT](https://chatgpt.com/share/2846e45f-b59f-4911-be09-09cd1e4f903c)

The `kubelet` tracks: 

- `emptyDir` volumes, except volumes of `tmpfs`
- Directories holding node-level logs
- Writeable container layers

>The `kubelet` tracks ***only the root filesystem*** for ephemeral storage. 
>OS layouts that mount a separate disk to `/var/lib/kubelet` or `/var/lib/containers` 
>*will not report ephemeral storage correctly*.

The kubelet writes logs to `/var/log` by default; 
and has a base directory for other locally stored data, 
`/var/lib/kubelet` by default.

#### Mounts

To avoid issues, mount all `/var/lib/*` on one XFS partition:

- `/var/lib/kubelet`
- `/var/lib/docker` 
- `/var/lib/containerd `

Mount logs dir on separate partition.

- `/var/logs`

#### Disk Pressure Thresholds

@ kubelet configuration:

```yaml
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "10%"
  nodefs.inodesFree: "5%"
```

##### Namespace scoped Quotas/Limits

@ `ResourceQuota` 

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
  namespace: my-namespace
spec:
  hard:
    requests.ephemeral-storage: "10Gi" # Total of requests
    limits.ephemeral-storage: "15Gi"   # Total of limits
```

@ `LimitRange`

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: storage-limit-range
  namespace: my-namespace
spec:
  limits:
    - type: Container
      default:
        ephemeral-storage: "1Gi"    # Default limit if not specified
      defaultRequest:
        ephemeral-storage: "500Mi"  # Default request if not specified.
      max:
        ephemeral-storage: "2Gi"    # Max allowed
      min:
        ephemeral-storage: "200Mi"  # Min that must be requested
```


### [Operator (Pattern)](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

The goal of an Operator is to put operational knowledge into software. Previously this knowledge only resided in the minds of administrators, various combinations of shell scripts or automation software like Ansible. It was outside of your Kubernetes cluster and hard to integrate. With Operators, CoreOS changed that.

Operators implement and automate common Day-1 (installation, configuration, etc.) and Day-2 (re-configuration, update, backup, failover, restore, etc.) activities in a piece of software running inside your Kubernetes cluster, by integrating natively with Kubernetes concepts and APIs. We call this a Kubernetes-native application. 

With Operators an application is treated as a single object, and exposes only that 
which makes sense for the application to work.

### [Cluster Control-plane TLS](https://kubernetes.io/docs/tasks/administer-cluster/certificates/) | [Managing TLS](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/)

### [__Authn__/__Authz__](https://kubernetes.io/docs/concepts/security/controlling-access/ "Kubernetes.io")

Regarding identity, Kubernetes has 
[two categories](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#user-accounts-versus-service-accounts)) 
of subject: 

1. [__`ServiceAccount`__](https://kubernetes.io/docs/concepts/security/service-accounts/) :  K8s object for non-human subjects AKA *entities*; Pod, DaemonSet, CronJob, 
   Job, CRD, controllers, operators, &hellip;, and **external services** (CI/CD pipelines for example). Upon creation of a Pod, K8s generates/attaches to it a common ServiceAccount named `default` in Pod's namespace (). This has neither `Role` nor `RoleBinding` objects and so its permissions are very limited (depending on cluster policies). Authentication is typically by Bearer Token. 
    ```bash
    sa=$(k get -n kube-system pod coredns-576bfc4dc7-f9kkh -o jsonpath='{.spec.serviceAccount}')
    tkn=$(k create -n kube-system token $sa --duration 10m)
    ip=$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}')
    # Send GET request to the protected API server
    curl -ikH "Authorization: Bearer $tkn" https://$ip:6443/version # JSON response body
    ```
1. [__user__ or __group__](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#users-in-kubernetes) : K8s concepts of human subjects. Neither are objects of the K8s API; however, both are searched for, and can be authenticated against, by K8s API from client's TLS certificate fields, and mapped to `kind` of `[Cluster]RoleBinding` : 
    ```bash
    $ k explain clusterrolebinding.subjects.kind
    GROUP:      rbac.authorization.k8s.io
    KIND:       ClusterRoleBinding
    VERSION:    v1

    FIELD: kind <string>


    DESCRIPTION:
        Kind of object being referenced. Values defined by this API group are
        "User", "Group", and "ServiceAccount". If the Authorizer does not recognized
        the kind value, the Authorizer should report an error.
    ```
    - Organization (`O`) maps to `Group` and Common Name (`CN`) fields of client's TLS certificate. 
    For example, "`Subject: O = team-x1-devs + O = system:basic-user, CN = fred`. 
    To see that of `default` user of a default kubeconfig:
    ```bash
    # View certificate text
    kubectl config view --raw -o jsonpath='{.users[].user.client-certificate-data}' \
        |base64 -d \
        |openssl x509 -text -noout

    # Send GET request to the protected API server using TLS certificate and key
    curl -k \
        --cert <(k config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' |base64 -d) \
        --key <(k config view --raw -o jsonpath='{.users[0].user.client-key-data}' |base64 -d) \
        https://$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}'):6443/version
    ```
    - The build-in **`system:masters`** group is the break-glass *uber admin* having unrestricted access to K8s API; 
    this subject is typically bound to the `cluster-admin` ClusterRole, **allowing any action** (`* verb`) 
    on **any resource** (`* resource`) in **any API group** across **all namespaces**.
        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
        ...
        name: cluster-admin
        ...
        subjects:
        - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: system:masters
        ```
    - [Create TLS certificate](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user) for a **user** or **group** : See [`K8s.users.and.groups.sh`](K8s.users.and.groups.sh) .
- [__Authentication__](https://kubernetes.io/docs/reference/access-authn-authz/authentication/ "Kubernetes.io") (Authn)
    - Two (Data-plane) scenarios
        1. Clients authenticating against the K8s API server
            - The two most common methods:
                - [X.509 certificate issued by K8s CA](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user "Kubernetes.io") 
                - Token (JWTs) generated by an OIDC provider, e.g., __Dex__ or __Keycloak__, that acts as proxy of upstream Identity Provider (__IdP__), such as AD/LDAP, against which it authenticates a subject, which is [presumably recognizable to K8s](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"), i.e., a user/group or `ServiceAccount` having K8s `cluster.user` and (`Cluster`)`RoleBinding`. 
        1. Users authenticating at web UI against an application running on the cluster.
            - Token (JWTs) generated by an OIDC provider (same as above method). 
    - [Authentication Plugins](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authentication-strategies "Kubernetes.io")
        - Static Token file
            - Bearer token
            - Service Account token
        - X.509 certificates
        - [Open ID Connect (OIDC) token](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")
        - Authentication proxy
        - Webhook
- [__Authorization__](https://kubernetes.io/docs/reference/access-authn-authz/authorization/ "Kubernetes.io") (Authz) | Modules/[Modes](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules "Kubernetes.io")   
  Regardless of authentication method, 
  K8s can implement Role-based Access Control ([RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/ "Kubernetes.io")) model 
  against subjects ([known by request attribute(s)](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#request-attributes-used-in-authorization "Kubernetes.io"))
  using a pair of K8s objects for each of the two scopes of K8s API resources (`api-resources`):
      1. Namespaced (`Deployment`, `Pod`, `Service`, &hellip;)
          - `Role` : Rules declaring the allowed actions (`verbs`) upon `resources` scoped to APIs (`apiGroup`).
          - `RoleBinding` : Binding a subject (authenticated user or ServiceAccount) to a role.
      1. Cluster-wide (`PersistentVolume`, `StorageClass`, &hellip;)
          - `ClusterRole`
          - `ClusterRoleBinding`

### [Manage TLS Certificates](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/)

    Organization         K8s Workloads              K8s Control Plane
    ------------         ---------------------      ------------------------------------------
    AD CS : Root CA  ->  Vault : Interm-CA Key  <-  Manually add 
                         Vault : Interm-CA Key  ->  kubelet mTLS CA-signed Certs Create/Rotate
                         Vault : Interm-CA Key  ->  kubelet mTLS CA-signed Certs Create/Rotate
                         Vault : Interm-CA Key  ->  kubectl CSR/approve CA-signed Cert 
                         App CA Trust Bundle    <-  kubectl 
                         App CA Trust Bundle    <-  App (Cert-manager)

The Intermidary (Subordinate) CA can be scoped in time, capabilities and permitted/excluded domains by declarations in `capolicy.inf` of the Root CA.

See [X.509 Name Constraints](https://www.sysadmins.lv/blog-en/x509-name-constraints-certificate-extension-all-you-should-know.aspx)

#### Q.

Is it reasonable for root CA to delegate to an intermediary CA 
whose key may be kept in Vault or some such for the purpose of 
automating TLS issue/rotation for a K8s  cluster?

#### A:

Yes, delegating a root CA to an intermediary CA whose key is kept in a secure system like HashiCorp Vault is a reasonable and common practice, especially for automating TLS certificate issuance and rotation in Kubernetes or similar environments. Here's why:

1. Security and Key Management:

    Root CA Security: The root CA is typically kept offline or in a highly secure environment because compromising it would undermine the entire certificate chain. Delegating to an intermediary CA allows you to keep the root key secure while still enabling automated certificate management.
    Vault's Security Model: HashiCorp Vault is designed to securely store and manage sensitive data like cryptographic keys. Keeping the intermediary CA's key in Vault allows secure management and restricted access, while enabling automation. Vault can also provide fine-grained access control and logging, enhancing security.

2. Automating Certificate Issuance and Rotation:

    TLS Certificate Lifecycle: Kubernetes environments often require frequent certificate issuance and renewal, especially for short-lived certificates to enhance security. Automating this process helps avoid certificate expiration and manual intervention, ensuring continuous availability.
    Intermediary CA for Automation: By using an intermediary CA whose key is managed in Vault, you can leverage automation tools like cert-manager to handle certificate requests, issuance, and renewal without needing access to the highly sensitive root CA key.

3. Flexibility and Scalability:

    An intermediary CA allows greater flexibility for handling different certificate policies, lifetimes, and usage scenarios without impacting the root CA. This setup scales well with Kubernetes clusters, which may have a high volume of certificate requests across services and pods.

4. Integration with Kubernetes:

    Vault Integration: HashiCorp Vault integrates well with Kubernetes through tools like Vault PKI and the Kubernetes secrets engine. This makes it easy to automate certificate issuance directly to services and workloads running in your Kubernetes cluster.
    cert-manager: In Kubernetes, cert-manager can work with Vault to automatically issue and renew certificates using the intermediary CA stored in Vault, simplifying the management of TLS for Kubernetes services, ingress, and control plane components.

5. Separation of Concerns:

    Using an intermediary CA for day-to-day operations (like issuing certificates for the Kubernetes cluster) reduces the risk of exposing the root CA, as the root is only involved when signing the intermediary CA. This separation adds an additional layer of security to your PKI architecture.

In summary, delegating certificate issuance to an intermediary CA whose private key is stored in Vault is a practical approach to automating TLS issuance and rotation in a Kubernetes environment, ensuring both security and scalability.

#### Q:

What CSR parameters/setting are required to scope the intermediary CA 
to some subset of things (domains?) the Root CA would allow?

#### A:

When delegating a root CA to an intermediary CA, certain parameters and settings in the Certificate Signing Request (CSR) are required to ensure that the intermediary CA is scoped correctly and limited in what it can issue. These constraints help ensure the security and integrity of the PKI by limiting the authority of the intermediary CA to a specific subset of domains, usage, or policies as defined by the root CA. The main parameters and settings to consider are:

1. Basic Constraints:

    CA
    : The Basic Constraints extension must be set to indicate that the certificate is for a CA (i.e., it can issue other certificates).
    Path Length Constraint: This limits the number of subordinate CAs that can be created beneath the intermediary CA. For example, setting pathLenConstraint=0 means that the intermediary CA can issue end-entity certificates but not delegate authority further to another CA.

Example:

```Makefile
basicConstraints = critical, CA:TRUE, pathlen:0
```

2. Key Usage:

The Key Usage extension specifies what cryptographic operations the certificate can be used for. For an intermediary CA, the key usage must include:

    Certificate Signing: To allow the intermediary CA to sign certificates.
    CRL (Certificate Revocation List) Signing: If the intermediary CA will sign its own revocation lists.

Example:

```Makefile
keyUsage = critical, digitalSignature, keyCertSign, cRLSign
```

3. Extended Key Usage (Optional):

Extended Key Usage (EKU) can be used to further restrict the types of certificates the intermediary CA can issue (e.g., only for TLS server certificates). However, EKU is more commonly applied to end-entity certificates, and it is generally less common in intermediary CA certificates. If you want to restrict the intermediary CA to specific purposes, this can be defined here.

Example:

```Makefile
extendedKeyUsage = serverAuth, clientAuth
```

4. Name Constraints:

The Name Constraints extension restricts the domains for which the intermediary CA can issue certificates. This can be a critical control to limit the authority of the intermediary CA to a specific set of domains or subdomains. For example, the intermediary CA could be restricted to issuing certificates only for example.com and its subdomains.

Example:

```Makefile
nameConstraints = critical, permitted;DNS:.example.com
```

    Permitted Subtrees: Specifies which domains or IP address ranges the intermediary CA is allowed to issue certificates for. For example, `.example.com` would allow issuance for example.com and any subdomain.
    Excluded Subtrees: Optionally, you can exclude certain subdomains from the set of allowed domains (e.g., `-example.com`).

5. Certificate Policies:

Certificate Policies allow you to define specific rules or requirements for certificates issued by the intermediary CA. These policies can define practices, legal obligations, or technical constraints.

    The root CA can issue the intermediary CA certificate with a specific policy identifier that restricts the types of certificates the intermediary CA can issue.
    This policy can also reference an external document, such as a Certificate Practice Statement (CPS), that defines the acceptable usage of the certificate.

Example:

```Makefile
certificatePolicies = 1.3.6.1.4.1.11129.2.5.1
```

6. Subject Alternative Name (SAN) and Subject Name:

While SAN is more relevant to end-entity certificates (such as those used for TLS), the root CA may impose certain restrictions on the Subject Name or Subject Alternative Names that the intermediary CA can include in the certificates it issues.

    Subject: The Subject section should reflect the intermediary CA's identity, typically the organization’s name.
    Subject Alternative Name: If desired, you could also scope this to specific domains or IP ranges, although this is more typically enforced through Name Constraints.

7. CRL Distribution Points (CDP) and Authority Information Access (AIA):

These extensions indicate where certificate revocation information and CA certificates can be retrieved. While they don’t directly restrict what the intermediary CA can issue, they are important for ensuring the proper distribution of trust information.

Example:

```Makefile
crlDistributionPoints = URI:http://crl.example.com/intermediaryCA.crl
authorityInfoAccess = caIssuers;URI:http://ca.example.com/rootCA.crt
```

8. Validity Period:

The intermediary CA’s validity period should be scoped appropriately. Typically, it has a shorter validity period than the root CA, ensuring that if compromised, the intermediary CA’s certificates will expire sooner.

### `kubectl`

Client CLI to communicate with Kubernetes API server
Must be configured to cluster, context and have user of `kubeadm`'s config.

### [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file 

>A reference to any file that is used to configure access to clusters. 
>This is a generic way of referring to configuration files. 
>It does not mean that there is a file named `kubeconfig`.

Optionally set using K8s environment variable: `KUBECONFIG=/path/to/that/file`

Example @ `~/.kube/config` (default location)

```yaml
apiVersion: v1
kind: Config
preferences: {}
current-context: kubernetes-admin@kubernetes
clusters:
- cluster:
    server: https://192.168.0.81:6443
    certificate-authority-data: REDACTED    # CA certificate        (public)
    # CA Certificate : /etc/kubernetes/pki/ca.crt
    # CA Key         : /etc/kubernetes/pki/ca.key
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
    namespace: default
  name: kubernetes-admin@kubernetes
users:
- name: kubernetes-admin
  user
    client-key-data: REDACTED               # Client key            (private)
    client-certificate-data: REDACTED       # Client certificate    (public)
```
- This kubeconfig may be clone of server config (only of a control node).
    - `/etc/kubernetes/admin.conf`.
- This client (`kubectl`) configuration file AKA kubeconfig 
  holds `clusters`, `contexts`, and `users`.
- The **client** is **configured to the `current-context`**
  by that declared `contexts[].name` value, having form `USER@CLUSTER`, 
  which is `<context.user>@<context.cluster>`.
    ```bash
    # Get the current context 
    kubectl config current-context #=> kubernetes-admin@kubernetes
    ```
    - A `context` has `contexts[].name`, and is defined by 
        - `cluster`
        - `user`
        - `namespace`
        - A `cluster` has `clusters[].name`, and is defined by
            - `server: https://<ip-address>:<port>` 
            - `certificate-authority-data: <ca-certificate>`
                - The public element of CA's key-cert pair.
        - A `user` has `users[].name`, and is defined by it key-cert pair 
            - `client-key-data: <private-key>`
            - `client-certificate-data: <public-certificate>` 
        - A `namespace` is just a `<string>`.

#### Select a `context` (`current-context`)

```bash
contexts_name=${user}@$cluster # contexts[].name: <context.user>@<context.cluster>
kubectl config use-context $contexts_name 
```

#### kubeconfig : [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts)

Add/Modify context(s), cluster(s), and/or credentials (user(s))

```bash
kubectl config --kubeconfig=$file set-context $contexts_name ...
kubectl config --kubeconfig=$file set-cluster $clusters_name ...
kubectl config --kubeconfig=$file set-credentials $users_name ...
```

Create and set the target kubeconfig (template)

@ `/tmp/config-demo`

```yaml
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
  name: development
- cluster:
  name: test

users:
- name: developer
- name: experimenter

contexts:
- context:
  name: dev-frontend
- context:
  name: dev-storage
- context:
  name: exp-test
```

Modify that kubeconfig

```bash
file='/tmp/config-demo'

# Add CLUSTER details

clusters_name='development'
server='https://1.2.3.4'
kubectl config --kubeconfig=$file set-cluster $clusters_name \
    --server=$server \
    --certificate-authority=$ca_cert

clusters_name='test'
server='https://5.6.7.8'
kubectl config --kubeconfig=$file set-cluster $clusters_name \
    --server=$server \
    --insecure-skip-tls-verify

# Add USER details

users_name='developer'    # users[].name NOT user.username 
kubectl config --kubeconfig=$file set-credentials $users_name \
    --client-certificate="$cert" \
    --client-key="$key"

users_name='experimenter' # users[].name
username='exp'            # users[].name.user.username
password='abc123'
kubectl config --kubeconfig=$file set-credentials $users_name \
    --username=$username \
    --password=$password  # BAD PRACTICE

# Add CONTEXT details

contexts_name='dev-frontend'
clusters_name='development'
ns='frontend'
users_name='developer'    
kubectl config --kubeconfig=$file set-context $contexts_name \
    --cluster=$clusters_name \
    --namespace=$ns \
    --user=$users_name

contexts_name='dev-storage'
ns='storage'
kubectl config --kubeconfig=$file set-context $contexts_name \
    --cluster=$clusters_name \
    --namespace=$ns \
    --user=$users_name

contexts_name='exp-text'
clusters_name='test'
ns='default'
users_name='experimenter' 
kubectl config --kubeconfig=$file set-context $contexts_name \
    --cluster=$clusters_name \
    --namespace=$ns \
    --user=$users_name

```
- `user.{username,password}` 
  exist only for normal users, 
  not for ServiceAccounts.
- Use [`client-go` credential plugins](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins)



### [Admission Controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

An admission controller is code of `kube-apiserver` that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

Admission controllers may be validating, mutating, or both. __Mutating controllers may modify objects__ related to the requests they admit; __validating controllers may not__.

Admission controllers __limit requests to create, delete, modify__ objects. Admission controllers can also block custom verbs, such as a request connect to a Pod via an API server proxy. Admission controllers do not (and cannot) block requests to read (get, watch or list) objects.

```bash
# List all enabled admission controllers
kube-apiserver -h |grep enable-admission-plugins

# Enable some admission controllers
kube-apiserver --enable-admission-plugins=NamespaceLifecycle,LimitRanger ...

# Disable some 
kube-apiserver --disable-admission-plugins=PodNodeSelector,AlwaysDeny ...
```

### Pods Inherit Environment

All Pods of a Namespace inherit the environment variables created by certain mechanisms:

The common environment variables like `KUBERNETES_*` come from Kubernetes itself and are automatically injected into every container running in a pod. These variables are part of Kubernetes' internal mechanism to provide containers with necessary information about the cluster environment.

#### Key Sources of Common Environment Variables:

1. **Service Environment Variables**: Kubernetes automatically creates environment variables for each service **in the same namespace** as the pod, providing the pod with the necessary information to interact with the services in the cluster. Note the Pod/container port is not included. These variables follow a pattern:
    - `${SVC_NAME}_SERVICE_HOST` : Service IP address.
    - `${SVC_NAME}_SERVICE_PORT` : Service port exposed.
    - `${SVC_NAME}_PORT` : Service's full TCP URL, including protocol and port.
    -  ...
    - Example:
        - **Service**:
        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          name: my-service
        spec:
          selector:
            app: my-app
          ports:
            - protocol: TCP
              port: 80          # Service port
              targetPort: 8080  # Pod/Container port
        ```
        - **Environment** injected into **newer Pods**:
          - `MY_SERVICE_SERVICE_HOST=10.96.0.2`
          - `MY_SERVICE_SERVICE_PORT=80`
          - `MY_SERVICE_PORT=tcp://10.96.0.2:80`
              - Note this is *not* an IANA scheme, but rather a convention adopted by projects (Docker, Redis, ZeroMQ, ...) to distinguish non-HTTP TCP from other transports (UDP, FTP, ) of Layer 4.
    - DNS-Based Service Discovery (Alternative): In addition to environment variables, Kubernetes provides DNS-based service discovery, where services can be accessed via their DNS names like `${SVC_NAME}.default.svc.cluster.local`. This is often preferred over relying on environment variables because it provides more flexibility and reduces reliance on environment variable injection. This behavior is the default configuration, so services are discovered by **pre-existing Pods**.

1. **Pod and Container Metadata**:
   - Variables like `HOSTNAME` are set to the name of the pod, and `HOME` is set to the home directory of the container's root user.
   - These variables help containers know their own identity and environment.

1. **Default Shell Environment**:
   - Variables like `PATH`, `TERM`, and `HOME` are standard environment variables that are typically provided by the container's base image or operating system. These are not injected by Kubernetes but come from the container's environment setup.

1. **ConfigMaps**:
   - **Purpose**: ConfigMaps are used to store configuration data as key-value pairs. Pods can reference ConfigMaps to set environment variables.
   - **Effect**: If multiple pods within a namespace reference the same ConfigMap in their environment configuration, they will share the same environment variables.
   - **Example**:
     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: my-config
     data:
       MY_VAR: "my_value"
     ```
     Pods can use this ConfigMap to set an environment variable:
     ```yaml
     envFrom:
     - configMapRef:
         name: my-config
     ```

1. **Secrets**:
   - **Purpose**: Secrets store sensitive data like passwords, tokens, or keys. Similar to ConfigMaps, Secrets can be used to set environment variables in pods.
   - **Effect**: Pods that reference the same Secret will share the environment variables derived from that Secret.
   - **Example**:
     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: my-secret
     data:
       MY_SECRET: bXktdmFsdWU=
     ```
     Pods can use this Secret to set an environment variable:
     ```yaml
     envFrom:
     - secretRef:
         name: my-secret
     ```

1. **ServiceAccounts**:
   - **Purpose**: ServiceAccounts provide identity to pods, allowing them to authenticate to the Kubernetes API server.
   - **Effect**: Pods using the same ServiceAccount will inherit environment variables related to service authentication, such as `KUBERNETES_SERVICE_HOST`, `KUBERNETES_SERVICE_PORT`, and the token associated with the ServiceAccount.

1. **Downward API**:
   - **Purpose**: The Downward API allows pods to access metadata about themselves or their environment, such as the pod's name, namespace, labels, and annotations.
   - **Effect**: If multiple pods in a namespace are configured to use the Downward API, they can inherit environment variables related to their own metadata.
   - **Example**:
     ```yaml
     env:
     - name: MY_POD_NAME
       valueFrom:
         fieldRef:
           fieldPath: metadata.name
     ```

1. **NetworkPolicies**:
   - **Purpose**: Although not directly related to environment variables, NetworkPolicies can indirectly cause pods to be aware of certain configurations or restrictions in their environment.

1. **Admission Controllers and Mutating Webhooks**:
   - **Purpose**: Admission controllers or mutating webhooks can modify the pod spec before it is created, including adding environment variables.
   - **Effect**: If a webhook is set up to inject environment variables based on specific criteria (e.g., all pods in a namespace), those pods will inherit the same environment variables.

1. **PodSecurityPolicies (PSPs)**:
   - **Purpose**: While PSPs are used to enforce security standards, they might influence environment variables if they enforce certain runtime configurations.

1. **Custom Resources**:
   - **Purpose**: Custom resources and operators can be designed to inject environment variables into pods based on custom logic.
   - **Effect**: If deployed in a namespace, these can cause all pods to inherit specific environment variables based on custom policies.

#### How These Variables Are Injected:

- **Kubernetes Service Discovery Mechanism**:
  - When a service is created in Kubernetes, it automatically injects environment variables into all pods within the same namespace. This is part of Kubernetes' built-in service discovery mechanism.
  - These variables are made available by the kubelet when it starts the container in a pod.

- **Pod Specification**:
  - Some environment variables can be explicitly defined in the pod specification (e.g., in a `Deployment`, `DaemonSet`, or when using `kubectl run`), but the ones you are seeing are automatically injected by Kubernetes.


In most cases, the inheritance or sharing of environment variables is due to explicit configuration via objects like ConfigMaps, Secrets, or ServiceAccounts, or due to cluster-wide policies applied by admission controllers or other custom mechanisms.

These common environment variables provide a way for containers to discover and connect to other services within the Kubernetes cluster, facilitating communication and integration between components.



### [Downward API](https://kubernetes.io/docs/concepts/workloads/pods/downward-api/) Example

Used to configure a Pod's environment variables to expose information about itself to containers running in the Pod. 

```yaml
apiVersion: v1
kind: Pod
...
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_NODE_NAME MY_POD_NAME MY_POD_IP;
          sleep 10;
        done;
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
```

```yaml
apiVersion: batch/v1
kind: Job
spec:
  template:
    metadata:
      labels:
        ...
        app.kubernetes.io/name: ingress-nginx
        ...
    spec:
      containers:
      - args:
        - create
        ...
        - --namespace=$(POD_NAMESPACE)
        ...
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace

apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
  - name: example-container
    image: busybox
    env:
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    command: ["/bin/sh", "-c"]
    args:
    - |
      echo "If by Kubernetes substitution: $(POD_NAMESPACE)"; \
      echo "If from shell environment: ${POD_NAMESPACE}"
```


### Naming convention

**Q:** Kubernetes is written in Golang. And best practices of Golang include naming convention that names should not "stutter". For example, if a struct value should not include the struct key name. However, it seems that Kubernetes has adopted the exact opposite convention. For example pod.volume.name=this-volume is the typical namiing convention. What's going on here? Is that just bad practices proliferating, or is this intentional?

**A:** The naming patterns you've observed, such as the redundancy in Kubernetes object names (e.g., appending `-service` to service names), highlight an interesting intersection between Kubernetes' declarative, self-describing architecture and the practical aspects of managing resources in a complex system. This redundancy, while seemingly at odds with the principles of naming clarity and efficiency, serves several purposes in the Kubernetes ecosystem:

1. **Contextual Clarity**: In large, complex deployments, where dozens or even hundreds of services, pods, and other resources interact, the additional context provided by such suffixes (`-service`, `-pod`, etc.) can be invaluable for quick identification and differentiation of resources. This is particularly true when resources of different types share similar base names, or when viewing aggregated logs or metrics across the system.

2. **Convention and Consistency**: Kubernetes has spawned its own set of conventions and best practices, developed by the community and the experiences of its users. These conventions, including naming patterns, help maintain consistency across different deployments and projects. For new users, learning these patterns can make it easier to understand and navigate Kubernetes resources.

3. **Automation and Tooling Compatibility**: Many tools and scripts are built around these naming conventions, expecting certain patterns to be present in resource names. This can help in automating tasks such as monitoring, logging, or CI/CD processes, where being able to predict and parse resource names based on their suffixes or prefixes becomes a powerful feature.

4. **Namespacing and Scope**: Kubernetes allows for complex scoping and namespacing of resources. The redundant naming conventions can help in scoping resources appropriately, making it clearer which resources belong to which domain or functional area within a larger system.

5. **Human Factors**: Ultimately, Kubernetes is used by humans, and the naming conventions reflect a balance between machine efficiency and human readability. While the redundancy might be "noise" in a strictly informational sense, it aids in quick comprehension and reduces cognitive load when scanning through resource lists or configurations.

Despite these reasons, it's important for users and teams to develop and follow their own conventions that best suit their workflows and organizational practices. Kubernetes is flexible enough to accommodate different naming strategies, and what might be redundant or noisy in one context could be clarity-enhancing in another. The key is finding the right balance between Kubernetes' declarative nature, the practical requirements of managing complex systems, and the preferences and practices of the teams involved.

### [Static Pods](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)

**Q:** Why does `kubeadm init --pod-network-cidr="10.100.0.0/12"` assign each Static Pod (of the K8s-core Pods) an IP address in the node-network (host) CIDR versus that of the explicitly-declared Pod Network?

**A:** Static Pods are a special type of pods in Kubernetes that are **managed directly by the `kubelet` on a specific node**. Unlike regular pods, which are part of a deployment or replica set, static pods are defined as YAML files on the node itself. **They do not reside in the etcd datastore** like other pods.

The reason static pods are assigned IP addresses on the node network (host network) rather than the explicitly-declared pod network CIDR is due to their unique nature:

- Local Management:  
    Static pods are managed locally by the `kubelet` running on the node.
    **They do not go through the Kubernetes control plane** (API server, controller manager, scheduler).
    As a result, they are not subject to the same network overlay and pod networking rules as regular pods.
    The `kubelet` on each node is responsible for managing Static Pods. It directly interacts with the container runtime (such as Docker or containerd) to start and stop containers for these pods. Since the `kubelet` is responsible for managing these pods on the node level, it assigns IP addresses to them based on the node's network.
    
- Early Bootstrapping:  
    Static pods are created during the early bootstrapping phase of the `kubelet`.
    At this point, the full Kubernetes control plane (including the network overlay) may not be fully operational.
    Assigning an IP address from the node network ensures that static pods can communicate with each other and with other local services (such as the `kubelet` itself) immediately after boot.

- Minimal Dependencies:  
    Static pods have minimal dependencies.
    They rely only on the `kubelet` and the local Docker runtime (or other container runtime).
    By using the node network, they avoid any potential issues related to network plugins or overlay networks.
    - No involvement of `kube-proxy`: Regular Pods created through the API server go through `kube-proxy`, which sets up the necessary network rules to enable communication between Pods across the cluster. Static Pods, being managed by the `kubelet`, don't go through `kube-proxy`, and their networking is more direct.

- No Network Abstraction:  
    Unlike regular pods, which are part of a logical network abstraction, 
    static pods are tightly coupled to the node.
    Their IP addresses are directly associated with the node’s network interfaces.
    This simplicity allows them to function reliably 
    even in scenarios where the full Kubernetes networking stack is not yet available.

In summary, static pods serve as a bridge between the host system and the Kubernetes world. Their direct association with the node’s network ensures their availability and functionality during the early stages of cluster bootstrapping. However, it’s essential to understand that static pods are an exception, and regular pods follow the rules defined by the pod network overlay (such as Calico, Flannel, or others) once the cluster is fully operational .

**Q:** Why declare `10.244.0.0/12` as Kubernetes default Pod Network CIDR when it is exactly the same as `10.240.0.0/12`, the latter of which reveals the first IP address of that declared range?

**A:** The choice of `10.244.0.0/12` as the default Pod Network CIDR in Kubernetes is indeed interesting. Let’s explore why this seemingly redundant range was selected:

- Historical Context:  
    The `10.244.0.0/12` range was chosen early in Kubernetes development.
    At that time, the decision might not have been as deliberate as it appears now.
    It’s possible that the choice was made without considering the similarity to `10.240.0.0/12`.

- Avoiding Commonly Used Ranges:  
    Kubernetes needed a private IP address range for pod networking.
    The `10.0.0.0/8` address space is commonly used for private networks.
    To avoid conflicts with existing networks, Kubernetes opted for a less common range.

- Granularity and Address Space:  
    The `/12` subnet provides a large address space (`4096` addresses).
    Kubernetes clusters can scale significantly, and having ample IP addresses is essential.
    The granularity allows for efficient allocation of pod IPs.

- Consistency and Predictability:  
    Kubernetes aims for consistency across clusters.
    By using a specific range like `10.244.0.0/12`, 
    administrators can predict the IP addresses assigned to pods.
    This consistency simplifies network management and troubleshooting.

- Avoiding Ambiguity:  
    The choice of `10.244.0.0/12` avoids ambiguity.
    If `10.240.0.0/12` were used, the first IP address (10.240.0.1) 
    might be mistaken for a special purpose (such as a gateway or DNS server).
    By starting at `10.244.0.1`, Kubernetes ensures that the entire range is available for pod IPs.

In summary, while the similarity between `10.244.0.0/12` and `10.240.0.0/12` might raise eyebrows, the decision likely prioritized consistency, predictability, and avoiding common address spaces. Kubernetes architects aimed for a balance between practicality and uniqueness when defining the default Pod Network CIDR.

### [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

Exposes a Deployment to a port under a protocol, sans IP Address(es). 
E.g., Create `my-service` to target TCP port `9376` on any Pod having the label `app.kubernetes.ip/name: MyApp` : 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

### Kubernetes API Server (Master)

#### [`kube-apiserver`](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) 

The Kubernetes API server validates and configures data for 
the api objects which include pods, services, replicationcontrollers, 
and others. The API Server services REST operations and 
provides the frontend to the cluster's shared state through 
which all other components interact.

The API is extensible. The core is `v1` . 
An important add-on API is `apps/v1`, 
which defines the `Deployment` and `ReplicaSet` objects.

### Cluster Management

`kubeadm`

Install/Upgrade tools using zero-downtime method

```bash
# Install kubeadm
sudo apt-get install -y --allow-change-held-packages \
    kubeadm=1.21.1-00
kubeadm version

# Inform the node
sudo kubeadm upgrade node

# Upgrade kubectl and kubelet to match kubeadm version
sudo apt-get install -y --allow-change-held-packages \
    kubectl=1.21.1-00 \
    kubelet=1.21.1-00

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl get nodes
```

## CNI : Container Network Interface 

The Pod network is created and managed by a CNI-compliant provider; Calico, Cilium, &hellip;

#### [CNI traffic](https://chatgpt.com/c/f11fe422-3170-4f7c-ac35-79cfee471b3a)

The CNI harnesses Linux Network Namespaces to dynamically create a virtual interface (e.g., `veth*`) per Pod. All Pod-to-Pod (Container-to-Container in effect) and Pod-to-Service intra-node traffic AKA __east-west traffic__ is via these virtual adapters. To handle inter-node AKA cross-node traffic, an encapsulation scheme is implemented; IP-in-IP or VXLAN. Encapsulation provides for tunneling (L2 over L3) from Pod to Host nework. that is, allowing the otherwise-isolated traffic on the virtual adapter (`veth*`) to be routed through the node network (`eth*`).

BGP is a more direct (lower overhead) alternative to encapsulation schemes such as IP-in-IP and VXLAN.

```bash
# Check for BGP status
calicoctl node status
```
```yaml
apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: true   # BGP mesh is enabled
```

##### East-West Traffic

1. __Pod-to-Pod__ (Same Node)
    - Handled by the virtual Ethernet (`*veth*`) adapter pairs created by Calico. 
      No network traffic leaves the node, and it's routed internally through the Linux kernel.

2. __Pod-to-Pod__ (Different Nodes)
    - Routed between the nodes vie physical adapter (`eth*`) 
      by one of several possible modes, per CNI configuration:
        1. IP-in-IP (Encapsulation): Protocol 4. The traffic is encapsulated in an IP-in-IP packet 
           and sent over the network to the destination node via physical adapaters.
        2. VXLAN (Encapsulation): Similar to IP-in-IP, but using VXLAN tunneling (L2 over L3). 
           This mode is often used in environments where BGP is not available.
        3. BGP (Non-Encapsulation): If supported by host network ("`nc -zv $peer_ip 179`"), 
          the CNI configures nodes to exchange routes via BGP, 
          allowing direct routing of pod traffic without encapsulation.
          This mode is the most efficient, as it has no encapsulate/decapsulate overhead.

3. __Pod-to-Service__
    - Outgoing : Typically routed through a `ClusterIP` via node kernel 
      handling __NAT__/__Masquerade__ using `iptables` or IPVS for routing 
      to the appropriate pod endpoint ("`sudo iptables -t nat -L -n -v`").
      If the service is of type `NodePort` or `LoadBalancer`, 
      the traffic might involve additional routing outside of the cluster, 
      potentially involving network load balancers.
    - Incomming : kube-proxy  

Firewall considerations

```bash
# IP-in-IP aka "Protocol Number 4" aka L3 (IPv4) Encapsulation
firewall-cmd --permanent --zone=$z --add-protocol=4

# VXLAN : L2 over L3 Encapsulation 
firewall-cmd --permanent --zone=$z --add-port=4789/udp

# BGP (Border Gateway Protocol)
firewall-cmd --permanent --zone=$z --add-port=179/tcp

# Masquerade (NAT)
firewall-cmd --permanent --zone=$z --add-masquerade

```
## K8s API Server Objects

### Resources Available 

```bash
# List all API resources (v1)
kubectl api-resources |less
```
```text
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
...
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
...
```

- Extensible API
- `apps/v1` is the most important add-on API.


Have hierarchy:

- `Deployment`: Represents tha deployed app.
    - `ReplicaSet`: Manages app replicas.
        - `Pods`: Adds features required to run the app.
- `ConfigMap`
- `Secrets`
- `PersistentVolumes`

### Object : `Node` (Minion)

- A k8s minion server that runs a `kubelet`.
- A compute unit.
- May run on a multitue of platforms:
    - A server
    - An OS 
    - `systemd` (Linux system and service manager)
    - `kubelet` (node agent) that runs on every node.
    - Container runtime (e.g., Docker engine)
    - Network proxy (`kube-proxy`) that handles K8s Services:
        - ClusterIP; internal Service that load balances k8s Pods
        - NodePort; open port on k8s node that load balances Pods
        - LoadBalancer; external to the cluster
    - Container Network Interface (CNI) provider

### Object : `Pod` 

- An abstraction of a server running an app.
- Can run one or more containers with a single NameSpace, 
  exposed by a single IP address.
- Typically created automatically by `Deployment`, or other API objects. 
- Regarding Docker image tags, do NOT use `latest` . 
- A collection of Kubernetes ___namespaces___ in a specific configuration; contains the following Linux namespaces (kernel filesystem component); provides the base functionality to create a running container from an image, and to scale and load balance per service within the software-defined networking (SDN) system spanning a K8s cluster.
    - PID namespaces
    - A single networking namespace
    - IPC namespace
    - `cgroup` (control group) namespace.
    - `mnt` (mount) namespace
    - `user` (user ID) namespace

### Object : Higher-level Abstractons

Typically spawn one or more Pods; typically create ___replica objects___, which then create Pods.

#### `Deployment`

The most common object; deploys a mircroservice

#### `Job`

Run a Pod as a batch process

#### `StatefulSet`

Host applications requiring specific needs; oftten stateful, e.g., data store.

Features 

- Ordinal Pod naming to ensure unique network identifiers
- Persistent storage always mounted to same Pod
- Ordered start/scale/update

#### `DaemonSet`

Run a single Pod as an "agent" on every node in a cluster; system services, storage, logging, ...

## YAML Manifest 

### Ingredients (fields):

- `apiVersion:` K8s API-server version
- `kind:` K8s Object type
- `metadata:` K8s Object sdministrative information
- `spec:` K8s Object specifics; `container:`(s) `name:`, `image:`, `command:`

Get more info about the field

```bash
kubectl explain $type.$fieldName[.$fieldName]
# E.g., 
kubectl explain pods.metadata
kubectl explain pods.spec.restartPolicy
# ALL possibilities
kubectl explain --recursive  pod.spec
```
- Use JSONPath identifer syntax

### Generate YAML 

```bash
kubectl create|run --dry-run=client -o yaml > app.yaml
```

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->


# [OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/3.11/html/architecture/architecture-index#architecture-index "docs.redhat.com")

## Chalenges of OpenShift in air-gapped network under ADDS?

| Category | Issue | How serious? | Notes |
|:---|:---|:---|:---|
| User Authentication | ✅ | High | You must properly integrate OpenShift OAuth into your Active Directory (SSO or LDAP). |
| UID/GID inside containers | ✅ | Medium | OpenShift **randomizes user IDs inside containers** (for security; "arbitrary UID"). Apps must run as **non-root** and tolerate **any** UID/GID. |
| SCC (Security Context Constraints) | ✅ | High | You must configure the correct SCCs (e.g., `anyuid`, `restricted`) based on your app needs and security posture. |
| Persistent Volumes (NFS/Gluster/CSI) | ✅ | Medium | If external storage is involved, random pod UIDs must still be able to access the PVC. Needs careful permissions setup. |
| Certificate Management | ✅ | High | Air-gapped OpenShift + Active Directory + TLS = need internal PKI for certs (e.g., internal CA, cluster-wide TLS bootstrapping). |
| Pull Secrets / Registries | ✅ | High | OpenShift nodes must pull from private registries inside air-gapped setup (mirror registries, signature trust setup). |
| User shell access to nodes | ✅ | Medium | If AD users are supposed to SSH into OpenShift nodes (which is rare), you'd face the same UID challenges. But OpenShift itself doesn't rely on user SSH logins. |

---

## Problems of OpenShift under AD:

1. **Authentication**:  
   OpenShift needs an OAuth provider config mapped to your AD or LDAP.  
   - Must configure **OAuth** with an **LDAP Identity Provider** against ADDS.
   - Optionally, use SAML if available in your AD.

2. **Authorization**:  
   OpenShift RBAC is *separate* from AD groups. You must **map** AD groups into OpenShift roles.

3. **UID/GID behavior inside Pods**:  
   Applications **cannot assume** static UIDs. They must tolerate **arbitrary UID/GID**.  
   If an app refuses to run unless UID=1000 or UID=0, you must use a special SCC (e.g., `anyuid`).

4. **Persistent Volumes**:  
   If a Pod UID randomizes, and you’re mounting NFS storage or similar, you need to allow "world-writable" (`0777`) or use supplemental groups.

5. **TLS Certificates**:  
   OpenShift will want **internal PKI** — you can't rely on public Let's Encrypt, etc. Must bootstrap trust internally.

6. **Mirrored Registries**:  
   OpenShift nodes must pull images inside air-gap. You must mirror the full set of OpenShift and operator registries.

---

## 🚀 Summary

| Statement | True or False |
|:---|:---|
| You’ll face identity and authorization work integrating OpenShift to AD | ✅ True |
| You must adapt your apps to run with random UIDs | ✅ True |
| You must carefully plan TLS and image pulls in air-gap | ✅ True |
| OpenShift’s problems here are better documented and understood | ✅ True |

---

# ✅ Good News:
- **OpenShift is built to handle corporate Identity Providers (IdPs)** like AD.
- **Rootless user namespace mapping is not your problem** in OpenShift. (Podman at user shell is a separate concern.)
- **Solutions exist and are official** (e.g., OpenShift + AD integration is supported, documented, and tested.)

# ❗ Bad News:
- **Apps must be OpenShift-compliant** (arbitrary UID tolerant, non-root, etc.)
- **AD integration still needs careful planning**.
- **TLS, DNS, and mirror registries must be air-gapped cleanly.**

---


## External Load Balancer

OpenShift (Red Hat OpenShift Container Platform) typically uses **external load balancers** to distribute traffic to the OpenShift cluster's control plane (API and Ingress) and application workloads. The exact load balancer depends on the underlying infrastructure:

### **1. On-Premises / Bare Metal:**
   - **HAProxy**: Often used as a software-based load balancer.
   - **F5 BIG-IP**, **Citrix ADC**, or **Avi Networks**: Enterprise-grade hardware/software load balancers.
   - **Keepalived + HAProxy**: For high availability in self-managed environments.

### **2. Cloud Providers:**
   - **AWS**: Elastic Load Balancer (ELB) or Application Load Balancer (ALB).
   - **Azure**: Azure Load Balancer or Application Gateway.
   - **Google Cloud**: Cloud Load Balancing (TCP/UDP or HTTP(S)).
   - **IBM Cloud**: IBM Cloud Load Balancer.

### **3. OpenShift Ingress (Router) Layer:**
   - OpenShift’s **Ingress Controller** (based on **HAProxy**) handles application traffic routing.
   - External load balancers forward traffic to OpenShift’s Ingress pods.

### **Configuration:**
   - For API servers, the load balancer directs traffic to control plane nodes (masters).
   - For applications, it routes traffic to OpenShift Router (Ingress) pods.

### **Key Considerations:**
   - **High Availability (HA)**: The load balancer must be highly available.
   - **Health Checks**: Ensures traffic only goes to healthy nodes/pods.
   - **TLS Termination**: Can be done at the load balancer or within OpenShift.


OpenShift itself does **not** deploy the external load balancer—you must set it up separately based on your infrastructure. Here's how it fits into the installation:

### **1. During OpenShift Installation (Required for High Availability)**
   - The OpenShift installer (for IPI - **Installer-Provisioned Infrastructure**) on platforms like AWS, Azure, or GCP **automatically provisions** a cloud load balancer (e.g., AWS ELB, Azure LB).
   - For **UPI (User-Provisioned Infrastructure)**, you __must manually configure__ the load balancer before installation.

### **2. Key Load Balancer Requirements**
   - **API Server Load Balancer**: Distributes traffic to control plane (master) nodes.
     - Listens on **TCP/6443 (Kubernetes API)** and optionally **TCP/22623 (Machine Config Server)**.
   - **Ingress (Router) Load Balancer**: Routes application traffic to OpenShift Ingress pods.
     - Typically listens on **TCP/80 (HTTP)** and **TCP/443 (HTTPS)**.

### **3. How OpenShift Interacts with the Load Balancer**
   - The installer (IPI) or admin (UPI) provides the load balancer's address in the installation config (`install-config.yaml`).
   - OpenShift components (API servers, routers) register themselves as backends.

### **4. Post-Installation**
   - OpenShift **does not manage** the external load balancer—you must update it manually if nodes are added/removed.
   - For cloud platforms, the load balancer is usually managed by the cloud provider (e.g., AWS ELB updates target instances automatically).

### **Example: AWS Installer-Provisioned Infrastructure (IPI)**
   - OpenShift installer **automatically creates**:
     - One **Network Load Balancer (NLB)** for the API.
     - One **Classic Load Balancer (CLB)** for Ingress (apps).
   - You don’t need to manually configure them.

### **Example: Bare Metal (UPI)**
   - You must **pre-configure** HAProxy/F5/Citrix before installation.
   - Example HAProxy config snippet for API:
     ```conf
     frontend openshift-api
       bind *:6443
       default_backend masters
       option tcp-check

     backend masters
       balance source
       server master1 192.168.1.10:6443 check
       server master2 192.168.1.11:6443 check
       server master3 192.168.1.12:6443 check
     ```

### **Summary**
- **IPI (Cloud)**: OpenShift installer handles LB setup.
- **UPI (Bare Metal/VMs)**: You must set up the LB before installation.
- OpenShift **relies on but does not manage** the external LB after deployment.

## Q:

Terminating TLS at HAProxy does not allow for multiple ingress controllers, each having its own TLS

## A:

 **Terminating TLS at HAProxy** (instead of passthrough) **breaks multi-tenancy** for OpenShift Ingress Controllers, as HAProxy would need to handle all certificates centrally, preventing individual Ingress Controllers from managing their own TLS certs. Here’s how to resolve this:

---

### **Problem: TLS Termination at HAProxy vs. OpenShift Ingress**
1. **Terminating at HAProxy**:
   - HAProxy decrypts traffic and forwards plain HTTP to OpenShift.
   - **Limitation**: Only one certificate (or SNI bundle) can be configured at HAProxy, blocking per-IngressController TLS.

2. **Passthrough to OpenShift**:
   - HAProxy forwards raw TLS traffic to OpenShift Routers.
   - **Advantage**: Each `IngressController` (e.g., for different domains) can manage its own TLS certs via OpenShift.

---

### **Solution: Use TCP Passthrough for Ingress HTTPS**
Configure HAProxy to forward **raw TLS traffic** (`mode tcp`) to OpenShift Routers, letting OpenShift handle TLS termination:

#### **HAProxy Config (Passthrough for Ingress)**
```conf
# Control Plane (API) - TLS Passthrough (mandatory)
frontend openshift_api
  bind *:6443
  mode tcp
  default_backend api_servers

# Data Plane (Ingress) - TCP Passthrough for HTTPS
frontend openshift_https
  bind *:443
  mode tcp                     # Critical: Forward TLS traffic unmodified
  default_backend https_routers

backend https_routers
  mode tcp
  balance roundrobin
  server worker1 192.168.1.20:443 check
  server worker2 192.168.1.21:443 check

# Optional: HTTP → HTTPS redirect (terminates at HAProxy)
frontend openshift_http
  bind *:80
  mode http
  redirect scheme https code 301
```

---

### **Why This Works**
- **OpenShift IngressControllers** handle TLS termination internally, supporting:
  - Multiple certificates (e.g., via `Ingress` or `Route` resources).
  - SNI-based routing (different certs per domain).
  - Automatic certificate rotation (e.g., with Let’s Encrypt + Cert-Manager).

- **HAProxy** acts as a dumb TCP proxy, avoiding conflicts with OpenShift’s TLS management.

---

### **Key Trade-offs**
| Approach               | Pros                          | Cons                          |
|------------------------|-------------------------------|-------------------------------|
| **HAProxy TLS Termination** | Offloads CPU from OpenShift. | Single certificate, no multi-tenancy. |
| **Passthrough (Recommended)** | Supports multiple IngressControllers. | OpenShift handles TLS (higher CPU usage on workers). |

---

### **Advanced: SNI Passthrough (If Absolutely Needed)**
If you **must** terminate some traffic at HAProxy while allowing OpenShift to handle other domains:
1. **Use SNI filtering** in HAProxy to split traffic:
   ```conf
   frontend openshift_https
     bind *:443
     mode tcp
     tcp-request inspect-delay 5s
     tcp-request content accept if { req_ssl_hello_type 1 }
     use_backend openshift_ingress if { req_ssl_sni -i apps.example.com }
     use_backend haproxy_terminated if { req_ssl_sni -i admin.example.com }
   ```
2. **Complexity**: Not recommended unless you have a hard requirement.

---

### **Best Practice**
1. **Always use passthrough** for OpenShift Ingress HTTPS (`:443`).
2. **Terminate TLS at HAProxy only** for:
   - Non-OpenShift services.
   - HTTP-to-HTTPS redirects (`:80`).

---

### **Verification**
1. Check OpenShift Routers are handling TLS:
   ```bash
   oc get route -n <namespace>  # Verify TLS settings per route
   ```
2. Test SNI support:
   ```bash
   openssl s_client -connect apps.example.com:443 -servername apps.example.com
   ```

### PROXY Protocol

### **OpenShift Ingress Support for PROXY Protocol**
Yes, **OpenShift Ingress (Router)** supports the **PROXY protocol** to preserve the **real client IP address** when the external load balancer (e.g., HAProxy) operates in **TCP mode (TLS passthrough)**. However, it must be explicitly enabled.

---

### **1. How PROXY Protocol Works**
- **Problem**: When HAProxy operates in `mode tcp`, the original client IP is lost (traffic appears to come from the LB’s IP).
- **Solution**: PROXY protocol prepends client connection metadata (including source IP) before the TLS handshake.
- **Requires**:
  - **HAProxy** must send PROXY protocol headers.
  - **OpenShift Ingress** must be configured to accept them.

---

### **2. Configuring HAProxy to Send PROXY Protocol**
Modify the HTTPS backend in `haproxy.cfg` to add `send-proxy`:
```conf
frontend openshift_https
  bind *:443
  mode tcp
  default_backend https_routers

backend https_routers
  mode tcp
  balance roundrobin
  server worker1 192.168.1.20:443 check send-proxy  # <-- Critical
  server worker2 192.168.1.21:443 check send-proxy
```

---

### **3. Enabling PROXY Protocol in OpenShift Ingress**
#### **Method 1: Editing the Default IngressController**
```bash
oc edit ingresscontroller/default -n openshift-ingress-operator
```
Add the `PROXY` protocol policy under `spec.tuningOptions`:
```yaml
spec:
  tuningOptions:
    proxyProtocol: Enabled  # <-- Enable PROXY protocol
```

#### **Method 2: Creating a Custom IngressController**
```yaml
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: proxy-protocol
  namespace: openshift-ingress-operator
spec:
  domain: apps.example.com
  endpointPublishingStrategy:
    type: LoadBalancerService
  tuningOptions:
    proxyProtocol: Enabled
```

---

### **4. Verification**
#### **Check IngressController Status**
```bash
oc get ingresscontroller/default -n openshift-ingress-operator -o yaml | grep proxyProtocol
```
Expected output:
```yaml
    proxyProtocol: Enabled
```

#### **Test Client IP Preservation**
1. Deploy a test app that echoes client IPs:
   ```bash
   oc create deployment test-app --image=nginx
   oc expose deployment/test-app --port=80
   oc create route edge test-app --service=test-app
   ```
2. Access the app and check logs:
   ```bash
   curl -k https://test-app.apps.example.com
   oc logs -l app=test-app | grep "X-Forwarded-For"
   ```
   - If PROXY protocol works, logs will show the **real client IP**, not the LB’s IP.

---

### **5. Key Considerations**
- **TLS Passthrough Required**: PROXY protocol only works in `mode tcp` (no TLS termination at LB).
- **Compatibility**: Ensure all LBs in the chain (e.g., cloud LB → HAProxy) support PROXY protocol.
- **Performance**: Minimal overhead (additional header per connection).

---

### **6. Troubleshooting**
- **If client IPs are still missing**:
  - Verify HAProxy’s `send-proxy` is enabled.
  - Check OpenShift Router logs:
    ```bash
    oc logs -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default -n openshift-ingress
    ```
  - Ensure no intermediate LBs strip PROXY headers.

---

### **Summary**
| Step | Component           | Action                                  |
|------|---------------------|-----------------------------------------|
| 1    | **HAProxy**         | Add `send-proxy` to backend servers.    |
| 2    | **OpenShift Ingress** | Set `spec.tuningOptions.proxyProtocol: Enabled`. |
| 3    | **Verification**    | Check app logs for client IPs.          |

**Result**: OpenShift Ingress will now correctly forward the original client IP to applications.  


## Firewall Rules

OpenShift **requires specific firewall rules** for proper operation, but whether they are **automatically configured** depends on the installation method and platform. Here’s a breakdown:

---

### **1. Installer-Provisioned Infrastructure (IPI) – Cloud (AWS, Azure, GCP)**
   - **Firewall rules are automatically configured** by the OpenShift installer.
   - Cloud provider security groups (AWS), NSGs (Azure), or firewall rules (GCP) are applied to allow:
     - **Control plane (master) communication** (TCP/6443 for API, TCP/22623 for machine config).
     - **Worker node communication** (TCP/10250 for Kubelet, TCP/30000-32767 for NodePort services).
     - **Ingress traffic** (TCP/80, TCP/443 for apps).
   - **No manual setup needed** in most cases.

---

### **2. User-Provisioned Infrastructure (UPI) – Bare Metal, VMware, On-Prem**

**You must manually configure firewall rules** before installation.


| **Component**       | **Port(s)**       | **Direction** | **Purpose**                     |
|---------------------|-------------------|---------------|----------------------------------|
| **API Server**      | TCP/6443          | Inbound       | Kubernetes API access            |
| **Machine Config**  | TCP/22623         | Inbound       | Node provisioning (masters only) |
| **ETCD**           | TCP/2379-2380     | Internal      | ETCD cluster communication       |
| **Kubelet**        | TCP/10250         | Internal      | Metrics & pod communication      |
| **Ingress (Router)** | TCP/80, TCP/443   | Inbound       | Application traffic              |
| **NodePort Services** | TCP/30000-32767 | Inbound       | Optional for external services   |
| **Internal Pod Network** | VXLAN (UDP/4789), Geneve (UDP/6081) | Internal | SDN (OpenShift SDN/OVN-Kubernetes) |
| **DNS**            | UDP/53            | Internal      | CoreDNS resolution               |

**Example for `firewalld` (RHEL/CentOS)**:

```bash
# Masters and Workers
firewall-cmd --permanent --add-port=6443/tcp       # API
firewall-cmd --permanent --add-port=10250/tcp      # Kubelet
firewall-cmd --permanent --add-port=4789/udp       # OpenShift SDN (VXLAN)
firewall-cmd --permanent --add-port=6081/udp       # OVN-Kubernetes (Geneve)
firewall-cmd --permanent --add-port=30000-32767/tcp # NodePort range
# Masters only
firewall-cmd --permanent --add-port=2379-2380/tcp  # ETCD
firewall-cmd --permanent --add-port=22623/tcp      # Machine Config
firewall-cmd --reload
```

---

### **3. OpenShift Does NOT Automatically Configure Host Firewalls (Except for IPI)**
   - **On bare metal or UPI**, you must ensure:
     - Host firewalls (`firewalld`, `iptables`, or cloud security groups) allow the required traffic.
     - OpenShift’s internal services (SDN, DNS, etc.) can communicate unblocked.
   - **OpenShift SDN/OVN-Kubernetes** manages internal networking but **does not modify host firewall rules**.

---

### **4. Post-Installation Adjustments**
   - If you later enable features like **Metrics, Logging, or Service Mesh**, additional ports may be needed.
   - **Egress firewall rules** can be managed via OpenShift’s `NetworkPolicy` or `EgressFirewall` (for project-level restrictions).

---

### **Key Takeaways**
- **IPI (Cloud)**: Firewall rules are auto-configured.
- **UPI (Bare Metal/VMware)**: You must manually open ports.
- **OpenShift itself does not modify host firewalls**—it assumes the required ports are open.

## Host Configuration

For a **User-Provisioned Infrastructure (UPI)** OpenShift deployment on **RHEL (Red Hat Enterprise Linux)**, the host systems (masters, workers, and bootstrap nodes) must meet specific requirements. Below are the key **kernel modules, swap settings, and network configurations** needed:

---

### **1. Kernel Modules**
OpenShift requires certain kernel modules for networking, storage, and security. Ensure these are loaded on all nodes (masters/workers):

#### **Required Modules**:
```bash
# Check loaded modules
lsmod | grep -E 'br_netfilter|overlay|nf_conntrack|iptable_filter|ebtables|ip_tables'

# Load if missing (persist via /etc/modules-load.d/)
modprobe br_netfilter
modprobe overlay
modprobe nf_conntrack
modprobe iptable_filter
modprobe ebtables
modprobe ip_tables
```
- **`br_netfilter`**: Required for Kubernetes network policy (must be enabled).
- **`overlay`**: Needed for container storage (CRI-O/Podman).
- **`nf_conntrack`**: For connection tracking (used by kube-proxy).
- **`iptables/ebtables`**: Used by OpenShift SDN/OVN-Kubernetes.

#### **Verify Kernel Parameters**:
```bash
# Ensure these sysctl settings are applied (persist in /etc/sysctl.d/)
cat > /etc/sysctl.d/99-openshift.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p /etc/sysctl.d/99-openshift.conf
```

---

### **2. Swap Settings**
- **Swap must be disabled** on all nodes (Kubernetes does not support swap for reliability).
  ```bash
  # Disable swap immediately
  swapoff -a

  # Remove swap entries from /etc/fstab (persistent)
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

  # Verify
  free -h | grep -i swap
  ```

---

### **3. Network Requirements**
#### **Host Network Configuration**
- **DNS Resolution**: All nodes must resolve each other and the OpenShift cluster name.
  ```bash
  # Example /etc/hosts (minimal)
  192.168.1.10 master-0.openshift.example.com
  192.168.1.11 master-1.openshift.example.com
  192.168.1.12 master-2.openshift.example.com
  ```
- **NetworkManager**: Must be running (required for OpenShift SDN/OVN-Kubernetes).
  ```bash
  systemctl enable --now NetworkManager
  ```

#### **Firewall Rules**
OpenShift requires specific ports to be open (see [previous answer](#what-firewall-settings-are-required-by-openshift-or-does-its-install-add-them) for details). For UPI, manually configure:
```bash
# Open ports on masters/workers (example for firewalld)
firewall-cmd --permanent --add-port={6443,22623,2379-2380,10250}/tcp
firewall-cmd --permanent --add-port={4789,6081}/udp  # VXLAN/Geneve (SDN)
firewall-cmd --reload
```

#### **Network Time Protocol (NTP)**
- All nodes must be time-synchronized (use `chronyd` or `ntpd`):
  ```bash
  systemctl enable --now chronyd
  chronyc sources  # Verify sync
  ```

---

### **4. Additional Host Requirements**
- **Disk**: Minimum **100GB** per node (more for etcd/workers).
- **CPU/Memory**:
  - **Masters**: 4+ vCPUs, 16GB+ RAM.
  - **Workers**: 2+ vCPUs, 8GB+ RAM.
- **SELinux**: Must be enabled in **`enforcing`** mode.
  ```bash
  getenforce  # Should return "Enforcing"
  ```
- **Container Runtime**: OpenShift installs **CRI-O** automatically (no Docker needed).

---

### **5. Pre-Installation Validation**
Run the OpenShift pre-flight checks:
```bash
# From the installer node
openshift-install preflight-check
```

---

### **Summary of UPI Host Prep**
| **Requirement**       | **Action**                                                                 |
|-----------------------|---------------------------------------------------------------------------|
| **Kernel Modules**    | Load `br_netfilter`, `overlay`, `nf_conntrack`, etc.                      |
| **Swap**             | Disable swap permanently.                                                 |
| **Firewall**         | Open [required ports](#what-firewall-settings-are-required-by-openshift-or-does-its-install-add-them) for API, SDN, etc. |
| **Network**          | Enable `NetworkManager`, NTP sync, and proper DNS.                        |
| **SELinux**          | Set to `enforcing`.                                                       |

For the full checklist, refer to the [OpenShift UPI Documentation](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html). Would you like a platform-specific guide (e.g., VMware, bare metal)?

## OS Requirement

For **modern versions of OpenShift (4.x)**, Red Hat mandates the use of **immutable, container-optimized operating systems** for cluster nodes. Here’s the breakdown:

---

### **1. Primary Operating Systems for OpenShift 4.x**
#### **a) Red Hat Enterprise Linux CoreOS (RHCOS)**  
- **Default for**:  
  - **Control Plane (Master) Nodes**  
  - **Worker Nodes** (unless using RHEL workers)  
- **Key Features**:  
  - Immutable, atomic updates via `rpm-ostree`.  
  - Auto-updated by the OpenShift **Machine Config Operator (MCO)**.  
  - Minimal, secure, and optimized for containers.  
  - Includes `crio` (CRI-O) as the default container runtime.  

#### **b) Red Hat Enterprise Linux (RHEL) 8/9**  
- **Optional for**:  
  - **Worker Nodes** (if you need custom packages/kernel modules).  
- **Requirements**:  
  - Must use **RHEL 8.6+ or RHEL 9.x** (specific minor versions depend on OpenShift release).  
  - Requires manual subscription attachment and compliance with OpenShift’s kernel/package restrictions.  

---

### **2. Deprecated/Unsupported OS Options**  
- **RHEL Atomic Host** (legacy, replaced by RHCOS).  
- **CentOS/RHEL 7** (not supported in OpenShift 4.x).  
- **Ubuntu, Fedora, or other Linux distros** (not supported for cluster nodes).  

---

### **3. Why RHCOS?**  
- **Immutable Design**: Prevents drift and ensures consistency.  
- **Automatic Updates**: Managed by OpenShift operators (no manual patching).  
- **Security**: Minimal attack surface (no SSH by default, read-only `/usr`).  
- **Integration**: Tightly coupled with OpenShift’s **Machine API** and **MCO**.  

---

### **4. When to Use RHEL Workers?**  
Only if you need:  
- Custom kernel modules (e.g., proprietary drivers).  
- Specialized workloads requiring host-level packages.  
- Legacy applications not fully containerized.  

**Note**: Mixing RHCOS (masters) and RHEL (workers) is supported but adds complexity.  

---

### **5. How to Verify OS in OpenShift?**  
```bash
oc get nodes -o wide  # Shows OS and kernel version
oc debug node/<node>  # Inspect the underlying OS
```

---

### **6. Future Direction**  
- OpenShift **5.x** (future) will likely continue enforcing RHCOS/RHEL as the only supported options.  
- **RHEL 9** will become the standard as RHEL 8 approaches EOL (2029).  

---

### **Summary Table**  

| **Node Type**       | **Recommended OS** | **Alternative OS** ---|
|---------------------|--------------------|-----------------------|
| **Control Plane**   | RHCOS              | None                |
| **Workers**         | RHCOS (default)    | RHEL 8/9 (if needed) |

For production, **stick with RHCOS unless you have a compelling reason to use RHEL workers**.  

Would you like details on how OpenShift manages RHCOS updates?
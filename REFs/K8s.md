# [Kubernetes](https://kubernetes.io/docs "Kubernetes.io") (K8s) | [Releases](https://kubernetes.io/releases/)

## TL;DR

Kubernetes is a universal control plane that is most commonly used to build platforms for managing containerized workloads.

## Vanilla Cluster

[Install a production-environment cluster using `kubeadm`.](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### Prep at each node

```bash
# Install kernel headers 
sudo dnf install kernel-headers-$(uname -r)
sudo dnf install kernel-devel-$(uname -r)

# Load kernel modules (now)
sudo modprobe br_netfilter
sudo modprobe ip_vs
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_wrr
sudo modprobe ip_vs_sh
sudo modprobe overlay

# Load kernel modules on boot
cat <<-EOH |sudo tee /etc/modules-load.d/kubernetes.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOH

# Set runtime kernel params (sysctl) for K8s networking
cat <<-EOH |sudo tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOH
```

|Kernel Parameter	| Description |
|-----------------|-------------|
|`net.bridge.bridge-nf-call-iptables`|Bridged IPv4 traffic via iptables.|
|`net.bridge.bridge-nf-call-ip6tables`|Bridged IPv6 traffic via iptables.|
|`net.ipv4.ip_forward`|IPv4 packet forwarding.|


```bash
# Apply the settings
sudo sysctl --system

# Disable swap (idempotent)
sudo swapoff -a
swap="$(cat /etc/fstab |grep ' swap' |grep -v '^ *#' |awk '{print $1}')"
[[ $swap ]] && swap="$(echo $swap |awk '{print $1}')"
[[ $swap ]] && sudo sed -i "s,$swap,#$swap," /etc/fstab


```

### Install CRI 

`containerd`

```bash
# If want Docker.io version : RPM method
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf makecache
# Install containerd package 
sudo dnf -y install containerd.io
# Else, if want Kubernetes.io version : binary method
# Install runc : containerd dependency
# @ https://github.com/opencontainers/runc/releases
ver='1.1.13'
arch=$(uname -m)
[[ $arch == 'x86_64' ]] && arch=amd64
url="https://github.com/opencontainers/runc/releases/download/v${ver}/runc.$arch"
sudo curl -O /usr/local/sbin/runc -sSL $url
# Install containerd binaries
ver='1.7.19'
arch=$(uname -m)
[[ $arch == 'x86_64' ]] && arch=amd64
url="https://github.com/containerd/containerd/releases/download/v$ver/containerd-${ver}-linux-${arch}.tar.gz"
curl -sSL $url |sudo tar -C /usr/local -xzvf -

# Configure as systemd service
url='https://raw.githubusercontent.com/containerd/containerd/main/containerd.service'
dst='/usr/local/lib/systemd/system/containerd.service'
sudo curl -sSL -O $dst $url

# Configure (TOML) 
conf='/etc/containerd/config.toml'
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
containerd config default |sudo tee $conf
#... and edit:
vi $conf 
#... else:
cat <<-EOH |sudo tee $conf
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.k8s.io/pause:3.9"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      discard_unpacked_layers = true
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOH

# Enable/start the service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# Print the running config
containerd config dump

```

### Install K8s tools and CNI Plugins

- `kubelet` : Node agent
- `kubeadm` : Administration CLI
- `kubectl` : API client CLI
- `kubernetes-cni` : CNI Plugins

```bash
sudo dnf makecache
# Install conntrack (undocumented dependency)
sudo dnf install -y conntrack 
# Install K8s tools
sudo dnf install -y kubelet kubeadm kubectl kubernetes-cni --disableexcludes=kubernetes
# Enable the node agent 
sudo systemctl enable --now kubelet.service
```
- CNI Plugins : Either of `kubernetes-cni` (RPM) or a release (binaries): https://github.com/containernetworking/plugins/releases
    ```bash
    ver=1.5.1
    arch=$(uname -m)
    [[ $arch == 'x86_64' ]] && arch=amd64
    url=https://github.com/containernetworking/plugins/releases/download/v${ver}/cni-plugins-linux-${arch}-v${ver}.tgz
    curl -sSL $url |tar -C /opt/cni/bin -xzf -
    ```

## [Overview](https://kubernetes.io/docs/home/?path=users&persona=app-developer&level=foundational) | [Tools](https://kubernetes.io/docs/reference/tools/ "kubernetes.io/docs/...") | [GitHub](https://github.com/kubernetes "Kubernetes repo") | [Wikipedia](https://en.wikipedia.org/wiki/Kubernetes)  


## [Admission Controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

An admission controller is code of `kube-apiserver` that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

Admission controllers may be validating, mutating, or both. Mutating controllers may modify objects related to the requests they admit; validating controllers may not.

Admission controllers limit requests to create, delete, modify objects. Admission controllers can also block custom verbs, such as a request connect to a Pod via an API server proxy. Admission controllers do not (and cannot) block requests to read (get, watch or list) objects.

```bash
# List all enabled admission controllers
kube-apiserver -h |grep enable-admission-plugins

# Enable some admission controllers
kube-apiserver --enable-admission-plugins=NamespaceLifecycle,LimitRanger ...

# Disable some 
kube-apiserver --disable-admission-plugins=PodNodeSelector,AlwaysDeny ...
```

## [Operator (Pattern)](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

The goal of an Operator is to put operational knowledge into software. Previously this knowledge only resided in the minds of administrators, various combinations of shell scripts or automation software like Ansible. It was outside of your Kubernetes cluster and hard to integrate. With Operators, CoreOS changed that.

Operators implement and automate common Day-1 (installation, configuration, etc.) and Day-2 (re-configuration, update, backup, failover, restore, etc.) activities in a piece of software running inside your Kubernetes cluster, by integrating natively with Kubernetes concepts and APIs. We call this a Kubernetes-native application. 

With Operators an application is treated as a single object, and exposes only that 
which makes sense for the application to work.

## Topics of Interest

### Pods' Inherit Environment

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

# [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

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

## Auth : [Controlling Access](https://kubernetes.io/docs/concepts/security/controlling-access/)

## `kubectl`

Client CLI to communicate with Kubernetes API server

Must be configured to cluster, context and have user of `kubeadm`'s config.

## [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file 

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

### Select a `context` (`current-context`)

```bash
contexts_name=${user}@$cluster # contexts[].name: <context.user>@<context.cluster>
kubectl config use-context $contexts_name 
```

### [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts)

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

## Kubernetes API Server (Master)

### [`kube-apiserver`](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) 

The Kubernetes API server validates and configures data for 
the api objects which include pods, services, replicationcontrollers, 
and others. The API Server services REST operations and 
provides the frontend to the cluster's shared state through 
which all other components interact.

The API is extensible. The core is `v1` . 
An important add-on API is `apps/v1`, 
which defines the `Deployment` and `ReplicaSet` objects.

## Cluster Management

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

## Object : `Node` (Minion)

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

### Object : Higer-level Abstractons

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


# [WASI](https://wasi.dev/) vs [wasmCloud](https://wasmcloud.com/)

WASI is a core component of WebAssembly tools; a low-level system standard that lets WebAssembly safely talk to operating systems, while wasmCloud is a higher-level cloud platform that uses those standards to run distributed applications across servers and Kubernetes. They are not competing choices; rather, wasmCloud uses WASI as a foundational layer to build and connect components. 

## What is WASI? 

- System interface: Stands for **W**eb**A**ssembly **S**ystem **I**nterface. 
- Low-level access: Gives Wasm code safe access to basic resources like files, clocks, random numbers, and network sockets. 
- Standardized: Acts as an open standard so compiled code can run outside web browsers on any compliant host. 
- Focus: Portability and security for raw binary execution. [1, 4]  

## What is wasmCloud? 

- Cloud platform: A CNCF-incubating runtime for building and orchestrating microservices and applications. 
- Orchestration layer: Functions for Wasm components much like Kubernetes does for containers. 
- Built on standards: Runs portable Wasm components that target standard interfaces like WASI (such as  and ). 
- Focus: Distributed coordination, security policies (deny-by-default), and pluggable capabilities like key-value stores and messaging. [2, 3, 4, 5]  

## Key Differences 

| Feature | WASI | wasmCloud  |
| --- | --- | --- |
| Layer | Low-level system API | High-level orchestration platform  |
| Purpose | Standardizes file, network, and clock access for Wasm | Manages, scales, and links microservices across clouds  |
| Dependency | Standalone specification | Uses WASI internally to execute standard components  |


---

# wasmCloud Platform

wasmCloud was specifically designed to break out of the limitations of a single Kubernetes control plane. 
However, the way it does this has changed significantly with its v2 architecture.

### 🧭 The v1 Approach: A Distributed Lattice

In its v1 architecture, wasmCloud created a "lattice" – an application layer network built on NATS (a CNCF project) that provided connectivity across diverse environments like edge, different clouds, and on-premise datacenters. This lattice used a "supercluster" pattern to connect multiple NATS clusters, enabling features like load balancing and failover across cluster boundaries.

In this model, challenge areas for Kubernetes such as edge, multi-cluster, and multi-cloud were **first-class use cases** for wasmCloud. The system could scale communication seamlessly across clusters, making the Kubernetes control plane boundaries largely irrelevant for the application itself.

So, the v1 platform is **a distributed mesh**. 

### 🔄 The v2 Shift: Kubernetes as the Substrate

The v2 architecture (as of March 2026) represents a major philosophical shift. It **treats Kubernetes as the core substrate**.

This change means that in v2, all desired state is kept within the cluster as Kubernetes custom resources, backed by `etcd`. No external coordination or cross-cluster state synchronization is required; each cluster operates as an autonomous unit.
So, wasmCloud 
The official v2 migration guide explicitly notes that this approach to multi-cluster deployments aligns with **Kubernetes' native capabilities**, emphasizing management within the boundaries of a single cluster.

This evolution redefines what "distribution" means, shifting from a distributed mesh network to **a federation of autonomous systems**.

### 🔑 Key Architectural Differences: v1 vs. v2

| Feature | wasmCloud v1 | wasmCloud v2 |
| :--- | :--- | :--- |
| **State Storage** | NATS JetStream KV (host registry, links, configs) | Kubernetes API + `etcd` via CRDs |
| **Multi-Cluster Model** | "Supercluster" pattern with NATS Gateways provides geo-aware communication across clusters | Aligns with Kubernetes' native multi-cluster management approaches; each cluster is an autonomous unit |
| **Primary Contract** | OAM YAML manifests (managed by `wadm`) | Kubernetes CRDs (like `Workload`, `WorkloadDeployment`) |

So, while the v1 architecture was a direct attempt to circumvent the limitations of the Kubernetes control plane, the v2 architecture has re-focused on being a first-class citizen *within* the Kubernetes ecosystem, leveraging its control plane more deeply.

---

# wasmCloud vs [SpinKube](https://www.spinkube.dev/)

SpinKube is simpler in concept, but both are installed using Kubernetes Operators and come with their own setup complexity. The key difference lies in how many components you're deploying under the hood.

>SpinKube: Hyper-efficient serverless on Kubernetes, powered by WebAssembly.

Here’s a detailed look at their installation processes and administrative overhead:

### 🏗️ Installation Architecture: Operator vs. Platform

| Aspect | SpinKube | wasmCloud |
| :--- | :--- | :--- |
| **Core Installation** | **A Kubernetes Operator**. The `spin-operator` manages the lifecycle of `SpinApp` custom resources. | **A Kubernetes Operator**. The `wasmcloud-operator` manages the lifecycle of Wasm workloads via its own CRDs. |
| **Number of Components** | **Minimal.** You typically install the `spin-operator` Helm chart, alongside `cert-manager` and a "runtime-class-manager" to install the Wasm shim on nodes. | **More Extensive.** The standard installation includes multiple components: the wasmCloud operator, a NATS messaging service, and the `wadm` (wasmCloud Application Deployment Manager). |
| **First-Party Tooling** | **Spin CLI (`spin`).** Used to build apps and generate Kubernetes manifests for deployment. | **wasmCloud Shell (`wash`).** Used for building, publishing, and managing components and applications. You also use `wash` to connect to the cluster's NATS service to interact with the wasmCloud lattice. |
| **Administrative Overhead** | **Lower.** Setup involves installing a few core components (Helm chart, shim installer). Once set up, deploying an app is similar to a standard Kubernetes deployment. | **Higher.** Because you're deploying a more complex platform (Operator + NATS + wadm), there are more components to manage, configure, and monitor. |
| **Operational Flexibility** | **Primarily Kubernetes-Focused.** Designed to run Spin applications as native pods on Kubernetes. | **More Flexible.** While it runs well on Kubernetes, wasmCloud is designed as a distributed platform. You can run it in multi-cloud, edge, or even as a standalone service. |

### 🧑‍💻 The Installation Process: Side-by-Side

While the principles are similar, the commands and steps differ significantly.

#### SpinKube Installation

For SpinKube, the process starts with preparing the cluster:
```bash
# 1. Install cert-manager (required for the operator's webhooks)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.0/cert-manager.yaml

# 2. Install the runtime-class-manager to provision Wasm shims on nodes
helm upgrade --install runtime-class-manager \
  --namespace runtime-class-manager --create-namespace \
  --version 0.2.0 \
  oci://ghcr.io/spinframework/charts/runtime-class-manager

# 3. Apply RuntimeClass and CRDs
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.runtime-class.yaml
kubectl apply -f https://github.com/spinframework/spin-operator/releases/download/v0.6.1/spin-operator.crds.yaml
```
Then, you install the `spin-operator` itself:
```bash
# 4. Install the Spin Operator with Helm
helm upgrade --install spin-operator \
  --namespace spin-operator --create-namespace \
  --version 0.6.1 \
  oci://ghcr.io/spinframework/charts/spin-operator
```
After this, you can create a `SpinApp` resource with `kubectl`.

#### wasmCloud Installation

For wasmCloud, the setup often involves an "all-in-one" Helm chart that deploys its entire ecosystem:
```bash
# 1. Install the wasmCloud platform chart, which includes Operator, NATS, and wadm
helm upgrade --install \
  wasmcloud-platform \
  --namespace wasmcloud --create-namespace \
  --values https://raw.githubusercontent.com/wasmCloud/wasmcloud/main/charts/wasmcloud-platform/values.yaml \
  oci://ghcr.io/wasmcloud/charts/wasmcloud-platform \
  --dependency-update
```
After this, you can manage components and applications using the `wash` CLI, which connects to the NATS service that's part of the platform.

### 🤔 How to Think About It

In short, **both require an Operator for installation, but they represent different paradigms:**

*   **SpinKube** is a **targeted integration**. You deploy a lightweight operator that allows you to run Spin apps directly on Kubernetes. It feels like a lightweight extension to your cluster, focusing on making `kubectl` the primary interface.
*   **wasmCloud** is a **platform of its own**. You deploy an entire system (Operator, NATS, wadm) that uses Kubernetes as an infrastructure substrate. The primary operational interface is often the `wash` CLI and the platform's own concepts, which gives you more power for distributed, heterogeneous environments but comes with more components to manage.

---

<!-- 

… ⋮ ︙ - ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->

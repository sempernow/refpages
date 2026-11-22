# [Karpenter](https://karpenter.sh)

>Just-in-time Nodes for Any Kubernetes Cluster

## K8s-Karpenter [Version Skew]((https://karpenter.sh/docs/upgrading/compatibility/)

Containers may be stuck in Pending because the Kubernetes scheduler cannot find a node that meets their requirements, or Karpenter is failing to provision new nodes due to the version mismatch. 
When Karpenter fails or has a version skew conflict, pods are accepted by the API server but get trapped in the scheduler queue forever. 

### 1. Diagnose the Exact Cause Instantly

To see exactly why the scheduler or Karpenter is blocking your pods, 
run this command against one of your pending CI runner pods:

```bash
kubectl describe pod $name -n $ns
```

Scroll to the very bottom to the Events: section. You will likely see one of two things: [2] 
 
* S**cenario A**: 0/X nodes are available: ... X Insufficient memory/cpu, X had untolerated taint. 
    Followed by a complete lack of Karpenter actions. (This means Karpenter isn't spinning up nodes).
* **Scenario B**: Karpenter attempts to scale up, but you see an error from Karpenter itself stating it failed to bind, or the node joins the cluster and is immediately deleted ("drifted").


### 2. Check the Karpenter Controller Logs

Because Karpenter is a separate controller, its provisioning errors won't always register inside the pod's events. Look at what Karpenter is doing under the hood:

```bash
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=100
```

Look out for these typical error patterns:

 
* "`karpenter is not compatible with kubernetes version`" (If you upgraded your cluster to v1.34 but kept an old version of Karpenter, Karpenter will actively refuse to provision new infrastructure).
* "`failed to decode NodePool/EC2NodeClass`" (API definition errors). 


### 3. Quick Fixes to Try Right Now


* **Fix 1**: Check your `NodePool` Node Selectors
If your CI pipeline definitions explicitly require a node running a v1.31 image 
(e.g., `kubernetes.io/version: "1.31"` or `ami-id: <old-ami>`), 
Karpenter will refuse to create it because your Karpenter controller on a v1.34 cluster is looking to provision v1.34 infrastructure. Open your pipeline yaml and look for `nodeSelector` or `affinity` blocks. Remove any static Kubernetes version constraints.
* **Fix 2**: Clear Out Stuck `NodeClaims`
Sometimes Karpenter creates a "ghost" machine that fails to fully register because the v1.34 control plane rejects its older setup components. Check if Karpenter is stuck trying to build a broken node:

```bash
kubectl get nodeclaims
```

If you see a `NodeClaim` stuck in a `Pending` or terminating state for several minutes, 
delete it manually (`kubectl delete nodeclaim <name>`) to force Karpenter to retry.

---

## `NodeClaim`
A NodeClaim is a **custom resource** used by Karpenter to request and track cloud infrastructure.  
Think of it as Karpenter's internal "receipt" or "ticket" for a new virtual machine (like an AWS EC2 instance). 

### How it works:

   1. When your CI runner pods go into Pending because there isn't enough cluster capacity, Karpenter catches the event.
   2. Instead of building a node immediately, Karpenter first writes a NodeClaim to the Kubernetes API.
   3. The NodeClaim tells your cloud provider: "Hey, launch me a server that has these exact specs (CPU, memory, version constraints)."
   4. Once the actual cloud server boots up and successfully registers as a Kubernetes worker node, the NodeClaim transitions to a healthy state. [1, 2] 

### Why it matters to your problem:
If your containers are stuck Pending, looking at the NodeClaims will tell you if Karpenter is even trying to help them. Run this command: [1] 

kubectl get nodeclaims

* If you see no NodeClaims: Karpenter is completely ignoring your pending pods. This usually means the pods have a nodeSelector, toleration, or affinity constraint that Karpenter's current rules (NodePool) can't satisfy. [3, 4] 
* If you see a NodeClaim stuck in Pending or Unknown: Karpenter requested a machine from the cloud provider, but the machine is failing to boot, failing to install the kubelet, or failing to talk back to your v1.34 control plane (likely due to the v1.31 version mismatch or network components crashing). [5, 6] 

To see exactly what a stuck capacity request is waiting on, run:

```bash
kubectl describe nodeclaim $name
```

Look at the `Status` block and `Events` at the bottom. It will give you explicit clues 
(e.g., `NodeNotFound`, `LaunchFailed`, or `ConsistencyCheckFailed`).  
When you run `kubectl get nodeclaims`, 
do you see any active claims listed, or is the list completely empty?

---

## Load Test Karpenter 

&hellip; using a GitLab CI/CD Pipeline.

To *trigger Karpenter to scale out and spawn new nodes*, your `.gitlab-ci.yml` needs to generate a massive surge of concurrent workload that exceeds the capacity of your current Kubernetes cluster nodes.
Here is a simple, plug-and-play .gitlab-ci.yml that uses a parallel matrix to launch 50 concurrent jobs simultaneously.

@ `.gitlab-ci.yml`

```yaml
stages:
  - scale-test

karpenter-trigger:
  stage: scale-test
  image: alpine:latest
  # Request high resources per pod so they don't all fit on existing nodes
  variables:
    KUBERNETES_CPU_REQUEST: "2"
    KUBERNETES_MEMORY_REQUEST: "4Gi"
  # Generate 50 parallel jobs (5 groups of 10)
  parallel:
    matrix:
      - GROUP: [A, B, C, D, E]
        INDEX: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  script:
    - echo "Triggering job ${GROUP}-${INDEX} to force Karpenter scale-up..."
    - sleep 60 # Keep the pod alive long enough for Karpenter to provision nodes
```
- `parallel.matrix`: This natively forces GitLab to create 50 di
stinct jobs at the exact same millisecond, 
flooding your Kubernetes scheduler.
- `KUBERNETES_CPU_REQUEST` / `MEMORY_REQUEST`: By asking for 2 CPUs and 4GB of RAM per job, 
    50 jobs will require a total of 100 CPUs and 200GB of RAM. Unless your cluster is already massive, 
    this resource deficit will immediately **trigger Karpenter to provision new EC2 instances**.
- `sleep 60:` Holds the pods in a Running state for one minute, 
    giving Karpenter enough time to bind the pending pods to the newly spun-up nodes.

**Monitor**:

```bash
kubectl get pods -n $glr_jobs_namespace -w
```

**REQUIREments**:

The GitLab Runner ignores `KUBERNETES_CPU_REQUEST` and `KUBERNETES_MEMORY_REQUEST` passed from a `.gitlab-ci.yml` file unless **`overwrite_allowed_resources`** is explicitly turned on in the runner's `config.toml`. 

@ `config.toml`
```toml
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        # This MUST be enabled for the CI variables to work!
        overwrite_allowed_resources = true  
```



---

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
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

# K8s VPA | Kubernetes v1.33+ (beta) or v1.35+ (GA)

Kubernetes VPA (**V**ertical **P**od **A**utoscaler) has existed for years;
however, it just became significantly more useful with a major feature that went **stable in late 2025**.

Here’s the breakdown:

*  **Mature Core**: VPA adjusts CPU/memory requests for pods based on usage. 
   It's an **optional add-on** installed via CRD, not part of the core Kubernetes API .
*  **The "New" Breakthrough**: The **In-Place Pod Resize** feature graduated to **GA in Kubernetes v1.35** (Dec 2025) . 
   Previously, VPA **had to evict and restart** your pod to change resources. Now it can update them **without a restart** .
*  **What This Means**: This is huge for **stateful workloads** (like databases) where restarts are disruptive. 
   It also enables features like "startup CPU boosts" to handle heavy initialization phases .


## Q:

If using VPA, is `qosClass` `Guaranteed` advised, or do we set `limits` higher than `requests`?

## A:

**Yes, the `Guaranteed` QoS class is generally advised** for production workloads with VPA;
set `limits` **equal to** `requests`. It provides the most stable and predictable performance. Pods with `Guaranteed` QoS are considered the most critical and are the **last to be evicted** when nodes are under memory pressure. For production, this stability is highly recommended.

### 💡 How VPA Handles Each QoS Class

Since VPA can adjust your resources, here is how it works with different QoS classes:

*   **`Guaranteed` Mode (`requests == limits`)**: VPA provides a single `target` recommendation, and [**Goldilocks**](https://github.com/fairwindsops/goldilocks "GitHub/FairwindsOps/goldilocks") (a common VPA dashboard tool) suggests setting **both** your request and limit to this exact `target` value. This is the recommended path for production stability.
*   **`Burstable` Mode (`requests < limits`)**: VPA provides `lowerBound` and `upperBound` recommendations. The advice is to set your **request** to `lowerBound` and your **limit** to `upperBound`. This offers more flexibility but lower stability than Guaranteed.

### ⚠️ Critical Warning for In-Place Resizes

With the new **in-place** updates (GA in K8s 1.35), an important rule applies: 
**VPA cannot change a Pod's QoS class during an in-place resize**.

Therefore, if you start a Pod with `requests < limits` (`Burstable`), 
VPA cannot resize it in-place to become `Guaranteed` (`requests == limits`) without restarting it. 
To benefit from zero-restart in-place updates on VPA, 
you should **pre-configure your pods with `Guaranteed` QoS** (`requests == limits`) from the start.

**Recommendation**: For production workloads that need stability, 
set `requests == limits` (`Guaranteed` QoS) and let VPA recommend the optimal target value for both.

If you are using the **`InPlaceOrRecreate`** update mode with this configuration, you get the best of both worlds: **stability** (Guaranteed QoS) and **zero-restart** resource adjustments (in-place resizes).

---

## Example 

Here’s a complete, production-ready example. It includes a **Deployment** with `Guaranteed` QoS and a **VPA** that will adjust it without restarts.

### 1. The `Deployment` (`Guaranteed` QoS)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: "500m"      # Request = Limit
            memory: "512Mi"  # Request = Limit
          limits:
            cpu: "500m"      # Equal to request → Guaranteed QoS
            memory: "512Mi"  # Equal to request → Guaranteed QoS
```


### 2. The VPA (In-Place Updates Enabled)
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "InPlaceOrRecreate"  # Prefers zero-restart updates
  resourcePolicy:
    containerPolicies:
    - containerName: app
      mode: "Auto"                   # VPA can both recommend and apply
      minAllowed:
        cpu: "100m"
        memory: "100Mi"
      maxAllowed:
        cpu: "2"
        memory: "4Gi"
```

### 3. What Happens Next

- VPA will recommend a **single `target`** value (e.g., `cpu: 750m`, `memory: 1Gi`).
- Because you used `requests == limits`, the pod has `Guaranteed` QoS.
- With `updateMode: InPlaceOrRecreate`, VPA will update both the **request and limit** to the target value **without restarting** the pod.
- The pod stays `Guaranteed` throughout—no evictions, no QoS demotion.


### 4. Pro Tip: Use Goldilocks to See Recommendations

Install Goldilocks (a VPA dashboard) to easily view what VPA is recommending before it applies changes:

```bash
kubectl create namespace goldilocks
kubectl apply -f https://raw.githubusercontent.com/FairwindsOps/goldilocks/master/install/goldilocks.yaml
```

Then check the VPA object directly:

```bash
kubectl describe vpa my-app-vpa
```

Look for the `Recommendation` section to see the suggested `target` value.

## 🚀 Step-by-Step Test with Kind

Testing VPA's `InPlaceOrRecreate` mode locally with Kind is a great way to see it in action.
 However, it needs some specific setup.

### 1. Create a Kind Cluster (K8s 1.35+)

You need K8s **1.33+** (with feature gate) or **1.35+** (GA) to support in-place updates
.
```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  InPlacePodVerticalScaling: true
EOF
```

### 2. Install VPA & Metrics Server
Use the official script. The **VPA 1.7+** has `InPlaceOrRecreate` enabled by default; 
for older versions, you need to enable the feature gate.

```bash
# Install Metrics Server (required for VPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install VPA
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

### 3. Deploy Workload & VPA

Create a file `vpa-demo.yaml`. 
This example uses a CPU-stressed pod with **very low initial requests** to force VPA to act.
```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      - name: stress
        image: ubuntu
        command: ["/bin/sh", "-c"]
        args: ["apt-get update && apt-get install -y stress-ng && stress-ng --cpu 1 --timeout 600s"]
        resources:
          requests:
            cpu: "50m"   # Intentionally low to trigger scaling
            memory: "100Mi"
          limits:
            cpu: "100m"
            memory: "200Mi"
---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: stress-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: stress-app
  updatePolicy:
    updateMode: "InPlaceOrRecreate"
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      minAllowed:
        cpu: 50m
        memory: 50Mi
      maxAllowed:
        cpu: 200m          # <-- This acts as a hard cap
        memory: 500Mi
```
Apply it: `kubectl apply -f vpa-demo.yaml`

### ⚠️ Common "Gotchas" & Troubleshooting

*   **`Too few replicas` Log**: If the VPA logs show `"Too few replicas" livePods=1 requiredPods=2`, the Updater is refusing to act because your Deployment has fewer than 2 replicas. This is a safety feature. **Fix:** Set `--min-replicas=1` in the VPA Updater deployment args or ensure your Deployment has at least 2 replicas.
*   **CPU vs. Memory Scaling**:
    *   **CPU**: VPA can increase and **decrease** CPU in-place.
    *   **Memory**: VPA can increase memory in-place, but decreasing it can cause a **container restart or pod eviction** depending on the `resizePolicy`.
*   **Timing**: Recommendations need 24-48 hours to stabilize. For testing, you can wait until the `status.recommendation` appears in `kubectl describe vpa stress-vpa`.

### 📖 Key Concepts to Know

*   `resizePolicy`: Set this on your container spec to control restart behavior. `restartPolicy: NotRequired` allows memory decreases without restarting the container (the default for Kubernetes 1.35+).
*   `InPlaceOrRecreate` Fallback: If an in-place update fails (e.g., new requests exceed node capacity), VPA will fall back to recreating the pod.

This setup gives you a safe sandbox to observe how VPA reacts to load without affecting production.

###

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

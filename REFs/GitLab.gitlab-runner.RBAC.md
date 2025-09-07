# K8s `gitlab-runner` RBAC 

## Q:

What is the appropriate K8s RBAC resources to configure a gitlab-runner in namespace "`gitlab-runner`" that allows for deploying and managing workloads (`pods`, `deployment`, `secrets`, ...) but only in namespace "teams"

## A:

To allow a `gitlab-runner` (in namespace `gitlab-runner`) to deploy and manage workloads such as `Pods`, `Deployments`, `Secrets`, etc., but **only within the `teams` namespace**, you need to:

---

### ✅ 1. Use a **ServiceAccount** in `gitlab-runner` namespace

This is the identity your GitLab Runner pods use.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-runner
  namespace: gitlab-runner
```

---

### ✅ 2. Create a **Role** in the `teams` namespace

This defines what actions are allowed within the `teams` namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-deployer
  namespace: teams
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "pods/log", "services", "secrets", "configmaps", "deployments", "replicasets", "jobs", "cronjobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

---

### ✅ 3. Create a **RoleBinding** in the `teams` namespace

This binds the service account in the `gitlab-runner` namespace to the role in `teams`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-deployer-binding
  namespace: teams
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: gitlab-runner
roleRef:
  kind: Role
  name: gitlab-deployer
  apiGroup: rbac.authorization.k8s.io
```

---

### Summary

| Component      | Namespace       | Purpose                                     |
| -------------- | --------------- | ------------------------------------------- |
| ServiceAccount | `gitlab-runner` | Used by GitLab Runner                       |
| Role           | `teams`         | Grants workload management permissions      |
| RoleBinding    | `teams`         | Allows above ServiceAccount to use the Role |

> 💡 This setup ensures **namespace isolation**: the runner can only manage workloads in `teams`, even though it's running in `gitlab-runner`.


## Additionally, 

The gitlab-runner must be allowed to create resources in its own namespaces, so 


```yaml
# RoleBinding to bind that Role to the runner's ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-job-binding
  namespace: gitlab-runner
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: gitlab-runner
roleRef:
  kind: Role
  name: gitlab-runner-job-manager
  apiGroup: rbac.authorization.k8s.io
```
```yaml
# Role for managing job pods and related resources in gitlab-runner namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-runner-job-manager
  namespace: gitlab-runner
rules:
- apiGroups: ["", "apps", "batch"]
  resources:
    - pods
    - pods/log
    - configmaps
    - secrets
    - services
    - jobs
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

```

## How to protect the gitlab-runner then

That's an excellent and subtle insight — and here's the nuanced answer:

> ✅ **Yes, you *can* protect the GitLab Runner controller from teams**, **but only if you separate execution and deployment namespaces** — **and don’t run ephemeral CI jobs in `gitlab-runner`**.

---

## 🔄 Why You're Feeling Stuck

If:

* CI jobs (ephemeral runner pods) run in `gitlab-runner`, and
* Those pods run developer-supplied code (`script:` in `.gitlab-ci.yml`),

Then:

* You're giving **developer-controlled pods access to the same namespace** that holds the GitLab Runner controller, config, and ServiceAccount.
* Those pods can, unless otherwise blocked:

  * Mount the same `ServiceAccount` (if not using `automountServiceAccountToken: false`)
  * Read or patch shared ConfigMaps, Secrets, or even disrupt the controller

So **yes — it's a real attack surface**, and many don't realize this.

---

## ✅ Real Isolation Strategy

To **truly isolate the GitLab Runner controller from developers**, follow this model:

### 🧩 Runner controller in `gitlab-runner` namespace

* Long-lived Deployment
* Uses a ServiceAccount: `gitlab-runner`
* Only binds that SA with RBAC to target namespace(s), like `teams`

### 🧩 CI job pods run in a separate namespace (`teams`)

* You must configure the runner Helm chart to:

  ```yaml
  runners:
    namespace: teams
  ```
* This causes job pods to spawn **in `teams`**
* Developers control `teams`, but **have no access to `gitlab-runner`**

### ✅ Net result:

| Namespace       | What Happens There         | Who Has Access         |
| --------------- | -------------------------- | ---------------------- |
| `gitlab-runner` | Runner controller pod      | Infra team only        |
| `teams`         | CI job pods, app workloads | Developers + runner SA |

Developers can:

* Deploy and manage in `teams`
* Write `.gitlab-ci.yml` that spawns jobs (in `teams`)

But **cannot touch**:

* The GitLab Runner controller pod
* Its ConfigMaps, Secrets, logs
* The Helm release or its `ServiceAccount`

---

## 🔥 Why Mixing Both in One Namespace is Dangerous

If ephemeral jobs run in the same namespace as the controller:

* Devs can `kubectl get secrets` or even `exec` into another pod, unless prevented
* You'd need complex policies to isolate **pods from pods in the same namespace**
* Even PodSecurityPolicy / PodSecurityAdmission can’t fully enforce RBAC-like isolation within a namespace

---

## 🛡 Additional Hardening (if needed)

* Set `automountServiceAccountToken: false` for CI jobs to prevent API access
* Use OPA/Gatekeeper to prevent pods in `gitlab-runner` from accessing runner resources
* Use Kubernetes `NetworkPolicy` to prevent job pods from talking to the controller pod

---

## ✅ TL;DR: You *Can* Isolate — but Only if:

* CI job pods run in a **different namespace** (e.g., `teams`)
* You do **not** run any dev-controlled code in the `gitlab-runner` namespace

## `values.yaml`

To implement the above:

Here’s a **secure and minimal `values.yaml`** for the official GitLab Runner Helm chart, designed to:

### ✅ Goals:

* Deploy the GitLab Runner **controller** in namespace: `gitlab-runner`
* Ensure **ephemeral job pods** run in namespace: `teams`
* Use a `ServiceAccount` that only has RBAC permissions in `teams`
* Prevent CI job pods from touching anything in `gitlab-runner`

---

## 📄 `values.yaml` for GitLab Runner

```yaml
## Runner registration
gitlabUrl: https://gitlab.example.com/
runnerRegistrationToken: "__REPLACE_ME__"

## Optional labels
runners:
  tags: ["k8s", "secure"]


  kubernetes:
    ## Don't automatically mount SA tokens in job pods (limit abuse)
    automountServiceAccountToken: false # Prevents the downward API from injecting the token

  ## Namespace where ephemeral CI job pods will run:
  namespace: teams

  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
  serviceAccountName: gitlab-runner

  ## Optional: Add limits to CI job pods
  resources:
    limits:
      memory: "512Mi"
      cpu: "500m"
    requests:
      memory: "256Mi"
      cpu: "250m"

  ## Optional: Job pod cleanup
  podAnnotations:
    cleanup.after.success: "true"
    cleanup.after.failure: "true"

## Install ServiceAccount in gitlab-runner namespace
serviceAccount:
  create: true
  name: gitlab-runner

## Optional: Use RBAC just for the namespace it runs jobs in
rbac:
  create: false  # We'll define custom RBAC externally — more secure

## Disable host-level mounts for security
metrics:
  enabled: false
```

---

## 🚀 How to Deploy This Securely

### 1. Create Namespace(s)

```bash
kubectl create namespace gitlab-runner
kubectl create namespace teams
```

### 2. Install Helm Chart

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  -n gitlab-runner \
  -f values.yaml
```

### 3. Create RBAC for ServiceAccount (`gitlab-runner`) in `teams`

You **must manually** create the Role/RoleBinding to allow deployments in `teams`:

```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: teams
  name: gitlab-deployer
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "deployments", "replicasets", "services", "jobs", "cronjobs", "secrets", "configmaps", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: teams
  name: gitlab-deployer-binding
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: gitlab-runner
roleRef:
  kind: Role
  name: gitlab-deployer
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```bash
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
```

---

## ✅ What This Achieves

| Component                  | Namespace       | Access                            |
| -------------------------- | --------------- | --------------------------------- |
| GitLab Runner (control)    | `gitlab-runner` | Has **no rights** there           |
| CI Job Pods                | `teams`         | Full access to workloads          |
| Developers                 | `teams`         | Can deploy, but not modify runner |
| Secrets in `gitlab-runner` | `gitlab-runner` | Not readable by CI jobs           |

This is the secure separation you're aiming for. Let me know if you'd like to also:

* Use an external secret manager (e.g., Vault),
* Use imagePullSecrets or affinity rules,
* Block specific container images or commands in CI jobs.


<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# … ⋮ ︙ • “” ‘’ – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻  ⚐ ⚑
# ☢  ☣  ☠  ¦ ¶ § † ‡ ß µ ø Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦  ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 𝐋𝐀𝐁
# ⚠️ ✅ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🧳 🥇 ✨️ 🔚

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>


-->

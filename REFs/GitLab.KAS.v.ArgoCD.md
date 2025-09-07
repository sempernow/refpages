# GitLab [KAS](https://docs.gitlab.com/user/clusters/agent/ "docs.gitlab.com") (Kubernetes Agent Server)

Install by [__Helm__](https://docs.gitlab.com/charts/installation/cloud/ "docs.gitlab.com") (GitLab v18.1 + K8s v1.33) or __Operator__

- [__Architecture__](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md "GitLab.com")

- [__`gitlab-agent`__](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent "GitLab.com") 


## Q:

GitLab runners on K8s require a token from GitLab. 
Other than that there seems nothing else is needed. 
So, what purpose is KAS and its container(s) and such?

## A:

GitLab Runners on Kubernetes only need a **registration token** to connect to GitLab and execute jobs. 
The **GitLab Agent for Kubernetes (KAS)** is for a **completely different purpose** than GitLab Runners:

---

### ✅ **GitLab Runner**:

* Purpose: Executes CI/CD pipelines.
* Auth: Needs a registration token (or access token if using GitLab API).
* Operation: Pulls job definitions from GitLab, executes them in pods (if on K8s), and reports results back.
* Use case: **Build, test, deploy** workflows triggered by GitLab pipelines.

---

### 🧠 **GitLab Kubernetes Agent (KAS)**:

* Purpose: Enables **real-time, bidirectional communication** between GitLab and a Kubernetes cluster.
* Components:

  * `kas`: A server component running in GitLab’s infrastructure.
  * `gitlab-agent`: A **pod running in your Kubernetes cluster** that connects outward to `kas`.
* Auth: Uses **agent tokens** (not the same as runner tokens).
* Operation: Uses gRPC tunnels for secure, persistent connections to GitLab.
* Use cases:

  1. **GitOps-style deployments** using **pull-based sync** (agent pulls config from GitLab projects and applies them).
  2. **Real-time K8s observability** (via GitLab UI).
  3. **Cluster management** (e.g., viewing workloads, scanning vulnerabilities).
  4. **Network-isolated clusters** (agent initiates outbound connection — no GitLab-to-cluster inbound access needed).

---

### ⚖️ Summary Comparison

| Feature                    | GitLab Runner        | GitLab Agent for K8s (KAS)            |
| -------------------------- | -------------------- | ------------------------------------- |
| Purpose                    | Run CI/CD jobs       | GitOps, real-time sync, observability |
| Needs GitLab token         | ✅ Registration token | ✅ Agent token                         |
| Deploys workloads          | ✅ via CI pipeline    | ✅ via GitOps (pull)                   |
| Talks to GitLab            | ✅ via GitLab API     | ✅ via gRPC tunnel                     |
| Useful without GitLab.com? | Yes                  | Yes, with self-managed GitLab         |
| KAS required?              | ❌ No                 | ✅ Yes (for GitOps + observability)    |

---

### ✅ Use KAS when:

* You want **GitOps pull-based deployment** (cluster pulls from GitLab).
* You need **observability or RBAC control** through GitLab UI.
* Your cluster is **behind a firewall** and can't be reached directly from GitLab.


---

## Q:

Is KAS a viable replacement for ArgoCD, or does it work in tandem, or some kind of optional arrangement?

## A:

Great question — and one that many teams ask when comparing **GitLab Agent for Kubernetes (KAS)** and **Argo CD**.

### 🧭 Short Answer:

**Yes**, GitLab Agent for Kubernetes can **replace Argo CD** for some GitOps use cases — especially in environments **already centered around GitLab**.
But it is **not yet a full feature-for-feature replacement** for teams using advanced Argo CD features.

---

### 🔍 Detailed Comparison: GitLab Agent (KAS) vs Argo CD

| Feature                                             | GitLab Agent (KAS)                                       | Argo CD                                         |
| --------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| **GitOps model**                                    | Pull-based                                               | Pull-based                                      |
| **Multi-repo support**                              | Yes                                                      | Yes                                             |
| **Multi-cluster support**                           | Yes                                                      | Yes                                             |
| **Sync methods**                                    | Agent pulls manifests from GitLab projects               | Argo pulls from Git repos                       |
| **Declarative app management**                      | Limited (no full UI for managing app-of-apps or nesting) | Full declarative + app-of-apps support          |
| **UI for app state**                                | Minimal (only shows workloads + logs)                    | Rich UI: health, history, sync, drift detection |
| **RBAC / SSO**                                      | Inherits GitLab project/group permissions                | Built-in RBAC, integrates with SSO              |
| **Drift detection**                                 | Limited                                                  | Yes (diffs live vs desired)                     |
| **Automated sync/reconciliation**                   | Yes (with manifest projects)                             | Yes (fully configurable)                        |
| **Templates/overlays (e.g., Kustomize, Helm)**      | Yes (if stored in GitLab project)                        | Yes (built-in Helm, Kustomize, Jsonnet, etc.)   |
| **Notifications/Webhooks**                          | No native alerting                                       | Yes                                             |
| **Progressive delivery (e.g., blue-green, canary)** | No                                                       | Yes (via Argo Rollouts integration)             |
| **Third-party integration**                         | GitLab-native                                            | Kubernetes-native (open ecosystem)              |
| **CLI**                                             | `kubectl gitlab-agent` (limited)                         | `argocd` CLI                                    |

---

### 🔄 Works **in tandem**?

Yes — some teams do this:

* **Use Argo CD** for complex GitOps flows, app templating, progressive delivery.
* **Use GitLab Agent (KAS)** to:

  * Automate config sync for shared infrastructure or secrets.
  * Provide observability of workloads in GitLab UI.
  * Centralize authentication (cluster management tied to GitLab groups/projects).

---

### ✅ Use GitLab Agent (KAS) when:

* You're already all-in on GitLab and prefer **fewer moving parts**.
* You want to **avoid opening inbound ports** on the cluster (KAS uses outbound gRPC tunnel).
* Your team is fine with **basic GitOps** (simple apps, infra-as-code sync).

### ✅ Use Argo CD when:

* You need **rich GitOps workflows**, drift detection, multiple environments.
* You want **templating support**, progressive delivery, or UI-driven sync controls.
* You're operating clusters independent of GitLab, or using multiple Git providers.

---

### 🧪 Final Take:

KAS is **viable for many production GitOps workflows**, especially if you want **tight GitLab integration**, but it's not as full-featured or mature as Argo CD for advanced deployment orchestration.

---

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

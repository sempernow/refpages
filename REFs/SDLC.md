# Q:

In real life, we never see SDLC handled as https://www.geeksforgeeks.org/software-engineering/software-development-life-cycle-sdlc/. Rather we arrive to find dev, test, staging and prod, if we're lucky and if luckier we find dev test and staging treated as SDLC, with success having a hash from dev that gets released and deployed to prod

# A:

You're right, and I think the reason is that the textbook and the real world describe different things under the same name.

The GeeksforGeeks version is a **process model**: the phases of *work* (requirements, design, build, test, deploy, maintain). What you find on the ground is an **environment topology**: the places code *sits*. Organizations take the environments as their SDLC because environments are concrete, you can provision and audit them, while phases are just intentions. So "testing" stops being an activity and turns into "the thing that happens in the test cluster," which is a different claim.

The luckier case you describe, where one hash built in dev is what ends up in prod, isn't really SDLC either. It's the **artifact lifecycle**, build-once-promote-many. And it's the only part with real integrity, because it's the only part that can be checked mechanically. A few things decide whether it actually holds:

- **Environments have to differ only by config.** If staging needs a rebuild because something was baked in at build time, the hash promise is broken and nobody notices. Config has to be injected at deploy time (12-factor, Helm values, Kustomize overlays) for "same SHA" to mean "same behavior."
- **Promote by digest, not tag.** `:v1.4.2` or `:staging` can be re-pointed, and `@sha256:...` can't. Plenty of shops say they promote artifacts when they're really promoting mutable tags.
- **Staging drifts.** It's usually smaller, has different data and has been hand-patched by someone at 2 a.m. So "passed staging" is weaker evidence than people treat it as, unless staging is rebuilt from the same IaC as prod.
- **The textbook phases don't vanish, they move.** In federal and DoD work, requirements, design and risk analysis live in the SSP, the change control board and the ATO package, mostly cut off from the pipeline. The paperwork lifecycle and the artifact lifecycle run side by side and rarely meet.

That last point is why the continuous-ATO idea (DoD's cATO, Iron Bank-style hardened images, SLSA provenance, cosign signatures, SBOMs attached to the digest) is interesting. It tries to make the pipeline itself the controlled, accredited object, so the evidence for each "phase" is produced and tied to that hash automatically. The textbook model's gates become attestations on the artifact.

So I'd put it this way: the textbook SDLC is how work *should* flow, environments are where code *lives*, and **the promoted hash is the one thread that runs through both**. Mature orgs make that thread carry the evidence. Everyone else has the environments and calls it a lifecycle.

Have you seen anywhere actually close the gap between the change-control side and the pipeline, or does the CCB still sign off on a ticket that only loosely refers to the digest?

---

Use **trunk-based development with artifact promotion**: branches say *what code exists*, environments say *which build is running where*, and they're *tracked separately*. Two branches can't map onto four environments, so the mapping has to live somewhere other than Git branches.

**Feature branches → ephemeral environments**
- Each MR gets a short-lived preview environment (GitLab Review Apps, or a namespace per MR on k0s), torn down on merge or close.
- These are disposable and don't count as one of your four.

**Merge to main → one build, one digest**
- Every merge to main builds the artifact once, signs it and attaches the SBOM.
- That digest is the unit of promotion from here on. **Nothing rebuilds.**

**Dev → auto-deploy from main**
- Every green main build goes to dev. Dev just means "the tip of main, running."

**Test → staging → prod: promote the same digest**
- Promotion is a gated step, not a merge. The same `@sha256:...` moves forward with ***each environment's own config injected at deploy time***.
- Gates get stricter as you go: automated tests for test, manual approval or a change ticket for staging, protected-environment approvers for prod.

**Release identity: tags on main**
- When a digest is promoted to staging as a candidate, you tag the main commit (`v1.4.0`). 
  The tag points to the commit, and the commit maps to the digest.

**Where environment state lives**
That's the part branches used to fake. You have two options:
- **GitOps deploy repo** (or a `deploy/` directory) with an overlay per environment, each pinning a digest. 
  Promotion is an MR that bumps the digest in `overlays/staging`. 
  That MR is your change record, with approvers, diff and timestamp, and it's the thing a CCB can sign. 
  It also closes the gap from my last answer.
- **Pipeline-native:** GitLab Environments with manual, protected deploy jobs 
    against a pipeline that has already built the artifact.   
    It's simpler, but the history lives in GitLab rather than Git.

**Hotfixes**
- The default is to fix forward on main and promote fast.
- If main has moved on with unreleasable work, cut a short-lived `release/1.4` branch from the `v1.4.0` tag, fix it, tag `v1.4.1`, promote, then cherry-pick the fix back to main and delete the branch. This is the only time a branch outlives a feature.

**Feature flags**
- Flags separate *deploy* (code is in prod) from *release* (users see it). 
  That's what lets main always be deployable even with half-finished work merged in.

A minimal GitLab sketch (Sans GitOps):

```yaml
build:
  stage: build
  rules: [{ if: '$CI_COMMIT_BRANCH == "main"' }]
  script:
    - docker build -t $IMG:$CI_COMMIT_SHA .
    - docker push $IMG:$CI_COMMIT_SHA
    - echo "DIGEST=$(crane digest $IMG:$CI_COMMIT_SHA)" > build.env
  artifacts: { reports: { dotenv: build.env } }

.deploy:
  script: ./deploy.sh "$IMG@$DIGEST" "$CI_ENVIRONMENT_NAME"
  resource_group: $CI_ENVIRONMENT_NAME

deploy_dev:     { extends: .deploy, stage: dev,     environment: dev }
deploy_test:    { extends: .deploy, stage: test,    environment: test,    when: manual }
deploy_staging: { extends: .deploy, stage: staging, environment: staging, when: manual }
deploy_prod:    { extends: .deploy, stage: prod,    environment: prod,    when: manual }  # protected env + approvers

```

The anti-pattern to avoid is a branch per environment (`dev`, `test`, `staging`, `prod`), where promotion is merging between them. Every merge is a rebuild, the branches drift, and "what's in prod" becomes a diff instead of a digest.



Those `deploy_*` jobs **push**. That is, `deploy.sh` talks to the cluster directly. 

If instead we use GitOps (ArgoCD or Flux) you **switch to a pull model**, 
and the CI jobs stop deploying anything. 
They shrink into **promote** jobs whose only output is a Git commit (or MR) to the deploy repo. 
Argo or Flux never reads CI; it reads the repo.

So there are two separate places:

**1. Deploy Repo : Holds the environment definition**, and it's more than env vars:

```
deploy/
  base/                    # Deployment, Service, etc. (shared)
  overlays/
    dev/kustomization.yaml
    test/kustomization.yaml
    staging/kustomization.yaml
    prod/kustomization.yaml
```

```yaml
# overlays/staging/kustomization.yaml
resources: [../../base]
images:
  - name: myapp
    newName: registry.example.com/myapp
    digest: sha256:4f1c...        # the thing that gets promoted
patches:
  - path: replicas.yaml           # env-specific sizing
  - path: ingress-host.yaml
configMapGenerator:
  - name: myapp-config
    envs: [app.env]               # plain config
# secrets: references only (ExternalSecrets / SOPS / SealedSecrets), never values
```

Each overlay is the environment's config (replicas, resources, hosts, config maps, secret references) plus one pinned digest. 
Most promotions change only that digest line.

**2. App Repo : CI `promote` jobs are thin writers:**

The promote job clones the deploy repo so it can edit the overlay, commit the new digest and push. 
It’s a write path that happens to start with a clone. The only reader in normal operation is Argo or Flux.

```yaml
.promote:
  image: registry.example.com/tools/kustomize-git
  script:
    - git clone https://oauth2:${DEPLOY_TOKEN}@gitlab.example.com/ops/deploy.git
    - cd deploy/overlays/$CI_ENVIRONMENT_NAME
    - kustomize edit set image myapp=registry.example.com/myapp@$DIGEST
    - git commit -am "promote $CI_ENVIRONMENT_NAME → $DIGEST ($CI_COMMIT_SHORT_SHA)"
    - git push        # dev/test: direct push
    # staging/prod: push a branch + open an MR instead, so approval happens in the deploy repo

promote_dev:     { extends: .promote, environment: dev }
promote_staging: { extends: .promote, environment: staging, when: manual }
promote_prod:    { extends: .promote, environment: prod,    when: manual }
```
- Scope of `ops/deploy` is a design choice, and there are four common ways to draw it:
    1. Per app `ops/deploy/app-x`
    2. Per team `ops/deploy/team-abc`
    3. Per cluster/fleet `ops/deploy/k8s-07`
    4. Platform vs. Workloads: 
        - `ops/deploy/platform`
        - `ops/deploy/apps`

Argo or Flux sees the commit, reconciles, and reports health.

**Who owns what:**

| Concern | Lives in |
|---|---|
| Build, sign, SBOM, digest | App repo CI |
| Which digest is in which environment | Deploy repo (Git history) |
| Environment shape (sizing, hosts, config) | Deploy repo overlays |
| Approval for staging and prod | MR approvals or protected branches on the deploy repo |
| Applying it to the cluster | Argo or Flux |
| Secrets | Vault or ESO; the repo holds references only |

**Some refinements:**

- **You can drop CI promotion for dev.** Flux image automation or Argo CD Image Updater can watch the registry and bump dev's digest itself. Keep the higher environments as explicit MRs so there's a human-approved record.
- **Keep GitLab Environments anyway.** They're cheap, and they give you a "what's deployed where" view and deployment approvals. Argo or Flux can post sync status back through notifications.
- **For compliance, the deploy-repo MR is your change record.** Who approved it, exactly what changed (one digest) and when are all in Git. Argo or Flux shows that the cluster matches, and that's the evidence an assessor wants.

So yes: the per-environment targets end up as nearly static config plus a digest pointer, and the deployer reads them. 
They just live in the deploy repo (ArgoCD/Flux) as manifests rather than as CI variables.

---

## Deploy Repo(s)

The scope of a deploy repo is a design choice, and there are four common ways to draw it:

| Scope | Layout | Good for | Watch out for |
|---|---|---|---|
| **Per app** | `ops/deploy/app-x` | Strong isolation, simple permissions | Repo sprawl, hard to see a whole environment at once |
| **Per team** | `ops/deploy/team-a` holding that team's apps | Matches ownership and approvals | Shared dependencies between teams need coordination |
| **Per cluster or fleet** | `ops/deploy/eks-03` holding everything that runs on a cluster | One place that answers "what's in prod" | Big blast radius; needs CODEOWNERS by path |
| **Platform vs. workloads** | `ops/deploy/platform` + `ops/deploy/apps` (either of which can be split further) | Separates cluster infrastructure from tenant apps | Ordering between them (CRDs before the apps that use them) |

A common mature setup is the last one: a **platform repo** owned by the platform team and one or more **workload repos** owned by app teams.

```yaml
ops/platform/                      # cluster plumbing, platform team approves
  clusters/
    prod-east/                     # what's installed on this cluster
    staging/
  infrastructure/
    ingress-nginx/
    cert-manager/
    external-secrets/
    kube-prometheus-stack/
    gitlab-runner/

ops/apps/                          # tenant workloads, app owners approve by path
  myapp/
    base/
    overlays/{dev,test,staging,prod}/
  otherapp/
    base/
    overlays/{dev,test,staging,prod}/
```

**How the deployer finds things:**

- **Argo CD:** an "app of apps" root Application per cluster, or better an **ApplicationSet** with a Git directory generator that creates one Application per `apps/*/overlays/<env>` automatically. Adding an app is then just adding a directory.
- **Flux:** a `Kustomization` per path, chained with `dependsOn` so the platform (CRDs, controllers) reconciles before the workloads.

**Making a shared repo safe:**

- Put CODEOWNERS on each path (`/myapp/overlays/prod/ @myapp-release-managers`) so one team can't change another team's prod pins.
- Use Argo CD **AppProjects**, or Flux with per-tenant service accounts, to limit which namespaces and resource kinds each app's manifests may touch. Repo permissions control who can *write*, and these control what the manifests are *allowed to do* on the cluster.
- Run validate-only CI on the repo (`kustomize build`, schema checks with kubeconform, policy checks with Conftest or Kyverno) so a broken manifest fails in the MR, not during reconciliation.

**Subset vs. all:** it's fine for a cluster to be fed by several repos. For example, `ops/platform` and `ops/apps` might both target prod while a vendor-supplied app comes from its own repo. The rule that keeps it sane is that **each resource on the cluster has exactly one owning repo and path**. Two repos managing the same object will fight, and Argo or Flux will flap between them.

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

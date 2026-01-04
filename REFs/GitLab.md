# GitLab | [Docs](https://docs.gitlab.com/runner/executors/kubernetes/)

## [Self-hosted GitLab EE|CE](https://about.gitlab.com/install/)

- [Reference Architectures](https://docs.gitlab.com/ee/administration/reference_architectures/index.html)
    - GitLab package (__Omnibus__) | [Install](https://about.gitlab.com/install/)
        - Omnibus GitLab architecture and components : Omnibus GitLab is a customized fork of the __Omnibus project from Chef__ ([`omnibus-gitlab`](https://gitlab.com/gitlab-org/omnibus-gitlab "GitLab.com/gitlab-org/omnibus-gitlab")), and it uses Chef components like cookbooks and recipes to perform the task of configuring GitLab on a user’s computer. Omnibus GitLab repository on GitLab.com hosts all the necessary components of Omnibus GitLab. These include parts of Omnibus that are required to build the package, like configurations and project metadata, and the __Chef related components that are used in a user’s computer after installation__.

            - Runit, a lightweight init system (predates `systemd`), is the service supervisor of GitLab Omnibus. The term `runsvdir` refers to a Runit component that handles serivce directories (`svdir`) created by Runit. So, while GitLab uses `systemd`, service supervision is delegated to Runit. | [ChatGPT](https://chatgpt.com/c/67098a1c-eb8c-8009-a07a-df93d1bf9b50)
                - See `/opt/gitlab/sv/*`
      - __Single-node__ : [Up to 20 RPS or 1,000 users](https://docs.gitlab.com/ee/administration/reference_architectures/1k_users.html) | [GitLab Single Server Architecture](gitlab-single-server-architecture.png)
      - Multi-node : [Up to 40 RPS or 2,000 users](https://docs.gitlab.com/ee/administration/reference_architectures/2k_users.html)
      - &vellip;
    - [Cloud native hybrid](https://docs.gitlab.com/ee/administration/reference_architectures/#cloud-native-hybrid) : Single- or Multi- node
    - __GitLab Operator__  : a __K8s Operator__ (Not for production)
        - [Releases](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases "gitlab.com/gitlab-org/cloud-native/") : [`/-/raw/<OPERATOR_VERSION>/CHART_VERSIONS`](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/raw/1.4.2/CHART_VERSIONS)


            |Operator|Chart|GitLab|
            |-----|-----|--------|
            |1.4.2|8.4.2|v17.4.2 |
            |1.4.2|8.3.5|v17.3.5 |
            |1.4.2|8.2.9|v17.2.9 |
          - [Docs](https://docs.gitlab.com/operator/ "docs.gitlab.com")
          - [`gitlab-org/cloud-native`](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator)
          - Installation : [`gitlab-org/cloud-native`](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/doc/installation.md) | [`docs.gitlab.com`](https://docs.gitlab.com/operator/installation.html)
              - Ingress : [Ingress-NGINX Controller](https://kubernetes.github.io/ingress-nginx/deploy/) (forked chart).
              - TLS : [`cert-manager`](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/doc/installation.md#ingress-controller)
              - Auth by [LDAP](https://docs.gitlab.com/ee/administration/auth/ldap/index.html "docs.gitlab.com/ee/administration/auth/ldap"), [SAML, and OAuth](https://docs.gitlab.com/ee/integration/omniauth.html "docs.gitlab.com/ee/integration/omniauth")
      - [GitLab Runner Operator](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator)


### Install &amp; [Configure](https://docs.gitlab.com/ee/administration/configure.html "docs.gitlab.com") : `/etc/gitlab/gitlab.rb`

```bash
# Install the package (RPM)
sudo dnf install -y gitlab-ee
# Else also inject configuration parameter(s) here (imperatively)
host=gitlab.local # Example; add/edit DNS record(s) of (sub)domain as apropos
sudo EXTERNAL_URL="https://$host" dnf install -y gitlab-ee
# Configure (further) declaratively (optional actually, but advised)
sudo vi /etc/gitlab/gitlab.rb
# Apply (re)configuration (REQUIRED; runs many Chef recipes)
gitlab-ctl reconfigure
# Verify the service is active (optional)
systemctl status gitlab-runsvdir.service # "status" else "is-active"
# Restart (optional)
gitlab-ctl restart [nginx] # All else one component by subcommand
```

<a name=ldap></a>

- [LDAP synchronization](https://docs.gitlab.com/ee/administration/auth/ldap/ldap_synchronization.html)
    - [Group sync](https://docs.gitlab.com/ee/administration/auth/ldap/ldap_synchronization.html#group-sync) : _If your LDAP supports the `memberof` property, when the user signs in for the first time GitLab triggers a sync for groups the user should be a member of. ... group sync process runs every hour on the hour, and_ ___`group_base` must be set in LDAP configuration for LDAP synchronizations based on group `CN` to work.___ _This allows GitLab group membership to be automatically updated based on LDAP group members._ : `/etc/gitlab/gitlab.rb` :
        ```ruby
        gitlab_rails['ldap_servers'] = {
            'main' => {
                'group_base' => 'ou=groups,dc=example,dc=com',
                }
        }
        ```
        - [External groups](https://docs.gitlab.com/ee/administration/auth/ldap/ldap_synchronization.html#external-groups) : `/etc/gitlab/gitlab.rb`
        ```ruby
        gitlab_rails['ldap_servers'] = {
            'main' => {
                'external_groups' => ['interns', 'contractors'],
                }
        }
        ```
- [External users](https://docs.gitlab.com/ee/administration/external_users.html) : _This feature may be useful when for example a contractor is working on a given project and should only have access to that project._ Such users are best handled as members of "[External&nbsp;groups](#ldap)" (above).
    - Features: 
        - Cannot create project, groups, and snippets in their personal namespaces.
        - Can only create projects (including forks), subgroups, and snippets within top-level groups to which they are explicitly granted access.
        - Can access public groups and public projects.
        - Can only access projects and groups to which they are explicitly granted access. External users cannot access internal or private projects or groups that they are not granted access to.
        - Can only access public snippets. 
    -  Methods to set user as "External user":
        - LDAP groups 
            - See "[External&nbsp;groups](#ldap)" section above.
        - SAML groups
        - OmniAuth: [Supported providers](https://docs.gitlab.com/ee/integration/omniauth.html#supported-providers) includes AuthO, AWS Cognito, Atlassian, GitHub, GitLab.com, Google, and &hellip;
            - JWT
            - OpenID Connect (OIDC)
            - Generic OAuth2
            - SAML 
            - Kerberos

#### Upon any (re)configuration

>Running "`gitlab-ctl reconfigure`" is the advised and standard method to apply changes made to `/etc/gitlab/gitlab.rb`. This command __ensures that all configuration changes are correctly applied across all GitLab components and services__.

```bash
# Apply the reconfiguration
gitlab-ctl reconfigure

# Verify service is active
systemctl is-active gitlab-runsvdir.service
# Or, for more info
systemctl status gitlab-runsvdir.service

```

### Install GitLab on K8s

[Install GitLab : operator and app](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/doc/installation.md) 

#### Install GitLab Operator 

Helm method

```bash
v=8.4.2 # Chart
# Download for offline install
helm pull gitlab/gitlab-operator --version $v
# Install the Operator
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm update gitlab-operator gitlab/gitlab-operator \
    --install  \
    --version $v \
    --create-namespace \
    --namespace gitlab-system
```

Manifest method

```bash
v=1.4.2 # Operator
url=https://gitlab.com/api/v4/projects/18899486/packages/generic/gitlab-operator/$v/gitlab-operator-kubernetes-$v.yaml
curl -sSLO $url
kubectl apply -f gitlab-operator-kubernetes-$v.yaml

```
- [GitLab Operator Releases](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases "gitlab.com/gitlab-org/cloud-native/")

#### Install GitLab (app) 

Manifest method (only).

```bash
# Install the app : GitLab (CRD)
crd=gitlab 
vi $crd.yaml # Configure for version and domain at least
kubectl -n gitlab-system apply -f $crd.yaml

# Monitor install process
kubectl -n gitlab-system get gitlab
kubectl -n gitlab-system logs deployment/gitlab-controller-manager -c manager -f

# Teardown
kubectl -n gitlab-system delete -f $crd.yaml
```

@ `gitlab.yaml`

```yaml
apiVersion: apps.gitlab.com/v1beta1
kind: GitLab
metadata:
  name: gitlab
spec:
  chart:
    ## https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/raw/1.4.2/CHART_VERSIONS 
    version: "8.4.2" # Chart
    values:
      global:
        hosts:
          domain: gitlab.k8s.local # use a real domain here
        ingress:
          configureCertmanager: true
      certmanager-issuer:
        email: admin@gitlab.k8s.local # use your real email address here
```

[Steps after installing GitLab](https://docs.gitlab.com/ee/install/next_steps.html)


## [GitLab Runner](https://gitlab.com/gitlab-org/gitlab-runner) | [Releases](https://gitlab.com/gitlab-org/gitlab-runner/-/releases)


### [Helm chart : How To](https://docs.gitlab.com/runner/install/kubernetes/)

```bash
repo=gitlab
chart=gitlab-runner
ver=0.76.3 # runner: v17.11.3

# Add repo
helm repo update $repo ||
    helm repo update $repo

# Available versions : chart vs. runner
helm search repo -l $repo/$chart

helm template $repo/$chart --version $ver

```

## [GitLab Agent for Kubernetes](https://chatgpt.com/share/680b9e25-1020-8009-83d4-12758edf02b1)

## CI/CD Pipelines 

Reference: "GitLab CICD Intermediate" [2023]

- GitLab CE Server (+Web GUI) | Linode VM @ 4 CPU / 8 Gi Memory
    - GitLab Runner (Golang) | Linode VM @ 2 CPU / 4Gi Memory
      See "3. Install GitLab Runner on Linux"
- [Install GitLab Runner | Linux](https://docs.gitlab.com/runner/install/linux-repository.html)
    - [GitLab Runner Operator](https://operatorhub.io/operator/gitlab-runner-operator) 
    The GitLab Runner operator manages the lifecycle of GitLab Runner in Kubernetes or Openshift clusters. The operator aims to automate the tasks needed to run your CI/CD jobs in your container orchestration platform.
    - [Use the agent to install GitLab Runner](https://docs.gitlab.com/runner/install/kubernetes-agent.html)
        - [Connecting a Kubernetes cluster with GitLab](https://docs.gitlab.com/ee/user/clusters/agent/) 
          Connect your K8s cluster with GitLab to deploy, manage, and monitor your cloud-native solutions. To connect a Kubernetes cluster to GitLab, you must first [install an agent in the cluster](https://docs.gitlab.com/ee/user/clusters/agent/install/index.html).
    - May have several, each scoped to a team, each available to that team only.
        - Must register and configure Runners with GitLab via Web UI ([ChatGPT](https://chatgpt.com/share/670ad40b-24d4-8009-8d08-49c3e51b8cf2)). Use the "Register an Instance Runner" (Button)
    - Executor : Where the pipelines run; several options: 
        - Kubernetes - Use the Kubernetes executor to use Kubernetes clusters for your builds. 
          The executor calls the Kubernetes cluster API and creates a pod for each GitLab CI job,
          dividing the build into multiple steps:
            1. Prepare: Create Pod having containers required for the build and services to run.
            1. Pre-build: Clone, restore cache, and download artifacts from previous stages. 
                This step __runs on a special container__ as part of the pod.
            1. Build: User build.
            1. Post-build: Create cache, __upload artifacts to GitLab__. 
                This step also __uses the special container__ as part of the pod. 
        - Docker - runs pipeline in container
        - Shell - runs pipline at shell of host OS.
- Metrics : 
    - [InfluxDB](https://www.influxdata.com/products/influxdb/) All-in-One solution : Collect/Proccess/Graph
        - [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) Agent at each Runner

## [GitLab `git` workflow](https://gitlab.com/sempernow/gitlab-workflow "sempernow/gitlab-workflow")

### Initialize a Project

```bash
# (Re)Set global/local(default) config param(s)
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR_EMAIL"
git config --global user.account $_GIT_HOST_ACCOUNT_USERNAME
git config --list

# Create the local project from origin (Git repo)
prj=prj
## Set network params for SSH mode
proto='git@'
host='gitlab.com' # Domain name of the Git-server host
path="$(git config user.account)/$prj"
keypath=~/.ssh/${host%.*}_$(git config user.account)
## SSH login sans creds prompts
ssh -T -i $keypath git@${host}
## Initialize : git init
git clone git@${host}:${path}.git && pushd $prj
## Create/commit  main bran
git switch --create main || git checkout main || git checkout -b main 
touch README.md
git add README.md
git commit -m "Project init @ $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
## Push to origin
git push --set-upstream origin main
# Else add origin in SSH mode and then push
# git remote add origin ${proto}${server}:${path}.git
# Push (securely)
# git push -u origin main # initial
# git push                # subsequent
```
- The project (URI) must already exist at the Git server (`$host`).

### Swap Modes (Protocols)

Git-server protocol/syntax allows for HTTPS using `'https://'`, 
and for SSH using either `'git@'` or `'ssh://'`.

```bash
proto='https://'
git remote set-url origin ${proto}${host}:${path}.git
git remote set-url origin git@gitlab.com:/acct-y/prj-y.git # Example
# Verify 
git remote show origin
```

### SSH : Key-pair Setup

Setup secure comms enabling login sans password.

```bash
# Generate key pair
ssh-keygen [-t ed25519|ecdsa|rsa] -C "$email_addr" -f $keypath # ~/.ssh/gitlab

# Fingerprint (fpr)
# Show fpr of any key (public/private have common fpr)
## -v show visual in addition to the hash.
ssh-keygen [-E md5|sha1(default)] -l[v] -f $keypath
# Show fpr of (remote) host(s) : VALIDATE host ON FIRST CONNECT
ssh-keygen [-E md5|sha1(default)] -l[v] -f $keypath

# Copy/Paste user's PUBLIC key (*.pub) to remote:
# Web GUI @ https://gitlab.com/-/profile/keys

# LOGIN to create SSH tunnel (sans shell) 
ssh -T[v[v[v[v]]]] -i $keypath git@github.com # -v; verbosity [levels]

# Optionally : Requires Git 2.10+
git config core.sshCommand "ssh -o IdentitiesOnly=yes -i $keypath -F /dev/null"
```
- [Copy/Paste user's ___public___ key (*.pub) to remote](https://gitlab.com/-/profile/keys)
- See: [Use SSH keys to communicate with GitLab](https://docs.gitlab.com/ee/user/ssh.html "docs.gitlab.com/...")

#### Configure @ `~/.ssh/config`

```bash
Host gitlab gitlab.com
  HostName gitlab.com
  User git
  RequestTTY no
  IdentityFile ~/.ssh/gitlab_sempernow
```

Thereafter:

```bash
# Login : creates SSH tunnel (sans shell) 
ssh gitlab
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


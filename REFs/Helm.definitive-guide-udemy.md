# [Helm : Definitive Guide from Beginner to Master](https://www.udemy.com/course/definitive-helm-course-beginner-master/ "Udemy.com")

- https://www.udemy.com/course/definitive-helm-course-beginner-master/
- https://github.com/lm-academy/helm-course
- https://github.com/lm-academy/helm-charts
- https://github.com/lm-academy/config-store

---
# Prerequisites

Install binaries of the associated applications, and create a target cluster

## Minimal docker on WSL2

To install the **headless Docker Engine** directly inside your WSL2 Ubuntu distribution (without heavy GUI tools like Docker Desktop), run the official install script:

```bash
curl -fsSL https://get.docker.com | sh
```

Then add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

The daemon should be running upon install.

### Prerequisites and Daemon Setup

- Open your Ubuntu WSL2 terminal and make sure your package list is fresh:  `sudo apt update`
- If you are running a modern Ubuntu release on WSL2, systemd or start the `docker` background process manually if systemd is disabled. 
- Test that the daemon responds locally: `docker ps`  

### Connecting with Minikube and Kind 

- Set Minikube to use the native Docker driver by running:  `minikube config set driver docker`
- Start Minikube cleanly inside WSL2:  `minikube start --driver=docker`
- For  (Kubernetes in Docker), `kind create cluster` will automatically detect the local `/var/run/docker.sock` socket inside your WSL2 environment and spin up worker/control nodes as containers.


## Install `kind`

```bash
# Download and install kind
curl -Lo ./kind https://k8s.io
sudo install -o root -g root -m 0755 kind /usr/local/bin/

# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-arm64

sudo install -o root -g root -m 0755 kind /usr/local/bin/

```

```bash
# Create
kind create cluster
# Verify kubeconfig was exported
kubectl config view
# Smoke test API
kubectl get --raw "/readyz?verbose"
# Or
curl -k https://localhost:34513/readyz?verbose
```

## Install `kubectl`

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# OR
ver=v1.36.1 # Match kind verson (within 1 minor version)
curl -LO "https://dl.k8s.io/release/$ver/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/
```

---

## Install `helm` on WSL2

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4

sudo bash get-helm.sh

helm --help
```

## [ArtifactHub](https://artifacthub.io/packages/search?kind=0&sort=relevance&page=1)


## Install `bitnami/wordpress` chart on `kind` cluster

```bash
# Install
helm install wp bitnami/wordpress
# Verify
kubectl get all
# Get password
helm status wp
echo Password: $(kubectl get secret --namespace default wp-wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
# Expose app to localhost
kubectl port-forward svc/wp-wordpress 8080:80
CTRL-Z
bg
curl -I http://localhost:8080

```

http://localhost:8080/


## Useful Helm CLI options

```bash
helm upgrade \
    $release $repo/$chart \
    --reuse-values \
    --values custom.yaml \
    --set "image.tag=bogus" \
    --version 23.1.28 \
    --atomic \
    --cleanup-on-fail \
    --debug \
    --timeout 2m 
```
- This upgrade performs a merge of all 
  declared `custom.yaml` (patch) values with 
  those of the existing release.
- Without the `--reuse-values` flag, 
  any values not declared in patch (`custom.yaml`)
  would revert to those of chart's default `values.yaml`
- The `--atomic` flag, without `--cleanup-on-fail` flag, 
  does not delete resources on fail. 
- v4: `--atomic` is **depricated** in favor of `--rollback-on-failure`

## Create a Chart 

```bash
☩ helm create app-x
```

Minimal **`Chart.yaml`**

```bash
☩ cat app-x/Chart.yaml |sed '/^#/d' |sed '/^$/d'
```
```yaml
apiVersion: v2
name: app-x
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```

Folder Structure | See [minimal folder structure](https://github.com/lm-academy/helm-course/tree/main/creating-charts/nginx)

```plaintext
my-chart/
├── .helmignore          # Patterns to ignore when packaging the chart
├── Chart.yaml           # Metadata about the chart (version, descr, API ver)
├── values.yaml          # Default configuration values for the templates
├── values.schema.json   # Optional: Schema to enforce structure on values.yaml
├── README.md            # Optional: Human-readable documentation
├── LICENSE              # Optional: Plain text license for the chart
├── charts/              # Directory for (standalone) sub-charts (dependencies)
├── crds/                # Optional: Custom Resource Definitions (not templatized)
└── templates/           # Directory for Kubernetes manifest templates
    ├── NOTES.txt        # Optional: Plain text file for post-installation notes
    ├── _helpers.tpl     # Named templates and helper functions
    ├── deployment.yaml  # Kubernetes Deployment template
    ├── hpa.yaml         # Kubernetes Horizontal Pod Autoscaler template
    ├── ingress.yaml     # Kubernetes Ingress template
    ├── service.yaml     # Kubernetes Service template
    └── tests/           # Directory for chart validation tests
        └── test-connection.yaml

```

```bash
helm template $chart_path # Process the chart into K8s manifests
helm lint $chart_path     # Validate the chart
helm install $release $chart_path # Install a release (name) of the chart

helm status $release 
helm get values $release # all|hooks|manifest|notes|values of a RELEASE
helm get manifest $release |yq '(.kind,.metadata)'
kubectl get all -l app.kubernetes.io/instance=$release
helm show all $repo/$chart # all|chart|crds|readme|values of a CHART

```
- The diff of `helm get manifest` against `helm template` 
  reveals (imperatively induced) drift.

### [lm-academy/helm-course](https://github.com/lm-academy/helm-course/blob/main/intro-go-templating/templates/sandbox.yaml)

@ WSL2 of laptop

```bash
☩ git clone https://github.com/lm-academy/helm-course.git
```

@ `./helm-course/creating-charts/nginx`

```bash
☩ tree .
.
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml

2 directories, 4 files

☩ helm lint .
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed

☩ helm template .
---
# Source: nginx/templates/service.yaml
apiVersion: v1
kind: Service
...

```

### Subcharts : [Deep dive of `bitnami/wordpress` chart structure](https://www.google.com/search?q=helm+charts+file+structure+supposedly+requires+standalone+charts+in+charts+dir%3B+however+bitnami%2Fwordpress-33.0.5+has+only+memcached%2Ftemplates%2F*.yaml+files&sca_esv=04df8f8015c05b9a&sxsrf=APpeQnsPsgxd8eC18l6VTcst7GplZ7HmAw%3A1786728727419&udm=50&source=chrome.ob&fbs=ABfTbFVyMZGZf1hfvX9uKjN_-G8c4u0nXx4bEIpwm1lnNH832a9BVCEiB2iPJNekNderQwLP8msUKsz-6AMxGyueJZ9cK2mNBy2II_6WvkKSZWdeggc7a5-PkN1W4krCU8bvvb222ld7DslYVIxVGS6hS5ngUrVOs5a9c652d2gi9qX87nTl4scoXT_hidx4oPA6XMgdJfhqS_GginZfx551wGsGgUQlfw&aep=1&ntc=1&cs=1&sa=X&ved=2ahUKEwjK-e2Y06CWAxU2lokEHXKpKHgQ2J8OegQIDhAD&biw=768&bih=743&dpr=1.25&mstk=AUtExfA1QiZc9AuMjmzIVcLU9BfkHrLy3WKjl-wXl9umuDfx4ZucMmQ3o_xYL9gfzfvta4F-XCFbd_sK53KYVkpLSaGKQFHJuI-xwbO7uYFC6TZBUpz7dvPX8nr-o_KQjLxW29NJbqqjMbnCl5VGfcAnoMuFwMSMw7Es3_tfHdtH-PVbcHd80zDML_BSkvjzKnau6DlAD3VRlvoq6Jw1B5I5oBhplAYY1RcWOS6W_mYcmBe8FRCoBcVMyh6d2A&csuir=1&atvm=2)


Helm dependencies are resolved and __packaged dynamically__ when a chart is compiled or downloaded, which is why the actual `bitnami/wordpress-33.0.5` file structure looks different on disk than it does in the raw source repository.

Helm handles standalone subcharts via the `charts/` directory. If you unpack the `.tgz` package directly or view it through the Helm CLI, you are seeing the post-build outcome of how Helm resolves dependencies: 

#### The Raw Source Structure vs. The Packaged Artifact

* __In the source repository__: The `bitnami/wordpress` chart defines `memcached` and `mariadb` as dependencies in its `Chart.yaml` file. ___The subcharts do not actually live inside the source code repository___ under `charts/`; they are separate, distinct charts maintained in the same monorepo or an external registry. 
* __In the distributed package__ (`.tgz`): When Bitnami builds and pushes the official chart package to an OCI registry or Helm repository, Helm pulls down the specific versions of the `memcached` and `mariadb` subcharts and locks them into the `charts/` directory as standalone, fully-formed charts. 


See `helm dependency build` @ `./helm-course/intro-go-templating`

```bash
☩ tree .
.
├── Chart.yaml
├── templates
│   └── sandbox.yaml
└── values.yaml

2 directories, 3 files
```

### Go Templates 

@ `./helm-course/intro-go-templating`

@ `sandbox.yaml`

```yaml
# I am a YAML comment, and I will remain in the generated YAML
{{- /* I am a GO comment, and I will NOT remain. */}}
{{- /* <function name> <arg1> <arg2> ... */}}
test: {{ lower .Values.test | replace " " "-" }}
labels:
  {{- /* The app label comes from the Release */}}
  app: {{ .Release.Name }}
  {{- /* The chart label comes from the Chart information */}}
  chart: {{ .Chart.Name }}
  {{- if eq .Values.environment "production" }}
  environment: production
  build: stable
  public-ingress: true
  {{- else }}
  environment: dev
  build: alpha
  public-ingress: false
  {{- end }}
```

Process the chart : Templates into Manifests

```bash
☩ helm lint .
==> Linting .
[INFO] Chart.yaml: icon is recommended
[WARNING] templates/sandbox.yaml: object name does not conform to Kubernetes naming requirements: "": metadata.name: Invalid value: "": a lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')

1 chart(s) linted, 0 chart(s) failed

☩ helm template .
---
# Source: intro-go-templating/templates/sandbox.yaml
# I am a YAML comment, and I will remain in the generated YAML
test: i-am-a-string
labels:
  app: release-name
  chart: intro-go-templating
  environment: dev
  build: alpha
  public-ingress: false
```

### Setting values

@ `./helm-course/creating-chart/nginx/values.yaml`

@ `values.yaml`

```yaml
## @param replicaCount Number of Nginx replicas to deploy
replicaCount: 3

## Settings for NGINX image
##
## @param image.name Nginx image name to use
## @param image.tag Nginx image tag to use
image:
  name: nginx
  tag: '1.27.0'

## NGINX container ports
##
## @param containerPorts.http
containerPorts:
  http: 80

## Settings for NGINX service
##
## @param service.enabled Whether to deploy the service altogether or not
## @param service.type The type of service in front of the Nginx pods
## @param service.port The port where the service is receiving requests
service:
  enabled: true
  type: ClusterIP
  port: 80
```

@ `./helm-course/creating-chart/nginx/templates`

@ `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
        release: {{ .Release.Name }}
    spec:
      containers:
        - name: nginx
          image: "{{ .Values.image.name }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.containerPorts.http }}

```

### Conditional Resource

Wrap the entire resource in a Golang conditional block

```yaml
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-svc
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.containerPorts.http }}
{{ end }}
```

### Packaging the chart

```bash
helm package --help 

helm package $chart_path # Generate archive (`.tgz`)

helm install ngx $chart_archive_path

```
- Version is that declared in `Chart.yaml`

Example:

```bash
Ubuntu (main *=) [10:57:45] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-course/creating-charts
☩ helm install ngx2 nginx-0.1.1.tgz
NAME: ngx2
LAST DEPLOYED: Mon Aug 17 10:58:02 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

Ubuntu (main *=) [10:58:03] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-course/creating-charts
☩ helm list
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART        APP VERSION
ngx     default         1               2026-08-17 10:46:53.340674867 -0400 EDT deployed        nginx-0.1.0  1.27.0
ngx2    default         1               2026-08-17 10:58:02.554025531 -0400 EDT deployed        nginx-0.1.1  1.27.0
```

### GitHub Pages creation

Working from a SEPARATE Git PROJECT

```bash
Ubuntu [11:09:48] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy
☩ git clone https://github.com/lm-academy/helm-charts.git
```
```bash

# Create an index.yaml for the packaged chart
chart_folder='helm-charts'
cd $chart_folder
helm repo index .

```

Here is the packaged chart:

```bash
Ubuntu (main *=) [12:28:22] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ ls
total 20K
-rw-r--r-- 1 x1 x1 1.1K Aug 17 11:10 LICENSE
-rw-r--r-- 1 x1 x1  744 Aug 17 11:10 README.md
-rw-r--r-- 1 x1 x1 3.1K Aug 17 11:10 glitchy-image-processor-0.1.0.tgz
-rw-r--r-- 1 x1 x1  863 Aug 17 11:16 index.yaml
-rw-r--r-- 1 x1 x1  922 Aug 17 11:10 nginx-0.1.0.tgz

Ubuntu (main *=) [12:29:32] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ gc 'feat(nginx): publish nginx chart v0.1.0'

```
- This will publish to GitHub Pages if that feature is enabled for the code base. The `README.md` is the landing page (if no `index.html` nor `index.md`).
  - GitHub (project root) left sidebar menu > Code and automation > Pages


## Install the published chart

```bash
helm repo add lm-academy https://lm-academy.github.io/helm-charts/
```
```bash
Ubuntu (main >) [13:20:00] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ helm search repo nginx
NAME                                            CHART VERSION   APP VERSION     DESCRIPTION                   
bitnami/nginx                                   25.0.20         1.31.3          NGINX Open Source is a web server that can be a...
bitnami/nginx-ingress-controller                12.0.7          1.13.1          NGINX Ingress Controller is an Ingress controll...
bitnami/nginx-intel                             2.1.15          0.4.9           DEPRECATED NGINX Open Source for Intel is a lig...
ingress-nginx/ingress-nginx                     4.15.1          1.15.1          Ingress controller for Kubernetes using NGINX a...
lm-academy/nginx                                0.1.0           1.27.0          A Helm chart for deploying Nginx to Kubernetes
prometheus-community/prometheus-nginx-exporter  1.23.0          1.5.1           A Helm chart for NGINX Prometheus Exporter

Ubuntu (main >) [13:20:21] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ helm install ngx lm-academy/nginx
NAME: ngx
LAST DEPLOYED: Mon Aug 17 13:21:43 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

Ubuntu (main >) [13:21:44] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ helm status ngx
NAME: ngx
LAST DEPLOYED: Mon Aug 17 13:21:43 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
RESOURCES:
==> v1/Deployment
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
ngx-nginx   3/3     3            3           41s

==> v1/Pod(related)
NAME                        READY   STATUS    RESTARTS   AGE
ngx-nginx-69cf5b875-kt2zd   1/1     Running   0          41s
ngx-nginx-69cf5b875-p27lz   1/1     Running   0          41s
ngx-nginx-69cf5b875-qvs5p   1/1     Running   0          41s

==> v1/Service
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
ngx-nginx-svc   ClusterIP   10.96.254.78   <none>        80/TCP    41s


TEST SUITE: None

```

### Leveraging Helm CLI for chart creation

```bash
helm create --help 
helm create backend-app # Generates a basic chart

```

```bash
Ubuntu (main %>) [13:28:41] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ helm create backend-app
Creating backend-app

Ubuntu (main %>) [13:29:50] [1] [#0] /c/Users/X1/Documents/helm-definitive-udemy/helm-charts
☩ ls backend-app/
total 12K
drwxr-xr-x 1 x1 x1 4.0K Aug 17 13:29 charts
drwxr-xr-x 1 x1 x1 4.0K Aug 17 13:29 templates
-rw-r--r-- 1 x1 x1 1.2K Aug 17 13:29 Chart.yaml
-rw-r--r-- 1 x1 x1 5.2K Aug 17 13:29 values.yaml

```

## Go Templating Deep Dive

[Helm : Chart Templating Guide](https://helm.sh/docs/chart_template_guide/)

E.g., Helm functions : [`merge`](https://helm.sh/docs/chart_template_guide/function_list#merge-mustmerge), which merges two dictionaries; say, two sets of labels (dev and prod)

Based on Golang, the operator is first:

  `list 1 2 3` --> `[1, 2, 3]`

But that result is just a string representation of the funtion output.

To output valid YAML:

```yaml
# Handle newline requirement
aList: 
{{ list 1 2 3 | toYaml }}

# ... newline and add indentation (nindent)
bList: {{ toYaml (list 1 2 3) | nindent 2 }}

# ... same using pipes only;
#     must account for absolute reference for indentation
one:
  two:
    cList: {{ list 1 2 3 | toYaml | nindent 6 }}

aDict: {{ dict "simple-key" "val1" "complex-key" (dict "k1" "v1") | toYaml | nindent 2 }}

```

### Named Templates | `_helpers.tpl`

Reusable components

`_helpers.tpl`
```yaml
{{- define "templating-deep-dive.fullname" -}}
{{- $defaultName := printf "%s-%s" .Release.Name .Chart.Name }}
{{- .Values.customName | default $defaultName | trunc 63 | trimSuffix "-"  -}}
{{- end -}}

{{- define "templating-deep-dive.selectorLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
managed-by: "helm"
{{- end -}}
...
```


Resource templates consume them

`deployment.yaml`
```yaml
...
metadata:
  name: {{ include "templating-deep-dive.fullname" . }}
  labels: 
    {{- include "templating-deep-dive.selectorLabels" . | nindent 4 }}
...
```

## Subcharts

```bash
helm dependency list $chart_path # List subcharts declared in Chart.yaml
helm dependency update $chart_path # Update Chart.lock per Chart.yaml
helm dependency build $chart_path
```
- See `dependencies:` key of (root) `Chart.yaml`

Subcharts may be a **conditional** dependency;
conditional per declaraton(s) of one or more applied Values files.

### Image dependencies 

There is *still* no helm command to ***list all (possible) images** (dependencies) of a chart (including those of subcharts, some of which may/not be enabled per Values).

#### Workarounds

**Method 1**:

```bash
helm template $chart_path \
  --set global.enabled=true \
  --set tags.all=true \
  --set $subchart.enabled=true \
  |yq '..|.image? | select(.)' |sort -u

```
- **How it works**: `helm template` parses all the YAML manifests. The `yq` tool recursively parses through every line looking for keys named `image` and suppresses empty (`null`) lines.
- **Forcing hidden images**: If your chart has dynamic switches like `mysql.enabled=false` by default, append explicit overrides directly into your command to force them to render (e.g., `--set mysql.enabled=true --set postgresql.enabled=true`).
  - See `--set $subchart.enabled=true`

**Method 2**:

Install plugin: [Helm Images](https://github.com/nikhilsbhat/helm-images)

>Helm plugin to fetch all possible images from the chart before deployment or from a deployed release

```bash
# Install plugin (once)
helm plugin install https://github.com/nikhilsbhat/helm-images
# List all images
helm images get $chart_path
```

**Fallback**

```bash
helm template $chart_path |
  grep -E 'image: ' |
  awk '{print $2}' |
  tr -d '"' |
  sort -u

```
- Britle/unrelible; presumes chart author abides best practices.

NONE capture all, except when every possible conditional is properly set. Here's an example using `bitnami/wordpress` chart:

```bash
# Method 1 (native helm CLI)
☩ helm template $chart_path   --set global.enabled=true   --set tags.all=true --set memcached.enabled=true   |yq '..|.image? | select(.)' |sort -u
---
registry-1.docker.io/bitnami/mariadb:latest
registry-1.docker.io/bitnami/memcached:latest
registry-1.docker.io/bitnami/wordpress:latest

# Method 2 (plugin)
☩ helm images get .
registry-1.docker.io/bitnami/wordpress:latest
registry-1.docker.io/bitnami/wordpress:latest
registry-1.docker.io/bitnami/mariadb:latest
registry-1.docker.io/bitnami/mariadb:latest

# Fallback
☩ helm template . |grep -E 'image: ' |awk '{print $2}' |tr -d '"' |sort -u
registry-1.docker.io/bitnami/mariadb:latest
registry-1.docker.io/bitnami/wordpress:latest
```

Yet native Bash reveals image dependencies hidden from all above ...

```bash
☩ find wordpress -type f -exec /bin/bash -c '
    cat "$1" |grep "image:"
  ' _  {} \;
      image: registry-1.docker.io/bitnami/apache-exporter:latest
      image: registry-1.docker.io/bitnami/os-shell:latest
      image: registry-1.docker.io/bitnami/wordpress:latest
      image: registry-1.docker.io/bitnami/mariadb:latest
      image: registry-1.docker.io/bitnami/mysqld-exporter:latest
      image: registry-1.docker.io/bitnami/os-shell:latest
      
      ... more lines but no other actual images.
```

- These lesser-known image dependencies would be required
  (and revealed by native helm) only if we add, e.g., 
  `-f ../values-hidden-images.yaml` having:
  ```yaml
  metrics:
    enabled: true

  volumePermissions:
    enabled: true
  ```

Even so, those dependencies are ***not*** revealed by `helm dependency list`.
They rather require the subcommand of Method 1:

```bash
☩ helm template $chart_path \
  --set global.enabled=true \
  --set tags.all=true \
  --set memcached.enabled=true \
  -f ../values-hidden-images.yaml \
  |yq '..|.image? | select(.)' |sort -u
---
registry-1.docker.io/bitnami/apache-exporter:latest
registry-1.docker.io/bitnami/mariadb:latest
registry-1.docker.io/bitnami/memcached:latest
registry-1.docker.io/bitnami/os-shell:latest
registry-1.docker.io/bitnami/wordpress:latest

```

### Managing Subcharts

Example is of a simple Express (Node.js) app, in a project (`src/`) having Dockerfile and compose.yaml to allow for local development in containerized environment. See `./helm-course/_exercises/05-chart-dependencies-subcharts`

#### [`config-store`](https://github.com/lm-academy/config-store)

```bash
git clone https://github.com/lm-academy/config-store.git
cd config-store
```
```bash
☩ tree
.
├── src
│   ├── db.js
│   ├── index.js
│   ├── models.js
│   └── routes.js
├── Dockerfile
├── LICENSE
├── README.md
├── compose.yaml
├── package-lock.json
└── package.json
```
```bash
docker composes up

```

#### `./helm-course/subcharts/config-store`

```bash
helm lint .
helm template .
helm install cs .
```

```bash
☩ tree .
.
└── config-store
    ├── charts
    │   └── postgresql-16.2.2.tgz
    ├── templates
    │   ├── tests
    │   │   └── test-connection.yaml
    │   ├── NOTES.txt
    │   ├── _helpers.tpl
    │   ├── deployment.yaml
    │   ├── hpa.yaml
    │   ├── ingress.yaml
    │   ├── service.yaml
    │   └── serviceaccount.yaml
    ├── Chart.lock
    ├── Chart.yaml
    ├── README.md
    └── values.yaml
```
- Note subchart; breaking change at Postgres 16.2.2;
  must set `userPasswordFiles: false` 
  in that section of our Values.

Update and modify the root `congig-store/Chart.yaml` as desired

```bash
helm repo list
helm repo update
helm search postgree
```

`Chart.yaml`

```yaml
apiVersion: v2
name: config-store
description: A Helm chart for Kubernetes
...
dependencies:
  - name: postgresql
    version: '16.2.2'
    repository: 'https://charts.bitnami.com/bitnami'
```
- If `repository` key is missing, then helm expects the chart to be local under `charts/`.


```bash
# Pull and archive (tarball) dependencies (charts) 
helm dependency update # Updates Chart.lock per Chart.yaml; use if Chart.yaml has changed.
helm dependency build  # Reads Chart.lock; use if no changes to Chart.* .
```

```bash
helm dependency list
helm template .
```

#### Passing Values from parent to subcharts

Add subchart-named section to *parent* Values file:

@ root `values.yaml`

```yaml
...
a-subchart-name:
  a-subchart-key: "This will override value at this key in the child (subchart)  at any Values.global.a-global-key"
...
```

#### Passing Values from parent to ALL subcharts

Use Helm's `global` keyword

```yaml
...
global:
  a-global-key: "This will override value at this key in ALL children (subcharts) at any Values.global.a-global-key"
...
```

Access from templates of any/all subcharts:

```yaml
... {{ .Values.global.a-global-key }} ...
```
- Subchart must delcare the `Values.global.*`, else the local `values.yaml` is used; that of `Values.*` if exist.

#### Parent Access to Subchart Templates 

Unlike templates of Library type subcharts, 
those of **Appliation type subcharts** are accessible by parent.
However, parent template fails if its referenced subchart is missing.

```yaml
... {{ include "a-subchart-template-name.a-subchart-key" . }} ...
```

- Best practice is to declare `Values.global.*` 
  at such shared keys in all consumers; 
  in the source subchart templates too.
- Note that such usage tightens coupling between parent and sub, 
  so use sparingly or not at all.

#### Conditional Subcharts

Use Helm's `condition` keyword in `Chart.yaml`

```yaml
...
dependencies:
  - name: postgresql
    version: '18.6.0'
    condition: postgresql.enabled
    repository: 'https://charts.bitnami.com/bitnami'
```



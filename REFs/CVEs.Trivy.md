# Trivy : CVEs Scanner

Targets (what Trivy can scan):

- Container Image
- Filesystem
- Git Repository (remote)
- Virtual Machine Image
- Kubernetes
- AWS

Scanners (what Trivy can find there):

- OS packages and software dependencies in use (SBOM)
- Known vulnerabilities (CVEs)
- IaC issues and misconfigurations
- Sensitive information and secrets
- Software licenses

References:

- [GitHub](https://github.com/aquasecurity/trivy)
- [Documentaion](https://aquasecurity.github.io/trivy) 
- OCI image : [`aquasec/trivy`](https://hub.docker.com/r/aquasec/trivy)
- [Air-gapped Environment](https://aquasecurity.github.io/trivy/v0.49/docs/advanced/air-gap/)

## Install 

Binary:

```bash
mkdir -p trivy
cd trivy 

# Download/Extract the binary
ver='0.49.1'
tarball="trivy_${ver}_Linux-64bit.tar.gz"
url=https://github.com/aquasecurity/trivy/releases/download/v${ver}/$tarball
curl -LO $url && tar -xvaf $tarball

# Install it
sudo cp trivy /usr/local/bin/
```

Helm [Charts](https://aquasecurity.github.io/helm-charts/) : [Trivy Operator](https://aquasecurity.github.io/trivy-operator/latest/) : 

```bash
ver='0.20.5' # Chart; trivy v0.18.4
helm repo add trivy-operator https://aquasecurity.github.io/helm-charts/
helm install trivy trivy-operator/trivy-operator --version $ver
```
- OCI Images  
  Registry: `ghcr.io` or `docker.io`
    - `aquasecurity/trivy:0.49.1`
    - `aquasec/trivy-operator:0.18.5-ubi8-amd64`
    - `aquasecurity/node-collector`
    - `aquasecurity/trivy-db`
    - `aquasecurity/trivy-java-db`

## Use

Binary:

```bash
# Download DB updates (CVEs)
trivy image --download-db-only
# Scan cached image (pull if needed)
trivy image python:3.4-alpine
# Scan saved image (tar)
trivy image python_3.4-alpine.tar
# Scan filesystem
trivy fs --scanners vuln,secret,misconfig myproject/
# Scan K8s cluster 
trivy k8s --report summary cluster
# Generate SBOM (Software Bill of Materials)
trivy sbom /path/to/sbom_file
```

Container:

```bash
trivy=aquasec/trivy:0.49.1-amd64
target=python:3.4-alpine
mkdir -p /tmp # Persist DB-updates downloads at /tmp/trivy/
docker run -v /tmp:/root/.cache $trivy image $target 
```
- CVE updates: `/root/.cache`


Other tools:

- `kube-bench` : Test cluster security against [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes) (Kubernetes 1.24)
    - [`aquasec/kube-bench:v0.7.2-ubi-fips`](https://hub.docker.com/r/aquasec/kube-bench)
- `aqua-scanner` : Aqua Security Trivy Plugin is a premium offering designed to enhance the security of your code repositories by seamlessly integrating with Trivy. Exclusively available for Aqua Security customers, this plugin provides advanced security features beyond standard vulnerability scanning.
    - [`aquasec/aqua-scanner:v0.160.10-amd64`](https://hub.docker.com/r/aquasec/aqua-scanner)

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


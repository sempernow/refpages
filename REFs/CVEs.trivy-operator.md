# Trivy : CVEs Scanner | [Docs](https://aquasecurity.github.io/trivy/v0.52/docs/) | [Trivy image](https://hub.docker.com/r/aquasec/trivy "hub.docker.com")

## [K8s : `trivy-operator`](https://aquasecurity.github.io/trivy-operator/latest/)

The Trivy Operator automatically discovers and scans all images running in a K8s cluster, including images of application pods and system pods. Scan reports are summarized and saved as `VulnerabilityReport` (CRD) resources, which are owned by a Kubernetes controller.

### Install by Helm 

[__`trivy-operator-install.sh`__](trivy-operator-install.sh)
```bash
bash trivy-operator-install.sh

kubectl patch cm trivy-operator-trivy-config -n trivy-system \
  --type merge \
  -p "$(cat <<EOF
{
  "data": {
    "trivy.severity": "HIGH,CRITICAL"
  }
}
EOF
)"
```
- Images :
    ```plaintext
    ghcr.io/aquasecurity/trivy
    ghcr.io/aquasecurity/trivy-operator
    ghcr.io/aquasecurity/node-collector
    ghcr.io/aquasecurity/trivy-db
    ghcr.io/aquasecurity/trivy-java-db
    ```

### `VulnerabilityReport`

Scan reports saved to CRD: `kind: VulnerabilityReport`

```bash
k get vulnerabilityreports -n kube-system -o yaml \
    |yq .items[].metadata.name
```
```plaintext
daemonset-kube-router-kube-router
pod-etcd-a1-etcd
pod-kube-apiserver-a1-kube-apiserver
...
```
```bash
kn kube-system
vr=pod-kube-apiserver-a1-kube-apiserver
k get VulnerabilityReport $vr -o json \
    |jq -Mr '.report.vulnerabilities | .[]? |select(.severity == "CRITICAL" or .severity == "HIGH")' \
    |jq . --slurp

```


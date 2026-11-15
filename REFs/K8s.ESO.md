# [External Secrets Operator (ESO)](https://external-secrets.io/latest/)

External Secrets Operator reads information from a third-party service like AWS Secrets Manager 
and automatically injects the values as Kubernetes Secrets.

The External Secrets Operator (ESO) maps a secret from its source of truth to a Kubernetes Secret through a declarative, controller-driven reconciliation loop. The core mapping logic is defined in the `ExternalSecret` custom resource, which acts as a blueprint specifying **what** to fetch, **where** to put it, and **how** to keep it in sync.

```bash
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
  # --set installCRDs=false
```

Fanout one secret to apps across namespaces

             AWS Secrets Manager
              (Source of Truth) 
                  secret-1
                     |
                     |
                    ESO 
    (SecretStore, ClusterExternalSecret)
                     |
              -------|---------
              |               |
        app-1/app-1      app-2/app-2 


### 🔄 The Mapping Workflow

The mapping process follows a clear sequence managed by the ESO controller:

1.  **Store Resolution**: The controller reads the `spec.secretStoreRef` in the `ExternalSecret` to locate the appropriate `SecretStore` or `ClusterSecretStore` . This store contains the authentication details and connection info for the external provider (e.g., AWS Secrets Manager, Vault).
2.  **Data Fetching**: Using the credentials from the store, ESO connects to the external API and fetches the specific keys or properties defined in the `ExternalSecret`'s `data` or `dataFrom` sections .
3.  **Target Materialization**: ESO writes the fetched values into a standard Kubernetes `Secret` object. The name of this target Secret is determined by `spec.target.name` (defaulting to the `ExternalSecret`'s name if unspecified) .
4.  **Continuous Sync**: The operator ensures the Kubernetes Secret remains in sync with the external source based on the `refreshInterval` and `refreshPolicy` (e.g., Periodic, OnChange, or CreatedOnce) .

### 📝 Key Configuration Elements

The mapping is explicitly controlled by specific fields in the `ExternalSecret` manifest:

*   **Mapping Keys**: The `spec.data` field maps a specific external key (`remoteRef.key`) to a specific key in the Kubernetes Secret (`secretKey`). Alternatively, `spec.dataFrom` can pull entire structured objects (like JSON) or find multiple secrets based on tags .
*   **Transformation**: Before the Secret is created, ESO can transform the data using Go templates via `spec.target.template`. This is useful for reformatting data, extracting specific parts of a certificate, or injecting values into a configuration file format .
*   **Lifecycle Ownership**: The `spec.target.creationPolicy` dictates how ESO interacts with an existing Secret. The default `Owner` policy makes ESO the owner (deleting the Secret if the `ExternalSecret` is removed), while `Merge` allows ESO to inject values into a pre-existing Secret without taking ownership .

### 💡 Practical Examples

mTLS PKI

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-mtls-identity
  namespace: prod-apps
spec:
  refreshInterval: "1h" # Automatically rotates keys when they update in AWS
  secretStoreRef:
    name: aws-secretsmanager-store
    kind: SecretStore
  target:
    name: app-mtls-tls-secret # The name of the final K8s secret
    template:
      type: kubernetes.io/tls # Enforces standard K8s TLS structure
      data:
        # Mapping extracted keys into standard Kubernetes TLS filenames
        tls.crt: "{{ .cert }}"
        tls.key: "{{ .key }}"
        ca.crt: "{{ .ca }}"
  data:
  # Extracts individual fields out of a single JSON payload in AWS
  - secretKey: cert
    remoteRef:
      key: prod/mtls-identity
      property: certificate
  - secretKey: key
    remoteRef:
      key: prod/mtls-identity
      property: private_key
  - secretKey: ca
    remoteRef:
      key: prod/mtls-identity
      property: root_ca
```

At AWS SecretsManager, there is one JSON object, `prod/mtls-identity`, per set of mTLS PKI:

```json
{
  "certificate": "-----BEGIN CERTIFICATE-----\nMIICXAIBAAKCAQEA0k...\n-----END CERTIFICATE-----",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA...\n-----END RSA PRIVATE KEY-----",
  "root_ca": "-----BEGIN CERTIFICATE-----\nMIIFdzCCBFCgAwIBAg...\n-----END CERTIFICATE-----"
}
```
Each "file" is a `property` and identified/declared as such at the K8s `ExternalSecret` .

Password 

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: my-app-secret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-store
    kind: SecretStore
  target:
    name: my-app-credentials # The resulting K8s Secret name
  data:
  - secretKey: password       # Key in the K8s Secret
    remoteRef:
      key: prod/db/password   # Key in the external provider
```

In this example, ESO fetches the value at `prod/db/password` from the store `aws-store` and maps it to the key `password` inside a new Kubernetes Secret named `my-app-credentials`. Workloads can then consume this Secret using standard Kubernetes mechanisms (e.g., `envFrom` or volume mounts) .

---

The Source of Truth (SoT) for the External Secrets Operator (ESO) **cannot be arbitrary storage like an S3 bucket**. ESO is not designed to read raw files or objects from general-purpose storage; it specifically integrates with **secret management systems** through predefined Provider interfaces.

### Why S3 is Not Supported

ESO's architecture relies on a `SecretStore` resource that maps to a specific **external API** capable of returning key-value pairs or structured secret data. S3 is an object storage service, not a secret management API, and ESO does not have a built-in S3 provider to parse objects from a bucket as secrets.

### What ESO Does Support

ESO supports a curated list of dedicated secret providers. Common examples include:
*   **Cloud Secret Managers**: AWS Secrets Manager, AWS SSM Parameter Store, Google Cloud Secret Manager, Azure Key Vault.
*   **Self-Hosted & Other Tools**: HashiCorp Vault, 1Password, GitLab Variables, and generic Webhooks.

### Possible Workarounds (If You Must Use S3)

If your secrets are stored in S3, you would need to introduce an intermediary:

1.  **Use a Generic Webhook**: You could build a custom API (using a Lambda or a small service) that reads the object from S3 and returns it. You would then configure ESO's **Webhook provider** to call that API.
2.  **Migrate**: Move the secrets from S3 into a dedicated secret manager (like AWS Secrets Manager) and point ESO to that instead.

In short, while ESO is flexible, its "source of truth" must be a service that speaks the language of secrets, not just raw object storage.

---

In a highly isolated, restricted environment such as AWS `us-iso-*`, if the Certificate Authority (CA) is self-built PKI, the External Secrets Operator (ESO) can indeed be used, but the core prerequisite is: **you must explicitly configure ESO to trust this self-built CA, otherwise TLS connections will fail due to `x509: certificate signed by unknown authority`**.

In such environments, you need to address the trust issue from two levels: ESO's own operational dependencies and the external secret source it connects to.

### 🔐 Core Solution: Configure Custom CA Trust

ESO's Providers typically support injecting custom CA certificates. You need to add the CA certificate chain (PEM format) that signed the external service's certificate to the `SecretStore` or `ClusterSecretStore` configuration.

**Configuration Example (using a generic Provider structure):**

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: my-isolated-store
spec:
  provider:
    # Take vault as an example, other providers have similar caBundle/caProvider fields
    vault:
      server: "https://vault.internal.iso"
      path: "secret"
      version: "v2"
      # Method 1: Directly fill in the Base64-encoded CA certificate
      caBundle: "<Base64 encoded CA certificate>"
      # Method 2: Reference CA from ConfigMap or Secret (more recommended)
      caProvider:
        type: ConfigMap
        name: internal-ca-bundle
        key: ca.crt
        namespace: external-secrets
      auth:
        # ... authentication configuration
```

ESO official documentation explicitly mentions in multiple Provider pages (such as Passbolt, Conjur) that if the service uses a certificate signed by a private CA, it is necessary to configure the CA bundle through `caBundle` or `caProvider`.

### ☁️ Special Considerations for AWS Isolated Regions (`us-iso-*`)

If your secret source is an AWS service within the isolated region (such as Secrets Manager), in addition to the CA issue, you also need to handle **endpoint resolution**.

1.  **Custom AWS Endpoints**: AWS isolated regions use completely different endpoint addresses than standard commercial regions. ESO supports overriding default endpoints through environment variables. You need to set the following on the ESO Controller Deployment:
    *   `AWS_SECRETSMANAGER_ENDPOINT`: Point to the Secrets Manager endpoint within the isolated region.
    *   `AWS_STS_ENDPOINT`: Point to the STS endpoint within the isolated region (if IAM roles are used).
2.  **CA Trust**: AWS services within the isolated region typically also use certificates issued by internal CAs. You need to ensure that ESO's container image trusts the root CA of that region, or that the CA bundle is injected at the system level (such as mounting to `/etc/pki/tls/certs`).

### 📦 ESO's Own Deployment in Restricted Environments

In addition to connecting to external services, ESO's own installation also needs to adapt to network isolation:
*   **Image Mirroring**: ESO's Controller, Webhook, and CertController images need to be pushed to a private container registry within the isolated environment.
*   **Disable External Dependencies**: Ensure ESO's Helm Chart does not attempt to pull images or charts from the public internet.

### 💎 Summary

In `us-iso-*` environments, ESO can function normally, but it is no longer "out-of-the-box". You must explicitly inject the self-built CA certificate chain into the `SecretStore` (via `caBundle`/`caProvider`), and if using AWS native services, you also need to override the default endpoints via environment variables.

---

In an isolated environment, if PKI materials are stored in S3 out-of-band, introducing a Lambda function to bridge S3 and AWS Secrets Manager, and then letting ESO read from Secrets Manager, is a feasible architecture. This essentially adds a "secret material loading pipeline" before ESO.

### Architecture Feasibility

This approach works because it breaks down the problem into three independently controllable segments:

1. **S3 as the out-of-band PKI storage location**: The CA generates certificates/keys out-of-band and places them in S3, which is a static storage layer and does not interact directly with ESO.
2. **Lambda as the synchronization bridge**: Use S3 event notifications to trigger Lambda, which reads new objects and writes them to Secrets Manager. AWS natively supports S3 event notifications to Lambda, with event types such as `s3:ObjectCreated:Put`.
3. **Secrets Manager as ESO's source of truth**: ESO natively supports AWS Secrets Manager; you only need to configure `SecretStore` to point to the correct region and endpoint, and it can then synchronize secrets to a Kubernetes Secret.

### Key Configuration Points in Isolated Environments

In `us-iso-*` environments, there are a few additional details to note:

**Lambda trigger configuration**: In the S3 bucket notification configuration, the target ARN should point to the Lambda function within the isolated region. Lambda needs to have permission to write to Secrets Manager, and the execution role's IAM policy needs to allow `secretsmanager:PutSecretValue` (or `CreateSecret` + `PutSecretValue`).

**ESO's Secrets Manager endpoint**: Although ESO supports AWS Secrets Manager, in isolated regions you must explicitly override the default endpoint. ESO's Controller supports specifying custom endpoints through environment variables, where `AWS_SECRETSMANAGER_ENDPOINT` points to the Secrets Manager endpoint within the isolated region.

**CA trust chain**: If the Secrets Manager endpoint within the isolated region uses a certificate issued by a self-built CA, ESO's connection to Secrets Manager will still encounter TLS trust issues. You need to inject the CA bundle through the `caBundle` or `caProvider` field in `SecretStore` (if the provider supports it), or mount the CA to the system trust store path in the ESO Pod.

**Secret format**: Lambda writes PKI materials (such as certificates and private keys) to Secrets Manager. It is recommended to use JSON key-value pairs for storage, for example `{"tls.crt": "...", "tls.key": "..."}`, so that ESO's `dataFrom` or `data` mapping is more straightforward when extracting them.

### A Detail to Watch Out For

S3 event notifications may occasionally be delivered more than once, and Lambda functions should be designed to be idempotent. As long as the content written to Secrets Manager is consistent each time (overwrite rather than append), repeated triggers will not cause problems. Additionally, if the PKI file is large (for example, a complete certificate chain plus private key), be mindful of the Secrets Manager single secret size limit (64 KB), though typically PKI materials are far smaller than this limit.

In summary, this solution is reasonable in isolated environments: S3 stores the raw materials, Lambda handles the "movement" of materials, Secrets Manager provides a standardized secret interface for ESO, and ESO completes the final step of synchronizing to Kubernetes. The only additional configuration work lies in the custom endpoint and CA trust for ESO within the isolated region.
---

When using the External Secrets Operator (ESO) to inject PKI material (such as private keys, public certificates, and CA bundles) into Kubernetes, AWS Secrets Manager is the most appropriate and robust source of truth.
While SSM Parameter Store can technically hold this material, Secrets Manager is better suited for PKI data for several operational reasons.

Why AWS Secrets Manager is Preferable for PKI with ESO

1. Large Payload Capacities:
PKI material—especially full certificate chains combined with private keys—can easily bloat. AWS Secrets Manager supports secret sizes up to 64 KB. In contrast, SSM Parameter Store limits standard parameters to 4 KB, which can be easily exceeded if you are bundling multiple root/intermediate certificates together.
2. Native Multi-Key JSON Payloads:
ESO handles JSON structures natively using the SecretStore or ClusterSecretStore resources. In Secrets Manager, you can store your PKI components cleanly in a single JSON object:

```json
{
  "tls.crt": "---BEGIN CERTIFICATE---...",
  "tls.key": "---BEGIN RSA PRIVATE KEY---...",
  "ca.crt": "---BEGIN CERTIFICATE---..."
}
```

ESO can target this single AWS secret and automatically map it into a standard Kubernetes kubernetes.io/tls secret. Doing this in SSM Parameter Store requires creating multiple hierarchical parameters (e.g., `/pki/tls.crt /pki/tls.key`), resulting in multiple ESO trackers and more complex configurations.
3. Auditability and Strict Lifecycle Control:
PKI assets are high-value targets. Secrets Manager provides detailed AWS CloudTrail logging down to the specific secret version, making it easier to track exactly when and who accessed a private key before it was synced to your cluster.

How ESO Maps the Secrets Manager Source of Truth

When configuring ESO, you define an ExternalSecret that pulls directly from the Secrets Manager JSON payload. This ensures your cluster treats AWS as the immutable source of truth:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: institutional-pki
spec:
  refreshInterval: "1h" # Automatically pulls updated certs if they renew in AWS
  secretStoreRef:
    name: aws-secretsmanager-store
    kind: SecretStore
  target:
    name: cluster-tls-secret # The resulting native Kubernetes Secret
    template:
      type: kubernetes.io/tls # Correct K8s type for PKI
  data:
    - secretKey: tls.crt
      remoteRef:
        key: prod/app/pki # Name of your AWS Secrets Manager Secret
        property: tls.crt
    - secretKey: tls.key
      remoteRef:
        key: prod/app/pki
        property: tls.key
```

The Alternative: AWS Certificate Manager (ACM)

If you are looking for a service that actually generates and manages the lifecycle of the PKI material (rather than just storing it), AWS Private CA combined with AWS Certificate Manager (ACM) is the actual source of truth for AWS-native PKI.

However, because ESO's primary job is mapping raw key/value pairs to Kubernetes secrets, AWS Secrets Manager remains the intermediate "storage" source of truth that bridges raw PKI files to the External Secrets Operator seamlessly.

IAM Policy configuration is required to safely grant the External Secrets Operator access to that specific PKI secret in AWS, else use ESO's native integration with ACM directly.


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

# `aws` v2 CLI

## EKS

```bash
# Get kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name> --dry-run

# List clusters
aws eks list-clusters --region <region>

# Describe cluster
aws eks describe-cluster --region <region> --name <cluster-name>

# Manage node groups
aws eks list-nodegroups --region <region> --cluster-name <cluster-name>

# Scale Node Group
aws eks update-nodegroup-config --region <region> --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --scaling-config minSize=2,maxSize=5,desiredSize=3 

# List Add-ons
aws eks list-addons --region <region> --cluster-name <cluster-name>

# Describe Add-ons
aws eks describe-addon-versions --kubernetes-version <version>

# List Access / IAM
aws eks list-access-entries --region <region> --cluster-name <cluster-name>

# List OIDC Provider 
aws eks describe-cluster --region <region> --name <cluster-name> --query
"cluster.identity.oidc.issuer" --output text
```

## KMS

```bash
# Create symmetric key
aws kms create-key --description "My secure master key" --key-usage ENCRYPT_DECRYPT --customer-master-key-spec SYMMETRIC_DEFAULT

# Create alias
aws kms create-alias --alias-name alias/my-app-key --target-key-id <key-id-or-arn>  

aws kms list-keys

aws  kms list-aliases

# Encrypt to binary blob
aws kms encrypt --key-id alias/my-app-key --plaintext fileb://plaintext.txt --output text --query CiphertextBlob > ciphertext.bin

# Encrypt to base64 (PEM)
aws kms encrypt \
  --key-id alias/my-app-key \
  --plaintext fileb://plaintext.txt \
  --query CiphertextBlob \
  --output text > ciphertext.pem

# Decrypt if binary blob
aws kms decrypt --ciphertext-blob fileb://ciphertext.bin --output text --query Plaintext | base64 --decode > decrypted.txt

# Decrypt if base64-encoded
aws kms decrypt \
  --ciphertext-blob fileb://<(base64 -d ciphertext.pem) \
  --query Plaintext \
  --output text | base64 -d

# Enable annual automatic rotation:
aws kms enable-key-rotation --key-id <key-id-or-arn>   

# Disable key rotation:
aws kms disable-key-rotation --key-id <key-id-or-arn>

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

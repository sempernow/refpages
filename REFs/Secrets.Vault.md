## Hashicorp (IBM) [Vault](https://developer.hashicorp.com/vault)

## [JWT](https://developer.hashicorp.com/vault/docs/auth/jwt "hashicorp.com") AuthN Method

The jwt auth method can be used to authenticate with Vault using OIDC or by providing a JWT.

### [Use HashiCorp Vault secrets in GitLab CI/CD](https://docs.gitlab.com/ci/secrets/hashicorp_vault/)


```bash
# Enable JWT method for environment having multiple OIDC issuers (apps)
issuer=jwt-gitlab
vault auth enable -path=$issuer jwt

# Configure Vault JWT AuthN method to trust gitlab.lime.lan
origin=https://gitlab.lime.lan
vault write auth/$issuer/config \
   oidc_discovery_url="$origin" \
   bound_issuer="$origin"

# Create a Role in Vault for GitLab Pipelines
# This role defines which GitLab project (or group) can authenticate and what policy to assign.
role=gitlab-ci-role
policy=gitlab-ci-policy
namespace=group-1/sub-2 # Scope to group, group/subgrp, or narrower still .../project
vault write auth/$issuer/role/$role \
   role_type="jwt" \
   user_claim="namespace" \
   bound_claims='{"namespace": "'$namespace'"}' \
   policies="$policy" \
   ttl="1h"

# Create a policy : gitlab-ci-policy.hcl
path "kv/data/gitlab/*" {
   capabilities = ["read"]
}

# Write policy
vault policy write gitlab-ci-policy gitlab-ci-policy.hcl

# Create secret in Vault
vault kv put kv/gitlab/group-1 $key=$value

```

@ `.gitlab-ci.yml`

```yaml
variables:
  VAULT_ADDR: "https://vault.lime.lan"

get-secrets:
  stage: prepare
  image: curlimages/curl:latest
  script:
    - echo "Verifying JWT..."
    - echo $CI_JOB_JWT |cut -d '.' -f2 |base64 -d |jq .
    - echo "Fetching Vault token using JWT..."
    - export VAULT_TOKEN=$(curl --request POST --data "{\"jwt\":\"$CI_JOB_JWT\",\"role\":\"gitlab-pipeline-role\"}" $VAULT_ADDR/v1/auth/jwt-gitlab/login |jq -Mr '.auth.client_token')
    - echo "Reading secret..."
    - curl -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/kv/data/gitlab/group-1 |jq -Mr .data.data.API_KEY

```

### [Vault authentication with GitLab OpenID Connect](https://docs.gitlab.com/integration/vault/ "docs.gitlab.com")

OIDC with OAuth2 Client Credentials (requires GitLab config); 
OpenID Connect client ID and secret from GitLab

## [AppRole](https://developer.hashicorp.com/vault/docs/auth/approle "hashicorp.com") AuthN Method

The AppRole role, policy, RoleID and SecretID are obtained from API, 
authenticating with personal token.


### Via API 

```bash
origin=https://vault.lime.lan:8200
name=approle-01
tkn='...' # Personal root_token from Vault web UI 

# Enable AppRole auth method
curl -sfX POST \
   -H "X-Vault-Token: $tkn" \
   --data '{"type": "approle"}' \
   $origin$/v1/sys/auth/approle

# Create an AppRole having policy/ies
curl -sfX POST \
   -H "X-Vault-Token: $tkn" \
   -d '{"policies": ["dev-policy","test-policy"], "token_type": "service"}' \
   $origin/v1/auth/approle/role/$name

# Fetch RoleID 
curl -sfX GET \
   -H "X-Vault-Token: $tkn" \
   $origin/v1/auth/approle/role/$name/role-id

# Create new SecretID
curl -sfX POST \
   -H "X-Vault-Token: $tkn" \
   $origin/v1/auth/approle/role/$name/secret-id

# Login using AppRole roleID (user) and secretID (pass)
client_token="$(curl -sX POST \
      -d '{"role_id":"'$roleID'","secret_id":"'$secretID'"}' \
      $origin/v1/auth/approle/login \
      |jq -Mr .auth.client_token
)"

# Read secret using client_token
secret_path=$team/$env/$app/$key # team-a/prod/postgres/role-3/schema-2
curl -sX GET \
    -H "X-Vault-Token: $client_token" \
    $origin$/v1/kv/data/$secret_path
```


### Via CLI | [Configure Environment Variables](https://developer.hashicorp.com/vault/docs/commands#configure-environment-variables "developer.hashicorp.com")

```bash
name=approle-01
# Enable AppRole auth method
vault auth enable approle

# Create named role
vault write auth/approle/role/$name$ \
    token_type=batch \
    secret_id_ttl=10m \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40

# GET RoleID
vault read auth/approle/role/$name$/role-id

# GET SecretID
vault write -f auth/approle/role/$name/secret-id
```

## [Read Secrets](https://developer.hashicorp.com/vault/docs/auth/approle) from Vault

```bash
# Read secret using client_token
secret_path=a/b/c/d
# secret_path=team-a/prod/postgres/role-3/schema-2
# secret_path=ops/ldap/sa/keycloak
curl -sX GET \
    -H "X-Vault-Token: $client_token" \
    $origin$/v1/kv/data/$secret_path
```

## Use Secret in K8s


Pod 

```yaml
apiVersion: v1
kind: Pod
...
spec:
  containers:
    - name: test-container
      image: <image_name>
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - secretRef:
          name: auth-secret
```

Secret 

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: auth-secret
type: Opaque
data:
  VAULT_APPROLE_ROLE_ID: <role_id>
  VAULT_APPROLE_SECRET_ID: <secret_id>
```

## Raft Storage 

A built-in storage backend for HashiCorp Vault that uses the **Raft consensus algorithm** to provide a highly available and consistent storage solution. It allows Vault to manage its own storage without relying on an external storage backend like Consul, etcd, or DynamoDB. Raft is particularly useful for small to medium-sized deployments where simplicity and self-management are desired.

Raft storage is integrated directly into Vault, meaning you don't need to set up an external storage backend (e.g., Consul) for Vault to operate in HA mode, where multiple Vault servers form a cluster and elect a leader to handle requests. If the leader fails, a new leader is automatically elected.


- **Storage Location**:
   - The actual data stored by Raft (e.g., secrets, policies, tokens) is written to disk on each Vault server in the cluster.
   - The data is stored in a directory specified in the Vault configuration file (e.g., `/vault/data`).
- **Configuration**:
   - Raft storage is enabled by specifying the `raft` storage backend in Vault's configuration file.
   - Each Vault server in the cluster must be configured to use Raft storage and point to the same cluster.
- **Cluster Formation**:
   - When you initialize the Vault cluster, the first node becomes the leader.
   - Additional nodes join the cluster by specifying the address of an existing node in the cluster.

By using Raft storage, you can simplify your Vault deployment while maintaining high availability and data consistency.

### Example Configuration

Here’s an example of how to configure Raft storage in Vault's configuration file (`config.hcl`):

```hcl
storage "raft" {
  path    = "/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/path/to/cert.pem"
  tls_key_file  = "/path/to/key.pem"
}

cluster_addr = "https://node1.example.com:8201"
api_addr     = "https://node1.example.com:8200"
```

- **`path`**: The directory where Raft will store its data.
- **`node_id`**: A unique identifier for the node in the Raft cluster.
- **`cluster_addr`**: The address and port used for cluster communication.
- **`api_addr`**: The address and port used for client requests.

---

### **Key Features of Raft Storage**
1. **Self-Managed**: No need for an external storage backend.
2. **High Availability**: Automatically handles leader election and failover.
3. **Data Replication**: Ensures data is replicated across all nodes in the cluster.
4. **Scalability**: Suitable for small to medium-sized deployments.

---

### **How to Use Raft Storage**
1. **Initialize the Cluster**:
   - Start the first Vault server with Raft storage enabled.
   - Initialize the cluster using `vault operator init`.

2. **Join Additional Nodes**:
   - Start additional Vault servers with the same Raft configuration.
   - Use `vault operator raft join` to add them to the cluster.

3. **Verify the Cluster**:
   - Use `vault operator raft list-peers` to check the status of the cluster.

---

### **When to Use Raft Storage**
- You want a simple, self-managed storage solution.
- You don’t want to rely on external dependencies like Consul or etcd.
- You need high availability and data replication for a small to medium-sized deployment.

---

### **Limitations**
- Raft is not designed for very large-scale deployments (e.g., thousands of nodes).
- It requires careful management of disk space, as all data is stored on each node.


## TLS : [Vault](https://developer.hashicorp.com/vault) + [Consul](https://developer.hashicorp.com/consul)  

A Vault cluster that uses Consul for storage or as a service discovery mechanism typically requires __two sets of TLS__ keys/certificates:

1. For securing Vault's API endpoints.
2. For securing communication between Vault and Consul.

Both sets are critical for maintaining a secure and trusted environment.


1. **Vault's TLS Certificates**:
   - These are used to __secure communication between clients and Vault's API__ servers.
   - Vault uses TLS to encrypt HTTP traffic, ensuring that data transmitted between clients and the Vault cluster is secure.
   - These certificates are configured in Vault's configuration file (e.g., `listener "tcp"` block) and are used for the Vault API endpoints.

2. **Consul's TLS Certificates**:
   - These are used to __secure communication between Vault and Consul__.
   - If Consul is being used as the storage backend or for service discovery, Vault needs to communicate with Consul securely. This requires TLS certificates to encrypt and authenticate the communication between Vault and Consul.
   - These certificates are configured in Vault's configuration file (e.g., `storage "consul"` block) and are used for Vault to interact with Consul.

### Why Two Sets of Certificates?
- **Vault's TLS Certificates**: Ensure that clients can securely communicate with Vault.
- **Consul's TLS Certificates**: Ensure that Vault can securely communicate with Consul, especially if Consul is acting as the storage backend or service discovery mechanism.

### Configuration Example:
#### Vault's TLS Configuration:
```hcl
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/path/to/vault.crt"
  tls_key_file  = "/path/to/vault.key"
}
```

#### Consul's TLS Configuration in Vault:
```hcl
storage "consul" {
  address = "127.0.0.1:8500"
  scheme  = "https"
  tls_ca_file = "/path/to/consul-ca.crt"
  tls_cert_file = "/path/to/consul.crt"
  tls_key_file  = "/path/to/consul.key"
}
```

### Vault/Consul PKI : [How To](https://chatgpt.com/share/67cb4678-4754-8009-8410-1de5c45689b0)

### &nbsp;
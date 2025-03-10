## Hashicorp (IBM) [Vault](https://developer.hashicorp.com/vault)

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
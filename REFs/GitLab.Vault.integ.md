# GitLab-Vault Ingetration  

GitLab integrates with **~~HashiCorp~~ IBM Vault** to securely fetch secrets during CI/CD pipelines using **JWT authentication**, 
which is secure and designed for that environment. This approach provides:

- **No service accounts or OIDC providers are required** for GitLab-Vault integration using JWT authentication.
- GitLab generates JWTs for CI/CD jobs, and Vault validates these JWTs using GitLab's public key.
- This approach is **simple, secure, and self-contained**, leveraging GitLab's built-in capabilities and Vault's JWT auth method.

## Features:

- **Short-Lived Tokens**:
   - The JWT and Vault token are short-lived, reducing the risk of misuse if compromised.
- **Fine-Grained Access Control**:
   - Vault policies allow you to restrict access to specific secrets based on GitLab metadata (e.g., project path, branch/tag).
- **No Long-Term Credentials**:
   - Unlike storing a private key in a CI/CD variable, JWT authentication does not require long-term credentials.
- **Dynamic Secrets**:
   - Vault can generate dynamic secrets (e.g., database credentials) that are automatically revoked after use.
- **Audit Logging**:
   - Vault provides detailed audit logs of all secret access, making it easier to monitor and detect unauthorized access.
- **Centralized Secret Management**:
   - Secrets are stored in Vault, not in GitLab, reducing the risk of accidental exposure.


### How GitLab Authenticates Against Vault

GitLab uses the **JWT (JSON Web Token)** authentication method to authenticate with Vault. 
This method is secure and specifically designed for CI/CD environments. Here's how it works:

---

#### 1. **JWT Authentication Flow**
   - **Step 1: GitLab Generates a JWT**:
     - When a CI/CD job runs, GitLab automatically generates a short-lived JWT for the job.
     - The JWT contains claims about the job, such as:
       - `namespace_path`: The GitLab group or project namespace.
       - `project_path`: The project path.
       - `pipeline_id`: The pipeline ID.
       - `job_id`: The job ID.
       - `ref`: The Git ref (branch or tag).
       - Other metadata.

   - **Step 2: GitLab Passes the JWT to Vault**:
     - The CI job uses the JWT to authenticate with Vault by sending it to Vault's `/auth/jwt/login` endpoint.

   - **Step 3: Vault Validates the JWT**:
     - Vault validates the JWT using GitLab's public key (configured in Vault).
     - Vault checks the JWT's claims to ensure it matches the expected values (e.g., project path, ref).

   - **Step 4: Vault Issues a Token**:
     - If the JWT is valid, Vault issues a short-lived token to the CI job.
     - This token has permissions defined by Vault policies.

   - **Step 5: CI Job Fetches Secrets**:
     - The CI job uses the Vault token to fetch secrets from Vault.

---

#### 2. **Vault Configuration for GitLab JWT Authentication**
   To enable JWT authentication in Vault:
   - **Step 1: Enable the JWT Auth Method**:
     ```sh
     vault auth enable jwt
     ```
   - **Step 2: Configure GitLab as a JWT Provider**:
     ```sh
     vault write auth/jwt/config \
       jwks_url="https://<gitlab-domain>/-/jwks" \
       bound_issuer="<gitlab-domain>"
     ```
     - Replace `<gitlab-domain>` with your GitLab instance's domain (e.g., `gitlab.com`).

   - **Step 3: Create a Role for GitLab CI Jobs**:
     Define a role that maps GitLab projects or namespaces to Vault policies:
     ```sh
     vault write auth/jwt/role/gitlab-ci \
       role_type="jwt" \
       bound_claims='{"project_path": "my-group/my-project", "ref": "main"}' \
       user_claim="project_path" \
       policies="gitlab-ci-policy" \
       ttl="1h"
     ```
     - `bound_claims`: Restricts access based on GitLab metadata (e.g., project path, branch/tag).
     - `policies`: Specifies the Vault policies to attach to the token.

   - **Step 4: Define Vault Policies**:
     Create a policy that grants access to specific secrets:
     ```sh
     vault policy write gitlab-ci-policy - <<EOF
     path "secret/data/my-app/*" {
       capabilities = ["read"]
     }
     EOF
     ```

---

### Example GitLab CI Job Using Vault

Here’s how you can fetch secrets from Vault in a GitLab CI job:

```yaml
stages:
  - fetch_secrets

fetch_secrets:
  stage: fetch_secrets
  script:
    - apk add vault jq  # Install Vault CLI and jq
    - export VAULT_TOKEN=$(vault write -field=token auth/jwt/login role=gitlab-ci jwt=$CI_JOB_JWT)
    - export DATABASE_PASSWORD=$(vault kv get -field=password secret/data/my-app/database)
    - echo "Database password: $DATABASE_PASSWORD"
```


When using **JWT authentication** for GitLab CI/CD pipelines with HashiCorp Vault, 
**no service accounts or OIDC providers are required**. 
The authentication process relies entirely on GitLab's built-in JWT capabilities and Vault's JWT auth method. 
Here's why this approach is unique and why it doesn't require additional components like service accounts or OIDC providers:


### Why No Service Accounts or OIDC Providers Are Needed

- **GitLab as the JWT Issuer**:
   - GitLab acts as the **JWT issuer** and generates JWTs for CI/CD jobs automatically.
   - These JWTs are signed using GitLab's private key, and Vault validates them using GitLab's public key (available via the `jwks_url`).
- **No External Identity Provider**:
   - Unlike OIDC (OpenID Connect), which relies on an external identity provider (e.g., Google, AWS IAM), GitLab's JWT authentication is self-contained.
   - GitLab itself provides the necessary identity information (e.g., project path, branch, job ID) in the JWT.
- **No Long-Term Credentials**:
   - Service accounts typically require long-term credentials (e.g., API keys, tokens), which can be a security risk if not managed properly.
   - With GitLab's JWT authentication, the JWT is short-lived and automatically generated for each CI/CD job, eliminating the need for long-term credentials.
- **Direct Integration**:
   - The integration between GitLab and Vault is direct and does not require an intermediary like an OIDC provider.
   - GitLab's JWT is passed directly to Vault for authentication.

---

### How It Works Without Service Accounts or OIDC

- **GitLab Generates a JWT**:
   - For every CI/CD job, GitLab generates a JWT containing metadata about the job (e.g., `project_path`, `ref`, `job_id`).
- **Vault Validates the JWT**:
   - Vault uses GitLab's public key (fetched from the `jwks_url`) to validate the JWT's signature.
   - Vault also checks the JWT's claims (e.g., `project_path`, `ref`) to ensure the job is authorized to access the requested secrets.
- **Vault Issues a Token**:
   - If the JWT is valid, Vault issues a short-lived token with permissions defined by Vault policies.
- **CI Job Fetches Secrets**:
   - The CI job uses the Vault token to fetch secrets.

---

### Comparison with OIDC and Service Accounts

| Feature                     | GitLab JWT Authentication               | OIDC Authentication                  | Service Accounts                     |
|-----------------------------|----------------------------------------|--------------------------------------|--------------------------------------|
| **Identity Provider**       | GitLab (built-in)                      | External OIDC provider (e.g., Google)| N/A                                  |
| **Credentials**             | Short-lived JWT                        | OIDC token                           | Long-term API keys/tokens            |
| **Integration Complexity**  | Simple (direct GitLab-Vault integration)| Requires OIDC provider configuration | Requires managing service accounts   |
| **Security**                | High (short-lived tokens, no long-term credentials) | High (short-lived tokens)            | Medium (requires careful management of long-term credentials) |

---

### Example: GitLab CI Job with Vault (No OIDC or Service Accounts)

Here’s how you can fetch secrets from Vault in a GitLab CI job using JWT authentication:

```yaml
stages:
  - fetch_secrets

fetch_secrets:
  stage: fetch_secrets
  script:
    - apk add vault jq  # Install Vault CLI and jq
    - export VAULT_TOKEN=$(vault write -field=token auth/jwt/login role=gitlab-ci jwt=$CI_JOB_JWT)
    - export DATABASE_PASSWORD=$(vault kv get -field=password secret/data/my-app/database)
    - echo "Database password: $DATABASE_PASSWORD"
```

---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

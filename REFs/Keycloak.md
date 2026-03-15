# Keycloak : [Server Admin Guide](https://www.keycloak.org/docs/latest/server_admin/index.html "keycloak.org") | [App Documentation](https://www.keycloak.org/documentation)


## SSO 
Keycloak bridges the gap between a legacy enterprise directory (AD) 
and the modern authentication protocols required by cloud-native applications.

In an environment having Linux hosts joined into domain having AD DC, the `realmd/sssd` setup authenticates *who* can access the Linux *hosts*, 
while Keycloak authenticates *who* can access the *applications* running on the Kubernetes cluster within those hosts.

Here's a detailed breakdown of why Keycloak is essential in that specific architecture.

### 1. Protocol Translation: From LDAP/Kerberos to OIDC/SAML

Your applications running inside Kubernetes (like dashboards, monitoring tools, or custom microservices) 
rarely speak LDAP or Kerberos directly. They expect modern, web-friendly standards like **OpenID Connect (OIDC)** or **SAML**.

*   **The Gap**: Your AD speaks LDAP and Kerberos. Your apps speak OIDC and SAML. They don't understand each other.
*   **Keycloak's Role**: Keycloak acts as a **protocol translator** or a **federation hub** . It connects to your AD via LDAP to verify user identities and fetch group memberships. Then, it presents those users to your applications using OIDC or SAML. This is often called **user federation** .

Think of it this way:
*   **Without Keycloak**: Every application in your cluster would need to be individually configured to understand LDAP, which is complex, less secure, and often not supported.
*   **With Keycloak**: You configure your app once to trust Keycloak (via OIDC). Keycloak handles the complexity of talking to AD.

### 2. Centralized Authentication & Single Sign-On (SSO) for Cluster Apps

With Keycloak acting as the broker, you enable a seamless user experience across all your internal tools.

*   **Scenario**: A developer wants to check the Kubernetes Dashboard, then view logs in Grafana, and finally check a metric in Prometheus.
*   **Without Keycloak**: They might need to log in separately to each service, potentially with different credentials.
*   **With Keycloak**: They authenticate once against Keycloak (which trusts their AD credentials), 
    and they are automatically logged in to **all connected applications** (Grafana, Kibana, the k8s dashboard, etc.) . 
    This is the power of SSO.

### 3. Enabling Kubernetes RBAC with External Users

To control who can do what in your cluster (e.g., `view`, `edit`, `admin`), Kubernetes needs to know who the users are. It doesn't have a user database of its own. Keycloak can be the source of this information.

*   You can configure your kubeadm cluster to trust Keycloak as an OIDC identity provider .
*   **The Process**:
    1.  A user authenticates with their AD credentials via Keycloak.
    2.  Keycloak issues a token containing their identity and group memberships (synced from AD).
    3.  When that user runs `kubectl`, the token is presented to the Kubernetes API server.
    4.  Kubernetes validates the token with Keycloak and uses the information (like group membership) to apply **RBAC (Role-Based Access Control)** policies you've defined .

This means your cluster's permissions map directly to your existing AD groups, without ever syncing AD users directly to the cluster.

### 4. Air-Gap Specific Advantages: Feature Richness Without Internet

In an air-gapped environment, you cannot rely on public identity providers (like Google or GitHub). 
Keycloak provides a comprehensive, self-contained IAM solution that is perfectly suited for this scenario .

As highlighted in the comparison table below, Keycloak offers features that are critical for an air-gapped environment but go far beyond simple LDAP binding.

| Feature | Why Grafana's AD/LDAP Integration Alone Falls Short | How Keycloak Fills the Gap in Your Air-Gapped Cluster |
| :--- | :--- | :--- |
| **Authentication Protocol** | Only LDAP. Most cloud-native apps (e.g., Kubernetes Dashboard, ArgoCD) don't support it. | Acts as a broker, speaking **OIDC/SAML** to apps and LDAP to your AD . |
| **User & Group Sync** | Grafana queries AD in real-time for each login. It doesn't store user info locally. | **Synchronizes users and groups** from AD into its own database, enabling features like local roles and offline authorization . |
| **Authorization Policies** | Relies solely on AD groups. Limited flexibility. | Allows you to define fine-grained **roles, permissions, and even attribute-based access control (ABAC)** within Keycloak, which can be independent of AD group structure . |
| **Multi-Factor Auth (MFA)** | Depends entirely on AD's MFA capabilities, which may be limited or not enforced. | Can enforce its own MFA (e.g., TOTP with Google Authenticator) even if AD doesn't require it . Critical for securing access in a sensitive environment. |
| **Management & Audit** | No centralized UI. User management happens in AD; app access is managed per app. | Provides a unified **admin UI and REST API** to manage users, roles, and sessions across all your applications. Offers built-in **audit logs** for compliance . |

### Summary: A Layered Security Model

In your air-gapped kubeadm cluster, you are effectively building a layered security model:

1.  **Infrastructure Layer (The Hosts)**: Your RHEL hosts are joined to AD via `realmd` and `sssd`. This controls who can SSH into the servers themselves—the underlying infrastructure.
2.  **Application Layer (The Cluster)**: Keycloak, deployed *inside* your Kubernetes cluster, integrates with the same AD. This controls who can access the applications and APIs running *on top* of that infrastructure.

Without Keycloak, your applications are isolated from your identity management system. With it, you create a seamless, secure, and standards-based bridge that brings your AD users into your cloud-native world.

Would you like to discuss the high-level steps for deploying Keycloak in your air-gapped cluster or how to configure it as an OIDC provider for Kubernetes?

---


### User Federation

User federation allows Keycloak to connect to external user databases, such as __LDAP__ or __Active Directory__, enabling __authentication and user data synchronization__ without migrating existing user data into Keycloak. This feature is essential for organizations that maintain centralized user directories and wish to leverage Keycloak for authentication and authorization.

### [Configuring User Federation](https://www.keycloak.org/docs/latest/server_admin/index.html#_ldap)

To set up user federation in Keycloak:

1. **Access the Admin Console**: Log in to the Keycloak Admin Console.
2. **Navigate to User Federation**: In the left-hand menu, click on "User Federation."
3. **Add a Provider**: Click on "Add provider" and select the type of external user store you wish to integrate, such as LDAP or Kerberos.
4. **Configure Connection Settings**: Provide the necessary connection details, including connection URL, bind DN, and credentials.
5. **Set Synchronization Options**: Choose synchronization settings to control how and when user data is synced between Keycloak and the external store.
6. **Define Mappers**: Configure mappers to map attributes from the external user store to Keycloak's user model.([Keycloak][2], [Keycloak][3], [Keycloak][1])

For detailed guidance on each of these steps, refer to the [Keycloak Server Administration Guide](https://www.keycloak.org/docs/latest/server_admin/index.html).([Keycloak][1])

### Advanced Configuration and Custom Providers

If your organization uses a custom user store or requires advanced integration, Keycloak offers the User Storage SPI (Service Provider Interface). This allows developers to implement custom providers to connect Keycloak with virtually any external user database. The [Keycloak Server Developer Guide](https://www.keycloak.org/docs/latest/server_development/index.html) provides in-depth information on creating and deploying custom user storage providers.([Keycloak][3], [Keycloak][1])

### Additional Resources

* **Keycloak Documentation Overview**: Explore all available guides and references at the [Keycloak Documentation page](https://www.keycloak.org/documentation).
* **Keycloak Admin REST API**: For programmatic management of user federation and other configurations, consult the [Keycloak Admin REST API documentation](https://www.keycloak.org/docs-api/latest/rest-api/index.html).([Keycloak][4], [Keycloak][5])

If you need assistance with specific configurations, such as setting up LDAP synchronization or creating custom mappers, feel free to ask!

[1]: https://www.keycloak.org/docs/latest/server_admin/index.html?utm_source=chatgpt.com "Server Administration Guide - Keycloak"
[2]: https://www.keycloak.org/securing-apps/token-exchange?utm_source=chatgpt.com "Configuring and using token exchange - Keycloak"
[3]: https://www.keycloak.org/docs/latest/server_development/index.html?utm_source=chatgpt.com "Server Developer Guide - Keycloak"
[4]: https://www.keycloak.org/documentation?utm_source=chatgpt.com "Documentation - Keycloak"
[5]: https://www.keycloak.org/docs-api/latest/rest-api/index.html?utm_source=chatgpt.com "Keycloak Admin REST API"


Correct — the **Storage SPI is not for storing AD DS user data** retrieved via LDAP synchronization.

### 🔍 Clarification:

#### ✅ When You Use Built-in LDAP User Federation:

Keycloak **does not store user data in its internal database** after LDAP sync (unless you explicitly enable "import"). Instead, it **queries the external store (e.g., AD DS)** on-demand via LDAP unless configured otherwise. This is the **default user federation model**, and it uses a built-in LDAP provider — **you do *not* need the Storage SPI** to use this.

> You configure this via **User Federation → Add provider → ldap** in the Admin UI.

#### 🛠️ The **Storage SPI** is for:

Creating **custom providers** to integrate with **non-standard or unsupported user stores**, such as:

* A legacy SQL database
* A flat file system
* A REST API for user authentication
* Custom LDAP variants with special behavior

You'd implement Storage SPI if:

* The external user source is *not LDAP or Kerberos*
* You need *custom mapping logic*
* You want to integrate with a backend that doesn't have a built-in provider in Keycloak

### ✅ TL;DR

| Use Case                                | Use Built-in Federation (e.g. LDAP) | Use Storage SPI |
| --------------------------------------- | ----------------------------------- | --------------- |
| AD DS over LDAP                         | ✅ Yes                               | ❌ No            |
| Custom SQL or REST-based user store     | ❌ No                                | ✅ Yes           |
| LDAP but need complex/unsupported logic | ⚠️ Maybe                            | ✅ Possibly      |
| You want to cache or import users       | ✅ Yes (with Import option)          | ❌ Not SPI’s job |

Let me know if you'd like a sample configuration for Keycloak's LDAP provider or an example Storage SPI plugin.


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

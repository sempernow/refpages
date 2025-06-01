# Keycloak : [Server Admin Guide](https://www.keycloak.org/docs/latest/server_admin/index.html "keycloak.org") | [App Documentation](https://www.keycloak.org/documentation)

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

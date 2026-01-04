# Active Directory (AD) : AD Federated Services (ADFS) : Linux Integration

## [Active Directory [AD] [AD FS] : Linux Integration [Keycloak] : Group Management](https://chatgpt.com/share/73401243-5ea0-4cdc-9090-d6dd709ada10?oai-dm=1)

>A group may be created using some federated authentication scheme such as Active Directory, affecting many machines of a domain, for which the command "`sudo usermod -aG $group $user`" does not work. How is such a group created on each machine thereof?

In environments where Active Directory (AD) or other types of federated authentication systems are used, group management is typically centralized rather than handled on each individual machine. Here’s how the process generally works:

1. Centralized Group Management

    Groups are managed centrally within Active Directory. This means you create, modify, and delete groups directly in the AD domain controller, not on individual machines. This centralized management approach allows changes to be propagated automatically to all machines within the domain that are connected to AD.

2. Group Creation in Active Directory

    To create a group in Active Directory:

    &vellip;&nbsp;

&nbsp;&vellip;&nbsp;

>Is there a favored software package for this on RHEL 8/9 machines?
ChatGPT

For RHEL (Red Hat Enterprise Linux) 8 and 9, the preferred method for integrating with Active Directory is using SSSD (System Security Services Daemon). SSSD provides a set of daemons to manage access to remote directories and authentication mechanisms. It also enhances the system's integration with various identity and authentication providers like Active Directory, LDAP, Kerberos, and others.

&vellip;&nbsp;


```bash
sudo dnf install -y sssd realmd oddjob oddjob-mkhomedir adcli samba-common-tools
```

* @ `/etc/pam.d/common-session`
    ```conf
    session optional pam_mkhomedir.so skel=/etc/skel umask=0077
    ```

&vellip;&nbsp;


>Is there a preferred way to integrate this into K8s to provide  SSO capability to web services?


Integrating Single Sign-On (SSO) capability into Kubernetes (K8s) for web services, particularly those authenticated through Active Directory (AD), involves several components. These are typically focused on using open standards like SAML, OpenID Connect (OIDC), or OAuth. Here are the general steps and technologies you might use to achieve this:

1. Kubernetes Authentication

Kubernetes itself doesn't handle user authentication at the application level directly. Instead, it relies on external identity providers (IdPs). For AD, this often means using a solution that can interface with OIDC or SAML.

2. Choosing an Identity Provider (IdP) for Active Directory:

    - **Active Directory Federation Services** (AD FS): This is a Windows Server role that **provides SSO capabilities** and can be used to set up a federation with your Kubernetes clusters using **SAML** or **OIDC**.
    - Azure Active Directory: If you're using Azure, you can integrate Azure AD with Kubernetes, which supports OIDC natively.
    - Third-Party **IdPs**: Tools like **Okta**, **Auth0**, or **Keycloak** can integrate with AD and provide OIDC or SAML tokens to Kubernetes.

&vellip;&nbsp;

In your scenario, where most applications are running on Kubernetes or Linux while Active Directory (AD) and Microsoft's certificate server run on Windows, using Keycloak in addition to AD can be advantageous over AD FS alone. Here’s why:

&vellip;&nbsp;

## [AD to K8s Integration Guide : ADFS [OIDC/Backend of IdP] to Dex [IdP] to OAuth2 Proxy to Apps](https://chatgpt.com/share/86673db4-299c-4f5d-8c0b-51bfa6e1ba5f)


To implement user authentication for applications running on a Kubernetes cluster using Active Directory (AD) as the authentication mechanism, you can use a combination of Kubernetes-native and external tools to integrate with AD. Here’s a comprehensive approach:

1. Integrate Kubernetes with Active Directory  
   Use **OpenID Connect** (OIDC)

    1. Configure Active Directory Federation Services (AD FS):  
        Set up AD FS to act as an OpenID Connect provider.
        Register your Kubernetes API server as a relying party (RP) or client in AD FS.

    2. Configure Kubernetes API Server:  
        Set the OIDC flags on the API server to use AD FS as the identity provider:
        ```yaml
        --oidc-issuer-url=https://your-adfs-server/adfs
        --oidc-client-id=your-kubernetes-client-id
        --oidc-username-claim=name
        --oidc-groups-claim=groups
        ```

    3. Install and Configure Dex:  
        Dex is an OIDC Identity Provider that can authenticate against AD.  
        Deploy Dex in your Kubernetes cluster.   
        Configure Dex to use AD as a backend:
        Example configuration:  
        ```yaml
        connectors:
        - type: ldap
        id: ldap
        name: Active Directory
        config:
            host: "ad.yourdomain.com:636"
            bindDN: "cn=service_account,dc=yourdomain,dc=com"
            bindPW: "password"
            userSearch:
            baseDN: "dc=yourdomain,dc=com"
            filter: "(objectClass=person)"
            username: "sAMAccountName"
            idAttr: "DN"
            emailAttr: "mail"
            nameAttr: "cn"
            groupSearch:
            baseDN: "dc=yourdomain,dc=com"
            filter: "(objectClass=group)"
            userMatchers:
                - userAttr: "DN"
                groupAttr: "member"
            nameAttr: "cn"
        ```

2. Integrate Applications with Active Directory  
   Use **OAuth2 Proxy**

    1. Deploy OAuth2 Proxy:
        OAuth2 Proxy can handle authentication using OIDC tokens   
        and act as a reverse proxy for your applications.  
        Deploy OAuth2 Proxy in your Kubernetes cluster.  
        Configure OAuth2 Proxy to use Dex as the OIDC provider:
        ```yaml
        kind: Deployment
        apiVersion: apps/v1
        metadata:
            name: oauth2-proxy
        spec:
            replicas: 1
            selector:
            matchLabels:
                app: oauth2-proxy
            template:
            metadata:
                labels:
                app: oauth2-proxy
            spec:
                containers:
                - name: oauth2-proxy
                image: quay.io/oauth2-proxy/oauth2-proxy:v7.0.0
                args:
                - --provider=oidc
                - --oidc-issuer-url=https://dex.yourdomain.com
                - --client-id=your-client-id
                - --client-secret=your-client-secret
                - --redirect-url=https://your-app.yourdomain.com/oauth2/callback
                - --cookie-secret=your-cookie-secret
                - --upstream=http://your-app:8080
        ```

    2. Configure Your Applications:
        * Ensure your applications are behind the OAuth2 Proxy.
        * **Redirect** users to the OAuth2 Proxy for authentication.

3. Managing Role-Based Access Control (RBAC)  
   Create RBAC Roles and Bindings:
        
    * Define roles and role bindings in Kubernetes 
      to map AD group memberships to Kubernetes roles:
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    namespace: default
    name: read-only
    rules:
    - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    name: read-only-binding
    namespace: default
    subjects:
    - kind: Group
    name: "your-ad-group"  # Name of the AD group
    apiGroup: rbac.authorization.k8s.io
    roleRef:
    kind: Role
    name: read-only
    apiGroup: rbac.authorization.k8s.io
    ```
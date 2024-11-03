# [K8s-AD Integration using Keycloak](https://chatgpt.com/share/35e90294-e894-45a6-bf5d-881c924be7af "ChatGPT.com")


## Q:

How to integrate keycloak on K8s on RHEL 8 with AD, 
given RHEL 8 is integrated with AD via Kerberos and password auth.

## A:

Integrating Keycloak on Kubernetes (K8s) running on RHEL 8 with Active Directory (AD), 
especially when RHEL 8 is already integrated with AD via Kerberos and password authentication, involves several steps. Below is a high-level guide to achieve this integration:

### Prerequisites

- Kubernetes Cluster: Ensure you have a running Kubernetes cluster on RHEL 8.
- Keycloak Deployment: Keycloak should be deployed on your Kubernetes cluster. 
- AD Integration on RHEL: Confirm that RHEL 8 is successfully integrated with AD using SSSD for Kerberos and password authentication.

### [LDAP](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol) : Lightweight Directory Access Protocol 

>Successor to DAP (Directory Access Protocol) of switched-based telecoms era, 
and is origin of [X.500](https://en.wikipedia.org/wiki/X.500) series standards.

#### Port(s): 

- LDAP : `389 TCP and UDP` 
- LDAPS : `636 TCP and UDP` (TLS)

Both schemes use TCP mostly, but for Connectionless LDAP (CLDAP) protocol, which is a lightweight version of LDAP that uses UDP for simple, stateless queries, such as when a client needs to locate a domain controller in a Microsoft Active Directory environment. This is commonly seen in the initial stages of authentication, such as during a "ping" to locate domain controllers.

#### [Terminology](https://ldap.com/glossary-of-ldap-terms/)

>__`CN=ldap-reader,OU=Service Accounts,DC=example,DC=com`__

- __DC__ : Domain Component
- __DN__ : Distinguished Name: a name that uniquely identifies an entry and its position in the DIT. It is comprised of a series of zero or more relative distinguished names (RDNs) separated by commas. 
    - __RDN__ : Relative Distinguished Name: one or more attribute name-value pairs. DNs are comprised of zero or more RDNs, but it is common to use the term RDN _to refer to the leftmost component_ of a DN because the attribute values included in the leftmost RDN component for a DN must also be present in the entry referenced by that DN. 
- __DIT__ : Directory Information Tree: the hierarchy of entries contained in a directory server. 


LDAP Security Objects

- __OU__ : Organizational Unit (OU): similar to a Window directory. For LDAP, it typically holds either Group objects or User objects.
- __CN__ : Common Name
    - __Group__ :  object containing a member attribute that is a list of Distinguished Names that define the users in that group.
    - __User__ : object describing a single person within the LDAP structure. Unlike a Group, a User does not contain a list. Instead, its attributes describe a user in as much detail as necessary.

### Step 1: Deploy Keycloak on Kubernetes

1. Create a Namespace for Keycloak:
```bash
kubectl create namespace keycloak
```
1. Deploy Keycloak: You can deploy Keycloak using a Helm chart or a custom deployment. Here's an example using a Helm chart:
```bash
helm repo add codecentric https://codecentric.github.io/helm-charts
helm install keycloak codecentric/keycloak --namespace keycloak
```
1. Expose Keycloak: Use an Ingress or a LoadBalancer service to expose Keycloak externally. Example:
```yaml
apiVersion: v1
kind: Service
metadata:
    name: keycloak
    namespace: keycloak
spec:
    ports:
    - port: 80
    targetPort: 8080
    protocol: TCP
    selector:
    app: keycloak
    type: LoadBalancer
```

### Step 2: Integrate Keycloak with Active Directory

1. Access Keycloak Admin Console:
    - Access the Keycloak admin console using the external IP or DNS name 
      provided by the LoadBalancer or Ingress.
    - Log in using the default admin credentials (which should be set during deployment).
1. __Create a New Realm__:
    - In the Keycloak admin console, create a new realm that will be used for AD integration.
1. __Add LDAP/AD__ as a __User Federation__ Provider: Allowing Keycloak to connect to, and synch with, other <dfn title="Identity Provider">IdP</dfn>/<dfn title="Identity Management">IdM</dfn> such as Active Directory Domain Services (AD DS), and otherwise act as an __intermediary IdP__. Implementing such __Federated Identity__ allows users to quickly move between systems securely.
    - Navigate to __User Federation__ in the Keycloak admin console.
    - Click on Add provider and select LDAP.
    - __Configure LDAP__ settings as follows:
        - __Vendor__: Active Directory
        - __Connection URL__: `ldap://<AD_SERVER_IP>:389` or `ldaps://<AD_SERVER_IP>:636` (for LDAPS)
        - __Users DN__: The base DN where your users are located, e.g., `OU=Users,DC=example,DC=com`
        - __Bind DN__: The DN of an AD service account that has read access to the user data, e.g., `CN=ldap-reader,OU=Service Accounts,DC=example,DC=com`
        - __Bind Credential__: The password for the Bind DN account.
        - __Kerberos Integration__: Set Allow Kerberos Authentication to ON 
          if Keycloak is to delegate authentication to AD using Kerberos.
        - __Sync Settings__: Configure how and when to synchronize user data from AD to Keycloak.
    - Test the connection to ensure that Keycloak can communicate with the AD server.
1. __Configure Kerberos__ Authentication (Optional):
    - If you want Keycloak to use Kerberos for authentication, additional configuration is required:
        - __Kerberos Realm__: Set the Kerberos realm, which should match your AD domain.
        - __Server Principal__: The principal name Keycloak will use, 
          usually something like `HTTP/<keycloak-hostname>@EXAMPLE.COM`.
        - __Keytab File__: Upload the keytab file for the Keycloak service principal, 
          which should be generated and exported from AD.
1. __Sync Users__:
    - After configuring the LDAP provider, 
     trigger a full sync to import AD users into Keycloak.

### Step 3: Integrate Kubernetes with Keycloak

UPDATE: [OIDC v. SAML](https://chatgpt.com/c/670b12d7-e734-8009-a1d1-2699eee21d6e "ChatGPT")

1. __Enable OIDC Authentication__ on Kubernetes :
- Update your Kubernetes API server configuration (`kube-apiserver.yaml`) 
  to __use Keycloak as the OIDC provider__. 
This involves adding flags to the API server configuration:
```bash
    --oidc-issuer-url=https://<keycloak-url>/auth/realms/<realm-name>
    --oidc-client-id=<client-id>
    --oidc-username-claim=preferred_username
    --oidc-groups-claim=groups
```
1. __Create a Keycloak Client__ for Kubernetes:
    - In the Keycloak admin console, create a new client for Kubernetes within your realm.
    - Set the Client ID to match the `--oidc-client-id` configured in Kubernetes.
    - Set the Access Type to `confidential`.
    - Configure the __Valid Redirect URIs__ to include the Kubernetes API server URL.
    - See [`kubelogin`](https://github.com/int128/kubelogin "github.com/int128/kubelogin")
1. __Configure RBAC in Kubernetes__:
    - Map the Keycloak roles/groups to Kubernetes RBAC roles. 
    You can use a `ClusterRoleBinding` or `RoleBinding` 
    to grant appropriate permissions to the users authenticating via Keycloak.

### Step 4: Testing and Verification

1. Login to Kubernetes using Keycloak:
    - Use a Kubernetes client (like `kubectl`) with an OIDC plugin 
      or a custom script to obtain an OIDC token from Keycloak.
    - Test the login and ensure users can authenticate to Kubernetes 
      via Keycloak using their AD credentials.
1. Monitor Logs and Debug:
    - Check the Keycloak and Kubernetes logs to ensure 
      that the integration is working correctly and troubleshoot any issues.


## Step 5: Optionally [Refactor Groups/Roles](https://chatgpt.com/share/78b62726-6535-4851-aa28-5baa1446a164 "ChatGPT")

>In environment having AD DS as the domain-level IdP, 
both K8s and its workloads (application services) 
have the option of abiding AD groups exclusively or 
refactoring to better fit upstream services.


### @ AD DS (Domain IdP) 

>AD's org-based groups (having users);  
are all synchronized with RHEL clients,  
providing realm-level (domain) __Authn__:

- `team_1_*`  
  &vellip;
- `team_3_members`
    - `u11`
    - `u33`
    - `u5`
    - `u44`
- `team_3_leaders`
    - `u11`
    - `u33`  
    &vellip;
- `team_11_*`  
  &vellip;

### @ Keycloak (OIDC / User-Federation IdP)

- __Authn__ : LDAP Realm has AD Groups. That is the coupling.  
The resulting __OIDC__ identity may match nothing but upstream (containerized) application(s).
    - Groups and Users synched with AD
        - __Requires AD service-account credentials__.
        - Groups may be refactored 
          (per application) for better fit.
- __Authz__ is per role(s) bound to OIDC Group(s) 
    - __OAuth2__ Role(s)
        - Realm-level
        - Client-level

#### Example @ Unchanged:

- `team_3_members`
    - Role-B
- `team_3_leaders`
    - Role-A
    - Role-B  
    &vellip;
- `team_11_* `  
  &vellip;

#### Example @ Refractored:

- App-X
    - `TestRack-B-Leaders`
        - Role-8
        - Role-4
        - Role-9
    - `POSTGRESQL_DB_OWNER`
        - Role-3
        - Role-7

        &vellip;  
- App-Y
    - `team_3_members`
        - Role-N
        - Role-R  
        &vellip;  

  
>An authenticated subject (identity) is issued a bearer token (JWT) 
having claims including `id: <UUID>`, `groups:[]` and `roles:[]`. 
Such claims scope all upstream API access (Authz) regardless (K8s API, App-X API, Web UI SSO, &hellip;). 


### @ K8s API __Authn__ modes for __Authz__

- Bearer token
    - `groups: []`
        - Has `Role`s via `RoleBinding`s
    - `user: <UUID>`
        - ~~Has `Role`s via `RoleBinding`s~~
            - Okay, but rather not.
    - ~~`roles: []`~~ 
        - K8s API ignores this.
- `ServiceAccount` token
    - Has `Role`s via `RoleBinding`s
- X.509 Certificate
    - groups from `/OU=team_3_members /OU=TestRack-B-Leaders`
        - Has `Role`s via `RoleBinding`s
    - user from `/CN=u33` 
        - ~~Has `Role`s via `RoleBinding`s~~
            - Okay, but rather not.

>`Role` and `RoleBinding` __are objects__ of K8s API,
>whereas `group` and `user` are merely __concepts__ of K8s API,
>known only as token subjects. The latter map 
>to `Role` only by `RoleBinding`.

`ClusterRole` and `ClusterRoleBinding` objects are ommitted here for clarity.
Where `Role` and `RoleBinding` are scoped to a `Namespace`, the `Cluster*` 
versions apply cluster-wide. 

So, the lone coupling is the map from domain IdP (AD DS) user/group 
to DevOps-controlled IdP (Keycloak) group/role.

User/Group (Authn) is otherwise decoupled from roles (Authz). 
Moreover, access to K8s API endpoints is entirely decoupled from that of applications. 
Though decoupled, these may be configured identically, entirely refactored, 
or any mix thereof, all at the discretion of cluster/application administrators, 
and that separation too (cluster admin vs teams/apps admin) 
is discretionary and maintains its flexibility.

## Summary

- Keycloak serves as the OIDC provider for Kubernetes, 
  integrating with AD via LDAP and optionally Kerberos.
- RHEL 8 acts as the underlying OS for Kubernetes and is already integrated with AD, 
  which facilitates secure communication and authentication.
- Kerberos can be configured in Keycloak if you require Kerberos-based SSO for users, 
 although it's optional.

This setup provides a secure and centralized authentication mechanism for Kubernetes users, leveraging existing AD infrastructure and using Keycloak as a flexible and powerful identity broker.



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


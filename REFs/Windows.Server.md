# [Windows Server](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?msockid=05311f3dde09664d0afc0b53dfa16779 "microsoft.com") 2019 | [Docs](https://learn.microsoft.com/en-us/windows-server/)


## Overview

Windows Server remains the industry standard domain controller for IdP (AD DS), IdM (AD UAC), X.509 (AD CS), DNS and DHCP. Linux (RHEL) hosts join into its domain via realm and SSSD.

However, engineers quickly learn that its prominence is due to clever vendor lock-in rather than any technological edge. In fact, WS2019 does not allow for any sort of automation, nonetheless DevOps/GitOps methods. Every domain becomes a handcrafted boutique; a once-per-universe configuration that will never, indeed can never, be repeated again. And the man hours required to craft one, even only to the point that it is tolerably sufficient, is gargantuan. As is its maintenance.

Vendor marketing:

_&hellip; the operating system that bridges on-premises environments 
with Azure services enabling hybrid scenarios maximizing existing investments. 
Create cloud native and modernize traditional apps using containers and micro-services._

That last sentence is laughable. Enterprises are slowly escaping the Windows hellscape, and moving to a purely K8s-based infra. Though very slowly.

### Installation options (2016/2019):

- __Server Core__ (headless):  
    This is the __recommended__ installation option. 
    It’s a smaller installation that includes the core components of Windows Server 
    and supports all server roles but __does not include a local graphical user interface__ (GUI). 
    _Managed remotely_ through __Windows Admin Center__, PowerShell, or other server management tools.
- __Server with Desktop Experience__ : __Server Manager__ (GUI):   
    This is the complete installation and includes a full GUI for customers who prefer this option.

### Three Versions

- __Datacenter__ : Virtual Machine for Cloud environments
    - https://1337x.to/torrent/4212270/Windows-Server-2019-DataCenter-3in1-ESD-en-US-DEC-2019-Gen2/ 
- __Standard__ : Physical server or minimally-virtualized environments
- __Essentials__ : Small biz up to 25 users and 50 devices

Requirements:

- CPU: 1 1.4 GHz
- RAM: 512 MB 
- Disk: 32 GB

### [Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview) (WAC) | [Chocolatey Package](https://community.chocolatey.org/packages?q=windows%20admin%20center)

UPDATE: This is __another useless Microsoft product__. It manages to log in to the domain controller, though having no ability to save credentials. And then it lists roles and such, but has none of the interfaces to any of the roles. 

__It merely lists the roles! That's all it does!__

PRIOR ...

A locally-deployed, __browser-based management tool__ set built to manage Windows Clients, Servers, and Clusters without needing to connect to the cloud. Windows Admin Center offers full control over all aspects of Windows-based server infrastructure and is __particularly useful for managing on-prem servers__.

WAC __requires its own separate installation__.WAC is not a built-in feature of WS2019.  
While it is designed to manage Windows Server environments, WAC itself is a web-based management tool that must be downloaded and installed manually.

Once installed, you can __use WAC to manage multiple Windows Servers, Hyper-V hosts, clusters, and even Windows 10 and 11 PCs__ from a single web-based interface. It simplifies server management tasks by centralizing the management tools and offering a modern, unified experience.
You can install WAC on a Windows Server or Windows client and access it via a web browser. 
It can also be deployed in a high-availability setup in larger environments.

## Realm v. Domain v. Forest v. Tree

### 🔹 **Active Directory Terminology**

| Concept       | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| **Domain**    | A logical grouping of objects (users, computers, etc.) under a single database and namespace (e.g., `example.com`).|
| **Forest**    | A collection of one or more domains that share a common schema and global catalog, with implicit trust.            |
| **Tree**      | A collection of domains in a **contiguous namespace** within a forest.                                           |

- Domains in a forest can trust each other automatically.
- A forest is the **security boundary**.

---

### 🔹 **Kerberos Terminology**

| Concept       | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| **Realm**     | A Kerberos concept, representing an authentication boundary—usually maps 1:1 to an AD domain and written in **ALL CAPS** (e.g., `EXAMPLE.COM`).|

- In practice, **AD Domain = Kerberos Realm** (case-insensitive match, but usually uppercase in Kerberos tools).
- When using Linux/SSSD/Kerberos to integrate with AD, you configure a `realm` like `EXAMPLE.COM`, which corresponds to the AD domain `example.com`.

---

### 🧭 Where They Intersect

| Term | Found In | Example |
|------|----------|---------|
| **Domain** | AD | `ad.lan` |
| **Forest** | AD | `ad.lan`, `corp.ad.lan` → part of the same forest |
| **Realm** | Kerberos | `AD.LAN` (used in krb5.conf, SSSD, etc.) |

- **In Linux config (e.g., `/etc/krb5.conf`, SSSD)**:
  ```ini
  [realms]
    AD.LAN = {
      kdc = dc1.ad.lan
      admin_server = dc1.ad.lan
    }
  ```
  Here, the Kerberos `REALM` refers to the AD **domain**.

---

### 🧩 Summary

| Term     | Role             | Example         | Scope          |
|----------|------------------|------------------|----------------|
| Domain   | Logical container | `example.com`    | One namespace  |
| Forest   | Trust boundary    | multiple domains | Entire AD      |
| Realm    | Auth boundary     | `EXAMPLE.COM`    | Often = Domain |

Let me know if you want to map this to a Linux config or see how realm joins work.


## Roles/Features

Selectable by checkbox at the AD Installation Wizard of the Server Manager GUI

- DHCP Server
- DNS Server
- __Active Directory__ | [Directory data store](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc736627(v=ws.10)) | [Manage by PowerShell AD Module](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/powershell/active-directory-replication-and-topology-management-using-windows-powershell)
    - __Domain Services__ ([AD DS](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)) | [Operations](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/ad-ds-operations)
    - __Federation Service__ ([AD FS](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/ad-fs-overview))  
    AD FS enables __Federated Identity__ and __Access Management__ by securely sharing digital identity and entitlements rights across security and enterprise boundaries. Implements OIDC, and OAuth Grant flows. Successor is Microsoft Entra ID.
        - [AD FS OIDC/OAuth Flows v. App Scenarios](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/overview/ad-fs-openid-connect-oauth-flows-scenarios)
        - DEPRICATED : Microsoft is hard selling its cloud service [Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/whatis) which mates to its labyrinth of proprietary apps, each designed to superglue customers to Microsoft Corporation.
    - __Certificate Services__ ([AD CS](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/active-directory-certificate-services-overview#key-features))  
      Issue and manages TLS certificates via web UI. Provides Public Key Infrastructure (PKI) 
      for cryptography, digital certificates and signature capabilities.
- PowerShell Desired State Configuration (DSC) in Windows Management Framework (WMF) 5  
    Windows Management Framework 5 includes updates 
    to Windows PowerShell Desired State Configuration (DSC), 
    Windows Remote Management (WinRM), 
    and Windows Management Instrumentation (WMI).
- [Manage Windows Server file servers](https://learn.microsoft.com/en-us/training/modules/manage-windows-server-file-servers/?source=recommendations) : In AD DS environment having a domain member configured as a file server.
- Deploy Network File System (NFS)
    - [Provision file shares in heterogenous environments](https://learn.microsoft.com/en-us/windows-server/storage/nfs/deploy-nfs#provision-file-shares-in-heterogeneous-environments) : SMB &amp; NFS protocols for file shares between Windows and Linux hosts. For this scenario, you __must have a valid identity mapping__ source configuration. Windows Server supports the following __identity mapping stores__:
        - Mapping File
        - Active Directory Domain Services (AD DS)
        - RFC 2307-compliant LDAP stores such as Active Directory Lightweight Directory Services (AD LDS)
        - User Name Mapping (UNM) server
    - [Provision file shares in UNIX-based environments](https://learn.microsoft.com/en-us/windows-server/storage/nfs/deploy-nfs#provision-file-shares-in-unix-based-environments) : No share between Windows and Linux. Enabling the option, __Unmapped UNIX User Access__ (UUUA) enables Windows servers to store NFS data without creating UNIX-to-Windows account mapping. &hellip; to quickly provision and deploy NFS sans mapping. 
        - Mapped user accounts use standard Windows SIDs
        - Unmapped user accounts use custom NFS SIDs.
    - [Configure NFS Authentication](https://learn.microsoft.com/en-us/windows-server/storage/nfs/deploy-nfs#configure-nfs-authentication) : 
        - Kerberos v5
            - Krb5: to authenticate users before granting them access to the file share.
            - Krb5i: to authenticate with integrity checking (checksums), 
            which verifies that the data hasn't been altered.
            - Krb5p: to authenticate NFS traffic with encryption for privacy. 
            This option is the most secure Kerberos option.
        - Enable __unmapped user access__ through `AUTH_SYS`. This option is insecure; it removes all authentication protections and __allows any user with access to the NFS server to access data__ under one of two settings: 
            - Allow unmapped user access by UID or GID, which is the default. 
            - Allow anonymous access.


## Hyper-V Prep

Networking : Connectivity between WSL2 &amp; Hyper-V VMs

### The NAT subnet option : [Overview of best options](https://chatgpt.com/share/67391a83-bdbc-8009-99fb-d69281826092 "ChatGPT")

@ [`network-nat.ps1`](network-nat.ps1)

See params it configured by running [`network-get.ps1`](network-get.ps1)

1. User above script or Hyper-V GUI to create the Internal Switch (`InternalSwitchNAT1`)
    - PowerShell script above creates the switch if not exist, yet using it to do so prior to finding the packet-forwarding solution mentioned below resulted in failure of connectivity tests.
    - Isolated, this is initally/automatically assigned an APIPA address
1. Use PowerShell to __create the `NAT1` subnet__ (`192.168.11.0/24`) 
   having __route to WSL subnet__ (`172.27.240.0/20`) __gateway__.
    ```powershell
    New-NetNat -Name "$NatName" -InternalIPInterfaceAddressPrefix "$NatCIDR"
    Set-NetIPAddress -InterfaceAlias "$WslAlias" -IPAddress "$WslGateway" -PrefixLength 20 
    ```
1. Use `ncpa.cpl` (GUI) to manually set 
   IP address within our declared `NAT1` CIDR 
   on `$NatAlias` interface (`InternalSwitchNAT1`).
1. __Enable IP packet forwarding__, per adapter (switch), 
   to provide connectivity across subnets.
    ```powershell
    # Enable IP packet forwarding (across subnets) : Per adapter
    Set-NetIPInterface -InterfaceAlias "$ExtAlias" -Forwarding Enabled -Verbose
    Set-NetIPInterface -InterfaceAlias "$WslAlias" -Forwarding Enabled -Verbose
    Set-NetIPInterface -InterfaceAlias "$DefAlias" -Forwarding Enabled -Verbose
    Set-NetIPInterface -InterfaceAlias "$NatAlias" -Forwarding Enabled -Verbose
    # Else all at once
    Get-NetIPInterface | Where-Object {$_.InterfaceAlias -like 'vEthernet (*' } | Set-NetIPInterface -Forwarding Enabled

    ```

WSL2 has connectivity to Windows 11 host (`External`) network regardless;
however, NAT subnet does not until packet forwarding is enabled.

__Verify connectivity__ from WSL2 to NAT1 subnet;
route between `Ubuntu` (WSL2) host and `a0.lime.lan` (NAT1) host:

```bash
Ubuntu [13:23:45] [1] [#0] /c/TEMP
☩ traceroute a0.lime.lan
traceroute to a0.lime.lan (192.168.11.104), 64 hops max
1   172.24.208.1  0.432ms  0.227ms  0.139ms    # WSL Gateway
2   192.168.11.104  0.448ms  0.230ms  0.287ms  # Target Hyper-V VM host
```

To test NAT1 prior to provisioning DHCP/DNS server on that subnet, 
manually add the IP and route on that CIDR to the host's network device. 
This task is performed from a Hyper-V Connect session:

```bash
# Manually assign IP within NAT1 CIDR
sudo ip addr add 192.168.11.111/24 dev eth0

# Add default gatewayy (The IPv4 declared at NAT1 adapter) 
sudo ip route add default via 192.168.11.1

```

Now test @ WSL:

```bash
☩ traceroute 192.168.11.111
traceroute to 192.168.11.111 (192.168.11.111), 64 hops max
  1   172.27.240.1  0.361ms  0.175ms  0.160ms
  2   192.168.11.111  0.326ms  0.231ms  0.164ms
```

___Success!___

### Add local DNS for best performance: 

@ [`network-dns.ps1`](network-dns.ps1)

Keep the default DNS configuration of WSL2 host:

```bash
...
# DNS @ WSL2 network is best handled automatically, 
# which auto-generates /etc/resolv.conf
# The nameserver is set to WSL's virtual DNS server (10.255.255.254)
# And it sets the default search domain for unqualified dowmain names:
# ☩ cat /etc/resolv.conf
# ...
# nameserver 10.255.255.254
# search SEMPERLAN hsd1.md.comcast.net
```
- See [`network-dns.ps1`](network-dns.ps1)

## Create VM of Hyper-V

- Generation: `2` 
- Name: `WinSrv2019`
- CPU: `2`
- RAM: `2048-4096` MiB (Dynamic)
- Network: `InternalSwitchNAT1`
    - If `External...`, then has DHCP issue. 
    See below: "DNS Options" WARNING under "Domain Controller Options", and [ChatGPT](https://chatgpt.com/share/670c59f1-7504-8009-beea-ff2f8d4caff9) .
- Integration Services
    - Guest services (check)
    - All should be checked.
- Disk: `0-32 GB` (Dynamic)
    - `14 GB` after install.
- ISO: `SRV2019STD.ENU.NOV2022.iso`
    - "__Windows Server 2019 Standard__ 1809 Build 17763.3650 en-US ESD NOV 2022"

## Install Windows Server 2019

### WARNING:  

Boot from ISO fails when installing Windows Server 2019 host on Hyper-V VM is using the Start button from Hyper-V menu. Rather, __select Connect option, and press Start button only from inside that window.__ This method captures the keyboard, allowing OS install on "Press any key &hellip;".  

__Any other method bricks the VM.__ 

### Windows Server Install

1. __Connect__
    - Options : Local Resources : More : Drives : Scratch (S:) or whatever to __share drive(s) between host and VM__.
    - Save conguration (checkbox)
1. __Start__ (button in the Connect window)
    - "GENERATION<sup>2</sup>" screen displays
    - __Windows Setup__ window (eventually) appears
        - Install option: "Custom ..." is the only viable/allowable.
        - Without Guest services of Settings menu, disk size is hardcoded to 127 GB. No options. ISO has no drivers.
        - "Customize settings"
            - "User name: __Administrator__" (hardcoded)
            - Password: __Admin!123__
    - Shutdown
        - Merge at Hyper-V takes many minutes.
1. __Remove DVD__ at Hyper-V Settings.
1. Connect/Start
    - Boots into Server Manager
        - Enter password
        - Local Server

### Activate @ "Not Activated"

How to __Activate via KMS__ using [Microsoft Activation Scripts (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts "GitHub.com") method at a PowerShell terminal:

```powershell
Install-WindowsFeature -Name VolumeActivation -IncludeManagementTools

# Run this statement and select the "KMS" option at its menu
irm https://get.activated.win | iex
```

### Disable MS Online Account Sign-in Requirement

The default OS install has a "Welcome" login 
sequence requiring a Microsoft account.
It blocks user from login until user signs up for MS account, 
enters creds of existing account, 
or selects a button that is effectively a 
"Repeatedly block and bother me again later".

This statement cures that:

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser" -Value 3 -Type DWord

```

## Configure Windows Server

1. __Ethernet adapter__ (`ncpa.cpl`)
    - Reference the network (`InternalSwitchNAT1`) __installed earlier__   
      in a PowerShell session at the host (Windows 11) :  
        - [`network-nat.ps1`](network-nat.ps1)
        - [`network-define.ps1`](network-define.ps1)
        - [`network-get.ps1`](network-get.ps1)
    - Ethernet adapter configuration:
        - Properties:
            - IPv6 (Uncheck)
            - IPv4 (check) : Properties:
                - "Use the following IP address" (check)
                    - IP address: `192.168.11.2` (Self)
                    - Subnet mask: `255.255.255.0` (`24` bit)
                    - Default gateway: `192.168.11.1` (NAT1 IPv4)
1. __Local Server__
    - Computer name: __`dc1`__ (Domain Controller 1)
    - Ethernet: __`192.168.11.2`__
        - Set static IP to that declared at 
        subnet (`InternalSwitchNAT1`) configured earlier.
    - Time zone: `Eastern`
    - IE Enhanced Security Configuration: `Off` (All)
        - IE Enhanced Security Configuration
            - Off @ Admin
            - Off @ User
        - Time zone : Change : EST


>__Server Manager__ is the GUI and main 
portal of __Windows&nbsp;Server&nbsp;2019__ Desktop.
[Windows Admin Center](https://www.microsoft.com/en-us/windows-server/windows-admin-center?msockid=05311f3dde09664d0afc0b53dfa16779 "microsoft.com") (WAC)" is a web UI providing remote access to the server.
It is installed separately, 
either on the AD server or any remote host


## Share Files between Host and VM 

How to add network share(s):

- @ Hyper-V Settings : Enable "__Enhanced Sesison Mode__"
- @ VM Settings : Integration Services : Check "__Guest Services__"
- @ Connect : "__Local devices and resources__" :
    Button: __More...__  : Checkbox: "__Scratch (S:)__" 
    and/or whatever other drive is to be shared.

## Add Roles

1. Open **Server Manager**.
2. Click **Manage** and select **Add Roles and Features**.
3. In the **Add Roles and Features Wizard**:
    - Click **Next** through the default screens :  
      "__Role-based or feature-based installation__".
    - Select sever ... 
    - At **Server Roles** screen, select whatever role(s)
    - Click **Next** and proceed with the installation.
4. After installation, you'll be prompted to **Complete $hellip; Configuration**. 
Click on the notification to complete.


### ADDS and DNS

>Adding the __Active Directory Domain Services__ (ADDS) role by Wizard adds the required DNS role, so need select only the ADDS role.

Reference video: "[Installing Active Directory Domain Services in Windows Server 2022, along with DNS and DHCP](https://www.youtube.com/watch?v=joIubWzQ6P8 "YouTube.com")"

#### [Add __ADDS__ Role](https://www.youtube.com/watch?v=0EklBDIZSgc&list=PLxTwjzMO9Zf4FZJ0BTtQlv5iErouqkbkk&index=2) (and __DNS__ role too) : 

Use the Wizard

- Add server role:
    - Server Manager : Manage : Add Roles and Features
        - Active Directory Directory Services
- Windows Update
    - This interrupted the workflow during promotion (below).
- Promote server to DC:
    - Promote this server to a domain controller  
        &vellip;
- Reboot
- Promote server to DC:
    - Promote this server to a domain controller
        - Deployment Configuration
            - __New forest__
            - Root domain name: __`lime.lan`__
            - Restore-mode password: `Admin!123`
        - Domain Controller Options
            - Forest functional level: Windows Server 2016 (From drop-down menu)
            - Domain functional level: Windows Server 2016 (From drop-down menu)
                - Assure compatibility w/ existing Forest/Domain
                - DNS Options (If not using this as DNS server)
                    - WARNING: A delegation for this DNS server cannot be created because authoritative parent zone cannot be found or it does not run Windows DNS infrastructure. If you are integrating with an existing DNS infrastructure, you should manually create a delegation to this DNS server in the parent zone to ensure reliable name resolution from outside the domain `lime.lan`.
                        - Ignore else reconfigure networking. See [ChatGPT](https://chatgpt.com/share/670c59f1-7504-8009-beea-ff2f8d4caff9)

#### Configure DNS

ADDS Wizard configures Forward Lookup Zone, but not Revers.

1. Open **DNS Manager** (`dnsmgmt.msc`).
2. Right-click the server and select **Configure a DNS Server**.
   - Select **Create a Forward Lookup Zone**.
   - Name the zone something relevant to your internal network (e.g., **`lime.lan`**).
   - Set the DNS server to use **forwarders** for external lookups (e.g., point it to `8.8.8.8` for Google DNS or your preferred DNS servers).

Create a __Reverse Lookup Zone__. 
The primary reverse lookup zone needs a pointer (`PTR`) record.
The ADDS Wizard does not do this for us.

- Create Primary Zone
- Add Network Addr
- Resolve
- Update PTR in Forward Record

#### DNS @ ADDS : `"_msdcs.<domain>"`

The `"_msdcs.<domain>"` zone created during the Active Directory Domain Services (AD DS) integration with the DNS role (via Wizard) is a critical component of AD DS's dynamic DNS infrastructure.  It enables seamless communication and operation of the AD environment by providing a dynamically updated repository of service location information.

- Automatically **created as a forward lookup zone** if it doesn't exist.
    - Configured to replicate across all DNS servers in the forest if the domain is part of a larger forest.
    - Ensures that critical DNS data is available across all DNS servers, improving redundancy and fault tolerance.
- What is `_msdcs.<domain>`?
    - **Namespace for Active Directory Services**:
        - `_msdcs` stands for "Microsoft Domain Controller Services."
        - This zone contains service locator (SRV) records and other essential DNS entries used by Active Directory to locate domain controllers and other AD services.
    - **Globally Unique Identifier (GUID) Records**:
        - Each domain controller in an AD forest is assigned a unique GUID. These GUIDs are stored in the `_msdcs` zone to allow clients to find specific domain controllers in the forest.
    - **Forest-wide Locator Records**:
        - `_msdcs.<domain>` includes records that are forest-wide, meaning they are necessary for locating services across the entire forest, not just within a single domain.
- Key Features of `_msdcs.<domain>`
    -  **Service Locator (SRV) Records**:
    - The zone holds SRV records that direct clients to domain controllers for authentication, replication, and other AD services.
    - Example: `_ldap._tcp.dc._msdcs.lime.lan` directs LDAP clients to a domain controller in the lime.lan domain.
    -  **Alias Records (CNAME)**:
    - It includes CNAME records that map GUIDs to domain controllers.
    - Example: `<DC-GUID>._msdcs.lime.lan` helps clients locate a specific domain controller.
- **Forest Root Information**:
   - In multi-domain forests, `_msdcs.<forest-root>` is shared across domains to ensure inter-domain operations, such as trust relationships and global catalog searches.
- Importance in AD DS Functionality
    - **Client Authentication**: Without `_msdcs`, clients wouldn't know which domain controller to contact for login authentication.
    - **Replication**: Domain controllers rely on `_msdcs` to locate replication partners.
    - **Global Catalog Services**: Used for locating global catalog servers across the forest.
- Management Considerations
    - **Replication Scope**:
        - By default, the `_msdcs.<domain>` zone is stored in the forest-wide DNS application partition.
        - Ensure that replication is correctly configured to all DNS servers in the forest.
    - **Do Not Modify Manually**:
        - The records in `_msdcs` are automatically maintained by AD DS. Avoid manual changes to prevent breaking critical AD operations.


## ADD DHCP Role 

Use the Wizard


**[Configure DHCP](https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/quickstart-install-configure-dhcp-server?tabs=powershell "learn.microsoft.com")**

@ PowerShell


XML scripts exported from Wizards allow for scripted configuration, either again here, or on other hosts:

```powershell

$dns    = "DNS.DeploymentConfigTemplate.xml"
Windows-Feature -ConfigurationFilePath $dns

$dhcp   = "DHCP.DeploymentConfigTemplate.xml"
Windows-Feature -ConfigurationFilePath $dhcp
```

Separately, this is is a PowerShell method of scripting the DHCP server. It is cobbled together from references:

```powershell
$NatNtwk    = "192.168.11"
$HostName   = "dc1.lime.lan"
$NatDNS     = "$NatNtwk.2"

# These first statements are performed by the Add-Role Wizard
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerSecurityGroup -ComputerName "$HostName" 
netsh dhcp add securitygroups
# If in ADDS
Add-DhcpServerInDC -DnsName "$hostName" -IPAddress "$NatDNS" -PassThru

# The following statements may be run *after* the above objects exist.

# Create/Define Scope
Add-DhcpServerv4Scope -Name "lime.lan" `
    -StartRange "$NatNtwk\.100" `
    -EndRange "$NatNtwk\.200" `
    -SubnetMask 255.255.255.0 `
    -LeaseDuration 8.00:00:00 `
    -State Active `
    -PassThru 

# Verify ADDS Authorized
Get-DhcpServerInDC
# IPAddress            DnsName
# ---------            -------
# 192.168.11.2         dc1.lime.lan

Restart-Service DHCPServer 

# Query available parameters
Get-DhcpServerv4<TAB>
```

@ GUI 

1. Open **DHCP Manager** (`dhcpmgmt.msc`).
2. Right-click on **IPv4** and select **New Scope**.
    - **Scope Name**: `lime.lan`.
    - **IP Range**: Set the IP range for the internal network. Align these with `InternalSwitchNAT1` subnet ([`network-nat.ps1`](network-nat.ps1)) parameters. See by running  [`network-get.ps1`](network-get.ps1)
        - **Start IP**: `192.168.11.100`
        - **End IP**: `192.168.11.200`
        - **Subnet Mask**: `255.255.255.0`
    - **Default Gateway**: Set this to the **vEthernet** interface on the host (`192.168.11.1`).
    - **DNS**: Set to this Windows Server IP, since it's the DNS server for our internal network. We set this to `192.168.11.2`; static IP at Windows Server's Local Server menu, aligned with delcared subnet params. See PowerShell scripts.
        - Manually set it.
3. **Activate the Scope**.
   - Right-click the new scope and click **Activate**.


To get a new IP address from DHCP:

- **Windows**: Use `ipconfig /release` and `ipconfig /renew`.
- **RHEL**: Restart the network service with `sudo systemctl restart network`.


Other tasks:

- Secondary Domain Controller:
- Read-only Domain Controller (RODC)

## Active Directory Users and Computers (__ADUC__)

In AD, there's a __built-in container__ named `CN=Users`, 
which is not technically an OU. 
Rather it's just a default container for user accounts and groups created during domain setup.

__Built-in Containers__

```
lime.lan
└── Users (CN=Users, DC=lime, DC=lan)
    ├── Administrator
    ├── Domain Admins
    ├── Domain Users
    ├── Guest
    └── Other default groups/accounts
```

__OUs__ (__Organizational Units__) are those we create:

```
lime.lan
└── OU1 (OU=OU1,DC=lime,DC=lan)
    ├── IT
    ├── DevOps
    └── OU1-01
```
- Group Policies can be linked to OUs.
- Administrative permissions may be delegated to (groups and users in) OUs.
    - See "__Delegate Control__" section (below)

__Naming conventions__ for AD Groups/Users of both Windows and Linux hosts:

- __Group__ name
    - `[ad-]linux-users` : Standard access
    - `[ad-]linux-admins` : Host administrators
    - `[ad-]linux-sudoers` : Users granted sudo access
    - `[ad-]linux-operators` : Limited management of Linux hosts/services.
- __User__ name
    - `alex.hamilton`
    - `alexhamilton`

### Create `admin` User

@ Server Manager : Tools : __Active Directory Users and Computers__ (__ADUC__)

#### 1. Create Organizational Units (OU)

Create new OU, `OU1`, and two OUs (`DevOps`, `IT`) nested under `OU1`.


- Active Directory Users and Computers [dc1.lime.lan]
    - `lime.lan` (Rt Click) : New : Organizational Unit : Name: `OU1`
        - `OU1` (Rt Click) : New : Organizational Unit : Name: `DevOps`
        - `OU1` (Rt Click) : New : Organizational Unit : Name: `IT`

__Resulting Structure__:

- ADUC [dc1.lime.lan]
    - lime.lan
        - OU1 
            - DevOps 
            - IT


#### 2. Create User

An AD user has creds for authn/authz against ADDS of Windows Server 2019 (`DC1`) 
at any host joined into that AD domain AKA realm.

- Active Directory Users and Computers [dc1.lime.lan]
    - lime.lan (Rt Click) : New : Organizational Unit : Name: `OU1`
        - OU1 
            - IT (Rt Click) : New : User : New Object (Window)
                - First name: `admin`
                - Last name:
                - Full name: `admin`
                - User logon name: `admin`

            &vellip;

__Resulting Creds__:

- User: `admin`
- Pass: `Foo!123456`

#### 3. Add User `admin` to Group `Domain Admins`

Click on user `admin`, right-click __Properties__ > __Member of__, and __Add&hellip;__ > Select Groups > __Check Names__ > type "domain" and select "__Domain Admins__".



### Delegation : "Delegate Control"

Delegation in AD DS refers to granting specific administrative permissions to a user or group for managing objects within an Organizational Unit (OU), without giving them full domain administrator privileges.

For example, if OU1 contains IT and DevOps sub-OUs, and you want IT admins to manage only the IT users and DevOps admins to manage only DevOps users, you can delegate specific administrative tasks to them without granting Domain Admin access.

List all

```powershell
Get-ACL "AD:OU=OU1,DC=lime,DC=lan" | Format-List
```


## Join Windows host (`Win11`) into ADDS Domain

@ Win11

- Verify apropos IP is assigned;  
  it should be within range of our DHCP server   
    - `192.168.11.<100-200>`
- __System__ (window) : __To rename this computer or ...__
    - __Change__ (button)
        - __Member of__ 
            - __Domain__ (checkbox) : 
            Enter the domain of our ADDS server:
                - `lime.lan`   
        - A pop-up window prompts for __credentials__ :  
          Enter those of an __ADDS admin__ user:
            - __User name__
            - __Password__
- Await confirmation
- Reboot


## [Join RHEL host into ADDS Domain](https://chatgpt.com/c/67427df4-6440-8009-9d12-adb9da2faa57 "ChatGPT")

[Integrating RHEL systems directly with ADDS](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html-single/integrating_rhel_systems_directly_with_windows_active_directory/index "docs.RedHat.com")

>You can join Red Hat Enterprise Linux (RHEL) hosts to an Active Directory (AD) domain by using the System Security Services Daemon (SSSD) or the Samba Winbind service to access AD resources. 

- `sssd` (System Security Services Daemon (SSSD)) : For identity and authentication.
    - Manages Kerberos, yet more granular control may be required. See `/etc/krb5.conf`
- `realmd` : To detect available domains and configure the underlying systemd services.

Test on RHEL8 host `a0.lime.lan` 
with AD user __`admin`__ member of AD group __Domain Admins__.

### Prep 

```bash
# Install pkgs
all='
    realmd 
    sssd 
    sssd-tools 
    samba-common 
    samba-common-tools 
    krb5-workstation 
    oddjob 
    oddjob-mkhomedir
'
sudo dnf install -y $all

# Add services / Open ports 
systemctl is-active firewalld &&
cat <<EOH |xargs -I{} sudo firewall-cmd --permanent --add-service={}
kerberos
dns
ldap
samba
EOH

systemctl is-active firewalld &&
    sudo firewall-cmd --reload
```


Also required for NFS to configure Kerberos security via AD:

```bash
dnf install -y krb5-workstation nfs-utils rpcbind
```

@ __`realm`__ prior to join:

```bash
domain=lime.lan
#sudo hostnamectl set-hostname $(hostname).$domain

dc=dc1.$domain
realm discover $dc
```
```plaintext
lime.lan
  type: kerberos
  realm-name: LIME.LAN
  domain-name: lime.lan
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
```
- Note: `configured: no`
- Note hostname should not be the host's FQDN,  
  but rather `FQDN=$(hostname).$domain`

### Join

__Requires an AD DS Administrator__ credentials

```bash
u1@a0 [15:39:28] [1] [#0] ~
☩ sudo realm join --user=Administrator $dc
Password for Administrator@LIME.LAN:

u1@a0 [15:39:51] [1] [#0] ~
☩
```

#### Leave/Join (AD) Domain

Changes at AD to __Service Principal Names__ (SPNs), 
which may be required, e.g., 
__adding an NFS server__ that uses Kerberos, 
are best __handled by leaving and then rejoining__ the domain. 
__Else the new SPNs are not recognized__ at RHEL hosts, 
as revealed at "`klist -k /etc/krb.keytab`".

There are other methods of adding the new entries to `*.keytab`, 
using PowerShell (`ktpass`) at AD server (below), but they are tedious, 
so use only if necessary.

@ `u1@a0`

```bash
domain=lime.lan
dc=dc1.$domain
realm discover $dc
realm list
sudo realm leave $domain
sudo realm join --user=Administrator $dc
#> Password for u1:
#> Password for Administrator:
realm discover $dc
```
```bash
☩ realm list
lime.lan
  type: kerberos
  realm-name: LIME.LAN
  domain-name: lime.lan
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
  login-formats: %U@lime.lan
  login-policy: allow-realm-logins
```

Yet doing so __resets all downstream configurations__, 
e.g., `/etc/sssd/sssd.conf`


#### Recreate Kerberos `*.keytab` having all SPNs

After adding an NFS server at host `a0`, 
Kerberos (`klist`) did not recognize the NFS server,
so reconfigured RHEL/AD :

1. `realm leave` at all RHEL hosts that are NFS clients
2. Run this PowerShell script at domain controller (Windows Server)
3. `realm join` at all RHEL hosts that are NFS clients

@ AD server

```powershell
$Realm = "LIME.LAN"
$Domain = "LIME"   # NetBIOS domain name
$Machine = "A0"
$KeytabPath = "C:\$Machine.keytab"

# Get all SPNs assigned to the machine
$SPNs = setspn -L "$Machine$" | Select-String -Pattern "^\s+\S+" | ForEach-Object { $_.ToString().Trim() }

# Check if SPNs were found
if (-not $SPNs) {
    Write-Host "No SPNs found for $Machine$ in domain $Realm"
    exit 1
}

# Generate keytab for the first SPN (without -append)
$FirstSPN = $SPNs[0]
$FirstPrincipal = "$FirstSPN@$Realm"
Write-Host "Adding $FirstPrincipal to keytab..."
ktpass -out "$KeytabPath" `
    -princ $FirstPrincipal `
    -mapuser "$Domain\$Machine$" `
    -crypto AES256-SHA1 `
    -ptype KRB5_NT_SRV_HST `
    -pass +rndpass

# Add remaining SPNs with -append
$SPNs | Select-Object -Skip 1 | ForEach-Object {
    $SPN = $_
    $Principal = "$SPN@$Realm"
    Write-Host "Appending $Principal to keytab..."
    
    ktpass -out "$KeytabPath" `
        -princ $Principal `
        -mapuser "$Domain\$Machine$" `
        -crypto AES256-SHA1 `
        -ptype KRB5_NT_SRV_HST `
        -pass +rndpass `
        -append
}

Write-Host "Keytab generated at $KeytabPath"
```

### Verify Join

- `realm list`

```bash
u1@a0 [15:39:51] [1] [#0] ~
☩ realm list
```
```plaintext
lime.lan
  type: kerberos
  realm-name: LIME.LAN
  domain-name: lime.lan
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common-tools
  login-formats: %U@lime.lan
  login-policy: allow-realm-logins

```
- Note, we are now: 
    - `configured: kerberos-member`
- Subsequent `sssd.conf` mods to allow logon by `$user` (v. `$user@domain`; see below), result in change to this report: 
    - "`login-formats: %U`"

### Enable Authn via SSSD


Enable and Start SSSD:   
Ensure SSSD is running __to handle authentication__:

```bash
sudo systemctl enable --now sssd
```

By default, only admins can log in.    

__Allow all AD users and groups of domain__:

```bash
sudo realm permit --all
```

Optionally, configure __Home Directory Creation__:   
If you want AD users to get home directories automatically on login:

```bash
sudo systemctl enable --now oddjobd
```

#### `oddjob`

Allows for other-than-default configuration AD users:

- `HOME` directory at `/home/<user>` v. `/home/<user>@<doman>`
- SSH by "`ssh <user>@<host>`" v. "`ssh <user>@<domain>@<host>`"

Configure

@ `/etc/sssd/sssd.conf`

```ini
...
[domain/lime.lan]
...
fallback_homedir = /home/%u
use_fully_qualified_names = False
...
```

Verify

```bash
☩ ansibash sudo cat /etc/sssd/sssd.conf 2>/dev/null \
    |grep -e == -e use_fully_qualified_names -e fallback_
=== u2@a0
fallback_homedir = /home/%u
use_fully_qualified_names = False
=== u2@a1
fallback_homedir = /home/%u
use_fully_qualified_names = False
=== u2@a2
fallback_homedir = /home/%u
use_fully_qualified_names = False
=== u2@a3
fallback_homedir = /home/%u
use_fully_qualified_names = False
```

```bash
☩ ssh u2@a1
Last login: Fri Mar 14 08:05:44 2025 from 172.24.217.171
@ /home/u2/.bash_functions
@ /home/u2/.bashrc_git
@ /home/u2/.bashrc_k8s
@ /home/u2/.bashrc_vim
@ /home/u2/.bashrc
@ /home/u2/.bash_profile
u2@a1 [08:30:15] [1] [#0] ~
```

### Create AD User 

Or add the existing RHEL user to AD (not advised). 
Either way, use __Windows Server__ tool __AD UAC__ (AD Users and Computers). 

#### AD UAC

- Verify host is joined into domain
    - AD UAC > lime.lan > Computers  
      Lists the hostname (uppercase) of all hosts in that AD realm (`lime.lan`)
- Create AD User
    - User: `u2`
    - Pass: `User!123`
- Add to AD Group(s)
    - If AD DS users are also Linux users, then create groups and reset the user's primary AD group:
        - `linux-sudoers`
        - __`linux-users`__
- Reset primary group of new AD User to `linux-users`
    - Default is "Domain Users", which is not advised for users of Linux hosts.

Then &hellip;

__Allow SSH by "`ssh $user@$host`" instead of requiring "`ssh $user@$domain@$host`" for AD DC users__:

@ `/etc/sssd/sssd.conf`

```ini
...
[domain/lime.lan]
...
fallback_homedir = /home/%u
use_fully_qualified_names = False
...
```

#### Verify LDAP synchs Users/Groups with AD 

```bash
☩ ssh a0
...
u1@a0 [10:33:32] [1] [#0] ~
☩ groups
u1 wheel domain users linux-users linux-sudoers
```

If auth fails, check service logs

```bash
sudo journalctl -u sssd -f
sudo tail -f /var/log/secure
```

### Verify Kerberos

@ `u1@a0`

```bash
u1@a0 [08:05:27] [1] [#0] ~
☩ kinit admin@LIME.LAN
Password for admin@LIME.LAN:

u1@a0 [08:06:40] [1] [#0] ~
☩ klist
Ticket cache: KCM:1000
Default principal: admin@LIME.LAN

Valid starting     Expires            Service principal
03/02/25 08:06:36  03/02/25 18:06:36  krbtgt/LIME.LAN@LIME.LAN
        renew until 03/09/25 09:06:14
```
```bash
☩ kinit u1@LIME.LAN
Password for u1@LIME.LAN:

☩ klist
Ticket cache: KCM:1000:28381
Default principal: u1@LIME.LAN

Valid starting     Expires            Service principal
03/02/25 08:11:22  03/02/25 18:11:22  krbtgt/LIME.LAN@LIME.LAN
        renew until 03/09/25 09:11:17

☩ klist -l
Principal name                 Cache name
--------------                 ----------
u1@LIME.LAN                    KCM:1000:28381
admin@LIME.LAN                 KCM:1000
```
```bash
☩ utc;utco;utcz;gmt
2025-03-02T08:17:57 [EST]
2025-03-02T08:17:57-0500
2025-03-02T13:17:57Z
2025-03-02T13:17:57Z
```

### SSH Auth using PKI

Now setup PKI for key-based authentication

```bash
# Generate key pair
ssh-keygen -t ecdsa -C admin@lime.lan -f ~/.ssh/dc1_admin
# Push key to target host
ssh-copy-id -i ~/.ssh/dc1_admin admin@a0.lime.lan
# Configure
vi ~/.ssh/config
```
```ini
Host admin
    Hostname 192.168.11.103
    User admin
    IdentityFile ~/.ssh/dc1_admin
```

Test/Verify

```bash
Ubuntu [18:34:30] [1] [#0] ~
☩ ssh admin
...
[admin@a0 ~]$ 

```

### Fix SELinux objects

```bash
# View current
☩ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

# Fix
☩ sudo semanage login -a -s sysadm_u 'admin@lime.lan'
```

Verify after logout/in

```bash
# View current (fixed)
☩ id -Z
staff_u:staff_r:staff_t:s0-s0:c0.c1023
```

### [Login Lockout v. Sudo (Non-)Lockout](https://chatgpt.com/share/679e5087-0d8c-8009-949a-c328ff4b5c02)

@ __`/etc/pam.d/sudo`__

```ini
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

@ __`/etc/pam.d/system-auth`__

```ini
auth     required  pam_faillock.so preauth silent audit deny=3 unlock_time=600
auth     required  pam_faillock.so authfail audit deny=3 unlock_time=600
```

## AD Certificate Services (AD CS)

UPDATE: 

Configure this as and Enterprise Subordinate CA rather than Enterprise Root CA.

- Generate the Enterprise Root CA (Lime LAN Root CA) using OpenSSL tools and keep offline.
- This subordinate (intermediary), and/or others such as `cert-manager` and Dogtag, 
  will issue the leaf CA certificates to K8s Ingress, K8s Control Plane perhaps, and any others.

See `iac/adcs/README` ([MD](iac/adcs/README.md)|[HTML](iac/adcs/README.html))


ORIGINAL: 

See snapshots of the GUI

1. Open **Server Manager**.
2. Click **Manage** and select **Add Roles and Features**.
3. In the **Add Roles and Features Wizard**:
    - Active Directory Certificate Services : Roles (checkboxes):
        - Certificate Authority
        - Certificate Authority Web Enrollment
            - CA name (checkbox)
            - Target CA: `dc1.lime.lan\lime-DC1-CA`
        - Certificate Enrollment Web Service (CES)
            - Type: Client certificate authentication 
        - Server Certificate
            - Specify a Server Authentication Certificate
                - Choose an existing certificate for SSL encryption 
                    - `dc1.lime.lan` (One year expiry)
        - Add the designated ADCS (web service) `User` (`Administrator`) to `Group` `IIS_IUSRS`
            - The certificate server is protected by ADDS
                - Authenticate at: https://dc1.lime.lan/certsrv/
4. __Save the Root CA certificate__
    - Open Certification Authority GUI (`crtsrv`)
        - __Right-click on the certificate__ (`dc1.lime.lan`)
        - Open
            - Details : "Copy to File" (button) : Next : 
                - "__Base-64 encoded X.509 (.CER)__" (checkbox) : Next ... Save file.
                    - E.g., `ca-root-dc1.lime.lan.cer`
5. __Import the Root CA certficate__ into host(s) and/or client(s) trust store, 
   so that the IIS-served TLS certificate of __Certificate Services__ web page will validate. 
    - @ Windows 11, open `certlm.msc` and import to "__Trusted Root Certification Authorities__" folder.

### Root CA certificate

Save the root CA certificate using PowerShell

```powershell
$caName     = "lime-DC1-CA"
$filePath   = "ca-root-dc1.lime.lan.cer"
$cert       = Get-ADObject -LDAPFilter "(cn=$caName)" -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties "cACertificate"
[System.IO.File]::WriteAllBytes($filePath, $cert."cACertificate"[0])

```

### Obtain a TLS cert via CSR 

#### @ https://dc1.lime.lan/certsrv/

1. Authenticate (against ADDS) by Username/Password
    - Administrator 
        - `User` must be member of `Group` `IIS_IUSRS`
2. __Request a certificate__
    - ... submit an [__advanced certificate request__](#hyperlink-mock)
3. __Submit a Certificate Request__ or Renewal Request
    - __Saved Request__ (HTML FORM : text input box): 
        - Paste the __CSR__ of __PKCS#10__ (New) / PKCS#7 (Renewal) __format__
    - __Certificate Template__:
        - __Web Server__ (dropdown)
    - Additional Attributes (text input box):
        - Leave blank 
4. Submit (button)

#### CSR

AD CS requires CSR in PKCS#10/#7 (New/Renew) format.
OpenSSL generates the request (`*.csr`) in that format by default.

Regarding Windows Server 2019 and prior, 
AD CS offers __only RSA-based certificates__ 
unless that role is configured otherwise, 
which is a non-trivial task that nearly no organization performs.

```bash
bits=4096
root=lime.lan
cn=kube.$root
TLS_ST=MD
TLS_L=AAC
TLS_O=SemperNet
TLS_OU=ops
## Create the configuration file (CNF) : See man config
## See: man openssl-req : CONFIGURATION FILE FORMAT section
## https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html
cat <<-EOH |tee $cn.cnf
[ req ]
prompt              = no        # Disable interactive prompts.
default_bits        = $bits     # Key size for RSA keys. Ignored for Ed25519.
default_md          = sha256    # Hashing algorithm.
distinguished_name  = req_distinguished_name 
req_extensions      = v3_req    # Extensions to include in the request.
[ req_distinguished_name ] 
CN              = $cn                   # Common Name
C               = ${TLS_C:-US}          # Country
ST              = ${TLS_ST:-NY}         # State or Province
L               = ${TLS_L:-Gotham}      # Locality name
O               = ${TLS_O:-Penguin Inc} # Organization name
OU              = ${TLS_OU:-GitOps}     # Organizational Unit name
emailAddress    = admin@$root 
[ v3_req ]
subjectAltName      = @alt_names
keyUsage            = digitalSignature
extendedKeyUsage    = serverAuth
[ alt_names ]
DNS.1 = $cn
DNS.2 = *.$cn   # Wildcard. CA must allow, else declare each subdomain.
EOH

# RSA
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey rsa:2048 -keyout $cn.key -out $cn.csr 
# ED25519
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey ed25519 -keyout $cn.key -out $cn.csr
# ECDSA (NIST P-256 curve)
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey ec:<(openssl ecparam -name prime256v1 -genkey) -keyout $cn.key -out $cn.csr
```

Request the TLS certificate using the HTML FORM of Windows AD CS web server at https://dc1.lime.lan/certsrv/ .
The response has both full-chain and end-entity certificates encoded in PKCS#7 and having DER (binary) format.

- `certnew.p7b`

```bash

# Convert certificate from PKCS#7 (.p7b) to PEM format
cn=kube.lime.lan
openssl pkcs7 -print_certs -in certnew.p7b -out $cn.crt

# Parse the certificate
openssl x509 -noout -issuer -subject -startdate -enddate -ext subjectAltName -in $cn.crt
```
```plaintext
issuer=DC = lan, DC = lime, CN = lime-DC1-CA
subject=C = US, ST = MD, L = AAC, O = DisselTree, OU = ops, CN = kube.lime.lan, emailAddress = admin@lime.lan
notBefore=Jan 25 14:32:36 2025 GMT
notAfter=Jan 25 14:32:36 2027 GMT
X509v3 Subject Alternative Name:
    DNS:kube.lime.lan, DNS:*.kube.lime.lan
```
- Note root CA is `lime-DC1-CA`

### &nbsp;

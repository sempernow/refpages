# [Windows Server](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?msockid=05311f3dde09664d0afc0b53dfa16779 "microsoft.com") 2019 | [Docs](https://learn.microsoft.com/en-us/windows-server/)


## Overview

Windows Server 2019 is the operating system that bridges on-premises environments 
with Azure services enabling hybrid scenarios maximizing existing investments. 
Create cloud native and modernize traditional apps using containers and micro-services.

Installation options (2016/2019):

- __Server Core__ (headless):  
    This is the recommended installation option. 
    It’s a smaller installation that includes the core components of Windows Server 
    and supports all server roles but __does not include a local graphical user interface__ (GUI). 
    _Managed remotely_ through __Windows Admin Center__, PowerShell, or other server management tools.
- __Server with Desktop Experience__ : __Server Manager__ (GUI):   
    This is the complete installation and includes a full GUI for customers who prefer this option.

Roles/Features

Selectable by checkbox at the AD Installation Wizard of the Server Manager GUI

- DHCP Server
- DNS Server
- __Active Directory__ | [Directory data store](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc736627(v=ws.10)) | [Manage by PowerShell AD Module](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/powershell/active-directory-replication-and-topology-management-using-windows-powershell)
    - __Domain Services__ ([ADDS](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)) | [Operations](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/ad-ds-operations)
    - __Federation Services__ ([ADFS](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/ad-fs-overview))  
    AD FS enables __Federated Identity__ and __Access Management__ by securely sharing digital identity and entitlements rights across security and enterprise boundaries. Implements OIDC, and OAuth Grant flows. Successor is Microsoft Entra ID.
        - [AD FS OIDC/OAuth Flows v. App Scenarios](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/overview/ad-fs-openid-connect-oauth-flows-scenarios)
    - __Certificate Services__ ([ADCS](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/active-directory-certificate-services-overview#key-features))  
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

Three Versions

- __Datacenter__ : Virtual Machine for Cloud environments
    - https://1337x.to/torrent/4212270/Windows-Server-2019-DataCenter-3in1-ESD-en-US-DEC-2019-Gen2/ 
- __Standard__ : Physical server or minimally-virtualized environments
- __Essentials__ : Small biz up to 25 users and 50 devices

Requirements:

- CPU: 1 1.4 GHz
- RAM: 512 MB 
- Disk: 32 GB

### [Windows Admin Center](https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/overview) (WAC)

A locally-deployed, browser-based management tool set built to manage Windows Clients, Servers, and Clusters without needing to connect to the cloud. Windows Admin Center offers full control over all aspects of Windows-based server infrastructure and is __particularly useful for managing on-prem servers__.

Windows Admin Center (WAC) is not a built-in feature of Windows Server 2019; it requires its own separate installation. While it is designed to manage Windows Server environments, WAC itself is a web-based management tool that must be downloaded and installed manually.

Once installed, you can use Windows Admin Center to manage multiple Windows Servers (including Windows Server 2019), Hyper-V hosts, clusters, and even Windows 10 and 11 PCs from a single web-based interface. It simplifies server management tasks by centralizing the management tools and offering a modern, unified experience.

You can install Windows Admin Center on a Windows Server or Windows client and access it via a web browser. It can also be deployed in a high-availability setup in larger environments.


## Preliminaries @ Hyper-V

Networking : Connectivity btwn WSL2 &amp; Hyper-V VMs

### [Overview of best options](https://chatgpt.com/share/67391a83-bdbc-8009-99fb-d69281826092 "ChatGPT")

### The NAT subnet option

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
    # Enable IP packet forwarding (across subnets)
    # Per adapter
    Set-NetIPInterface -InterfaceAlias "$WslAlias" -Forwarding Enabled
    Set-NetIPInterface -InterfaceAlias "$DefAlias" -Forwarding Enabled
    Set-NetIPInterface -InterfaceAlias "$NatAlias" -Forwarding Enabled

    # Else all at once
    Get-NetIPInterface | Where-Object {$_.InterfaceAlias -like 'vEthernet (*' } | Set-NetIPInterface -Forwarding Enabled

    ```
    - WSL2 has connectivity to Windows 11 host (`External`) network regardless; 
      NAT subnet does not, until packet forwarding is enabled.

Verify

```bash
traceroute $ip_of_hyperv_vm
```

@ WSL2 and PowerShell (subnets)

```bash
☩ traceroute 172.30.121.104
traceroute to 172.30.121.104 (172.30.121.104), 64 hops max
  1   172.27.240.1  0.297ms  0.126ms  0.129ms    # WSL Gateway
  2   172.30.121.104  0.415ms  0.226ms  0.169ms  # Target Hyper-V VM host

```

To test NAT1 sans DHCP/DNS server on that subnet, we must manually add IP and route on that CIDR. Perform this from a Hyper-V Connect session:

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

Though leave DNS @ WSL2 that of its default configuration:

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


## Configure Windows Server

1. __Ethernet adapter__ (`ncpa.cpl`)
    - Subnet (`InternalSwitchNAT1`) parameters declared earlier:  
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

## Create `DomainAdmin` User 

@ Server Manager : Tools : __Active Directory Users and Computers__ (__ADUC__)

### 1. Create Organizational Units (OU)

Create new OU, `OU1`, and two OUs (`DevOps`, `IT`) nested under `OU1`.


- Active Directory Users and Computers [dc1.lime.lan]
    - lime.lan (Rt Click) : New : Organizational Unit : Name: `OU1`
        - OU1 (Rt Click) : New : Organizational Unit : Name: `DevOps`
        - OU1 (Rt Click) : New : Organizational Unit : Name: `IT`

__Resulting Structure__:

- ADUC [dc1.lime.lan]
    - lime.lan
        - OU1 
            - DevOps 
            - IT


### 2. Create User

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

### 3. Add User `admin` to Group `Domain Admins`

Click on user `admin`, right-click __Properties__ > __Member of__, and __Add&hellip;__ > Select Groups > __Check Names__ > type "domain" and select "__Domain Admins__".

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


## [Join RHEL 8 host (`a0`) into ADDS Domain](https://chatgpt.com/c/67427df4-6440-8009-9d12-adb9da2faa57 "ChatGPT")

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

Hostname change to FQDN having apropos realm not necessary? 
Does kerberos require/expect FQDN?

```bash
domain=lime.lan
sudo hostnamectl set-hostname a0.$domain

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


### Join

```bash
sudo realm join --user=Administrator $dc
```

Actually:

```bash
u1@a0 [15:39:28] [1] [#0] ~
☩ sudo realm join --user=Administrator $dc
Password for Administrator@LIME.LAN:

u1@a0 [15:39:51] [1] [#0] ~
☩
```

### Verify Join

- `realm list`

```bash
u1@a0 [15:39:51] [1] [#0] ~
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
- Note, we are now: `configured: kerberos-member`

### Allow through firewall

```bash
sudo firewall-cmd \
    --add-service=kerberos \
    --add-service=dns \
    --add-service=ldap \
    --add-service=samba \
    --permanent

sudo firewall-cmd --reload
```

### Enable Authn via SSSD

Enable and Start SSSD:   
Ensure SSSD is running __to handle authentication__:

```bash
sudo systemctl enable --now sssd
```

Allow Domain Users to Log In:   
By default, only admins can log in.    

Allow all domain users:

```bash
sudo realm permit --all
```
- Ran this

Allow specific AD groups:

```bash
sudo realm permit "Domain Admins"
```
- Untested


Optionally, configure __Home Directory Creation__:   
If you want AD users to get home directories automatically on login:

```bash
sudo systemctl enable --now oddjobd
```
- Ran this.

### Verify Authn against ADDS from RHEL host

From the newly-joined RHEL host of the domain:

##### `ssh "admin@lime.lan"@localhost`

Success! 

Note that `HOME` dir is created for user `admin`

```bash
u1@a0 [15:59:31] [1] [#0] ~
☩ ssh "admin@lime.lan"@localhost
admin@lime.lan@localhost's password:

[admin@lime.lan@a0 ~]$ ls -hal
total 12K
drwx------. 2 admin@lime.lan domain users@lime.lan  62 Nov 24 15:59 .
drwxr-xr-x. 7 root           root                   78 Nov 24 15:59 ..
-rw-------. 1 admin@lime.lan domain users@lime.lan  18 Nov 24 15:59 .bash_logout
-rw-------. 1 admin@lime.lan domain users@lime.lan 141 Nov 24 15:59 .bash_profile
-rw-------. 1 admin@lime.lan domain users@lime.lan 492 Nov 24 15:59 .bashrc

[admin@lime.lan@a0 ~]$ pwd
/home/admin@lime.lan

```

Also note the RHEL host (`a0`) is now in the 
Domain Controller's DNS records. 
See DNS console at host `WinSrv2019` 
(Windows Server 2019).

```bash
Ubuntu [16:23:44] [1] [#0] ~
☩ ssh admin@lime.lan@a0.lime.lan
admin@lime.lan@a0.lime.lan's password:
Last login: Thu Nov 28 16:23:42 2024 from 172.27.240.169
[admin@lime.lan@a0 ~]$
```

Yet auth here fails:

```bash
Ubuntu [16:25:05] [1] [#0] ~
☩ ssh admin@a0.lime.lan
admin@a0.lime.lan's password:
Permission denied, please try again.
admin@a0.lime.lan's password: #... FAILing
```

## Fix AD-user reference : `admin@$host` vs `admin@$domain@host`


The issue arises because the username `admin` alone is ambiguous on a system joined to an Active Directory (AD) domain. Without explicitly specifying the domain (e.g., `admin@lime.lan`), the RHEL system treats the username as a local account. Since there’s no local `admin` user, authentication fails.


### **Why This Happens**

When you use `admin@lime.lan`:
- The system recognizes it as a fully qualified username (including the domain).
- SSSD correctly routes the authentication to the AD domain controller (`dc1.lime.lan`).

When you use just `admin`:
- The system attempts to authenticate a local Linux user account named `admin`.
- Since no local account exists, authentication fails.

Note home dir created by `oddjob` 

```bash
☩ ls /home
total 8.0K
drwx------.  2 admin@lime.lan domain users@lime.lan   83 Nov 24 16:29 admin@lime.lan
drwx------.  3 gitops         gitops                 111 Sep 22 12:53 gitops
drwx------.  2 testuser       testuser                83 Jun 28 07:35 testuser
drwx------. 10 u1             u1                    4.0K Nov 28 16:32 u1
drwx------.  5 u2             u2                    4.0K Nov 12 20:47 u2
```


### __FIX__

#### TL;DR

```bash
☩ sudo cat /etc/sssd/sssd.conf
# - If duplicate entries, the final (highest line number) setting wins.
# - Order of blocks matters.
# - Order of params does not matter.
[sssd]
domains             = lime.lan
config_file_version = 2
services            = nss, pam

[domain/lime.lan]
default_shell                   = /bin/bash
ad_server                       = dc1.lime.lan
krb5_store_password_if_offline  = True
cache_credentials               = True
krb5_realm                      = LIME.LAN
realmd_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = lime.lan
use_fully_qualified_names = False
ldap_id_mapping = True
access_provider = ad
# Bogus
#user_mapping = admin:admin@lime.lan
```
- Not valid key of that block : `user_mapping = admin:admin@lime.lan`
- `use_fully_qualified_names = False`


```bash
sudo sss_override user-add admin@lime.lan --name=admin
```
- Untested/unnecessary

```bash
Ubuntu [17:29:11] [1] [#0] ~
☩ ssh admin@a0.lime.lan
admin@a0.lime.lan's password:
Last login: Thu Nov 28 17:29:01 2024 from 172.27.240.169
[admin@a0 ~]$
```

##### SSH Auth using PKI

Setup PKI 

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

#### 1. **Always Specify the Domain**

Continue using the fully qualified username format:

```bash
ssh admin@lime.lan@a0.lime.lan
```

This is the most reliable method, 
as it explicitly tells the system to authenticate against the AD domain.


#### 2. **Set the AD Domain as Default for Login**

If you want to avoid specifying the domain every time, 
configure SSSD to treat the AD domain as the default.

- Edit `/etc/sssd/sssd.conf`:
    ```ini
    [domain/lime.lan]
    use_fully_qualified_names = False
    default_domain_suffix = lime.lan
    ```

- Restart SSSD:
    ```bash
    sudo systemctl restart sssd
    ```

- Test by logging in without specifying the domain:
    ```bash
    ssh admin@a0.lime.lan
    ```

This configuration automatically appends the 
domain `lime.lan` to usernames during authentication.


#### 3. **Add a Domain Alias for Local Convenience**
If you prefer the `admin` format but want it to resolve to `admin@lime.lan`, you can add an alias in `/etc/sssd/sssd.conf`.

- Add a domain mapping:
    ```ini
    [domain/lime.lan]
    user_mapping = admin:admin@lime.lan
    ```

- Restart SSSD:
    ```bash
    sudo systemctl restart sssd
    ```

This approach is less common but can simplify access for specific users.


#### 4. **Test and Verify**
Once you've applied the changes, test authentication:
- Without domain: `ssh admin@a0.lime.lan`
- With domain: `ssh admin@lime.lan@a0.lime.lan`

Additionally, check logs for any errors if authentication still fails:

```bash
sudo journalctl -u sssd -f
sudo tail -f /var/log/secure
```


### &nbsp;
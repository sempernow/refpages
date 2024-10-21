# [Windows Server](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?msockid=05311f3dde09664d0afc0b53dfa16779 "microsoft.com") 2019 | [Docs](https://learn.microsoft.com/en-us/windows-server/)


## Overview

Windows Server 2019 is the operating system that bridges on-premises environments 
with Azure services enabling hybrid scenarios maximizing existing investments. 
Create cloud native and modernize traditional apps 
using containers and micro-services.

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
    - __Domain Services__ ([AD DS](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)) | [Operations](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/ad-ds-operations)
    - __Federation Services__ ([AD FS](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/ad-fs-overview))  
    AD FS enables __Federated Identity and Access Management__ by securely sharing digital identity and entitlements rights across security and enterprise boundaries. Implements OIDC, and OAuth Grant flows. Successor is Microsoft Entra ID.
        - [AD FS OIDC/OAuth Flows v. App Scenarios](https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/overview/ad-fs-openid-connect-oauth-flows-scenarios)
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

## VM on Hyper-V

- Name: `WinSrv2019`
- CPU: `2`
- RAM: 1024-4096 MiB
- Network: `Ethernet`
    - Has DHCP issue; want outside that of gateway. 
    May modify to use Default (Private/Internal). 
    See "DNS Options" WARNING under "Domain Controller Options" (below).
    Also, [ChatGPT](https://chatgpt.com/share/670c59f1-7504-8009-beea-ff2f8d4caff9) .
- Disk: 0-127 GB
    - 14 GB after install.
- ISO: `Win.Server.2019.Standard.1809.Build.17763.3650.En-US..ESD Nov.2022.iso`
- User: `Administrator`
- Pass: `Admin!123`

## On 1st Login

@ Connect window 

1. Select Size: 13nn x nnn
1. Allow discovery: Yes
1. Server Manager (pop up)
    - "Try managing servers with [Windows Admin Center](https://www.microsoft.com/en-us/windows-server/windows-admin-center?msockid=05311f3dde09664d0afc0b53dfa16779 "microsoft.com") (WAC)" 
        - Don't show this message again. (Checked)
        - WAC is a Web UI providing remote access to the server.
          It is a separate install. It is free. 
          It may be installed on the AD server or any other machine.
- Server Setup page 
- Shut Down
    - Hyper-V
        - Virtual Machines 
            - WinSrv2019 
                - "Merge in Progress"  ... 10+ minutes

## Videos : 

- Quick : [Learn AD in 30mins](https://www.youtube.com/watch?v=85-bp7XxWDQ "YouTube")
- Series : [How to &hellip; Windows Server 2019](https://www.youtube.com/watch?v=XZkYV-Tac8U&list=PLxTwjzMO9Zf4FZJ0BTtQlv5iErouqkbkk "YouTub")

TODOs:

- Roles: ADDS, DNS
    - Active Directory Domain Services (ADDS)
        - Domain Controller (DC)
        - Secondary Domain Controller:
            - Read-only Domain Controller (RODC)
    - DNS

DONEs: 

At __Server Manager__, which is the GUI 
and main portal of __Windows&nbsp;Server&nbsp;2019__ Desktop:

- [Install AD DS](https://www.youtube.com/watch?v=0EklBDIZSgc&list=PLxTwjzMO9Zf4FZJ0BTtQlv5iErouqkbkk&index=2) : 
    Menu/Select, in order:
    - Server Manager : Local Server
        -  Computer Name : Change:
            - `Win2019-DC01`
    - IE Enhanced Security Configuration
        - Off @ Admin
        - Off @ User
    - Time zone : Change : EST
    - Reboot
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
                - New forest
                - Root domain name: `DEVOPS.LOCAL`
                - Restore-mode password: Admin!123
            - Domain Controller Options
                - Forest functional level: Windows Server 2012 (From drop-down menu)
                - Domain functional level: Windows Server 2012 (From drop-down menu)
                    - Assure compatibility w/ existing Forest/Domain
                    - DNS Options
                        - WARNING: A delegation for this DNS server cannot be created because authoritative parent zone cannot be found or it does not run Windows DNS infrastructure. If you are integrating with an existing DNS infrastructure, you should manually create a delegation to this DNS server in the parent zone to ensure reliable name resolution from outside the domain `DEVOPS.LOCAL`.
                            - Ignore else reconfigure networking. See [ChatGPT](https://chatgpt.com/share/670c59f1-7504-8009-beea-ff2f8d4caff9)



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


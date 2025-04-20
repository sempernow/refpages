# NFS

## Options for File Sharing between Windows &amp; Linux hosts

- **Samba** | [`wikipedia.org`](https://en.wikipedia.org/wiki/Samba_(software) "Wikipedia.org") | [`samba.org`](https://www.samba.org/ "samba.org") : Samba is a FOSS implementation of the __SMB__ (Server Message Block) __protocol__. Samba runs on Windows and most Linux distros. Suitable for straightforward __file sharing between Windows and Linux systems__, especially in small to medium-sized environments. Samba is convenient because it supports the SMB protocol natively used by Windows, making it simple to configure cross-platform file sharing. Yet larger enterprises often use more advanced or specialized systems, especially when higher performance, scalability, or advanced features are required. 
    - Samba services are implemented as two daemons:
        - `smbd` : Provides the file and printer sharing services.
            - Configuration : Located at either:
                - `/etc/smb.conf`
                - `/etc/samba/smb.conf`
        - `nmbd` : Provides the NetBIOS-to-IP-address name service.
    - SMB Versions:
        - **SMB1** AKA **CIFS**: This version is __deprecated__ and disabled by default on most modern systems because it has many security issues (such as susceptibility to man-in-the-middle attacks) and lacks the encryption and integrity checks present in later versions. Microsoft and other vendors strongly recommend disabling SMB1.
        - [**SMB2**](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/4287490c-602c-41c0-a23e-140a1f137832 "learn.microsoft.com") &amp; **SMB3**: These versions are __current and secure__, with SMB3 being the most recent and providing enhancements such as encryption, improved performance, and better resilience. SAMBA fully supports these versions.

- **NFS** (Network File System): Primarily used in Unix/Linux environments, though it can be used on Windows with a client installation. NFS is often __preferred in Linux-heavy environments__ because it __offers better performance with Linux file systems__. Some organizations use both SAMBA and NFS depending on whether the client is Windows or Linux.

- **NetApp** &amp; **EMC Isilon**: These are dedicated, enterprise-grade __storage appliances__ that support __multi-protocol access__, including **SMB**, **NFS**, and sometimes **iSCSI**. They provide advanced features like snapshotting, replication, and high-availability configurations, which are beneficial for large-scale deployments. 
    - [NFS in vSphere/ESXi environment](https://chatgpt.com/share/6800c8c1-aa1c-4e94-9601-a022f240f7fa "ChatGPT") 
    - [Linux NFS AD Permissions Issues](https://chatgpt.com/share/6718413f-03c0-8009-8b4e-b7435fc7f9ba "ChatGPT")

- **Ceph**: An open-source distributed storage platform that supports multiple interfaces, including __CephFS__ for file storage. Ceph can integrate with SAMBA for SMB shares or directly with NFS for Unix/Linux systems, making it a flexible option for mixed environments.

- **Azure Files** &amp; **AWS FSx**: For enterprises moving to the cloud, managed storage solutions like Azure Files (with SMB and NFS support) or AWS FSx for Windows File Server (SMB support) are becoming popular for hybrid cloud environments. These services are fully managed, scalable, and offer high availability and integration with cloud-native services.

In most enterprises, the choice between these depends on factors like performance requirements, ease of management, security, scalability, and support for disaster recovery.


## NetApp

Runs under ONTAP, a proprietary OS having a Unix-like CLI.

**Use NFSv3**, which abides Linux-client UID/GID permissions, 
requiring only minimal coupling of server-client configurations. 

***NFSv4 uses names*** of users and groups instead, 
and requires evermore coupling of server-client configurations. 
Moreover, if storage consumers include automated provisioners 
(e.g., for containerized workloads),
the highly-coupled if not manual 
configuration requirements are worst fit.

### @ Client machine(s)

```bash
# Remote NFS server (SERVER:EXPORT) params
server=192.168.0.216
export=/remote/export

# Local NFS client mount params
mount=/local/path
options='nfsvers=3,sec=sys,proto=tcp,port=2049,noacl,nolock'

# Prep the local mount point
sudo mkdir -p $mount
sudo chown :$aGID $mount
sudo chmod g+s $mount # So all files created thereunder/after are of group $aGID

# Mount now : does not survive reboot and is not mounted by `mount -a`
sudo mount -t nfs -o "$options" $server:$export $mount

# Mount persistently and by `mount -a` 
cat /etc/fstab |grep $mount ||
    echo "$server:$export    $mount    defaults,$options    0 0" |sudo tee -a /etc/fstab

```
- [Required client services](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#services-required-on-an-nfs-client_mounting-nfs-shares "docs.redhat.com") (RHEL)
- [Enabling client-side caching of NFS content](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#enabling-client-side-caching-of-nfs-content_mounting-nfs-shares "docs.redhat.com")
- `chmod g+s` : SetGID bit (`setgid`) on mount point so all created thereunder inherit parent `GID`
- [Mount __options__](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#frequently-used-nfs-mount-options_mounting-nfs-shares "docs.redhat.com") : "`defaults,...`" 
    - `nfsvers` (NFS version) : Use instead of `nfs` if at RHEL 7+
    - `sec` (Security mode)
        - Use `sys` for authentication of NFS operations by local (client) UNIX UIDs/GIDs (`AUTH_SYS`)
        - Use `krb5` for Kerberos V5 instead.
    - `port`, `proto` : `2049/TCP` is the default for NFS, both `NFSv3` and `NFSv4`, 
  assigned by <def title="Internet Assigned Numbers Authority">IANA</def>.  
  Hence those parameter declarations are often omitted.

@ `/etc/fstab`

```ini
192.168.0.216:/remote/export    /local/path    nfs    defaults,nfsvers=3,sec=sys,port=2049,proto=tcp,noacl,nolock    0 0 
```


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


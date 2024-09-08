# [NFS](https://chatgpt.com/share/6800c8c1-aa1c-4e94-9601-a022f240f7fa "ChatGPT") : ESXi / NetApp

## NetApp 

Runs under ONTAP, a proprietary OS having a Unix-like CLI.

**Use NFSv3**, which abides client UID/GID permissions, 
requiring only minimal coupling of server-client configurations. 

***NFSv4 uses names*** of users and groups instead, 
and requires evermore coupling of server-client configurations. 
Moreover, if storage consumers include automated provisioners 
(e.g., for containerized workloads),
the highly-coupled if not manual 
configuration requirements are worst fit.

### @ Client machine(s)

```bash
srv=192.168.0.216
export=/remote/export
mount=/local/path
opts='nfsvers=3,sec=sys,proto=tcp,port=2049,noacl,nolock'
# Prep mount point
mkdir -p $mount
chown $aUID:$aGID
chmod g+s $mount

# Mount now
mount -t nfs -o "$opts" $srv:$export $mount

# Mount persistently, and by `mount -a` : Append if mount not already declared
cat /etc/fstab |grep $mount ||
    echo "$srv:$export    $mount    "defaults,$opts"    0 0" |sudo tee -a /etc/fstab
```
- [Required client services](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#services-required-on-an-nfs-client_mounting-nfs-shares "docs.redhat.com") (RHEL)
- [Enabling client-side caching of NFS content](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#enabling-client-side-caching-of-nfs-content_mounting-nfs-shares "docs.redhat.com")
- `chmod g+s` : SetGID bit (`setgid`) on mount point so all created thereunder inherit parent `GID`
- [Mount __options__](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_file_systems/mounting-nfs-shares_managing-file-systems#frequently-used-nfs-mount-options_mounting-nfs-shares "docs.redhat.com") : "`defaults,...`" 
    - Use `nfsvers` parameter instead of `nfs` (to declare NFS version) if at RHEL 7+
    - `sec` (Security mode)
        - Use `sys` for authentication of NFS operations by local (client) UNIX UIDs/GIDs (`AUTH_SYS`)
        - Use `krb5` for Kerberos V5 instead.
- Port `2049/TCP` is the default for NFS, both `NFSv3` and `NFSv4`, 
  assigned by <def title="Internet Assigned Numbers Authority">IANA</def>.  
  Hence those parameter declarations are often omitted.

@ `/etc/fstab`

```ini
192.168.0.216:/remote/export    /local/path    nfs    defaults,nfsvers=3,sec=sys,proto=tcp,port=2049,noacl,nolock    0 0 
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


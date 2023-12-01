# [`docker-machine create`](https://docs.docker.com/machine/reference/create/) | [Drivers](https://github.com/docker/docker.github.io/blob/master/machine/AVAILABLE_DRIVER_PLUGINS.md)

- ISSUE @ `docker-machine` @ Cloud (AWS) Machine(s)
    - Not communicating properly; can ssh, can init/join swarm, but fails to properly connect and report engine version etc; vpc and/or security group issue?
        ```bash
        docker-machine ls 
        #... does not report engine version etc.; "unable to connect".
        ```

- [ISSUE @ `v18.09.0`](https://github.com/docker/machine/issues/4608 "BretFisher @ GitHub") [of `boot2docker.iso`](https://github.com/boot2docker/boot2docker/releases/download/v18.09.0/boot2docker.iso). It __breaks Swarm Ingress__, so no internet connectivity; can `ping` but not browse (or `curl`, `wget`, &hellip;) to any exposed port(s) of any service.
    - __Workaround__ by selecting another version, per "`--hyperv-boot2docker-url`" option &hellip;
        ```powershell
        docker-machine create -d hyperv --hyperv-virtual-switch "External Switch" --hyperv-boot2docker-url \
            "https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso" \
            $_VM
        ``` 
    - [FIXED? (Mar 3, 2019) @ `v18.09.2`](https://github.com/docker/docker.github.io/issues/7780#issuecomment-469022882 "github.com/docker/docker.github.io/issues") Yes, this is fixed.
        ```powershell
        PS> docker-machine ssh h1                                                                              ( '>')
          /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
         (/-_--_-\)           www.tinycorelinux.net

        docker@h1:~$ uname -a
        Linux h1 4.19.130-boot2docker #1 SMP Mon Jun 29 23:52:55 UTC 2020 x86_64 GNU/Linux
        ```
        - Use __Git for Windows__ (`MINGW64`) or __PowerShell__ for all `docker-machine` commands. 
            - WSL FAILs @ `docker swarm join ...`; only leader "joins", but not even it is "active" @ "`docker-machine active`" or `docker-machine ls`.
            - WSL 2 FAILs @ all things Docker.


## [`docker-machine create`](https://docs.docker.com/machine/reference/create/)[`--driver hyperv`](https://docs.docker.com/machine/drivers/hyper-v/)

- Must use __Git for Windows__ (`MINGW64`) or __PowerShell__  for all `docker-machine` tool commands
    - WSL cannot create its storage:
        - @ `/c/HOME/.docker/machine/machines/vm2/fixed.vhd`
    - WSL-created nodes fail @ `... swarm join ...`
    - WSL 2 FAILs @ all things Docker.
- OS ([`boot2docker`](https://github.com/boot2docker/boot2docker)) Automatically installed, unlike other drivers, e.g., AWS.
    - Use default (latest); ___earlier-version issue___ (broke swarm) ___is resolved___.



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


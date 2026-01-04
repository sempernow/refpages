# [Vagrant](https://www.vagrantup.com/ "HashiCorp") | [Boxes](https://app.vagrantup.com/boxes/search) | [Docs](https://www.vagrantup.com/docs/index.html)
## [CM](https://www.vagrantup.com/intro/index.html "Configuration Management Intro @ vagrantup.com") for VM-based Development Environments   
>Why not docker container?    
Docker designed for __single process__; no `systemd`, etc.  
Why not `docker-machine` VM?   
Vagrant does __synched folders__, whereas `docker-machine mount` fails @ Win/WSL.

- __Vagrant Project__ is a Vagrant box. It is created at the host.
    - Best practice is to build each project at its own directory,   
    with its own `Vagrantfile`, and use (git) versioning.  

- __Vagrant box__ is a VM, configurated per (__ruby__) `Vagrantfile`, and run as   
a guest machine on a [Vagrant-supported `provider`](https://www.vagrantup.com/docs/providers/) (hypervisor or similar),   
such as VirtualBox, Hyper-V, Docker, AWS EC2, .... The list is growing.

    - Many [current boxes @ `generic/...`](https://app.vagrantup.com/generic), from [Roboxes.org](https://roboxes.org/); [Packer](https://www.packer.io/) project.

    - Namespaced (MAKER/BOX) per Vagrant repo: `username/boxname`
    - Stored globally for current user.   
        - An __immutable initial image__ usable by multiple projects;  
         modifications per project are orthogonal to other projects.  

    - Some [Vagrant boxes](https://app.vagrantup.com/boxes/search?provider=hyperv "Discover Vagrant Boxes :: hyperv") support __Hyper-V__ __`provider`__,   
    but __VirtualBox__ is its [most supported](https://app.vagrantup.com/boxes/search "Discover Vagrant Boxes :: all"). 
- Integrates with [Packer](https://www.packer.io/ "Build Automated Machine Images @ Packer.io"), for [creating new boxes](https://www.vagrantup.com/docs/vagrant-cloud/boxes/create.html).

## Install ([MD](Vagrant.Install.html "@ browser"))

## Usage @ Windows

- @ `SystemDrive`, else fails security check(s). 
- Run as Administrator.
    - @ `cmd`, PowerShell, or `mintty` ([Git-for-Windows](https://gitforwindows.org/)) shell.  
        - @ `mintty`, some vagrant commands fail.

## Commands 

#### Ad hoc

```bash
# Verify (List Commands)
vagrant
# Init (creates VagrantFile)
vagrant init
# Add the Box (Download box image)
vagrant box add $_MAKER/$_BOX
# Start/Boot the VM/OS [per specified provider]
vagrant up [--provider=hyperv|virtualbox|vmware|libvirt|docker|...]  
```

#### Configured 

```bash
# Create(Download)/Start/Boot the image/VM/OS 
vagrant up 
# (Re)Provision (if up already)
vagrant provision
# Restart [+(Re)Provision] 
vagrant reload [--provision] [--debug] 
# Login 
vagrant ssh 
```
- @ box
    ```bash
    vagrant@$_BOX:~$  # In the box!
    # CTRL+D to exit, or ...
    vagrant@$_BOX:~$ logout
    Connection to 192.168.1.23 closed.
    ```
```bash
# SSH config (if issues)
vagrant ssh-config 
# Box ...
vagrant box add|remove|prune|list|...
```

#### VM per se

```bash
# VM commands (pause|resume|stop)
vagrant up|suspend|resume|halt
# Terminate VM (Removes @ Hyper-V)
vagrant destroy
# Remove the (downloaded) Box
vagrant box remove
```  

## Project Setup  ([Getting Started](https://www.vagrantup.com/intro/getting-started/project_setup.html "www.vagrantup.com"))

- Run as __Administrator__ (console with elevated privileges).
- Work from a per-project folder
    ```bash
    # Create/GoTo new project dir
    mkdir $_PROJECT; cd $_PROJECT
    ```
- If using `mintty`, then subshell per `winpty bash` command,   
else can't hide password on SMB connect; error message:   
`"Error! Your console doesn't support..."`
## Select a [Vagrant Box](https://app.vagrantup.com/boxes/search "Vagrant Boxes @ app.vagrantup.com/boxes/")
### [`generic/ubuntu1604` Roboxes.org](https://app.vagrantup.com/boxes/search?provider=hyperv&q=generic&sort=downloads "hyperv :: generic/... @ Vagrant Boxes")   
- [Roboxes](https://roboxes.org), a [Packer](https://www.packer.io/) project, has many current Vagrant boxes.

## Configure
### [`Vagrantfile`](https://www.vagrantup.com/docs/vagrantfile/ "Vagrant Docs @ www.vagrantup.com/docs/...") ([Hyper-V specific](https://www.vagrantup.com/docs/hyperv/configuration.html "Vagrant/docs/hyperv"))  

```ruby
# if Vagrant API Version: "2"
Vagrant.configure("2") do |config|

    # Base box
    config.vm.box = "generic/ubuntu1604"

    # @ Hyper-V 
    config.vm.provider "hyperv" do |h|
        # VM name
        h.vmname = "vagrant.generic.ubuntu1604"
        # Improve spin-up time
        h.enable_virtualization_extensions = true
        # h.differencing_disk = true # depricated
        h.linked_clone = true
    end

    # Network  
    config.vm.network "public_network"
    
    # Synched Folder(s)
    # Disable (SMB) a Synched Folder (default @ Hyper-V)
    config.vm.synced_folder ".", "/vagrant", disabled: true
    # Enable (SMB) a Synched Folder (required @ Hyper-V)
    config.vm.synced_folder ".", "/vagrant"

    # Upload file(s) to guest (VM)
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

    # Run host script(s) @ guest (VM)
    config.vm.provision :shell, path: "bootstrap.sh"
end
```
- [Synched Folders](https://www.vagrantup.com/docs/synced-folders/basic_usage.html)  
    - __Box path__ must be __absolute__; host path can be relative (to project `Vagrantfile` root).
    ```ruby 
    # Enable (SMB) a Synched Folder (required @ Hyper-V)
    config.vm.synced_folder ".", "/vagrant"
    # Synch AWS-creds folder @host to @box
    config.vm.synced_folder "./../../.aws/", "/home/vagrant/.aws"
    # ... + create [Abs/Rel]-host-path, owner, group, mount options
    config.vm.synced_folder "/abs/path/foo/", "/home/vagrant/foo", create: true, 
        owner: "vagrant", group: "vagrant", mount_options: ["uid=1000", "gid=1000"]
    ```

- [Providers](https://www.vagrantup.com/docs/providers/): `hyperv` | `virtualbox` | `vmware` | `libvirt` | `docker` | `...`
- [Provisioners](https://www.vagrantup.com/docs/provisioning/): `shell` | `file` | `docker` | `ansible` | `chef_...` | `puppet_...` | `...`
    ```ruby 
    # Shell Provisioner :: Run script(s) @ box, @ up 

    # Inline (type:shell, key:inline, val:"...")
    config.vm.provision "shell", inline: "echo hello"

    # External script(s); path rel to project Vagrantfile
    config.vm.provision "shell", path: "test1.sh"
    # External script(s); run as "vagrant" user (default is as "root")
    config.vm.provision "shell", path: "test2.sh", privileged: false
    # expect: '/home/vagrant/vagrant-shell.ran2'
    # Guest script; if script is already @ guest
    config.vm.provision "shell",
    inline: "/bin/sh /path/at/guest/guest.sh"

    # Named provisioner (name:bootstrap)
    config.vm.provision "bootstrap", type: "shell" do |s|
        s.inline = "echo foo"
    end
    # Define, for multiple provisioners (Chef uses)
    config.vm.define "web" do |web|
        web.vm.provision "shell", inline: "echo bar"
    end
    config.vm.provision "shell", inline: "echo baz"

    # ... @ `vagrant up`, the run order: hello, foo, baz, bar

    # File Provisioner :: Upload file(s) to guest (VM)
    # will CREATE (sub)folder(s) @ box, if not exist
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
    config.vm.provision "file", source: "~/Vagrant/test/foodir", destination: "root.newfoodir"
    config.vm.provision "file", source: "~/Vagrant/test/foodir", destination: "$HOME/remote/sub.newfoodir"
    ``` 

    - __File Provisioner__ (based) __uploads__ are __run as__ the _SSH user_ (per `vagrant ssh-config`), or as _PowerShell user_. Best practice is to __script the uploads__ using __Shell Provisioner__, explicitly setting the `privileged:` boolean thereof.
- [Networking](https://www.vagrantup.com/docs/networking/basic_usage.html)

    ```ruby 
    # Config for "public" or "private" IP address
    # (Meanings vary per provider; both functioned @ Hyper-V)
    config.vm.network "public_network"
    # Let DHCP server provide IP address
    config.vm.network "private_network", type: "dhcp"
    # Static IP
    config.vm.network "private_network", ip: "192.168.1.55"
    # Port forwarding
    config.vm.network "forwarded_port", guest: 80, host: 8080
    # Specifiy Interface (Adapter; no effect @ Hyper-V)
    config.vm.network "public_network", bridge: "en1: External-GbE"
    ```

    ```ruby
    # Synch folder(s); @host, @box
    config.vm.synced_folder ".", "/vagrant"  # "default"
    ```

    - Hyper-V requires explicitly enabling synch, even for the "default" synched folder, which is the above. SSH uploads may fail without it.

    - If __Synch Folder__(s) __enabled__, then @ `vagrant up` ...

        ```-
        ==> web: Preparing SMB shared folders...
        ...
        web: Username: 
        web: Password (will be hidden): 
        ...
        ```
        
        - If console has no `tty` (fix `mintty` @ `winpty bash`)   
        an error is reported, but the process continues.  

            ```
            Error! Your console doesn't support hidden ...
            ...
            ```

- [Tips & Tricks @ Hyper-V](https://blogs.technet.microsoft.com/virtualization/2017/07/06/vagrant-and-hyper-v-tips-and-tricks/ "technet.Microsoft.com, 2017")  
Vagrant uses `SMBv1`; check if enabled (PowerShell)

    ```powershell
    # Vagrant uses SMBv1; check if enabled 
    Get-SmbServerConfiguration
    ```


# [Vagrant](https://www.vagrantup.com/) :: [Installation](https://www.vagrantup.com/docs/installation/) | [Downloads](https://www.vagrantup.com/downloads.html)

## @ Win10
- Install per [download/installer](https://www.vagrantup.com/downloads.html) (`.msi`) file

- Configure for Hyper-V `provider`, at _user level_,   
so needn't config per project at `Vagrantfile`.

```powershell
# set your default provider on a user level
[Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "hyperv", "User")
# Vagrant uses SMBv1; check if enabled 
Get-SmbServerConfiguration
```

### [@ WSL](https://www.vagrantup.com/docs/other/wsl.html) (beta)


## @ Ubuntu

```bash
# Install VirtualBox + Vagrant (NOT AS ROOT)
sudo apt-get install virtualbox -y
sudo apt-get install vagrant -y
```

- Do not install VirtualBox/Vagrant as __root__, else VirtualBox __denies access by user__;   
this is ___irreversable___; uninstall/reinstall "properly" fails; residue from original install, apparently. 

- Cannot run VirtualBox or any other such 3rd party app in any OS running as a VM in Hyper-V.   
Hyper-V allows __nested virtualization__ ([MD](Hyper-V.Nested-Virtualization.html "@ browser")) only for guests running Hyper-V. 

    - E.g., Vagrant box @ VirtualBox VM on Ubuntu @ Hyper-V VM 

            Vagrant Box:        ubuntu/trusty64
                                 -----------
            Type-2 Hypervisor:   VirtualBox
                                   -------
            OS @ VM @ Hyper-V:   Ubuntu 18.04
                                   -------
            Type-1 Hypervisor:     Hyper-V

        - Nope.  ([MD](Hyper-V.Nested-Virtualization.html "If @ browser"))



## [@ Linux (other)](https://www.vagrantup.com/downloads.html)

# Quick Start
```bash
# Verify
vagrant 
# Popular box (VirtualBox provider)
vagrant box add ubuntu/trusty64
# Init  
vagrant init ubuntu/trusty64
# launch VM 
vagrant up
# login
vagrant ssh  
# debug ssh issues
vagrant ssh-config 
```

### [Tips & Tricks @ Hyper-V](https://blogs.technet.microsoft.com/virtualization/2017/07/06/vagrant-and-hyper-v-tips-and-tricks/ "technet.Microsoft.com, 2017")

```ruby
Vagrant.configure("2") do |config|
    config.vm.box = "hashicorp/precise64"
    config.vm.provider "hyperv"
    config.vm.network "public_network"
    # Disable (SMB) Synched Folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
    # Set provider to Hyper-V
    config.vm.provider "hyperv" do |h|
    # Improve spin-up time
        h.enable_virtualization_extensions = true
        # h.differencing_disk = true # depricated
        h.linked_clone = true
    end
end
```
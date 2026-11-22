## [Nested Virtualization](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization) 

Expose `Intel-VT` extenstions to guest OS.   
Hyper-V nests only Hyper-V.  
Does __not__ allow VirtualBox or any other 3rd party virtualization app. 

```powershell
# Expose VT Extensions
Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
# MAC Spoofing (Networking with Nested VMs)
Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On
```

### App @ VM on VirtualBox on Linux ([MD](VirtualBox.Install.html "@ browser")) @ VM on Hyper-V  (___Fails___.)
> E.g., for running [__Vagrant__](https://www.vagrantup.com/)'s popular `ubuntu/trusty64` box, which requires [__VirtualBox__](https://www.virtualbox.org/) as the `provider`.   
Hyper-V and VirtualBox are mutually exclusive hypervisors; __cannot co-exist__ on one Win-OS, so would be a work-around.

    VM-based-app:     Vagrant|Minikube|...
                         -----------
    Type-2 Hypervisor:    VirtualBox
                           -------
    OS @ VM @ Hyper-V:   Linux Guest
                           -------
    Type-1 Hypervisor:     Hyper-V  

- ___Nope___; Hyper-V nests only Hyper-V.

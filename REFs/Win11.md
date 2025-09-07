# Window 11

## Network Adapters

@ "Control Panel\Network and Internet\Network Connections"

- Properties : UNCHECK (Disable) IPv6 
    - At adapter(s) bound to gateway,
      else DNS latency is some 10x greater.

## Install

Use [__Rufus__]() or [__Ventoy__]() utility to create a bootable USB

### Machine Prep

Gather information for bootable USB creation

```powershell
# Partition Style
(Get-Disk -Number (Get-Partition -DriveLetter $env:SystemDrive.Substring(0, 1)).DiskNumber).PartitionStyle

# EUFI Secure Boot status
Confirm-SecureBootUEFI

```

### Disable Requirement for MS Online Account Sign-in


We want to install a __local-only account__, 
[bypassing requirement of online Microsoft account]
(https://www.tomshardware.com/how-to/install-windows-11-without-microsoft-account)

__Rufus__ has options that handle this when burning to a USB drive.

Otherwise, or additional methods &hellip;

#### Build 24H2

- __Method 1__
    - Follow install menus until "Select Country" page
    - Shift + F10, which launches a __CMD window__. 
        - __`OOBE\BYPASSNRO`__ (at the command prompt),
      which causes computer to reboot.
    - Shift + F10 again
        - __`ipconfig /release`__ (at the command prompt).
    - Close CMD window
    - Resume install.
    - At screen: "__Let's connect you to a network__",
    click "__I don't have Internet__" to continue.
        - "__Continue with limited setup__"

- __Method 2__
    - Follow install menus until User page 
    - Add user name
        - Click Next (button)
    - Do not enter password at Password page.
        - Click Next (button)

##### Method if __After__ Installation

The default OS install has a "Welcome" login 
sequence requiring a Microsoft account.
It blocks user from login until user signs up for MS account, 
enters creds of existing account, 
or selects a button that is effectively a 
"Repeatedly block and bother me again later".

This statement cures that:

```powershell
Set-ExecutionPolicy Unrestricted

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser" -Value 3 -Type DWord

```

#### Builds 26120 and beyond

The OOBE/BYPASSNRO command has been erased and no longer works. 
Instead, there's a new command called __`start ms-chx:localonly`__ that does something similar. Here's how you use it.

- Follow the Windows 11 install process until you get to the Sign in screen.
- Shift + F10, which launches a __CMD window__. 
    - __`start ms-cxh:localonly`__ 


### __Activate__ @ "Not Activated"

How to __Activate via KMS__ using [Microsoft Activation Scripts (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts "GitHub.com") method at a PowerShell terminal:

```powershell
Install-WindowsFeature -Name VolumeActivation -IncludeManagementTools

# Run this statement and select the "KMS" option at its menu
irm https://get.activated.win | iex
```
- [__`get.activated.win`__](iac/get.activated.win)



### OS/Boot Utilities

```powershell
# Add drivers to mounted WIM  
dism /mount-wim /wimfile:D:\sources\install.wim /index:1 /mountdir:C:\Mount
dism /Image:S:\Mount /Add-Driver /Driver:C:\drivers\ /Recurse
dism /unmount-wim /mountdir:C:\Mount /commit
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,bD:\boot\etfsboot.com#pEF,e,bD:\efi\microsoft\boot\efisys.bin D:\ C:\Win11-custom.iso

# Fix boot record
bcdboot S:\Windows /s Z: /f UEFI # Z: is (small ~ 100MB) EFI partition
shutdown /r /t 1 /o

# Fix OS
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```
- Typically, EFI partition is not assigned a letter (`Z:`); use `DISKPART` to assign:
    ```powershell
    diskpart
    ```
    ```powershell
    list disk
    list volume
    list partition
    select disk ...
    list volume
    select volume ...
    select partition ...
    assign letter z
    exit
    ```
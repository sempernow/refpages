# Win10x64 Pro Install/Update Notes | [Win10 Version History](https://en.wikipedia.org/wiki/Windows_10_version_history) 

## 2020-11-27 @ XPC

#### `[Win10-Pro-x64] [2004.19041.630] [20H1] [KB---------] [2020-11-27]`

- Win10 Version 2004, ["May 2020 Update" (`20H1`)](https://en.wikipedia.org/wiki/Windows_10_version_history_%28version_2004%29)
    - Has no `KB...` identifier association.
    - Shortcuts mod ruined; shortcut icon reverted to hideous original.
        - Repaired by reapplying the mod 
            - @ `Shortcut-mod-Win10.v1903-v2004.7z`
    - Update History is no longer visble @ Windows Update window.
    - Stores/saves `C:\Windows.old\` (`30GB`) 

## 2020-06-06 @ XPC 

#### `[Win10-Pro-x64] [1909.18363.778] [19H2] [KB4549951] [2020-04-14]`

## 2020-06-07 :: Win10 @ XPC reinstall 

- Reinstalled; reformatted `C:` and then applied previously captured WIM (`Win10.1903.XPC.[SECURE].wim` `#2`) per `wimlib apply` 
    - Required due to accidental destruction of Registry `HKCR` in its entirety.
        ```shell 
        wimlib-imagex apply D:\Win10.XPC.wim 2 C:
        ```
        - ___Nothing else is required____; 
            - Sans bootfix, booted uneventfully into Windows on first try.
        - Then, successfully performed Windows Update to `19H2`.

## 2019-11-13 @ XPC 

#### `[Win10-Pro-x64] [1903.18362.476] [19H1] [2019-10-08] [KB4524570]`

- Product Key @ 19H1: `00331-10000-00001-AA544` 

Update to version 1903 (`19H1`) per Windows Update. To do so, had to reset to zero all the delays. Such were previously set to avoid unwanted/buggy updates. __To change update schedule__: Settings > "Update & Security" > "Advanced options" 

As with the ISO method used at HTPC, the update reset several settings; folder views, SendTo endpoints, Shortcuts (name and icon-overlay), &hellip;

## 2019-11-11 @ HTPC  

#### `[Win10-Pro-x64] [1903.18362.418] [19H1] [2019-10-08] [KB4517389]`

- Product Key @ 19H1: `00330-80000-00000-AA847`

Update to version 1903 (`19H1`) per ISO; ___needn't use that method___; instead, select faster updates by setting to zero all the delays under "Advanced options", under Settings > "Update & Security" menu. Using the ISO method, several settings were reset to defaults; folder views, SendTo endpoints, Shortcuts (name and icon-overlay), &hellip;


## 2018 @ XPC 

- Product Key @ RS4: `00331-10000-00001-AA205`  
- Product Key @ RS3: `00331-10000-00001-AA821`  

## 2018-09-28 "Docker for Windows" installed (`Hyper-V` enabled)  

- MS OS Hyper-V enabled per Docker or PS   
    - PS Enable: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -Al`
    - PS Validate:  `Get-EventLog -LogName SYSTEM -Source Microsoft-Windows-Hyper-V-Hypervisor`
    - Had repeatedly failed to enable, by any method, under the previous OS build (RS3)  

## 2018-09-28 Update `v1803 build 10.0.17134` (RS4) per Windows install-media (USB) 
- ISO @ "`Win10 Pro x64 [1803.17134.286] RS4 Sep.2018 V.2 Pre-actvd [TeamOS]`"  
    - Install onto `8GB` USB drive per Rufus app.
- Update from online OS, per `setup.exe` in folder of install-media (USB)
    - Select Custom/Upgrade menu option during OS install (_not_ the clean install option).
    - `\Activator` folder containing `.rar` apps added to user's `\Desktop` folder, where it remained for several reboots, until Avast anti-virus detected as malware and moved `activator.exe` to Virus Chest. Not known if it executed, but Product Key has changed since `RS3`. 

## 2018-06-04 ___FAILed___ @ Windows Update `v1803 build 10.0.17134` (RS 4).

## 2018-06-04 Moved system from OCZ SSD to Crucial SSD
- Cloned all partitions of Win 10 system disk, OCZ SSD (`60GB, SATA2`), to Crucial SSD (`110GB, SATA3`), using "Casper 10" app from WinPE (`Gandalf-Win10PEx64 RS3 bld 16299 [2018-05-08]`) @ SD3 USB (`SanDisk Ultra.Fit 32GB USB3.0 SDCZ43-032G-GAM46`). The app automatically matched partition types and sizes. Afterward, shutdown and phycially disconnected the OCZ SSD, and then booted into the "new" Crucial SSD volume without incident. This new clone (Crucial) appears to function normally; reparse points (`SYMLINK`, `SYMLINKD` and `JUNCTION`) all appear to be preserved. Then applied a previously captured "Scratch" volume image (`S:`), using `DISM.exe`, to the remaining free space (`52GB`), after creating a "Simple Volume" there, on the Crucial SSD.

## 2018-06-01 

- On boot, before or after user login, OS reports ___corrupted Defender file___ (`MpClient.dll`); "`MSASCuiL.exe - Bad image`". 
    - ___Fixed by overwriting with last-good from a prior volume capture___ (WIM). Required first, "Administrators" group take ownership and full access of the file, and grant "Administrators" full access to its folder (`C:\Program Files\Windows Defender`). Note that "LastGood" compresses, whereas "Corrupted" does not, which implies corrupted is random.  (Renamed here for observation.)  
````
09/29/2017  09:41 AM         1,072,536 MpClient.Corrupted.dll
06/04/2018  03:31 PM         1,072,748 MpClient.Corrupted.dll.7z
09/29/2017  09:41 AM         1,072,536 MpClient.LastGood.dll
06/04/2018  03:31 PM           362,810 MpClient.LastGood.dll.7z
````

- Windows Update recurringly reports error trying to update Defender:   
    - `Update for Windows Defender antimalware platform - KB4052623 (Version 4.16.17656.18052) - Error 0x80070643`

## 2018-04
- `Win10 Pro x64 [1709.16299.251] RS3 [Gen2].iso`  
- `1709.16299.371` per Windows Update
- Settings &nbsp;> System &nbsp;> About  
    ````
    Edition     Windows 10 Pro
    Version     1709  
    OS Build    16299.371 
    ````  
- Hardware drivers (ASRock H270M-Pro4 mainboard); the only one required is that for sleep (power) function; `INF(v10.1.1.38)\SetupChipset.exe`, which was installed on 2018-05-03. Without it, the scripted sleep command, "`RunDll32.exe powrprof.dll,SetSuspendState`", would cause the machine to __shutdown instead of sleep__. All other drivers for this machine installed per Windows Update, and seem to function without issue for months now.  

- @ DxDiag &nbsp;> Operating System:  
  `Windows 10 Pro 64-bit (10.0, Build 16299) (16299.rs3_release.170928-1534)`
-  [Windows 10 Version/Build History](
https://en.wikipedia.org/wiki/Windows_10_version_history)  

    ````
    2.1 v1507 10.0.10240 2015 Threshold 1 (RTM)
    2.2 v1511 10.0.10586 2015 Threshold 2 (November Update)
    2.3 v1607 10.0.14393 2016 Redstone 1 (Anniversary Update)
    2.4 v1703 10.0.15063 2017 Redstone 2 (Creators Update)
    2.5 v1709 10.0.16299 2017 Redstone 3 (Fall Creators Update) 
    2.6 v1803 10.0.17134 2018 Redstone 4 
    2.7 v1809
    ````

## [Automate OS Config](https://github.com/Disassembler0/Win10-Initial-Setup-Script) per `PowerShell`  

- `Win10.ps1` ([Nifty script](https://github.com/Disassembler0/Win10-Initial-Setup-Script/blob/master/Win10.ps1) for development environment!)  

    ````
    s:\> powershell.exe -NoProfile -ExecutionPolicy Bypass `
    s:\> -File Win10.ps1 [-preset tweaks.txt]
    ````

- `tweaks.txt` (Optional.)

    ````
    # Security tweaks
    EnableFirewall
    EnableDefender

    # UI tweaks
    ShowKnownExtensions
    ShowHiddenFiles
    ````
- `EnableScriptHost` (func @ `Win10.ps1`) :: Required @ `vpn.bat`

    ````powershell 
    PS> Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" `
        -Name "Enabled" -Type DWord -Value 1
    ````

## Config 

- `config.bat`

    ````
    s:\> config.bat CMD_LIB_VARS "ACLs_GROUP ACLs_USER CDROM_V CMD_LIBRARY_PATH CMD_LIB_VARS DOWNLOADS GITREPO GITUSER GOBIN GOPATH GOROOT HOME KEEPAWAKE LANDOMAIN LANMACHINES LANROUTER LANTCROOT MOTHERBOARD PASSGODIR PORTABLE_APPS RAMDISK SCRATCH STATIC_VOL STATIC_DIR STORAGE TAP_DEVICE TEMP TORRENT VERSIONING"
    ````

    ````bash 
    # Sort a space-delimited a string 
    $ echo $varsList | tr " " "\n" | sort | tr "\n" " "
    ````

## Manual Install

- `VSCodeSetup-x64-1.22.2.exe`
- `7z1801-x64.exe`
- `Git-2.16.2-64-bit.exe`
- `Firefox Installer.exe`
- [`Chocolatey`](https://chocolatey.org/install)`.bat` (Run as Admin.) `(v0.10.10)` 

## Automate Install per [Chocolatey](https://chocolatey.org/packages)

- Use `choco.Auto.Pkgs.cmd`  

    ````
    s:\> choco install python -y           3.6.5
    s:\> choco install nodejs-lts -y      8.11.1
    s:\> choco install notepadplusplus -y  7.5.6
    s:\> choco install irfanview -y         4.51
    s:\> choco install pia -y               78.0
    s:\> choco install openvpn -y          2.4.4
    s:\> choco install golang -y          1.10.1
    s:\> choco install mpc-hc -y          1.7.13
    ````

> Regarding Vim, do not install it per se, per Chocolatey or otherwise. That from the [Vim website](https://vim8.org/) is __incompatible__ with Cgywin, and leaves residue on uninstall (See `HKCR_[asterisk]_shell_Vim.reg` for cleanup/removal). Use Cygwin's setup app to install its `vim` package. The Git-for-Windows terminal app (`Git-2.16.2-64-bit.exe`) installs its own `vim` app/version by default. 

## WSL

### [Install](https://docs.microsoft.com/en-us/windows/wsl/install-win10) Windows Subsystem for Linux (WSL) 

1. PowerShell (Enable WSL)  

    ````powershell
    PS> # Run PowerShell as Admin:  
    PS> Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux  
    ````

1. [Microsoft Store](https://www.microsoft.com/en-us/store/p/debian-gnu-linux/9msvkqc78pk6)  (Select/Install distros) 
    - Start Menu &nbsp;> Microsoft Store

### [Usage](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)  

- Equivalent ...  

    ````
    wsl.exe
    bash.exe  
    <distro>.exe
    ````
    ````
    s:\> wsl.exe 
    s:\> wsl [command]
    s:\> :: OR 
    s:\> bash.exe
    s:\> bash -c [command]
    s:\> :: OR
    s:\> debian.exe /?  :: show available commands (per distro-name) 
    s:\> debian.exe     :: launches distro @ CURRENT SHELL ...  

    f06y@XPC:~  
    ````

- Change default user (per distro), e.g., ...

    ````
    > debian.exe config --default-user USERNAME
    ````

- Admin   

    ````bash
    $ sudo su  # MUST use; 'su' FAILs 

    # $HOME dir CHANGE  
    $ sudo vim /etc/passwd  # E.g., from `/home/uZer` to `/mnt/s/HOME`
    # ... edit @ username, then reboot

    # if user is NOT login|default user
    $ usermod -m -d /newhome/username username 
    # else unstoppable parent processes.

    # Reset Password
    $ passwd username
    $ exit
    ````
- Package installs @ Debian

    ````bash 
    $ cat /etc/debian_version       # 9.3; version number 
    $ cat /etc/os-release           # OS Info  

    $ sudo su
    # GNU Dev Tools
    $ apt-get update                   # pkgs version-info update      
    $ apt-get install build-essential  # gcc, make, ...
    $ apt-get install dh-autoreconf    # autoreconf 
    # @ Kali
    $ apt-get dist-upgrade            
    $ apt-get install metasploit-framework  # turn off anti-virus
    # Apps
    $ apt-get install libssl-dev -y      # openssl crypto lib
    $ apt-get install openssh-client -y  # ssh client
    $ apt-get install openssh-server -y  # ssh server
    $ apt-get install man-db -y   # man pages
    $ apt-get install vim -y      # vim editor 
    $ apt-get install strace -y   # debugger
    $ apt-get install rsync -y    # rsync

    # NOT needed; ntfs volumes mounted, per WSL default, @ /mnt/... 
    $ apt-get install ntfs-3g -y  # Debian|Ubuntu
    $ yum install ntfs-3g     -y  # RHEL 

    $ ls -la '/mnt/c/Users/X1'      # fixed-drives automount by default
    ````

- WSL commands passed into `bash -c` are forwarded to the WSL process without modification.

    ````
    s:\> bash -c ls -la            :: depricated   
    s:\> wsl.exe ls -la            :: use this   
    s:\> dir | bash -c "grep foo"  :: pipes work  
    ````

- Currently, the "Insider Build 17643" has `CTRL+C/V` for copy/paste between OSs, but copy/paste per mouse works regardless.  

###  [Distro Management](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)  

- `wslconfig.exe`  
    Manage any|all available (installed) Linux distro(s)    

    ````
    s:\> wslconfig /list /all  
    s:\> wslconfig /unregister <DistributionNames> 
    s:\> wslconfig /setdefault Ubuntu       
    s:\> wslconfig /list 
    ````

- `wsl.conf` @ `%USERPROFILE%`   
    - Configures certain functionality per distro launch @ `/etc/wsl.conf` (???)   
    - By default, sans `wsl.conf`, all fixed drives  (`NTFS`, etal) __automount__ @ `/mnt`, e.g., `/mnt/c`, `/mnt/d`, ...`  

### WSL References  

- [Commands](https://docs.microsoft.com/en-us/windows/wsl/wsl-config )  
- [User Accounts & Permissions](https://docs.microsoft.com/en-us/windows/wsl/user-support)   
- [Interoperability](https://docs.microsoft.com/en-us/windows/wsl/interop#creators-update-and-anniversary-update) [Creators Update]   
## [Disable Automatic Updates](https://www.easeus.com/todo-backup-resource/how-to-stop-windows-10-from-automatically-update.html) 

1. `gpedit.msc` (Group Policy Editor)  
    &nbsp;> Computer Configuration &nbsp;> Administrative Templates  
    &nbsp;> Windows Components &nbsp;> Windows Update   
    &nbsp;> Configure Automatic Updates &nbsp;> Disabled &nbsp;> Apply, OK  
    
    - Or "__Enable__" instead, and select __option #3__, which is the default. It auto-downloads the update(s) and notifies user, but does not auto-install. The user may then update per user action: Start Menu > Settings > Update ...

2. `services.msc` (Services)  
    &nbsp;> Windows Update &nbsp;> Disable  
    - Flaw: restarts automatically, repeatedly, after a while.   

>Regardless, also change the "Update Channel" at Start Menu > Settings > Update ... > Advanced ... > to "__Semi-Annual Channel__", from its default "Semi-Annual Channel (Targeted)". The former is intended for enterprises; the latter for __Guinea Pigs__. That is, the update is pushed to the "Targeted" channel to work out the bugs, but not to the non-targeted until it actually works. Also, at that window, select the maximum delays 365/30 days, at the respective pull-down menus, which quiets the update-reminder spam; recurring pop-ups at the taskbar.   

## Disable Telemetry 
- `gpedit.msc`  
    &nbsp;> Computer Configuration &nbsp;> Administrative Templates  
    &nbsp;> Windows Components &nbsp;> Data Collection and Preview Builds  
    &nbsp;> Telemetry

## Disable Cortana 
- `gpedit.msc`  
    &nbsp;> Computer Configuration &nbsp;> Administrative Templates   
    &nbsp;> Windows Components &nbsp;> Search  
    &nbsp;> Allow Cortana &nbsp;> Disabled &nbsp;> Apply, OK

- "Cortana & Search Settings"   
    Start &nbsp;> Cortana &nbsp;> Settings &nbsp;> Privacy   
    &nbsp;> Speech, inking & typing &nbsp;> Toggle off all  

### Nope, it's still running.

- [Disable Cortana (SearchUI.exe)](https://codesport.io/mining-tutorials/disable-searchui-exe-disable-cortana-on-windows-10/)  
This method moves (renames) its directory.
    ````
    :: Disable
    C:\> taskkill /f /in SearchUI.exe
    C:\> move %windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy ^
         %windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.000

    :: Restore 
    C:\> move %windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.000 ^
         %windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy
    ````

## OneDrive 
- [Disable](https://support.office.com/en-us/article/turn-off-disable-or-uninstall-onedrive-f32a17ce-3336-40fe-9c38-6efb09f944b0?ui=en-US&rs=en-US&ad=US)   
    OneDrive &nbsp;> ... More   
    &nbsp;> Settings &nbsp;> Account &nbsp;> Unlink this PC &nbsp;> Unlink account 

- Remove from sight (File Explorer) 
    - per `gpedit.msc`   
 (*FAILs to remove from File Explorer.* )   
    &nbsp;> Computer Configuration &nbsp;> Administrative Templates   
    &nbsp;> Windows Components &nbsp;> OneDrive   
    &nbsp;> "Prevent the usage of OneDrive for file storage"   
    &nbsp;> Enable  (Reboot.)  

    - per `regedit`  
    `HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}`  
    &nbsp;> `System.IsPinnedToNameSpaceTree` &nbsp;> `0`  

## KMS (Key Managment Service)
- List Activated Clients on KMS Server, per `PowerShell`. This is only for OEM Volume License installs. 

    ````powershell
    PS> $(foreach ($entry in (Get-EventLog -Logname "Key Management Service")) `
        {$entry.ReplacementStrings[3]}) | sort-object -Unique
    ````

    (Running this showed none.)

### &nbsp;


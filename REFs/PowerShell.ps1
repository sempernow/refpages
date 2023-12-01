Exit
# PowerShell is a task-based command-line shell and scripting language built on .NET.
# https://docs.microsoft.com/en-us/powershell/

# Get drives
Get-DiskImage
## OR
Get-Volume 

# Mount/Unmount ISO file
Mount-DiskImage -ImagePath C:\TEMP\a.iso
Dismount-DiskImage -ImagePath C:\TEMP\a.iso

# List DISABLED SERVICES 
$( Get-Service | Where-Object {$_.StartType -eq "Disabled"} ) > services.disabled.log
# FAILS @ SOME FILE PATHs 
# SOLUTION @ CMD 
powershell "$( PS-COMMAND )" > services.disabled.log

# Print STDOUT to FILE 
... | Out-File "$_PATH" -Append

# PS Version info
$PSVersionTable      
# OS Version, e.g., "Windows 10 Pro [1803.17134.345]"
$_os = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")
$_os.ProductName + ' [' + $_os.ReleaseId + '.' + $_os.CurrentBuild + '.' + $_os.UBR + ']'

# Module GALLERY  https://www.powershellgallery.com
Install-Module -Name $ModuleName [-Scope CurrentUser]

# Module Import
Import-Module $ModuleName
    # DockerCompletion Module (1K downloads) https://github.com/matt9ucci/DockerCompletion
    # Install from PowerShell Gallery
    Install-Module DockerCompletion 
    # DockerMsftProvider (500K downloads)
    Install-Module -Name DockerMsftProvider 

    # Windows Update Module :: PSWindowsUpdate  https://www.powershellgallery.com/packages/PSWindowsUpdate/2.1.1.2
    Install-Module -Name PSWindowsUpdate 
        Add-WUOfflineSync
        Add-WUServiceManager
        Get-WUHistory
        Get-WUInstall
        Get-WUInstallerStatus
        Get-WUList
        Hide-WUUpdate
        Invoke-WUInstall
        Get-WURebootStatus
        Get-WUServiceManager
        Get-WUUninstall
        Remove-WUOfflineSync
        Remove-WUServiceManager 
        Update-WUModule  

        # Else use UsoClient.exe  https://www.thewindowsclub.com/how-to-run-windows-updates-from-command-line-in-windows-10
        USOClient.exe 

# Profile.ps1 :: Show Path 
$Profile
# Profile.ps1 :: Edit
notepad $Profile  

# Set Prompt  https://ss64.com/ps/syntax-profile.html
function Global:prompt {"$PWD`nPS>"}

# Run PS COMMAND(s) from CMD.exe
Powershell.exe -Command "& {Enable-NetAdapterBinding –InterfaceAlias '%_adapter%' –ComponentID ms_tcpip6}"

# Run PS SCRIPT from CMD.exe
Powershell.exe -File 'C:\foo bar\foo.ps1' arg1 arg2

# Variable :: Get/Set
$_foo
$_foo = "bar"

# Print an Environment variable 
$Env:USERPROFILE 

# Change Dir 
Set-Location -Path $_NewLocation

# Names are: VERB-NOUN 
Get-Date                      # date/time
Get-Command *-Date            # list such cmdlets
Get-Help Get-Date             # all help about Get-Date cmdlet
Get-Command Get-Date -Syntax  # all syntax
Get-Date | Get-Member         # list objects of Get-Date cmdlet

# Allow scripts
set-executionpolicy RemoteSigned
get-executionpolicy

# Windows Update log (sent to USERPROFILE/Desktop)
Get-WindowsUpdateLog

# ===================================

# Registry Keys :: Get/Set
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Get-ItemProperty $key 
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowSuperHidden 1
Stop-Process -processname explorer

# Network Adapters :: Get/Set
    # Adapter/Network Category (Public|Private)
        Get-NetConnectionProfile
        $_profile = Get-NetConnectionProfile -InterfaceIndex 25 -Name Unident*
        $_profile.NetworkCategory = "Private"
        Set-NetConnectionProfile -InputObject $_profile
    # Adapter Metric (Priority; lower is higher)
        Get-NetIPInterface
        Set-NetIPInterface -InterfaceIndex 7 -InterfaceMetric 3
        # Reset to Automatic 
        Set-NetIPInterface -InterfaceIndex 7 -AutomaticMetric enabled 

    # Disable/Enable IPv6 per Adapter 
        $_adapter = "vEthernet (External-GbE)"    # @ HTPC
        $_adapter = "vEthernet (External Switch)" # @ XPC
        Get-NetIPInterface –InterfaceAlias $_adapter
        Disable-NetAdapterBinding –InterfaceAlias $_adapter –ComponentID ms_tcpip6
        Enable-NetAdapterBinding  –InterfaceAlias $_adapter –ComponentID ms_tcpip6

# Network :: Test Connection (ping); returns 0 on success; nothing otherwise 
$(Test-Connection -ComputerName $SERVER -ErrorAction SilentlyContinue -Count 1).StatusCode 

# Get MAC Address
$(Get-NetAdapter -InterfaceAlias 'vEthernet (Default Switch)*').MacAddress

# Attempt to remove disconnected Interfaces of Default Switch; Win10 auto-spawns one per reboot
$_adapter = $(Get-NetAdapter -InterfaceAlias 'vEthernet (Default Switch)*' | Where-Object status -eq 'disconnected').Name 
# FAIL ...
Get-NetAdapter -InterfaceAlias 'vEthernet (Default Switch)*' | Where-Object status -eq 'disconnected' | Remove-VMNetworkAdapter  -ManagementOS -VMNetworkAdapterName
# FAIL ...
Remove-VMNetworkAdapter -ManagementOS -VMNetworkAdapterName 'vEthernet (Default Switch)*'  | Where-Object status -eq 'disconnected'

# Try ...
$_adapter = $(Get-NetAdapter -InterfaceAlias 'vEthernet (Default Switch)*' | Where-Object status -eq 'disconnected').MacAddress
Get-VMNetworkAdapter | Where-Object MacAddress -eq $_adapter | Remove-VMNetworkAdapter 


# Windows Error Reporting :: Get/Set
Get-WindowsErrorReporting
Disable-WindowsErrorReporting
Enable-WindowsErrorReporting


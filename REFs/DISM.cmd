@echo off
:: --------------------------------------------------------------------
::  DISM.exe :: Deployment Image Servicing and Management (DISM) Tool
:: --------------------------------------------------------------------
call _edit.bat "%~f0" 
if %ERRORLEVEL% GTR 0 ( notepad "%~f0" )
GOTO :EOF
*********

:: Check for Windows OS errors while OS is online
DISM.exe /Online /Cleanup-Image /CheckHealth
:: Fix Windows OS errors while OS is online, ONLY IF /CheckHealth reports "repairable"
DISM.exe /Online /Cleanup-Image /ScanHealth
:: per Windows Update ... 
DISM.exe /Online /Cleanup-image /Restorehealth
:: per alternate source
DISM.exe /Online /Cleanup-Image /RestoreHealth /Source:C:\RepairSource\Windows /LimitAccess
:: Advised to run System File Checker (SFC) tool AFTER using the DISM tool.
sfc /scannow

:: Shrink/Cleanup WinSxS folder (delete previous versions of updated components)
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
:: Shrink/Cleanup Service Packs (remove any backup components needed for uninstallation)
Dism.exe /online /Cleanup-Image /SPSuperseded

:: OS backup params
set _WIMdir=D:\1 Data\Disk Images\___Volumes\System-WIMs\XPC\Win10x64.Pro.RS4
set _source=C:
set _target=R:\test
set _wim=%_WIMdir%\Win10.XPC.RS4.wim
set _name=Win10x64.Pro.RS4.XPC [59GB] [2018-09-30]
set _descr=1803.17134.286 RS4 +Hyper-V +Docker

:: Capture
DISM.exe /Capture-Image /ImageFile:"%_wim%" /CaptureDir:"%_source%" /Name:"%_name%" /Description:"%_descr%" /ConfigFile:"%_cnf%"

:: Append 
DISM.exe /Append-Image /ImageFile:"%_wim%" /CaptureDir:"%_source%" /Name:"%_name%" /Description:"%_descr%" /ConfigFile:"%_cnf%"

:: Apply [Extract] 
DISM.exe /Apply-Image /ImageFile:"%_wim%" /Index:%_index% /ApplyDir:"%_source%"

:: Info @Win10
DISM.exe /Get-ImageInfo /ImageFile:"%_wim%"
    
:: Info @Win7
DISM.exe /Get-WimInfo /WimFile:"%_wim%"

:: Split WIM into multiple SWM files
DISM.exe /Split-Image /ImageFile:D:\sources\install.wim /SWMFile:E:\sources\install.swm /FileSize:3800

:: =========================================================================
:: Win 10 [capture/append per DISM is NOT available @ Win 7]

:: Capture DISK to wim, e.g., OFFLINE SYSTEM drive [@ WinPE session]

  DISM /Capture-Image /ImageFile:<path_to_wim_file> /CaptureDir:<source_path> /Name:<image_name>  /ConfigFile:<configuration_file.ini>
    
    [/Description:<image_description>] [/ConfigFile:<configuration_file.ini>] {[/Compress:{max|fast|none}] [/Bootable] | [/WIMBoot]} [/CheckIntegrity] [/Verify] [/NoRpFix] [/EA]

  :: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/capture-images-of-hard-disk-partitions-using-dism

:: Capture MOUNTED wim TO NEW wim

  DISM /Capture-Image /ImageFile:"%_wim%" /CaptureDir:D:\Mount /Name:"%_name%" /Description:"%_descr%" /ConfigFile:"%_cnf%"

:: Unmount a mounted wim; save or discard changes [EITHER/ONE]

  DISM /Unmount-Wim /mountdir:D:\Mount /commit 
  DISM /Unmount-Wim /mountdir:D:\Mount /discard 

:: Mount wim onto a target-folder [for modification]

  DISM /Mount-Wim /WimFile:"%_wim_path%" /index:2 /MountDir:"%_mount_path%"

:: Apply [system] wim to drive-root; make bootable

  DISM /Apply-Image /ImageFile:K:\Sources\install.wim /Index:1 /ApplyDir:C:\ /Bootable
    
    :: Then, if initial OS install, use BCDBOOT.exe to add/fix boot records, e.g., ...
    
      C:\Windows\System32\BCDBOOT C:\Windows
      
    :: Windows Install per DISM 
    ::
    ::  - Boot into Windows Install media [USB or such]
    ::  
    ::  - SHIFT+F10 for command prompt; 
    ::    partition, then apply images per partition, e.g., ...
    ::  
    ::    DISKPART /s F:\CreatePartitions-UEFI.txt
    ::    
    ::    then enter DISM command[s]; see "Apply" section, above


:: Slipstream Drivers into a WinPE image 

  :: Mount 

    DISM /Mount-Wim /WimFile:C:\mExtract\sources\boot.wim /Name:"Win7PE_x86" /MountDir:c:\mount

  :: Add the USB 3.0 driver

    DISM /Image:C:\mount /Add-Driver /Driver:R:\USB_Drivers\x86 /Recurse

  :: Unmount/Save/Commit

    DISM /unmount-Wim /mountdir:c:\mount /commit

:: Add Windows Update a Windows Install Image with KBxxx...
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/add-updates-to-customized-windows-and-winpe-images

  :: Mount the 'install.wim'
  md C:\mount\Windows
  Dism /Mount-Image /ImageFile:"C:\Images\install.wim" /Index:1 /MountDir:C:\mount\Windows

  :: Add the 'KBxxxxxxxx-x64.msu' package
  Dism /Add-Package /Image:C:\mount\Windows /PackagePath:C:\MSU\Windows10-KBxxxxxxx-x64.msu /LogPath:AddPackage.log

  :: Unmount
  Dism /Unmount-Image /MountDir:C:\mount\Windows /Commit

  :: Recommended: Boot the image to complete the update process, and then clean up the image
  :: 1. Boot a reference device to Windows PE.
  :: 2. Press Ctrl+Shift+F3 at the OOBE screens to enter AUDIT MODE.
  :: 3. Open the Command Prompt as an administrator.
  :: 4. Clean up the Windows image. Use '/ResetBase' ONLY NOW, after PC booted into audit mode.
  Dism /Cleanup-Image /Online /StartComponentCleanup /ResetBase

:: REF [2018-04-16]
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows

    :: Command-Line Options [2017-05-02]
    :: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14

:: CONFIG (.ini)
[ExclusionList]
\$ntfs.log
\hiberfil.sys
\pagefile.sys
\swapfile.sys
"\System Volume Information"
\RECYCLER
\$Recycle.Bin
\Windows\CSC
\TEMP\*
\CACHE\*
\Intel\*
\PORTABLE_APPS\*
\Dropbox\*
\tools\Cygwin\dev\*
\Cygwin\dev\*
\Users\X1\AppData\Local\Packages\TheDebianProject*
\Windows\SoftwareDistribution\Download\*

[CompressionExclusionList]
\WINDOWS\inf\*.pnf
*.7z
*.avi
*.cab
*.cbr
*.deb
*.gif
*.jpg
*.mkv
*.mp3
*.mp4
*.png
*.tgz
*.txz
*.wim
*.xz
*.zip
*.rar
*.rpm

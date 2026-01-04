# Windows 11 Repair 

Open a PowerWhell terminal __run as Administrator__

```powershell
DISM /Online /Cleanup-Image /RestoreHealth

```

Else

```powershell
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

Example output

```plainteext
Microsoft Windows [Version 10.0.26100.1742]
(c) Microsoft Corporation. All rights reserved.

C:\Users\X1>DISM /Online /Cleanup-Image /RestoreHealth

Deployment Image Servicing and Management tool
Version: 10.0.26100.1150

Image Version: 10.0.26100.1742

[==========================100.0%==========================] The restore operation completed successfully.
The operation completed successfully.
```

Else 

```powershell
# Mount Windows-11-Install ISO using "Open With ... Windows Explorer ", and then run : 

# Find index 
dism /Get-WimInfo /WimFile:D:\Sources\install.wim

# Set to proper index, e.g., 6
DISM /Online /Cleanup-Image /RestoreHealth /Source:D:\Sources\install.wim:6 /LimitAccess

```

Else

- Create installation USB of downloaded [Windows 11 Disk Image (ISO)](https://www.microsoft.com/en-us/software-download/windows11) using [__`rufus`__](https://rufus.ie/en/)
    - Select Bypass TPM
    - Bypass all the Microsoft nonsense
- Reboot and Disable TPM at UEFI menu
- Run `setup.exe` of the USB volume (Windows 11 Installation)
- Choose __Upgrade this PC__ now and select __Keep personal files and apps__.

Else 

- Mount Windows 11 install ISO
- Run `setup.exe` from the mounted drive.
- Choose __Upgrade this PC__ now and select __Keep personal files and apps__.
- Follow the installation process.


Else disable TPM and then try again

- Open `regedit`
- `HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup`
- Right-click in the right pane → New → DWORD (32-bit) Value.
- `AllowUpgradesWithUnsupportedTPMOrCPU`
- Double-click it, set Value data to `1`, and click OK.
- Close `regedit`
- Restart

Else 

If Windows still blocks installation, delete `appraiserres.dll` from the USB.

### &nbsp;


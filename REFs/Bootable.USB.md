# [Create Bootable Windows 10 USB](http://www.intowindows.com/install-windows-10-from-usb-drive/)

## Using the Rufus app ...

- Partition Type:  
`MBR` ([Master Boot Record](https://en.wikipedia.org/wiki/Master_boot_record "Wikipedia")) scheme for `BIOS` or `UEFI` (`2TB` partition limit).  
`GPT` ([GUID Partition Table](https://en.wikipedia.org/wiki/GUID_Partition_Table "Wikipedia")) scheme for `UEFI` only.  

- File System:  
`NTFS` for `BIOS` machine (faster file transfers).  
`FAT32` for `UEFI` or `BIOS` machines.  

## Manually ...

### 1. Partition and format the USB drive (`disk 1`).
- `DiskPart.exe`  
    - if UEFI machine  

    ````
    SELECT DISK 1
    CLEAN
    CONVERT GPT
    CREATE PARTITION PRIMARY
    ACTIVE
    FORMAT FS=FAT32 QUICK 
    ASSIGN
    EXIT
    ````  

    - if __not__ UEFI machine  

    ````
    SELECT DISK 1
    CLEAN
    CONVERT MBR
    CREATE PARTITION PRIMARY
    ACTIVE
    FORMAT FS=NTFS QUICK 
    ASSIGN
    EXIT
    ````  

### 2. Copy Boot Config Data (BCD).

- @ Windows OS at drive `C:`, and USB at drive `K:` &hellip; 
    - Using [`BCDBoot.exe`](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di "BCDBoot Command-Line options @ docs.microsoft.com")    
        ````
        bcdboot.exe C:\Windows /S K: /F ALL
        ````  
- @ Windows Install ISO __mounted__ at drive `J:`, and USB at drive `K:` &hellip;  
    - Using [`BCDboot.exe`](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di "BCDBoot Command-Line options @ docs.microsoft.com")  
        ````
        bcdboot.exe J:\BOOT /S K: /F ALL
        ````  
    - Using `BOOTSECT.EXE` (legacy; Windows XP)  
        ````
        PUSHD J:\BOOT
        bootsect.exe /NT60 K:
        ````  

>Can specify machine firmware type; `/F UEFI|BIOS|ALL`.

### 3. Copy all files from mounted ISO (`J:`) to USB (`K:`).
- `robocopy.exe J: K: /s`  

# &nbsp;
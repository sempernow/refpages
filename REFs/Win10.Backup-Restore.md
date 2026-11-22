# Windows 10 Sytem Partition Restore 

```
wimlib-imagex apply D:\Win10.XPC.wim 2 C:
```

# Windows 10 System Partition(s) Backup
# 2018+
## [`wimlib` CLI tool](https://wimlib.net/)  
### Capture/Append the system partition as a `.WIM` file.
Supposedly, `wimlib` can capture Win10 while OS is online,  
but __best to do offline__, such as __from Windows PE OS__. 
#### Params

```shell
set _WIMdir=%~dp0
set _source=C:
set _wim=Win10.RS4.XPC.M.2-NVMe.wim
set _name=2019-05-05 @ 110GB NVMe SSD
set _descr=[Win10-Pro-x64] [1803.17134.590] +nvm +Yarn +VScode-extensions
set _config=--config="%~dp0wimlib.win10.conf"
```

#### Capture

```shell
wimlib-imagex.exe capture "%_source%" "%_WIMdir%%_wim%" "%_name%" "%_descr%" %_config%
```

#### Append

```shell
wimlib-imagex.exe append "%_source%" "%_WIMdir%%_wim%" "%_name%" "%_descr%" %_config%
```

#### Info

```shell
wimlib-imagex.exe info "%_WIMdir%%_wim%" > "%_WIMdir%%_wim%.log" 
```

# Older &hellip;
## per DISM (`.wim`) files
Use the DISM tool.
## per Windows 7 method; `.vhdx` files
````
Start Menu -> Settings -> Backup -> "More options" -> "See advanced settings" -> "System Image Backup" -> "Create a system image"
````
User selects the target drive and source partitions. The application first creates folders ...  
````
`{DRIVE}:\WindowsImageBackup\%COMPUTERNAME%
    \Backup YYYY-MM-DD NNNNNN
```` 
... and then generates the backup files (`.vhdx` and `.xml`) thereunder, for all selected partitions. By default, it selects all required partitions, including the boot (EFI) and system (Primary) partitions. Unlike the DISM (`.wim`) method, these (`.vhdx`) are __uncompressed__ images.
### &nbsp;

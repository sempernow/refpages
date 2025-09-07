# WSLtty ([`mintty/wsltty`](https://github.com/mintty/wsltty "@ GitHub"))

>UPDATE : WSLtty ***does not support*** WSL v2

```powershell
%USERPROFILE%\AppData\Local\wsltty\bin\mintty.exe --WSL="Ubuntu-18.04" --configdir="%USERPROFILE%\AppData\Roaming\wsltty" -
```
- At "Target" of distro Shortcut file(s) pinned to Start Menu.

## Integrated into Windows File Explorer 

__Folder Context menu__ items per Registry keys referencing a central batch script, 
handling both `WSLtty` and `ConEmu` modes, 
per environment variable; `WSL_MODE`, `WSL_DISTROS` (See `config.bat`).

### [`LinuxHere.cmd`](file:///c:/Program%20Files/_unregistered/cmd_library/LinuxHere.cmd "@ cmd_library")

### Registry keys @ `HKCR`  

```reg
[HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu]
@="Linux Ubuntu"
"Icon"="C:\\ICONS\\Apps\\Linux.Ubuntu.ico,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu\command]
@="C:\\windows\\system32\\cmd.exe /c \"C:\\Program Files\\_unregistered\\cmd_library\\LinuxHere.cmd\" ubuntu"
```

- Per distro.
- Issue: No such keys set @ `HKCR\Directory\shell\...` because starts at _parent folder_, not selected folder. Need to pass selected folder to this script. (`Directory\Background` handles user select inside any folder, whereas `Directory\shell` handles user select at a selected folder.)

## Install 

```bat
choco install wsltty
```

- @ `%LOCALAPPDATA%\wsltty`

### Installation process generates batch/shortcut scripts:

```bat
%LOCALAPPDATA%\wsltty\bin\mintty.exe -i "%ICONpath%" --WSL="%DISTROname%" --configdir="%APPDATA%\wsltty" -
```

- Two for each installed Linux distro. 
    - One starting at `$HOME` dir
    - One staring at `%USERPROFILE%` dir
    
    E.g., [`Ubuntu.bat`](file:///c:/Users/X1/AppData/Local/wsltty/Ubuntu-18.04.bat "@ %LOCALAPPDATA%\wsltty")

- If not distro name, then default distro is used.

>The batch/shortcut file generations require user to manually launch a post-install batch script. See `choco` report on install.

## Commandline options for `mintty.exe`: 

- See [`man mintty`](man.mintty.html) (At batch, not bash, terminal.)


 
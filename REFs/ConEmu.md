# [ConEmu](https://conemu.github.io/ "github.io") | [Maximus5/ConEmu](https://github.com/Maximus5/ConEmu "GitHub Repo")
Tabbed terminal window; integrates all Win-compatible shells, and into Win Explorer

## FIX @ 2020-10-09

Launch of `wsl` (@ ConEmu) was [FAILing after Win Update and/or WSL 2](https://stackoverflow.com/questions/58794164/conemu-doesnt-work-with-wsl-since-windows-update "Jun 2020 @ StackOverflow.com") attempt (`wsl --set-version Ubuntu-18.04 2`). This is the fix:

```shell
wsl.exe -d Ubuntu-18.04 -cur_console:am:""
```
- To add icon, enter "`/icon PATH`" at "Task parameters" text box, e.g.,
    ```plaintext
    /icon "C:\ICONS\Apps\Linux.Ubuntu.ico"
    ```

Sans distro specificity &hellip;

```shell
wsl.exe -cur_console:am:"":
```



## Refererences  
- [`ConEmu.exe` command line switches](https://conemu.github.io/en/ConEmuArgs.html "GitHub.io/ConEmu Args") 

- [`{{Bash::WSL}}`](https://conemu.github.io/en/BashOnWindows.html "GitHub.io/ConEmu/BashOnWindows")
- [Switches](https://conemu.github.io/en/NewConsole.html "GitHub.io/ConEmu") :: `-cur_console` | `-new_console` ([difference](https://conemu.github.io/en/NewConsole.html#the-difference))
    - `-cur_console:m:/foo` &mdash; (mount); prepend `/foo` to path.  
    - `-cur_console:m:""` &mdash; (mount); strip all prefixes from path.
- [Split Screen @ Active Pane](https://conemu.github.io/en/SplitScreen.html#From-your-shell-prompt "GitHub.io/ConEmu/SplitScreen")
    - `CTRL`+`SHIFT`+`O`  (vertically)  
    `CTRL`+`SHIFT`+`E`  (horizontally)  

## Settings 

- [@ `CmdInit.cmd`](file:///c:/Program%20Files/ConEmu/ConEmu/CmdInit.cmd)  > Set command prompt 

- [@ `ConEmu.xml`](file:///c:/HOME/.config/ConEmu/ConEmu.xml)  < Settings Export 

- @ ConEmu > Settings > `{Shells::cmd (Admin)}`

    ```shell
    cmd.exe /k "%ConEmuBaseDir%\CmdInit.cmd" -new_console:a
    ```

- @ ConEmu > Settings > `{Bash::WSL}`    
    
    ```shell
    set "PATH=%ConEmuBaseDirShort%\wsl;%PATH%" 
        & %ConEmuBaseDirShort%\conemu-cyg-64.exe --wsl 
        -cur_console:pm:""
    ```
    - Task parameters: `/icon "C:\ICONS\Apps\Linux.tux.ico"`

- @ ConEmu > Settings > `{Bash::Ubuntu}`   

    ```shell
    cmd.exe /c wslconfig /setdefault Ubuntu-18.04 
        & set "PATH=%ConEmuBaseDirShort%\wsl;%PATH%" 
        & %ConEmuBaseDirShort%\conemu-cyg-64.exe --wsl 
        -cur_console:am:"":C:"%ConEmuDrive%\ICONS\Apps\Linux.Ubuntu-18.04.ico"
    ```

- @ ConEmu > Settings > `{Bash::Git bash (Admin)}` 

    ```shell
    set "PATH=%ConEmuDir%\..\Git\usr\bin;%PATH%" 
        & "%ConEmuDir%\..\Git\git-cmd.exe" --no-cd 
            --command=/usr/bin/bash.exe -l -i 
        -cur_console:a:p:m:"" 
        -cur_console:t:"MINGW64 (Admin)"
    ```
    
- @ ConEmu > Settings > `{Bash::Git bash (Admin)}` [@ `winpty`](https://github.com/rprichard/winpty "rprichard/winpty @ GitHub") | [about](https://stackoverflow.com/questions/48199794/winpty-and-git-bash "@ StackOverflow.com")

    ```shell
    set "PATH=%ConEmuDir%\..\Git\usr\bin;%PATH%" 
        & "%ConEmuDir%\..\Git\git-cmd.exe" 
            --no-cd 
            --command=/usr/bin/winpty.exe 
                /usr/bin/bash.exe -l -i 
        -cur_console:a:p:t:"MINGW64 (Admin)"
    ```

- @ ConEmu > Settings > `{Bash::CygWin (Admin)}`

    ```shell
    set "PATH=%ConEmuDir%\..\Git\usr\bin;%PATH%" 
        & "%ConEmuDir%\..\Git\git-cmd.exe" 
            --no-cd 
            --command=%ConEmuBaseDirShort%\conemu-msys2-64.exe 
                /usr/bin/bash.exe -l -i 
        -cur_console:ap
    ```

## @ `script.cmd` 

- WSL @ ConEmu 

    ```shell
    wslconfig.exe /setdefault "%_DISTRO_FULLNAME%"
    start ConEmu64.exe -Single ^
        -run C:\Windows\System32\wsl.exe ^
        -cur_console:am:"" ^
        -cur_console:C:"%ConEmuDrive%\ICONS\Apps\Linux.%_DISTRO_.ico"
    ```

    - See [`LinuxHere.cmd` @ `cmd_library`](file:///C:/Program%20Files/_unregistered/cmd_library/LinuxHere.cmd).  
        - Used to integrate `wsl.exe` app-launch into Windows Explorer (context menu).  
    - Sets default distro, then lauches it at a ConEmu terminal. 
        - Single instance; new tab at existing ConEmu window, else new window; `-Single`  
        - Prefix path, e.g., on drag-n-drop (POSIX-converted); `-cur_console:am:"PX"`   
        - Set tab icon; `-cur_console:C:"ICON_PATH"`

## @ Explorer (folder) Context Menu   
### `HKCR\Directory\Background\shell\...`

```powershell
; WSL
[HKEY_CLASSES_ROOT\Directory\Background\shell\WSL]
@="WSL"
"Icon"="C:\\ICONS\\Apps\\Linux.tux.ico,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\WSL\command]
@="C:\\windows\\system32\\cmd.exe /c \"C:\\Program Files\\_unregistered\\cmd_library\\LinuxHere.cmd\""

; Ubuntu
[HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu]
@="Linux Ubuntu"
"Icon"="C:\\ICONS\\Apps\\Linux.Ubuntu.ico,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu\command]
@="C:\\windows\\system32\\cmd.exe /c \"C:\\Program Files\\_unregistered\\cmd_library\\LinuxHere.cmd\" ubuntu"

; ConEmu
[HKEY_CLASSES_ROOT\Directory\Background\shell\ConEmu]
@="ConEmu"
"Icon"="C:\\Program Files\\ConEmu\\ConEmu64.exe,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\ConEmu\command]
@="C:\\Program Files\\ConEmu\\ConEmu64.exe -Dir \"%V\""
```

- Launch app @ current directory. 
- See [`LinuxHere.cmd` @ `cmd_library`](file:///C:/Program%20Files/_unregistered/cmd_library/LinuxHere.cmd).

### &nbsp;
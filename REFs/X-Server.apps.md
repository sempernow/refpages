# Windows [X Server](https://en.wikipedia.org/wiki/X_Window_System) (`X11`)  
Allows GUI apps installed at a session host (WSL distro) to launch as a client GUI app (at Windows).  

### Setup @ `~/.bashrc`   

```bash
export DISPLAY=:0
```

## Apps 
### [VcXsrv](https://sourceforge.net/projects/vcxsrv/) 

```shell
choco install vcxsrv -y
```

- Settings for X-Server auto-launch. Copy/paste into shortcut for GUI use, or script (`.cmd` | `.bat`) for CLI use.

    ```shell
    "%ProgramFiles%\VcXsrv\vcxsrv.exe" :0 -ac +bs -reset -terminate -dpi auto -render color -lesspointer -multiwindow -multimonitors +xinerama -clipboard -emulate3buttons -hostintitle -keyhook -wgl -swrastwgl -winkill
    ``` 

- Running the X-Server fixes `xclip` issue @ WSL; otherwise `xclip` fails @ `putclip()`; creates file "`xclip -i -f -silent -selection clipboard`" @ `PWD`; see `putclip()` function @ `~/.bash_functions` .

- @ Linux, may also want install `xclip`.

### [MobaXterm](https://mobaxterm.mobatek.net/)  (GUI)

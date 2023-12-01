# WSL :: Manually Uninstall a Distro

# If distro fails to (re)install, ...
Delete its folders @ dirs: 

    C:\Program Files\WindowsApps\  
        DISTRO
            \AppxMetadata
            \Assets
            \DISTRO.exe (SYNLINK)
            
    C:\Users\X1\AppData\Local\Microsoft\WindowsApps\  
        DISTRO\DISTRO.exe
        
    C:\Users\X1\AppData\Local\Packages\  
        DISTRO\

Unregister per `wslconfig.exe` 

```bash
wslconfig /l  # list all distros
wslconfig /u $_DISTRO
```

Then reinstall the distro normally, through Microsoft Store.

## If FUBAR, then toggle the WSL feature itself (off, then on again)  ...

@ Start Menu ...

    @ Settings (icon) > Apps & features (@ left menu)
        > Programs and Features  (@ bottom)
        > Turn Windows features on or off (link)
        > WSL Windows Subsystem for Linux (check-box)

(Reboot each time.)
### &nbsp;

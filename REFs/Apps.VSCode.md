# [VS Code](https://code.visualstudio.com/ "code.visualstudio.com")

## About

__Visual Studio Code__ is __built on__ the __Electron__ framework, which allows developers to create desktop applications using web APIs, standards, and technologies like JavaScript, HTML, and CSS. 

Electron essentially __combines__ the __Chromium rendering engine__ and the __Node.js runtime__, enabling the development of cross-platform applications. 

Web APIs utilized by VS Code:

1. **DOM APIs**: Even though it's a desktop application, VS Code __uses HTML and CSS__ for rendering its interface, which means it relies on the __Document Object Model__ (DOM) APIs for dynamic content updates and UI manipulations.

2. **Web Storage API**: VS Code uses storage mechanisms like `localStorage` or `sessionStorage` for persisting state and settings between sessions, similar to web applications.

3. **Fetch API**/**WebSockets**: These are used for network communication. For instance, extensions in VS Code can use these APIs to communicate with external services, fetch data, or interact with web-based services.

4. **Web Workers**: These are used to run (javascript) scripts in __background threads__, allowing VS Code to perform heavy tasks __without blocking the UI__, enhancing performance and responsiveness.

## Install

Windows methods ordered by preference:

1. CLI: Chocolatey: `choco install vscode`
1. GUI: [Download](https://code.visualstudio.com/) (`.msi`)

### Add "Open with ..." to __Explorer Context__ Menu 

```plaintext
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\shell\Open with VS Code]
@="Edit with VS Code"
"Icon"="C:\\Program Files\\Microsoft VS Code\\Code.exe,0"

[HKEY_CLASSES_ROOT\*\shell\Open with VS Code\command]
@="\"C:\\Program Files\\Microsoft VS Code\\Code.exe\" \"%1\""
```

### Disable Telemetry 

    @ Menu: File > Preferences > Settings > Search > telemetry
    
    @ settings.JSON: "telemetry.enableTelemetry": "false",
    If by GUI, adds: "telemetry.telemetryLevel": "off",  (instead)

### __Depricated__ or Obsolete

VS Code has improved over the years. 
The following installation and configuration methods 
are no longer used or advised.

#### Install per User setup by downloading from MS site
    
VSCodeUserSetup-x64-v.vv.v.exe @ https://code.visualstudio.com/

- No Administrator privileges required
- Icons per filetype @ Window File Explorer

Chocolatey installs as System setup, 
but okay to use choco upgrade if 
a proper `JUNCTION POINT` exists.

#### `JUNCTION POINT` 

"`%ProgramFiles%\VS-Code`" 

~~is required by File Explorer REG entries, and by `openedit.bat`~~

```shell
:: @ System setup
symlink.bat j "%ProgramFiles%\VS-Code" "%ProgramFiles%\Microsoft VS Code" 
:: @ User setup
symlink.bat j "%ProgramFiles%\VS-Code" "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code" 
symlink.bat j "%ProgramFiles%\Microsoft VS Code" "%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code"  
```

#### v1.46.0, FAIL @ downloading Extensions, unless via VPN adapter.

"Unable to open extension ..."

FIX: 

Enable IPv6 @ Gateway Router  
IPv6 > Enable > Native
        
NOT FIX:
    
Set interface metric of TAP to higher number than desired interface.
At PowerShell:

1. `Get-NetIPInterface`
2. `Set-NetIPInterface -InterfaceIndex 19 -InterfaceMetric 100` 

NOT FIX: 

Reset IPv6  

```shell
ipconfig /flushdns
nbtstat –r
netsh int ip reset
netsh winsock reset
netsh winsock reset catalog
netsh int ipv6 reset reset.log
```

## [User interface](https://code.visualstudio.com/docs/getstarted/userinterface)

## Shortcut Keys 

```plaintext
CTRL + SHIFT + TAB    Files [Cycle]
CTRL + P              Files Menu
CTRL + F4             Close File

CTRL + `              Terminal [Toggle]
CTRL + ,              User Settings
CTRL + SHIFT + P      Command Pallete
F11                   Full Screen [Toggle]
```

## Format Code [w/ Beautify extension installed]

```plaintext
SHIFT + ALT + F       Windows 
SHIFT + OPTION + F    Mac
CTRL + SHIFT + I      Ubuntu
```

## User Settings (`settings.json`)

`%UserProfile%\AppData\Roaming\Code\User`

## Terminal (`CTRL+`) 

Uses Git-for-Windows, but invokes `.bashrc` NOT `.bash_profile` (`@USERPROFILE`)

## Extensions 

To Rollback/Specify Version : Extensions side bar   
> settings (icon) > "Install Another Version"

### Vim 

by __vscodevim__

File > Preferences > Keyboard Extensions > "Vim emulation ..."

ISSUE @ publisher:"vscodevim"  https://github.com/Microsoft/vscode/issues/40260

>Everytime we push an update, we always seem to see cases where the extension fails to load. The recommendation I've been giving folks is to delete `~/.vscode/extensions/vscodevim` and reinstall.

So, on fail, delete:

- @ Windows : `del %USERNAME%/.vscode/extensions/vscodevim.vim-*`
- @ Linux : `rm ~/.vscode/extensions/vscodevim` 

and then reinstall.

### Remote Development 

by __Microsoft__

- __Remote - SSH__ - Work with source code in any location by opening folders on a remote machine/VM using SSH. Supports x86_64, ARMv7l (AArch32), and ARMv8l (AArch64) glibc-based Linux, Windows 10/Server (1803+), and macOS 10.14+ (Mojave) SSH hosts.
- __Remote - Tunnels__ - Work with source code in any location by opening folders on a remote machine/VM using a VS Code Tunnel (rather than SSH).
- __Dev Containers__ - Work with a separate toolchain or container based application by opening any folder mounted into or inside a container.
- __WSL__ - Get a Linux-powered development experience from the comfort of Windows by opening any folder in the Windows Subsystem for Linux.

#### Remote - WSL

DEPRICATED ~~DO NOT INSTALL this extension~~ 

- It breaks paths by prepending drive path to absolute path, 
    so `code <FilePath>` fails to open the existing file. 
- It breaks the integration between WSL and Win; 
    forcing WSL to use its own installed version;
    downloads and installs something on first run.
- It forces new app launch for each call.
    - No method to disable the __recurring, nagging pop up__ to install it.

Use __WSL__ or broader __Remote Development__ extension instead.

### [Go extension]([fails](https://github.com/golang/vscode-go/blob/master/docs/tools.md).) 

Install from Git Bash [MINGW64]

Requires `.git` folders of all Golang source intact, 
else `go get -u -v PKG` fails.

Install Golang unstall using Chocolatey,
which installs to `C:\tools\go`

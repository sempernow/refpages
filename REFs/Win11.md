# Window 11

## Network Adapters

@ "Control Panel\Network and Internet\Network Connections"

- Properties : UNCHECK (Disable) IPv6 
    - At adapter(s) bound to gateway,
      else DNS latency is some 10x greater.

## Install

Windows 11 Install using a local-only account.
(Bypass requirement to have an online Microsoft account.)
https://www.tomshardware.com/how-to/install-windows-11-without-microsoft-account

### Method 1

- Follow install menus until "Select Country" page
- Shift + F10, which launches a CMD window. 
- Type: OOBE\BYPASSNRO and press Enter,
  which causes computer to reboot.
- Shift + F10 again
- Type: ipconfig /release
- Close CMD window
- Resume install.
- At screen: "Let's connect you to a network",
 click "I don't have Internet" to continue.
- "Continue with limited setup"

### Method 2

- At Sign in screen, click and add a local-account name.
- Next and add local-account password.
- Click Sign in 
- At " "Oops, something went wrong" click Next.
- Repeat local-account creation: (name, password).


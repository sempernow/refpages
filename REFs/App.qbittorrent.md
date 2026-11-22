# [qBittorrent](https://chocolatey.org/packages?q=qbittorrent "@ Chocolatey.org")

### Install/update @ 2019-11-08 (v4.1.9) 

```shell
choco install qbittorrent
```

- ___Set its network adapter:___
    - @ Tools >  Options > Advanced > Network Interface
        - Select the VPN-client-specific adapter (e.g., `TAP1` or `PIA`).  
- Validate the IP shown ("`External IP:...`") at the __Execution Log__ (tab). It _should be_ the __dynamic IP__ of the current VPN (e.g., OpenVPN or PIA client) connection, _not_ that assigned per ISP (which is static). 

### ISSUE/FIX @ 2019-11-08 

Upon resetting all my network adapters, qBittorrent would fail to download anything; the app's Execution Log (tab) showed message: "The network interface defined is invalid &hellip;". 

~~___Fix___ @ Tools >  Options > Advanced > Network Interface, and select the appropos adapter; vEthernet (External Switch). It had switched itself to TAP1, perhaps due to the network reset.~~

UPDATE 2019-11-14: ___Do NOT use any adapter except that of VPN___ (`TAP1`). Validate (`External IP: ...`) at the Execution Log (tab). This _should be_ the IP of the current (OpenVPN) VPN connection, _not_ that assigned per ISP. 

###  [qBittorrent official forums](https://qbforums.shiki.hu/index.php?topic=7408.0) 

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([MD](___.html "@ browser"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->


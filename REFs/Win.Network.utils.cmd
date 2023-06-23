notepad "%~f0" & GOTO :EOF

:: puTTY  https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
:: PuttyKeyGen: converts SSH key-pair formats, from PEM (AWS) to PPK (puTTY) 

:: Nmap for Windows (install per chocolatey) @ https://nmap.org/book/man.html
    nmap HOST                       rem Regular scan 
    nmap -sn HOST                   rem Ping scan
    nmap -T4 -F HOST                rem Quick scan
    nmap -sn --traceroute HOST      rem Quick traceroute
    nmap -T4 -A -v HOST             rem # Intense scan  
    nmap -p 1-65535 -T4 -A -v HOST  rem # Intense scan, all TCP ports
	rem Slow comprehensive scan
    nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script "default or (discovery and safe)" HOST  

:: CMDline Scripts and UTILs

	rem  View/test available LAN hosts
		netshares.bat
		server.bat TARGET_MACHINE_NAME
	
	rem  View IP of adapters & gateway
		ip.bat       
		ipALL.bat  
	
	rem  WakeOnLan.exe
		LAN.bat NEW 

	rem  test connectivity
		ping <ip>      
	rem  ... also resolve host name [get it from IP]
		ping -a <ip>   

	rem  show name/ip of gateway server 
		nslookup 
	rem  show name/ip of host [server]
		nslookup <host(target)-IP> [<server-IP>]
		nslookup <target-name>  [<server-IP>]
	
:: Show all adapters/interfaces

	rem  shows All Adapters		Adapter IP & MAC, and Server-IP 
		ipconfig /all   
		ipconfig /allcompartments /all


	rem  ARP table; LAN's Address Resolution Protocol [ARP] table; 
	rem  all nodes; IP, MAC, type ['static'|'dynamic']
		arp -a 

		rem  ARP table includes the GATEWAY ROUTER's IP & MAC address, e.g., ...
		
		rem  Internet Address      Physical Address      Type
		     192.168.1.1           e0-3f-49-9a-8b-b8     dynamic ... router
		     192.168.1.251         00-1c-c0-4d-94-bf     dynamic ... client

:: Show ...

	rem  netstat :: displays protocol stats & current TCP/IP network connections.
		NETSTAT [-a] [-b] [-e] [-f] [-n] [-o] [-p proto] [-r] [-s] [-x] [-t] [interval]
		netstat -bof      :: TCP: application + proto addr:port[local+foreign] PID
		netstat -ano      :: all open; proto addr:port[local+foreign] PID
		netstat -esp TCP
	
	rem  route :: show/manipulate network routing tables
	route print

	rem  netsh :: display or modify the network config @ local or remote machine; also provides a scripting feature [if no params] allowing batch mode.
	netsh int tcp show global
	netsh int tcp show heuristics
	netsh int ipv4 show route

	rem  display all wireless networks and channels detected.

		netsh wlan show all
		netsh wlan show profiles
		netsh wlan show drivers

:: Reset TCP Stack ...
	
	netsh int ip reset

:: Reset Firewall ...	

	netsh advfirewall reset

:: Nuclear Option ...

	netsh winsock reset all
	netsh int ipv4 reset all
	netsh int ipv6 reset all

	ipconfig /release [ADAPTER]
	ipconfig /renew [ADAPTER]
	ipconfig /flushdns
	ipconfig /displaydns
	ipconfig /registerdns

	E.g., 
	ipconfig /release "vEthernet (External-GbE)"





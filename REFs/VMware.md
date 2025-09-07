# [VMware](https://www.vmware.com/ "VMware.com") | [Proxmox v. ESXi v. OpenStack](https://chatgpt.com/share/f5522c3c-a597-42ac-adee-4d445b0836f6 "ChatGPT.com")

>VMware is now (2023) owned by __Broadcom__,  
>which has (2024) [__discontinued its *free* ESXi__](https://knowledge.broadcom.com/external/article?legacyId=2107518 "knowledge.broadcom.com") hypervisor"

## [ESXi](https://en.wikipedia.org/wiki/VMware_ESXi)

- Type:  
    Bare-metal, Type-1 hypervisor.
- Purpose:  
    ESXi is installed directly on server hardware to allow it to run multiple virtual machines (VMs) efficiently by 
    virtualizing the hardware resources of the physical server.
- Use Case: 
    ESXi is for server-level deployments. It's widely used in data centers and enterprise environments where organizations need to run multiple VMs on a server. ESXi is the foundation of VMware's enterprise-level virtualization stack.
- Key Features:  
    Resource management, high availability, support for clustering, performance tuning, and security for running multiple VMs.
- Relation to VMware Workstation and vCenter:   
    Unlike VMware Workstation, ESXi is for server-level deployments. It can be managed either directly via its web interface or through vCenter for larger environments.

__Components__/__Features__:

- Horizon __Connection Server__: 
    This is the core component of the Horizon VDI architecture. It manages session brokering, authentication, and directs incoming VDI connection requests from users to their respective virtual desktops or published applications.
- __ESXi Hosts__ (Physical Servers): 
    These are the servers where the VMs or desktops are hosted. They run the VMware ESXi hypervisor, which allows multiple VMs to share physical hardware resources.
-  __Thin Clients__: 
    These are minimalistic computers that primarily provide network connectivity and the necessary interfaces to interact with the user's virtual desktop. They run thin client operating systems and include client software, 
    typically the VMware __Horizon Client__.
- __NSX__ (Networking and Security Virtualization)
    - SDN requiring [VMware Cloud Foundation](https://www.vmware.com/products/cloud-infrastructure/vmware-cloud-foundation) (__VCF__) : Private Cloud Platform
- __vMotion__ : live migration of a VM to another physical machine without any downtime
    - Enterprise feature : Requires license
-  `.vmdk` : Proprietary virtualization format; __Proxmox__ supports that and others (`.qcow2` and `.vdi`).
- ~~[Free version](https://my.vmware.com/en/web/vmware/evalcenter?p=free-esxi6) for registered users~~

__Tools__:

- __vSphere Client__ is the __administrative interface__ for the overall management of VMware's vSphere products, including __ESXi hosts__ and __vCenter Servers__.
- VMware __Remote Console__ (__VMRC__) is used for direct interaction with a VM's operating system, similar to accessing a physical machine's console. It's part of managing VMs within the vSphere environment, but is focused on VM interaction rather than broader infrastructure management.
- VMware __Horizon Client__ is specifically for accessing virtual desktops and applications in a __VDI__ environment.

## vCenter 

- Type:  
    Centralized management platform for VMware environments.
- Purpose:  
    vCenter allows administrators to manage multiple __ESXi__ hosts 
    and the VMs running on them from a single console. 
    It provides advanced features like __VM migration__ (__vMotion__), 
    high availability (HA), distributed resource scheduling (DRS), and more.
- Use Case:   
    vCenter is used in enterprise environments where many ESXi hosts and VMs 
    need to be centrally managed for efficiency, scalability, and high availability.
- Key Features:   
    __Centralized management of multiple ESXi hosts__, resource pooling, 
    load balancing, VM migration, and performance monitoring.
- Relation to ESXi and VMware Workstation:  
    vCenter is used to manage multiple ESXi hosts, 
    providing features and functionalities that individual ESXi hosts or VMware Workstation cannot offer on their own. It is not directly related to VMware Workstation, but some users use VMware Workstation for testing and then move to ESXi and vCenter for production.

Components/Features:

- Manage/Access multiple ESXi hosts, all from one console. 
- __vCenter__ is deployed on ESXi VM host as __either__:
    1. __VCSA__ (VMware Center (vCenter) Service __Appliance__) (preferred)
        - Was OpenSUSE; now (v6.5+) is VMware __Photon OS__
    2. __Windows__, which uses MS SQL database
- Flash (legacy) and HTML5 based interfaces available. 
- Advanced features; VM Cloning, load balancing, ...

The technology that facilitates connection to vCenter and provides the pop-up window 
where you interact with the VM is primarily the __VMRC__ or the __Web Console__.

### VMware Remote Console (VMRC) 

VMRC connects to vCenter Server, allowing users to interact directly with the guest operating system of a VM through a pop-up window. It handles the keyboard, video, and mouse (__KVM__) streams, making it feel like you are directly logged onto the machine. VMRC can be __launched from the vSphere Web Client or directly as a standalone application__.

Sometimes informally referred to as the "__vSphere Remote Client__".
The VMRC is actually a KVM-type of utility that provides console access to guest operating systems running on VMware VMs. VMRC allows you to remotely interact with the VM's operating system as if you were sitting in front of it, complete with screen, keyboard, and mouse input. 

### vSphere Web Console
    
An alternative to VMRC, especially in newer versions of vSphere, is the web console provided directly through the HTML5-based vSphere Client. This console allows for interaction with the VM without needing to install additional software like VMRC.

Both VMRC and the web console use a combination of technologies, 
including proprietary VMware protocols, to provide secure and efficient access 
to manage and operate the VMs remotely. 

These tools ensure that you have near-real-time interaction with the VMs, 
enabling tasks such as configuring operating systems, installing applications, 
and monitoring operations directly from the console window.

## Guest VM Networking

    [VM1] ----\
    [VM2] ----> [vSwitch0] ---[vmnic0]--- [Physical Switch] --- [Router/Gateway]
    [VM3] ----/


- __vSwitch__ is a Layer 2 switch
    - It connects VMs to each other (on the same ESXi host).
    - It connects VMs to physical networks if it has one or more uplinks; physical NICs (vmnic0).
    - It does not provide Layer 3 routing — no default gateway lives "in" the vSwitch.
- __Router/Gateway__ is the default gateway for the subnet.
    - If on isolated NAT subnet, this may be merely the NAT device AKA "subnet address",
      whereof ping test is expected to fail.

### Verify Connectivity from a Guest VM

From inside a host (RHEL) of a **guest VM**, 
we can gather useful clues to infer 
whether the **vSwitch has an uplink** 
and whether the **default gateway is reachable**.

---

### ✅ **Check 1: Routing table**

```bash
☩ ip route show
default via 192.168.11.1 dev eth0 proto dhcp src 192.168.11.100 metric 100
192.168.11.0/24 dev eth0 proto kernel scope link src 192.168.11.100 metric 100

```
* This shows the **default gateway** (here, `192.168.11.1`).
* If it's missing, the VM won’t be able to route off its subnet.

---

### ✅ **Check 2: Ping the default gateway**

```bash
☩ ping -c 3 -W 1  192.168.11.1
PING 192.168.11.1 (192.168.11.1) 56(84) bytes of data.

--- 192.168.11.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2056ms
```
* If this fails **but other VMs on the same ESXi host are reachable**, as is the case here,
then the vSwitch likely **has no uplink** to the gateway. 

If on a NAT-isolated subnet, as this host is, 
then failure on `ping` of that NAT device (AKA subnet) address is normal.
Yet we can verify connectivity to an upstream gateway on another subnet:

```bash
☩ ping -c 3 -W 1  192.168.28.1
PING 192.168.28.1 (192.168.28.1) 56(84) bytes of data.
64 bytes from 192.168.28.1: icmp_seq=1 ttl=63 time=4.22 ms
64 bytes from 192.168.28.1: icmp_seq=2 ttl=63 time=6.67 ms
64 bytes from 192.168.28.1: icmp_seq=3 ttl=63 time=4.35 ms

--- 192.168.28.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 4.217/5.080/6.672/1.126 ms
```
---

### ✅ **Check 3: Trace the path to an external host**

```bash
# To gateway router of another subnet
☩ traceroute 192.168.28.1
traceroute to 192.168.28.1 (192.168.28.1), 30 hops max, 60 byte packets
 1  _gateway (192.168.11.1)  0.345 ms  0.319 ms  0.304 ms
 2  192.168.28.1 (192.168.28.1)  4.150 ms  4.545 ms  4.108 ms

# To internet host
☩ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (192.168.11.1)  0.515 ms  0.488 ms  0.473 ms
 2  192.168.28.1 (192.168.28.1)  5.500 ms  5.616 ms  5.452 ms
 3  172.27.219.3 (172.27.219.3)  15.673 ms 172.27.219.2 (172.27.219.2)  22.335 ms  19.875 ms
 4  po-53-317-rur201.gambrills.md.bad.comcast.net (68.86.252.33)  19.809 ms po-53-318-rur202.gambrills.md.bad.comcast.net (68.86.252.69)  17.724 ms *
 5  * * *
 6  po-200-xar01.gambrills.md.bad.comcast.net (96.216.84.61)  22.059 ms  26.977 ms  26.948 ms
 7  ae-99-rar01.capitolhghts.md.bad.comcast.net (162.151.61.121)  20.781 ms  25.308 ms  25.283 ms
 8  be-3-arsc1.capitolhghts.md.bad.comcast.net (96.110.235.69)  25.220 ms  16.551 ms  21.570 ms
 9  be-31421-cs02.beaumeade.va.ibone.comcast.net (96.110.40.21)  19.398 ms be-3104-pe04.ashburn.va.ibone.comcast.net (96.110.37.130)  19.331 ms be-3311-pe11.ashburn.va.ibone.comcast.net (96.110.32.130)  17.314 ms
10  * * be-3312-pe12.ashburn.va.ibone.comcast.net (96.110.34.122)  18.597 ms
11  * * *
12  * * dns.google (8.8.8.8)  21.271 ms
```
* If it **hangs immediately**, the VM can’t reach the gateway.
* If it reaches the gateway but fails further, your upstream routing or firewall may be blocking.

---

### ✅ **Check 4: Interface and ARP info**

```bash
# Does public interface (here, eth0) have (DHCP) assigned IP address
☩ ip -4 addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 192.168.11.100/24 brd 192.168.11.255 scope global dynamic noprefixroute eth0
       valid_lft 200397sec preferred_lft 200397sec

# Is gateway IP in ARP table
☩ ip neigh show
192.168.11.2 dev eth0 lladdr 00:15:5d:1c:2f:01 REACHABLE
192.168.11.1 dev eth0 lladdr 00:15:5d:1c:2f:00 REACHABLE
```
* Confirm the public interface (`eth0`) has an IP address in the expected subnet.
* See whether the gateway IP appears in ARP (if it doesn’t, try pinging it first).
    - Our NAT subnet has no gateway router.

---

### ✅ **Optional: Check DNS resolution**

```bash
☩ dig google.com

; <<>> DiG 9.16.23-RH <<>> google.com
;; global options: +cmd
;; Got answer:
...
;; ANSWER SECTION:
google.com.             117     IN      A       142.251.163.138
...
;; Query time: 18 msec
;; SERVER: 192.168.11.2#53(192.168.11.2)
;; WHEN: Fri May 09 07:55:10 EDT 2025
;; MSG SIZE  rcvd: 135
```
* If DNS fails but `ping 8.8.8.8` works, your network might be OK,
but your `/etc/resolv.conf` is misconfigured.
* If both fail, it’s likely a routing or uplink issue.

---

### ❌ What you **cannot** see from the VM:

* Whether the **vSwitch has a physical uplink** (vmnic) attached.
* Whether the **port group** is on a trunked VLAN.
* The actual **vSwitch configuration** on ESXi.

You’ll need access to **vSphere or ESXi host CLI** to see those.

---

## Virtual Desktop Infrastructure (VDI) 

This uses VMware __Horizon__; a VDI platform to provide a virtual desktop and application services, allowing users to access personal desktop environments hosted on VMware ESXi servers through lightweight or thin client devices.

This VDI setup is particularly __popular in enterprise environments__ where security, management, and cost efficiency are paramount. It allows organizations to provide a standardized set of applications and resources to users, 
regardless of their physical location or the capabilities of their local hardware.

Here's how it generally works:

Prior to authentication, the __client pop-up__ in a VMware __Horizon VDI__ environment 
is typically part of the __Horizon Client__ application that's __installed on the thin client__. 
This client software is responsible for initiating the connection 
to the VMware __Horizon Connection Server__. 

Here's how the sequence usually unfolds:

- __Horizon Client Initialization__: When the thin client is powered on and the VMware Horizon Client is launched, the initial screen usually __prompts the user to enter the server address__ (the Horizon __Connection Server__) and possibly other connection parameters. This step is necessary for the thin client to know where to direct its authentication request and subsequent virtual desktop session traffic.
- __Login Screen__: After the server address is provided and successfully reached by the Horizon Client, the next screen typically presented is the login screen. Here, the user is asked to provide their credentials, which might include a username and password. Additional layers of security such as two-factor authentication (2FA) may also be part of this process depending on the organization's security policies.
- __Session Broker__: Once the credentials are entered and validated by the Connection Server, 
it acts as a session broker, determining which resources (virtual desktops or applications) 
are available to the user based on their credentials and group memberships.
- __Resource Selection__: If multiple resources are available (e.g., different virtual desktops or applications), 
the user may be presented with a selection screen where they can choose the desired virtual desktop or application to launch.
- __Connection Establishment__: After selecting the resource, the Horizon Client establishes a connection 
using <dfn title="PC-over-IP is a proprietary remote display protocol used in AWS Workspaces and VMware Horizon View">[__PCoIP__](https://en.wikipedia.org/wiki/Teradici#PCoIP_Protocol)</dfn> 
or <dfn title="VMware proprietary protocol using that of H.264">__Blast Extreme__</dfn> protocols, and the user's virtual desktop session begins. The user then interacts with their desktop environment as if it were running locally, 
although it is hosted on the ESXi servers in the data center.

### Process

1. __User Authentication__: The user logs into the Horizon Client installed on their thin client or another device. 
    Authentication is usually handled by the Connection Server, 
    which may integrate with enterprise directory services like Microsoft Active Directory.

2. __Desktop Provisioning__: Once authenticated, the Connection Server brokers a connection to a virtual desktop instance hosted 
    on one of the ESXi hosts. This desktop can be a persistent desktop, 
    which maintains user data and settings between sessions, or a non-persistent desktop, which provides a clean state at every login.

3. __Connection__: The Horizon Client on the thin client establishes a connection to the virtual desktop using VMware's PCoIP (PC-over-IP) 
    or Blast Extreme protocols. These protocols are designed to deliver high-performance virtual desktop experiences over the network 
    with efficient compression and encryption.

4. __User Session__: The user interacts with the Windows environment as if they were using a local PC, 
    but all processing happens on the server-side. The thin client simply displays the desktop and handles input and output.

### Advantages

- __Security__: Since data is processed and stored in the data center, sensitive information never leaves the secure environment.
- __Cost-Effective__: Thin clients are generally cheaper to maintain and consume less power than traditional desktop PCs.
- __Centralized Management__: Updates, patches, and software installations can be managed centrally, which simplifies IT operations.


## Workstation

- Type:  
    Desktop virtualization software.
- Purpose:  
    It allows users to run multiple VMs on a single desktop or laptop computer. It's primarily used for personal or small-scale development, testing, and learning.
- Use Case:  
    Ideal for developers, IT professionals, and hobbyists 
    who want to create and run VMs on their personal machine without the need for dedicated server hardware.
- Key Features:  
    Supports a variety of guest operating systems, snapshots, virtual networking, and resource sharing (like CPU, memory, disk, etc.) between VMs.
- Relation to ESXi and vCenter:  
    VMware Workstation __can connect to and manage ESXi hosts__, but it's generally not part of a larger enterprise-grade data center solution.

- VMware Workstation Pro 17.5.2 
    - https://1337x.to/torrent/6098934/VMware-Workstation-Pro-17-5-2-23775571-Lifetime-Activation-Serials-AppDoze/

## ESXi Subnets and Firewalls

@ ChatGPT4o

### Q: 

Regarding VMs under ESXi, shouldn't each set of logically related VMs have their own firewalled subnet defined and managed via the hypervisor and perhaps allowing prgrammatic access from the VMs?

### A: 

Yes, it is a good practice to segment logically related VMs into their own firewalled subnets within an ESXi environment. 
This approach provides several advantages:

### Advantages of Firewalled Subnets for Logically Related VMs:

1. __Security__: By isolating groups of VMs, you can limit the blast radius of any potential security incidents. 
If one VM is compromised, the attacker's ability to move laterally within the network is restricted.

2. __Traffic Control__: Firewalled subnets allow you to control the flow of traffic between different groups of VMs. This ensures that only necessary and approved communication paths are allowed, reducing the risk of unauthorized access.

3. __Compliance__: Many regulatory frameworks require strict network segmentation to protect sensitive data. Isolating VMs into different subnets can help meet these requirements.

4. __Performance Management__: Segregating traffic can help in managing and optimizing network performance by reducing congestion and ensuring that critical applications have the necessary bandwidth.

### Implementation in ESXi:

1. __Virtual Switches (vSwitches)__: Use ESXi's virtual switches to create isolated networks for different groups of VMs. Each vSwitch can have its own set of port groups and VLANs.
    - Port groups define the network configuration, including VLAN ID, network traffic policies, and security settings for the connected VMs.

2. __Distributed Virtual Switches (vDS)__: For larger environments, consider using VMware vSphere Distributed Switches, which provide centralized management of network configurations across multiple ESXi hosts.

3. __Firewall Rules__: Configure firewall rules to control traffic between subnets. This can be done using VMware NSX (Networking and Security Virtualization) if available, or through physical firewalls and network devices if NSX is not in use.

4. __Programmatic Access__: Allow programmatic access to manage and configure network settings from the VMs. This can be achieved using VMware's APIs and tools like PowerCLI for scripting and automation.

### Steps to Set Up Firewalled Subnets:

>Terraform, or Ansible module `community.vmware`, can be used for this.

1. __Define Subnets__: Plan and define the subnets based on the logical grouping of VMs.
2. __Create vSwitches/vDS__: Set up virtual switches or distributed switches in ESXi to host the subnets.
3. __Assign VLANs__: Assign VLAN IDs to the port groups on the switches to segregate the network traffic.
4. __Configure Firewalls__: Implement firewall rules to control the traffic between different subnets. If using NSX, leverage its micro-segmentation capabilities.
5. __Programmatic Configuration__: Use scripts and automation tools to manage network configurations and ensure consistency across the environment.

### Example:

- __Development Environment__: Subnet A
- __Production Environment__: Subnet B
- __Database Servers__: Subnet C

Each of these subnets would be isolated on different vSwitches or port groups with appropriate VLANs and firewall rules to control the traffic flow between them, ensuring that development servers cannot directly access production databases, for instance.

This segmentation and isolation strategy is a key part of a robust network security posture in a virtualized environment like ESXi.


## [Create VMs via IaC method](https://chatgpt.com/share/6701397c-d940-8009-b7f7-6d103934228a)

### 1. Terraform / vSphere Provider


### 2. Ansible : `community.vmware.vmware_guest`

Module to create and manage VMs on vSphere.

### 3. vSphere Automation SDK

VMware provides SDKs for Python, Go, and other languages to automate VM creation and management via API calls.


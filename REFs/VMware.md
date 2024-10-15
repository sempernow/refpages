# [VMware](https://www.vmware.com/ "VMware.com")

## [Proxmox v. ESXi v. OpenStack](https://chatgpt.com/share/f5522c3c-a597-42ac-adee-4d445b0836f6 "ChatGPT.com")

>VMware is now owned by Broadcom, which has __discontinued the Free ESXi Hypervisor__ : [End Of General Availability of the free vSphere Hypervisor](https://knowledge.broadcom.com/external/article?legacyId=2107518 "knowledge.broadcom.com")"


## vSphere ESXi 

- Type:  
    Bare-metal, Type-1 hypervisor.
- Purpose:  
    ESXi is installed directly on server hardware to allow it to run 
    multiple VMs efficiently by virtualizing the hardware resources of the physical server.
- Use Case: 
    ESXi is for server-level deployments. 
    It's widely used in data centers and enterprise environments 
    where organizations need to run multiple VMs on a server. 
    ESXi is the foundation of VMware's enterprise-level virtualization stack.
- Key Features:  
    Resource management, high availability, support for clustering, 
    performance tuning, and security for running multiple VMs.
- Relation to VMware Workstation and vCenter:   
    Unlike VMware Workstation, ESXi is for server-level deployments. 
    It can be managed either directly via its web interface 
    or through vCenter for larger environments.

Components/Features:

- NSX : Networking and Security Virtualization SDN
    - Requires [VMware Cloud Foundation](https://www.vmware.com/products/cloud-infrastructure/vmware-cloud-foundation) (VCF) : Private Cloud Platform
- vMotion : live migration of a VM to another physical machine without any downtime
    - Enterprise feature : Requires license
-  `.vmdk` : Proprietary virtualization format only, 
   whereas Proxmox supports that and others; `.qcow2` and `.vdi`
- Remote access only; per Web console
- ~~[Free version](https://my.vmware.com/en/web/vmware/evalcenter?p=free-esxi6) for registered users~~

## Workstation

- Type:  
    Desktop virtualization software.
- Purpose:  
    It allows users to run multiple virtual machines (VMs) on a single desktop or laptop computer. 
    It's primarily used for personal or small-scale development, testing, and learning.
- Use Case:  
    Ideal for developers, IT professionals, and hobbyists 
    who want to create and run VMs on their personal machine without the need for dedicated server hardware.
- Key Features:  
    Supports a variety of guest operating systems, snapshots, virtual networking, 
    and resource sharing (like CPU, memory, disk, etc.) between VMs.
- Relation to ESXi and vCenter:  
    VMware Workstation __can connect to and manage ESXi hosts__, 
    but it’s generally not part of a larger enterprise-grade data center solution.

- VMware Workstation Pro 17.5.2 
    - https://1337x.to/torrent/6098934/VMware-Workstation-Pro-17-5-2-23775571-Lifetime-Activation-Serials-AppDoze/

## vCenter 

- Type:  
    Centralized management platform for VMware environments.
- Purpose:  
    vCenter allows administrators to manage multiple ESXi hosts 
    and the VMs running on them from a single console. 
    It provides advanced features like __VM migration__ (__vMotion__), 
    high availability (HA), distributed resource scheduling (DRS), and more.
- Use Case:   
    vCenter is used in enterprise environments where many ESXi hosts and VMs 
    need to be centrally managed for efficiency, scalability, and high availability.
- Key Features:   
    Centralized management of multiple ESXi hosts, resource pooling, 
    load balancing, VM migration, and performance monitoring.
- Relation to ESXi and VMware Workstation:  
    vCenter is used to manage multiple ESXi hosts, 
    providing features and functionalities that individual ESXi hosts or VMware Workstation cannot offer on their own. It is not directly related to VMware Workstation, but some users use VMware Workstation for testing and then move to ESXi and vCenter for production.

Components/Features:

- Manage/Access multiple ESXi hosts, all from one console. 
- Deployed on VM, on vSphere ESXi host, as either:
    1. VCSA VMware Center Service Appliance VM (preferred)
        - Was openSUSE; @ 6.5 is VMware Photon OS
    2. Windows VM on vSphere ESXi host; uses MS SQL database
- Flash (legacy) and HTML5 based interfaces available. 
- Advanced features; VM Cloning, load balancing, ...

## ESXi : Subnets and Firewalls

@ ChatGPT4o

### Q: 

Regarding VMs under ESXi, shouldn't each set of logically related VMs have 
their own firewalled subnet defined and managed via the hypervisor 
and perhaps allowing prgrammatic access from the VMs?

### A: 

Yes, it is a good practice to segment logically related VMs into their own 
firewalled subnets within an ESXi environment. 
This approach provides several advantages:

### Advantages of Firewalled Subnets for Logically Related VMs:

1. **Security**: By isolating groups of VMs, you can limit the blast radius of any potential security incidents. If one VM is compromised, the attacker’s ability to move laterally within the network is restricted.

2. **Traffic Control**: Firewalled subnets allow you to control the flow of traffic between different groups of VMs. This ensures that only necessary and approved communication paths are allowed, reducing the risk of unauthorized access.

3. **Compliance**: Many regulatory frameworks require strict network segmentation to protect sensitive data. Isolating VMs into different subnets can help meet these requirements.

4. **Performance Management**: Segregating traffic can help in managing and optimizing network performance by reducing congestion and ensuring that critical applications have the necessary bandwidth.

### Implementation in ESXi:

1. **Virtual Switches (vSwitches)**: Use ESXi’s virtual switches to create isolated networks for different groups of VMs. Each vSwitch can have its own set of port groups and VLANs.
    - Port groups define the network configuration, including VLAN ID, network traffic policies, and security settings for the connected VMs.

2. **Distributed Virtual Switches (vDS)**: For larger environments, consider using VMware vSphere Distributed Switches, which provide centralized management of network configurations across multiple ESXi hosts.

3. **Firewall Rules**: Configure firewall rules to control traffic between subnets. This can be done using VMware NSX (Networking and Security Virtualization) if available, or through physical firewalls and network devices if NSX is not in use.

4. **Programmatic Access**: Allow programmatic access to manage and configure network settings from the VMs. This can be achieved using VMware’s APIs and tools like PowerCLI for scripting and automation.

### Steps to Set Up Firewalled Subnets:

>Terraform, or Ansible module `community.vmware`, can be used for this.

1. **Define Subnets**: Plan and define the subnets based on the logical grouping of VMs.
2. **Create vSwitches/vDS**: Set up virtual switches or distributed switches in ESXi to host the subnets.
3. **Assign VLANs**: Assign VLAN IDs to the port groups on the switches to segregate the network traffic.
4. **Configure Firewalls**: Implement firewall rules to control the traffic between different subnets. If using NSX, leverage its micro-segmentation capabilities.
5. **Programmatic Configuration**: Use scripts and automation tools to manage network configurations and ensure consistency across the environment.

### Example:

- **Development Environment**: Subnet A
- **Production Environment**: Subnet B
- **Database Servers**: Subnet C

Each of these subnets would be isolated on different vSwitches or port groups with appropriate VLANs and firewall rules to control the traffic flow between them, ensuring that development servers cannot directly access production databases, for instance.

This segmentation and isolation strategy is a key part of a robust network security posture in a virtualized environment like ESXi.


## [Create VMs via IaC method](https://chatgpt.com/share/6701397c-d940-8009-b7f7-6d103934228a)

### 1. Terraform / vSphere Provider



### 2. Ansible : `community.vmware.vmware_guest`

Module to create and manage VMs on vSphere.

### 3. vSphere Automation SDK

VMware provides SDKs for Python, Go, and other languages to automate VM creation and management via API calls.


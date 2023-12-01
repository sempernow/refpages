#!/bin/bash
exit
# VIRTUALIZATION :: Libvert & KVM [CentOS 7 64-bit]
# RHCSA section
#   KVM [Kernel-based Virtual Machine] is a virtualization 
#   infrastructure for the Linux kernel; turns it into a hypervisor. 
#   https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine

  # requires 64-bit
  arch # => x86_64
  
  # required CPU support  
  egrep 'vmx|svm' /proc/cpuinfo # see flags: vmx @ Intel, svm @ AMD

  # required kernel modules 
  lsmod | grep kvm
  
  # required service 
  systemctl status libvertd 
  
  ip link show # => virbr0 ... 
  
  # kernel virtualization daemon 
  libvertd         # handles all; kvm, kvm-intel, kvm-amd,...
  
  # virtualization management programs
  virt-manager &   # GUI; launch as background process
  vrsh             # CLI; shell interface
  virt-install     # installer
  
  # install all KVM packages
  yum install -y kvm libvirt virt-manager qemu-kvm

  virsh            # launch shell
  virsh list       # list running virtual machines
  virsh list --all # list existing virtual machines 
  virsh destroy MACHINENAME # stop vm named MACHINENAME
  virsh start   MACHINENAME # start vm named MACHINENAME 
  
  # vm config files [xml]
  /etc/libvirt/qemu 
  
  virsh edit MACHINENAME.conf # use to edit config; instead of vim

# RHCE section
# RHEL7: Set up a lab using KVM [for RHCSA 7 & RHCE 7 exams]
# CertDepot  https://www.certdepot.net/rhel7-set-lab/
# KVM  https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine
# 
# INSTALL KVM HOST
# https://www.certdepot.net/rhel7-configure-physical-machine-host-virtual-guests/
	yum update 
	yum group install "Virtualization Host"
	yum install -y virt-install
	yum install -y virt-top
	
	#Start the libvirtd service:
	systemctl start libvirtd
	
	# Activate the Chronyd/NTP service at boot and start it:
	systemctl enable chronyd && systemctl start chronyd
	
	# Check the installation:
	virt-host-validate
	#=>
		QEMU: Checking for hardware virtualization : PASS
		QEMU: Checking for device /dev/kvm : PASS
		QEMU: Checking for device /dev/vhost-net : PASS
		QEMU: Checking for device /dev/net/tun : PASS
		LXC: Checking for Linux >= 2.6.26 : PASS

# CONFIGURE NETWORK SETTINGS
# https://www.certdepot.net/rhel7-configure-lab-network-settings/

	# Install the bridge-utils package (if not already there):
	yum install -y bridge-utils

	# Stop the Firewalld service:
	systemctl disable firewalld
	systemctl stop firewalld

		# Note: Firewalld needs NetworkManager to define which network interface a packet is coming from. As we are going to stop NetworkManager, Firewalld should be stopped too.

	# Stop the NetworkManager service:

	systemctl mask NetworkManager
	systemctl mask NetworkManager-dispatcher
	systemctl stop NetworkManager 

		# Note: As NetworkManager is a dbus-activated service, disabling it is not enough to be sure that it will not restart any more. Masking needs to be done before stopping, otherwise you won’t be sure it is really stopped. NetworkManager-dispatcher is a service run by NetworkManager to start or stop services according to network interfaces going up or down.

	# Start the network service:
	systemctl start network
	chkconfig network on

	# CREATE A BRIDGE called br0 (here the physical interface is eth0):
	virsh iface-bridge eth0 br0

	# Alternatively, you can manually create the bridge as follows:
	# Rename the ifcfg-eth0 configuration file in ifcfg-br0:
	cd /etc/sysconfig/network-scripts
	mv ifcfg-eth0 ifcfg-br0

	# Edit the ifcfg-br0 file:
	vim /etc/sysconfig/network-scripts/ifcfg-br0
		DEVICE=br0
		ONBOOT=yes
		TYPE=Bridge
		BOOTPROTO=none
		IPADDR=192.168.1.5
		NETMASK=255.255.255.0
		GATEWAY=192.168.1.1
		IPV6INIT=yes
		IPV6_AUTOCONF=yes
		DHCPV6=no
		STP=on
		DELAY=0
		DNS1=192.168.1.1
		DOMAIN=example.com

	# Create the new ifcfg-eth0 file:
	vim /etc/sysconfig/network-scripts/ifcfg-eth0
		DEVICE=eth0
		ONBOOT=yes
		BRIDGE=br0
		HWADDR="XX:XX:XX:XX:XX:XX"

	# Now, you need to reboot to get your bridge working.
	
# SETUP LOCAL REPOSITORY
# https://www.certdepot.net/rhel7-set-local-repository-lab/
#  Downloading packages from the Internet takes time.
#  To be able to quickly deploy new VMs, you need a local repository.


# CONFIGURE A MASTER NAME SERVER
# https://www.certdepot.net/rhel7-configure-master-name-server/

# CREATE a VM GUEST
# https://www.certdepot.net/rhel7-install-red-hat-enterprise-linux-systems-virtual-guests/
#   Install RHEL systems as virtual guests.
#   Two steps:
#     1. create a Kickstart file with all the config 
#        params; ip address, disk partitioning, etc
#     2 run the command for the creation itself.

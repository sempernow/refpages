#!/bin/sh
# ------------------------------------------------------
#  Maintenance Script for AsusWRT/Merlin Router [SSH]
#  @ /jffs/scripts/  [line 1 MUST be `#!/bin/sh`]
# 
#  ARGs: 0|1|2|3 [x(auto-Yes-to-query)]
#   0) Update self 
#   1) Update hosts file        [load/chmod/reboot]
#   2) Validate hosts file      [cat/head/tail]
#   3) Block Malicious Scripts  [update/chron]
#   4) VPN [on|off]             vpn_client1_state
# ------------------------------------------------------
case $1 in
	"0") # Update self
		[[ "$2" ]] && { _query=y; } || { echo ; read -n 1 -rp ' Update self [y/N] ' _query; }
		[[ "${_query}" == 'y' ]] && { echo;echo; } || { exit; }
		# `cp` source seen @ Windows Network as '\\SMB\Data\hosts'
		[[ -e "/tmp/mnt/WinPE/Data/${0##*/}" ]] && {
			cp "/tmp/mnt/WinPE/Data/${0##*/}" "/jffs/scripts/${0##*/}"
			chmod 700 "/jffs/scripts/${0##*/}"
		} || { echo;echo " ERR :: '${0##*/}' NOT EXIST @ '/tmp/mnt/WinPE/Data'"; }
	;;
	"1") # Update hosts file per 'hosts.add' method
		[[ "$2" ]] && { _query=y; } || { echo ; read -n 1 -rp ' Update hosts file [y/N] ' _query; }
		[[ "${_query}" == 'y' ]] && { echo;echo; } || { exit; }
		# `cp` source seen @ Windows Network as '\\SMB\Data\hosts' 
		[[ -e '/tmp/mnt/WinPE/Data/hosts' ]] && {
			cp '/tmp/mnt/WinPE/Data/hosts' '/jffs/configs/hosts.add'
			chmod 400 /jffs/configs/*  # make it read-only
			reboot # then login again, after reboot, to validate [see below]
		} || { echo;echo " ERR :: 'hosts' NOT EXIST @ '/tmp/mnt/WinPE/Data'"; }
	;;
	"2") # Validate hosts file is auto-appended 
		# echo ; read -n 1 -rp ' Validate hosts file [y/N] ' _query
		# [[ "${_query}" == 'y' ]] && { echo;echo; } || { exit; }
		_hosts='/tmp/etc/hosts'; clear; echo "@ $_hosts"
		cat "$_hosts" | ( head -n 20 ; echo; tail -n 15 )
		# head -n12 "$_hosts"; echo '...'
		# tail -n400000 "$_hosts" | head -n3; echo '...'
		# tail -n300000 "$_hosts" | head -n3; echo '...'
		# tail -n200000 "$_hosts" | head -n3; echo '...'
		# tail -n100000 "$_hosts" | head -n3; echo '...'
		# tail -n 3 "$_hosts"; echo '==='
		# wc -l "$_hosts" | awk '{print $1 " lines"}'
	;;
	"3") # Block Malicious Scripts per firewall rules; `ya-malware-block.sh` 
			 # https://github.com/RMerl/asuswrt-merlin/wiki/How-to-block-scanners,-bots,-malware,-ransomware
			 # 'ya-malware-block.sh' @ shounak-de [GitHub]  
			 # https://github.com/shounak-de/misc-scripts 
		[[ "$2" ]] && { _query=y; } || { echo ; read -n 1 -rp ' Block Malicious Scripts [y/N] ' _query; }
		[[ "${_query}" == 'y' ]] && { echo;echo; } || { exit; }
		# fetch/update script 
		wget --no-check-certificate -O /jffs/scripts/ya-malware-block.sh \
			https://raw.githubusercontent.com/shounak-de/misc-scripts/master/ya-malware-block.sh
		chmod 700 /jffs/scripts/ya-malware-block.sh
		# Run script, and update per Cron Utility, `cru`, every 6 hrs 
    	# https://www.snbforums.com/threads/yet-another-malware-block-script-using-ipset-v4-and-v6.38935/]
		[[ -e '/jffs/scripts/ya-malware-block.sh' ]] && {
			/jffs/scripts/ya-malware-block.sh
			cru a UpdateYAMalwareBlock "0 */6 * * * /jffs/scripts/ya-malware-block.sh"
		} || { echo;echo " ERR :: '/jffs/scripts/ya-malware-block.sh' NOT EXIST"; }
	;;
	"4") # toggle VPN per $2, else instruct and show state
		[[ ! "$2" ]] && { printf "%s\n\n" 'ARG: on|off  (Toggle VPN)'; } || {
			_vpn_status=$( nvram show | grep vpn_client1_state | awk -F = '{ print $2}' ) 
		}
		[[ "$2" == 'on' && "$_vpn_status" != '2' ]]  && service start_vpnclient1
		[[ "$2" == 'off' && "$_vpn_status" != '0' ]] && service stop_vpnclient1
		nvram show | grep vpn_client1_state
	;;

	*) cat "$0" | head -n 11 ;;
esac

echo

exit $?
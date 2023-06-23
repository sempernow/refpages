#!/bin/bash
# --------------------------------------------------
#  Writes a Windows Registry file [.reg] 
#  to replace default drive icon with  
#  autorun.ico @ drive root; for all drive letters
# --------------------------------------------------
drives_icons() {
	echo 'Windows Registry Editor Version 5.00'
	echo ''

	echo '[HKEY_CURRENT_USER\Software\Classes\Applications\Explorer.exe\Drives]'
	echo ''

	for x in {A..Z}
	do
		echo '[HKEY_CURRENT_USER\Software\Classes\Applications\Explorer.exe\Drives\'"${x}]"
		echo ''
		echo '[HKEY_CURRENT_USER\Software\Classes\Applications\Explorer.exe\Drives\'"${x}"'\DefaultIcon]' 
		echo '@="'"${x}"':\\autorun.ico"' 
		echo ''
	done
}

filename="${0##*/}"
filename="${filename/.sh/}"
drives_icons > "${filename}.reg"

exit

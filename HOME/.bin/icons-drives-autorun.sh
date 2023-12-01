#!/bin/bash
# Creates .reg to load into registry per `regedit FILE` command @ Windows cmd.exe
# Contains the keys to set the default icon for all drives to the drive root autorun.ico file

_file="${0##*/}.reg"

cat <<-EOF1 > "$_file"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\Applications\Explorer.exe\Drives]

EOF1

for d in $(echo {A..W} )
do 
	printf "%s\n\n" "[HKEY_CURRENT_USER\\Software\\Classes\\Applications\\Explorer.exe\\Drives\\${d}]" >> "$_file"

	printf "%s\n" "[HKEY_CURRENT_USER\\Software\\Classes\\Applications\\Explorer.exe\\Drives\\${d}\\DefaultIcon]" >> "$_file"
	printf "%s\n\n" "@=\"${d}:\\\\autorun.ico\"" >> "$_file"
done

exit 




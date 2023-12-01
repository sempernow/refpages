#!/bin/bash
#_ovpn=$( find . -type f -iname '*.ovpn' -printf "%f\n" )
#echo "$_ovpn"

exit

find . -iname '*.ovpn' -exec sed -i '/disable-occ/d' {} \+      # delete
find . -iname '*.ovpn' -exec sed -i '$ a\disable-occ' "{}" \+   # append line

find . -iname '*.ovpn' -exec sed -i '/^\s*$/d' "{}" \+          # remove blank or empty lines

find . -iname '*.ovpn' -exec sed -i 's/auth-user-pass/auth-user-pass PIA.ovpn.txt/g' {} \+ # replace
#find . -iname '*.ovpn' -exec sed -i '/auth-user-pass/d' {} \+                             # delete
#find . -iname '*.ovpn' -exec sed -i '$ a\auth-user-pass PIA.ovpn.txt' {} \+               # append
find . -iname '*.ovpn' -exec sed -i 's/cipher BF-CBC/cipher AES-128-CBC/g' "{}" \+         # replace
find . -iname '*.ovpn' -exec sed -i '$ a\auth-nocache' "{}" \+                             # append line

#find . -iname '*.ovpn' -exec sed -i '$ a\redirect-gateway' "{}" \+    # append line
#find . -iname '*.ovpn' -exec sed -i '/link-mtu 1542/d' "{}" \+        # delete line

#  echo "auth-nocache" | tee -a *.ovpn > /dev/null                     # alt method using `tee`

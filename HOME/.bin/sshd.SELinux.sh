# Fix sshd SELinux issues 
sudo semanage fcontext -a -t NetworkManager_etc_rw_t authorized_keys
restorecon -v authorized_keys
ausearch -c sshd --raw | audit2allow -M my-sshd
semodule -i my-sshd.pp

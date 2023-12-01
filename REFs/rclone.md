# `rclone` :: `rsync` for cloud-storage services 

## [Install](https://rclone.org/downloads/ "rclone.org/downloads")

`curl https://rclone.org/install.sh | sudo bash`

## Usage
```bash
# Config; interactive; provides URL that returns OAuth token 
rclone config  # 'rclone.conf' stored @ ~/.config/rclone/

# Synch; skip per checksum, not mtime, match
rclone sync $_SRC $_REMOTE:$_DST -c 

# E.g., between local path & Google Drive
_SRC='/d/Dropbox/disk_utilities'  # Local path
_REMOTE='google'                  # Config name 
_DST='Dropbox/disk_utilities'     # Remote path
```

## Config file

- [@ `rclone.conf`](rclone.conf)

## References
- [rclone.org](https://rclone.org/ "rclone.org")
- [My one-liner Linux Dropbox client](http://lpan.io/one-liner-dropbox-client/ "lpan.io")


### &nbsp;

<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->


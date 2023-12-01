#!/bin/bash
# --------------------------
#  synch HOMEx
# --------------------------
_rsync() { 
    # ARGs: HOSTNAME
    # default to that in LANMACHINES which is not this machine
    _subject=HOME  # common folder; @ both source and target
    # set remote (host)
    _host=${LANMACHINES/$HOSTNAME/}                # remove self machine
    _host="$( echo "$_host" | awk '{print $1 }' )" # ensure only one
    [[ "$1" ]] && _host="$1"                       # overridden if arg
    [[ $_host ]] || { printf "\n  %s\n" 'FAILed @ HOSTNAME'; return; }

    rsync -itu   "/s/$_subject/"*   "//$_host/s$/$_subject/"   # ~/    root-files (not dots)
    rsync -itu   "/s/$_subject/."*  "//$_host/s$/$_subject/"   #  /.*  dot-(files+folders)
    rsync -itudr "/s/$_subject/etc" "//$_host/s$/$_subject/"   # ~/etc folder
}

_rsync "$@"



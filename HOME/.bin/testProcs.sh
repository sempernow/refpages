#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  
# -----------------------------------------------------------------------------
_it=${1:-100}

_do () {
    for i in $(seq 1 $_it); do
        echo $i >/dev/null
    done
}

_proc () {
    while read; do
        echo $REPLY >/dev/null
    done < <(seq 1 $_it)
}

_pipe () {
    seq 1 $_it | xargs -I SEQ /bin/bash -c 'echo $1 >/dev/null' _ SEQ
}

printf "\n%s\n" "=== $_it @ do-loop" 
time _do $_it
printf "\n%s\n" "=== $_it @ Process Substitution" 
time _proc $_it
printf "\n%s\n" "=== $_it @ Pipeline"
time _pipe $_it

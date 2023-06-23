#!/bin/bash
export _rm="$1" 
export _rp="$2" 
find . -maxdepth 1 -name '*'${_rm}'*' -execdir /bin/bash -c 'mv "$@" "${@/${_rm}/${_rp}}"' _ {} \;

#!/bin/bash
export _rm="$1" 
find . -maxdepth 1 -name '*'"${_rm}"'*' -execdir /bin/bash -c 'mv "$@" "${@/${_rm}/}"' _ {} \;

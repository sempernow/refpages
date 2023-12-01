#!/bin/bash
# ---------------------------------------
#  go get ... ALL VScode Analysis Tools
# ---------------------------------------
[[ -d "$GOROOT" ]] || { echo 'GOROOT var must be set to a folder path'; exit; }
read -p 'go get -u -f -v ... ALL VScode Analysis Tools  (Press ENTER to proceed)'
export GOBIN="$GOROOT\bin"
echo "GOBIN reset to '$( go env GOBIN )'"

_pkgs="
github.com/uudashr/gopkgs/cmd/gopkgs
github.com/nsf/gocode
github.com/ramya-rao-a/go-outline
github.com/acroca/go-symbols
golang.org/x/tools/cmd/guru
golang.org/x/tools/cmd/gorename
github.com/rogpeppe/godef
github.com/sqs/goreturns
github.com/golang/lint/golint
github.com/derekparker/delve/cmd/dlv
"

go get -u -f -v $_pkgs

export GOBIN=
echo "GOBIN unset"

read -p '... DONE  (Press ENTER to end)'

exit 

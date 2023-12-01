#!/bin/bash
# -----------------------------------------------------
#  make data
# -----------------------------------------------------
function makeData() {
    _segmentSize='150'
    _segments=${1:-1}
    _file='./frags/f'
    [[ -d './frags' ]] || mkdir ./frags

    ipsum() { 
    # generates serialized set of html fragments 
        printf "\n%s%.3d%s\n" '<h2><code>el[' "$1" "] @ $_segmentSize</code></h2>"
        printf "%s\n" "<p>"
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $_segmentSize  | tr -d '\n' | sed 's/.\{6\}/& /g'
        printf "\n%s" "</p>"
        printf "\n%s" "<div><span>foo</span> &#x2627; <span>bar</span> <span>baz</span></div>"
    }
    for i in $(seq 1 $_segments); do 
        ipsum $i > "${_file}.$i.html"
    done
}

makeData "$@"


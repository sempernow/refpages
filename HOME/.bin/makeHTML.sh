#!/bin/bash
# -----------------------------------------------------
#  make HTML
# -----------------------------------------------------
function makeData() {
    _segmentSize='150'
    _segments=${1:-1}
    _file='data.html'
    printf '' > "$_file"

    ipsum() { 
    # generates one file containing (serialized) html component.
        printf "\n%s%.3d%s\n" '<h2><code>el[' "$1" "] @ $_segmentSize</code></h2>"
        printf "%s\n" "<p>"
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $_segmentSize  | tr -d '\n' | sed 's/.\{6\}/& /g'
        printf "\n%s" "</p>"
        printf "\n%s" "<div><span>foo</span> &#x2627; <span>bar</span> <span>baz</span></div>"
    }
    for i in $(seq 1 $_segments); do 
        ipsum $i >> "$_file"
    done
}

makeData "$@"


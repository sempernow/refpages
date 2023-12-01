#!/bin/bash
# -----------------------------------------------------
#  make data
# -----------------------------------------------------
function makeData() {
    #set -a
    _segmentSize='150'
    _segments=${1:-1}
    _file='data.json'
    printf '' > "$_file"

    ipsum() { 
    # generates an array of json segments; serialized data for a web component.
        (( $1 == 1 )) && printf "%s\n" '['
        printf "%s%.3d%s" '{"head":"el[' "$1" "] @ $_segmentSize\",\"body\":\""
        strings /dev/urandom | grep -o '[[:alnum:]]' | head -n $_segmentSize | tr -d '\n' | sed 's/.\{6\}/& /g'
        printf "%s" '","f1":"foo","f2":"&#x2627;","f3":"bar","f4":"baz"}'
        (( $1 == $_segments )) && printf "\n%s" ']' || printf ','
    }
    # Here, the do-loop is faster than the pipeline
    #seq 1 $_segments | xargs -I SEQ /bin/bash -c 'ipsum $1 >> "$_file"' _ SEQ
    for i in $(seq 1 $_segments); do 
        ipsum $i >> "$_file"
    done
}

makeData "$@"

exit

#!/usr/bin/env bash
# -------------------------------------------------------------
#  Content Security Policy (CSP) scheme to protect app from XSS attack.
#  Generate a Subresource Integrity (SRI) string 'sha384-XXXX...'
#  Browser prevents script execution unless hash match.
#  
#  REF  
#    https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity  
# 
#  ARGs: FILE
#
#  HTML  
#    <script src="https://foo.CDN.com/bar.js"
#      integrity="sha384-qhBCTNl9f4BU/oqVJZiqWMHZJ..."
#      crossorigin="anonymous"></script>
#
#  HTTP Response Header
#    Content-Security-Policy: require-sri-for script; 
# -------------------------------------------------------------
[[ -f "$@" ]] || { script_info "$0"; exit 99; }

# Generate an integrity string for file ("$@"); print to STDOUT; e.g., 
# "sha384-dUKsHPC/irjROOobK9MnyuSfZ+OHFay7hCdfp+n/FnMLe77qDyL3GvposKvuE/Ph".
[[ $(type -t openssl) ]] && { 
    printf "sha384-$(cat "$@" | openssl dgst -sha384 -binary | openssl base64 -A)" 
} || {
    [[ $(type -t shasum) ]] && {
        printf "sha384-$(shasum -b -a 384 "$@" | awk '{ print $1 }' | xxd -r -p | base64)"
    }
}


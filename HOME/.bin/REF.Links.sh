#!/usr/bin/env bash

# Markdown to HTML @ all hereunder
find . -name '*.md'   |grep -v '/vendor' |grep -v '/modules' |xargs -I{} md2HTML.exe "{}"

# REF.Links.md : run @ /IT dir
rm 'html.log' 'html2.log' 'names.log' 2> /dev/null
find . -not -path "./DEV/*" -type f \( -name 'REF.*' ! -iname 'PRJ.*.URL' ! -name 'REF.*.lnk' ! -name 'REF.*.md' \) | sed 's/\\/\//g' | sed 's/ /%20/g' | sed 's#/d/#file:///d:/#g' >> 'html.log'
#[[ ! -f 'html.log' ]] && { echo '  No REF.*.html files here' ; }
awk '{print "(" $1 ")"}' html.log > html2.log
find . -not -path "./DEV/*" -type f \( -name 'REF.*' ! -iname 'PRJ.*.URL' ! -name 'REF.*.lnk' ! -name 'REF.*.md' \) -exec /bin/bash -c 'echo "## [${@##*/}]" >> "names.log"' _ "{}" \;
sed -i 's/.html//g; s/REF.//g' "names.log"
paste -d '' "names.log" "html2.log" | sort > 'REF.Links.md'
md2html.exe 'REF.Links.md'
rm 'html.log' 'html2.log' 'names.log' 2> /dev/null


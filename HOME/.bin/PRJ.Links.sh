#!/usr/bin/env bash

# Markdown to HTML @ all hereunder
find . -name '*.md'   |grep -v '/vendor' |grep -v '/modules' |xargs -I{} md2HTML.exe "{}"

# PRJ.Links.md 
rm 'html.log' 'html2.log' 'names.log' 2> /dev/null
#find . -not -path "./DEV/*" -type f \( -name 'PRJ.*' ! -iname 'PRJ.*.URL' ! -name 'PRJ.*.lnk' ! -name 'PRJ.*.md' \) |  sed 's/\\/\//g' | sed 's/ /%20/g' | sed 's#/d/#file:///d:/#g' >> 'html.log'
find . -type f \( -name 'PRJ.*' ! -iname 'PRJ.*.URL' ! -name 'PRJ.*.lnk' ! -name 'PRJ.*.md' \) |  sed 's/\\/\//g' | sed 's/ /%20/g' | sed 's#/d/#file:///d:/#g' >> 'html.log'
#[[ ! -f 'html.log' ]] && { echo '  No PRJ.*.html files here' ; }
awk '{print "(" $1 ")"}' html.log > html2.log
#find . -not -path "./DEV/*" -type f \( -name 'PRJ.*' ! -iname 'PRJ.*.URL' ! -name 'PRJ.*.lnk' ! -name 'PRJ.*.md' \) -exec /bin/bash -c 'echo "## [${@##*/}]" >> "names.log"' _ "{}" \;
find . -type f \( -name 'PRJ.*' ! -iname 'PRJ.*.URL' ! -name 'PRJ.*.lnk' ! -name 'PRJ.*.md' \) -exec /bin/bash -c 'echo "## [${@##*/}]" >> "names.log"' _ "{}" \;

sed -i 's/.html//g; s/PRJ.//g' "names.log"
paste -d '' "names.log" "html2.log" | sort > 'PRJ.Links.md'
md2html.exe 'PRJ.Links.md'
rm 'html.log' 'html2.log' 'names.log' 2> /dev/null


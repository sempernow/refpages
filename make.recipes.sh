#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  normalize refpages : for use @ Makefile 
# -----------------------------------------------------------------------------


getrefs() {
	refsync temp
	find ./REFs -type f -exec rm "{}" \+ 
    tmp=$(ls $TEMP -ahsrt --group-directories-first |grep tmp. |tail -n 1 |awk '{print $NF}')
	cp -p $TEMP/$tmp/* ./REFs
}

normalize(){
    pushd ./REFs
    find . -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
    find . -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
    popd
}

index() {
    pushd ./REFs
    rm index.md index.html 2> /dev/null
    find . -type f -iname '*.md' -exec md2html.exe "{}" \;
    fname 'REF.'
    # find . -type f -printf "%f\n" >> 'html.log'
    # awk '{print "(" $1 ")"}' html.log > html2.log
    # find . -exec /bin/bash -c 'echo "## [${@##*/}]" >> "names.log"' _ "{}" \;
    # sed -i 's/.html//g; s/REF.//g' "names.log"
    #paste -d '' "names.log" "html2.log" | sort > 'index.md'
    find . -type f ! -iname '*.md' -printf "## [%f](%f)\n" >>index.md
    md2html.exe 'index.md'
    popd
}

"$@"
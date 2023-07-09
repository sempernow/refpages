#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  normalize refpages : for use @ Makefile 
# -----------------------------------------------------------------------------

normalize () {
    find ./REFs -type f -iname '*.html' -exec rm "{}" \+
    find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
}

getrefs() {
	refsync temp
	find ./REFs -type f -exec rm "{}" \+ 
    tmp=$(ls $TEMP -ahsrt --group-directories-first |grep tmp. |tail -n 1 |awk '{print $NF}')
	cp -p $TEMP/$tmp/* ./REFs
}

normalize(){
    find ./REFs -type f -iname '*.html' -exec rm "{}" \+
    find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
    find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
    cd ./REFs && fname 'REF.'
}

"$@"
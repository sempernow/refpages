#!/usr/bin/env bash
#------------------------------------------------------------------------------
# See Makefile recipes
# -----------------------------------------------------------------------------

_NEWEST=/tmp/REFs.newest.file

gitpush() {
    REQUIREs gc git gl
    unset newest 
    [[ -f "$_NEWEST" ]] && newest=$(cat $_NEWEST) && printf "\n%s\n" "=== NEWEST: '$(cat "$_NEWEST")'"
    gc "$newest" && git push && gl
    [[ -f "$_NEWEST" ]] && rm -f "$_NEWEST"
}

getrefs() {
    mkdir -p REFs

    # Purge folders
    find ./REFs -type f -exec rm "{}" \+

    # Dump all REF.* files to tmp folder under $TEMP dir unless already created less than 5min ago
    tmp(){ find /c/TEMP -type d -ctime -.003  -iname 'tmp.*' |tail -n1; }
    [[ -d $(tmp) ]] || refsync temp

    # Copy content to this project's REFs folder
    cp -p $(tmp)/* REFs/

    # Remove some
    rm REFs/REF.{Biz,L9s}*md 2>/dev/null

    # CKAD : Copy entire source dir
    dir='/d/1 Data/IT/Container/Kubernetes/CKAD'
    [[ -d "$dir" ]] && cp -rp "$dir/"* REFs/CKAD/
    rm REFs/CKAD/LOG.* REFs/REF.Kubernetes.CKAD.* 2>/dev/null
    # CKA : Copy entire source dir
    dir='/d/1 Data/IT/Container/Kubernetes/CKA'
    [[ -d "$dir" ]] && cp -rp "$dir/"* REFs/CKA/
    rm REFs/CKA/LOG.* REFs/REF.Kubernetes.CKA.* 2>/dev/null

    # Capture the newest of all REFs/* (in UTC Zulu) before downstream mods (normalize and such) update file mtimes and otherwise ruin the record.
    printf "$(find REFs -type f -printf '%TY-%Tm-%TdT%TH:%TM %P @ ' -exec env TZ=UTC date -r {} +'%Y-%m-%dT%H:%MZ' \; |sort -r |head -n 1 |cut -d' ' -f2-)" \
        |tee $_NEWEST
    [[ -f "$_NEWEST" ]] && printf "\n%s\n" "=== NEWEST: '$(cat "$_NEWEST")'"

    return 0
}

normalize(){
    # Reset paths at internal links : strip the distributed-source parent.
    pushd ./REFs
    find . -type f ! -path './.git/*' -iname '*.html' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
    find . -type f ! -path './.git/*' -iname '*.html' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
    find . -type f ! -path './.git/*' -iname '*.html' |xargs sed -i "s/REF.//g"
    popd
}

index() {
    # Purge obsolete MD/HTML, and then refresh HTML
    REQUIREs md2html.exe || exit
    rm _index.md index.md *.html 2>/dev/null
    pushd ./REFs
    rm index.md *.html 2>/dev/null
    find . -type f ! -path './.git/*' -iname '*.md' -exec md2html.exe "{}" \;

    # Strip namespace used for the distributed source reference files
    fname 'REF.'
    pushd CKAD
    fname 'REF.'
    popd
    pushd CKA
    fname 'REF.'
    popd


    popd

    # Build index of links
    find ./REFs -maxdepth 1 -type f ! -path './.git/*' ! -iname '*.md' \
        -printf "## [%f](%p)\n" >>index.md
    find ./REFs/CKAD -maxdepth 1 -type f -iname 'Kubernetes.CKAD.html' \
        -printf "## [%f](%p)\n" >>index.md
    find ./REFs/CKA -maxdepth 1 -type f -iname 'Kubernetes.CKA.html' \
        -printf "## [%f](%p)\n" >>index.md

    # Sort links alphabetically and build the landing page (index.html).
    sort -f index.md >>_index.md
    echo '# [`sempernow/refpages`](https://github.com/sempernow/refpages "sempernow/refpages @ GitHub")' >index.md
    cat _index.md >>index.md
    
    # Process md2html 
    md2html.exe index.md
    
    # Delete markdowns
    find . -type f ! -path './.git/*' -iname '*.md' -and ! -iname 'README.md' -exec rm "{}" \+
    
    perms
}

links() {
    # Replace Win-configured URIs of md2html.exe with their local-project equivalents.
    #sed -i 's#https://sempernow.github.io/web#/refpages#g' index.html
    find . -type f ! -path './.git/*' -iname '*.html' -exec sed -i 's#https://sempernow.github.io/web#/refpages#g' "{}" \+
}

perms() {
    find . -type d ! -path './.git/*' -exec chmod 755 "{}" \+
    find . -type f ! -path './.git/*' -exec chmod 640 "{}" \+
}

"$@"

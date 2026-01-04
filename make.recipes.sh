#!/usr/bin/env bash
#------------------------------------------------------------------------------
# @ Makefile recipes
# -----------------------------------------------------------------------------

_NEWEST=/tmp/REFs.newest.file

gitpush() {
    REQUIREs gc git gl
    unset newest 
    [[ -f "$_NEWEST" ]] && newest=$(cat $_NEWEST) && printf "\n%s\n" "=== NEWEST: '$(cat "$_NEWEST")'"
    gc "$newest" && git push && gl
    [[ -f "$_NEWEST" ]] && rm -f "$_NEWEST" || true
}

getrefs() {
    mkdir -p REFs

    # Purge folders
    find ./REFs -type f -exec rm "{}" \+ 

    # Dump all REF.* files to tmp folder under $TEMP dir unless done less than 5min ago
    tmp(){ find /c/TEMP -type d -ctime -.003 -iname 'tmp.*' |tail -n1; }
    [[ -d $(tmp) ]] && echo "... copying the recently-cached set of REFs ..." || refsync temp
    cp -rp $(tmp)/* REFs/

    # Remove some
    rm REFs/REF.Biz*md REFs/REF.L9s.*md 2>/dev/null

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
    find . -type f ! -path './.git/*' -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
    find . -type f ! -path './.git/*' -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
    find . -type f ! -path './.git/*' -iname '*.md' |xargs sed -i "s/REF.//g"
    popd
}

index() {
    # Purge obsolete MD/HTML, and then refresh HTML
    rm README.md index.md *.html 2>/dev/null
    pushd ./REFs
        rm index.md *.html 2>/dev/null
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
    find ./REFs -maxdepth 1 -type f ! -iname '*.html' \
        -printf "## [%f](%p)\n" >>index.md
    find ./REFs/CKAD -maxdepth 1 -type f -iname 'Kubernetes.CKAD.md' \
        -printf "## [%f](%p)\n" >>index.md
    find ./REFs/CKA -maxdepth 1 -type f -iname 'Kubernetes.CKA.md' \
        -printf "## [%f](%p)\n" >>index.md
    sort -f index.md >>README.md

    # Cleanup
    rm index.md 2>/dev/null
    find . -type f ! -path './.git/*' -iname '*.html' -exec rm "{}" \+
    perms
}

perms() {
    find . -type d ! -path './.git/*' -exec chmod 755 "{}" \+
    find . -type f ! -path './.git/*' -exec chmod 640 "{}" \+
}

"$@"

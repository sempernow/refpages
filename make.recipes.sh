#!/usr/bin/env bash
#------------------------------------------------------------------------------
# @ Makefile recipes
# -----------------------------------------------------------------------------

getrefs() {
    mkdir -p {HOME/.bin,REFs}

    # Purge folders
    find ./REFs -type f -exec rm "{}" \+ 
    find ./HOME -type f -exec rm "{}" \+ 
    find ./HOME/.bin -type f -exec rm "{}" \+ 
    find ./HOME/.bin -type f -iname '*.zip' -exec rm "{}" \+ 

    # Dump all REF.* files to tmp folder under $TEMP dir
	refsync temp
    
    # Find the most recent tmp.* dump folder
    tmp=$(ls $TEMP -ahsrt --group-directories-first |grep tmp. |tail -n 1 |awk '{print $NF}')

    # Copy content to this project's REFs folder
	cp -p $TEMP/$tmp/* REFs/
    
    # Remove some
    rm REFs/REF.Biz*md REFs/REF.L9s.*md 2>/dev/null

    # CKAD
    ckad='/d/1 Data/IT/Container/Kubernetes/CKAD'
    [[ -d '/d/1 Data/IT/Container/Kubernetes/CKAD' ]] && cp -rp '/d/1 Data/IT/Container/Kubernetes/CKAD/'* REFs/CKAD/
    rm REFs/CKAD/LOG.* REFs/REF.Kubernetes.CKAD.* 2>/dev/null

    # CKA
    ckad='/d/1 Data/IT/Container/Kubernetes/CKA'
    [[ -d '/d/1 Data/IT/Container/Kubernetes/CKA' ]] && cp -rp '/d/1 Data/IT/Container/Kubernetes/CKA/'* REFs/CKA/
    rm REFs/CKA/LOG.* REFs/REF.Kubernetes.CKA.* 2>/dev/null


    # Copy/Update the specified ~/.* scripts to this project's HOME folder
    cp -p ~/{.profile,.bash_profile,.bashrc,.bash_win,.bash_functions,.vimrc,.terraformrc,.gitconfig,.gitignore,.gitignore_global} HOME/

    # Copy/Update all ...
    cp -rp ~/.bin/* HOME/.bin/

}

normalize(){
    # Reset paths at internal links : strip the distributed-source parent.
    pushd ./REFs
    find . -type f ! -path './.git/*' -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
    find . -type f ! -path './.git/*' -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
    popd
}

index() {
    REQUIREs md2html.exe || exit
    
    # Purge obsolete MD/HTML, and then refresh HTML
    rm index.md *.html 2>/dev/null
    pushd ./REFs
    rm index.md *.html 2>/dev/null
    # find . -type f -iname '*.md' -exec md2html.exe "{}" \;

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

    # Sort links alphabetically and build README.md .
    cat README.src.md >README.md
    sort -f index.md >>README.md
    md2html.exe README.md

    # Cleanup
    rm index.md 2>/dev/null
    find . -type f ! -path './.git/*' -iname '*.html' -exec rm "{}" \+
    perms
}

perms() {
    find . -type f ! -path './.git/*' -exec chmod 0644 "{}" \+
    find . -type f  -iname 'make.recipes.sh' -exec chmod 0755 "{}" \+
}

"$@"

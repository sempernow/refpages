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

    # Dump all REF.* files to tmp folder under $TEMP dir
	refsync temp
    
    # Find the most recent tmp.* dump folder
    tmp=$(ls $TEMP -ahsrt --group-directories-first |grep tmp. |tail -n 1 |awk '{print $NF}')

    # Copy content to this project's REFs folder
	cp -p $TEMP/$tmp/* REFs/
    
    # Remove some
    rm REFs/REF.{Biz,L9s}*md HOME/.bin/*.{zip,7z,png,jpg} 2>/dev/null

    # CKAD
    ckad='/d/1 Data/IT/Container/Kubernetes/CKAD'
    [[ -d '/d/1 Data/IT/Container/Kubernetes/CKAD' ]] && cp -rp '/d/1 Data/IT/Container/Kubernetes/CKAD/'* REFs/CKAD/
    rm REFs/CKAD/LOG.* REFs/REF.Kubernetes.CKAD.* 2>/dev/null

    # CKA
    cka='/d/1 Data/IT/Container/Kubernetes/CKA'
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
    find . -type f ! -path './.git/*' -exec chmod 0644 "{}" \+
    find . -type f  -iname 'make.recipes.sh' -exec chmod 0755 "{}" \+
}

"$@"

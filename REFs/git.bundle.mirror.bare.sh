#!/usr/bin/env bash
exit
# CHEATSHEET : https://training.github.com/downloads/github-git-cheat-sheet/ 
# GitHub Help https://help.github.com/
# Pro Git  https://git-scm.com/book/en/v2

###########################################################
## BUNDLE : git bundle : Migrate repo : Capture as ONE FILE
    # 1. Create bundle file from source host.
    git bundle create $repo.bundle --all # All branches (refs) and tags
    # 1.b. Verify bundle (if at source repo) : Full check: format, prerequisites, coverage
    git bundle verify $repo.bundle # Working at root of source repo
    # 1.c List bundle content (from anywhere) : Smoke test the bundle
    git bundle list-heads $repo.bundle 
    # 2. Clone (Extract from) bundle and push to destination host.
    git clone $repo.bundle $repo # Creates $repo folder
    cd $repo
    git remote add origin git@$new_host/$repo.git       # SSH mode
    git remote add origin https://$new_host/$repo.git   # HTTP mode
    
    git push -u origin --all
    git push origin --tags

    # Other git operations on a *.bundle
    # Clone a repo from local bundle (instead of from remote origin)
    git clone $repo.bundle $repo  # Clone a repo from bundle
    # Fetch (not merge) updates from bundle
    git fetch ../$repo_updates.bundle main
    # Pull latest from bundle's main; merging it into current branch.
    git pull ../$repo_updates.bundle main

###################################################################
## MIRROR : git clone --mirror : Use to mirror, sync, backup a repo
    # 1. From source
    git clone --mirror host1:$repo.git # --bare instead here does about same (less ancillary objects)
    # 2. To destination 
    git remote set-url origin host2:$repo.git
    git push --mirror origin 

###############################################
## BARE : git clone --bare : Use to host a repo
    # Like mirror, but all remote references (push, pull, ...) are purged.
    # - At host2
    git clone --bare host1:$repo.git 
    cd $repo.git            # Contains the database and meta only; all packed away
    git show-ref            # list all references; branches, tags, ...
    git ls-tree -r $branch  # List all content (paths) : repo_sub_dir/sub2/fname.ext

    #################
    ## HOST Git repos 
        # 1. At the Git host (git01.lime.lan)
        # Setup : RUN AS root
        # - Idempotent 
        dnf install -y git
        alt=/srv/git
        id git || adduser --system --shell /usr/bin/git-shell --create-home --home-dir $alt git
        # --system: system account (UID < 1000)
        # --shell git-shell: disables login shell, and restricts SSH to server-side Git commands only.
        # --home-dir /home/git : Sets user's HOME dir 
        # Configure a non-standard ($alt) HOME for local user that SELinux treats as it would those of /home
        seVerifyHome(){
            ## Verify SELinux fcontext EQUIVALENCE
            sudo semanage fcontext --list |grep "$1" |grep "$1 = /home"
        }
        export -f seVerifyHome
        seVerifyHome $alt || {
            ## Force SELinux to accept SELinux declarations 
            ## REGARDLESS of current state of SELinux objects at target(s)
            sudo semanage fcontext --delete "$alt(/.*)?" 2>/dev/null # Delete all rules; is okay if no rules exist.
            sudo restorecon -Rv $alt # Apply the above purge (now).
            ## Declare SELinux fcontext EQUIVALENCE : "$alt = /home"
            sudo semanage fcontext --add --equal /home $alt
            sudo restorecon -Rv $alt # Apply the above rule (now).
        }
        # Make the repos root and SSH dirs for user git
        sudo -u git mkdir -p $alt/{repos,.ssh}
        sudo -u git touch $alt/.ssh/authorized_keys
        sudo -u git chmod 700 $alt/.ssh
        sudo -u git chmod 600 $alt/.ssh/authorized_keys
        # SSH-mode setup : The git admin appends clients' key(s) to authorized keys file of this Git host (git@host)
        sudo -u git cat $public_key_of_client >> ~/.ssh/authorized_keys
        # Add content                                                   Use Case
        # -----------                                                   --------
        sudo -u git git init --bare    $alt/repos/$repo.git             # New, empty repo
        sudo -u git git clone --bare   https://example.com/$repo.git    # Existing repo : Remotes are purged
        sudo -u git git clone --mirror https://example.com/$repo.git    # Existing repo : Remotes are preserved
        # Test local access 
        sudo -u git git-upload-pack /srv/git/repos/$repo.git  #...hangs; ok.
        # Test ssh access
        ssh -Ti $client_key git@$(hostname -f) "git-upload-pack '/srv/git/repos/$repo.git'"

        # 2. At remote client(s) : `git clone|pull|push|... `
        ssh -T git@$host 'git --version'                  # Smoke test access 
        git ls-remote git@$host$:/srv/git/repos/$repo.git # List content
        git clone git@$host:/srv/git/repos/$repo.git      # Clone repo from the host (origin)


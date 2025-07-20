#!/usr/bin/env bash
exit
# CHEATSHEET : https://training.github.com/downloads/github-git-cheat-sheet/ 
# GitHub Help https://help.github.com/
# Pro Git  https://git-scm.com/book/en/v2

#############################
## COMMON COMMANDs @ workflow
    mkdir ${REPONAME}          # create repo container                
    git init                   # create local repo
    git status                 # should be empty
    git add FILE1 FILE2        # add file[s]
    git rm FILE3               # Remove FILE3 from git AND local filesystem.
    git rm FILE4 --cached      # Remove FILE4 from git, but NOT from local filesystem.
    git status                 # Status of working copy of current branch
    git commit -am "a message" # Commit all changed files at working copy of current branch
    git push                   # Push commit to origin (remote)

###########################
## Merge source into target
    git status # Ensure working dir is clean; no uncommitted changes
    git checkout $target    
    git pull origin $target # Pull latest changes from its remote 
        # OPTIONAL :  Previews
        git merge --no-commit --no-ff $source   # Preview the merge
        git merge-base $target $source          # Find point of divergence 
        # OPTIONAL : Visualize the divergence
        git log --graph --oneline $(git merge-base main $source)..$target
        git log --graph --oneline $(git merge-base main $source)..$source
        # OPTIONAL : Show how many commits each branch has since diverging
        git rev-list --count main..$source      # commits only in source
        git rev-list --count $source..$target   # commits only in target
        # OPTIONAL : Show the actual changes that would be merged
        git diff $(git merge-base main feature-branch)..feature-branch
    # Merge (actually) source into target
    git merge $source 
        # -s recursive Default merge : Recursively merges branches with complex histories
        # -X theirs : Polite : Attempts normal merge; selects $source only on conflict
        # --strategy=theirs : Destroy everything of $target not in $source

    # Test normal merge
    git merge $source
    # Inspect conflicts...
    git merge --abort

    # Test -X theirs strategy
    git merge -X theirs $source
    # Inspect result...
    git reset --hard HEAD~1 # Undo last commit (the merge)

    # Test -s theirs strategy
    git merge -s theirs $source
    # Inspect result...
    git reset --hard HEAD~1 # Undo last commit (the merge)

    # Check out main's version
    git checkout --ours $conflicted_file
    #... consider AND/OR ...
    git checkout --theirs $conflicted_file
    git add $conflicted_file
    # ... choose, then go to next conflict ...
    git checkout --theirs $next_conflicted_file
    git add $next_conflicted_file
    #... when done ...
    git commit 

    # Check out feature's version 

    # See both versions
    git diff --ours
    git diff --theirs

    # 1. Abort the current merge (if conflicted)
    git merge --abort

    # OR (if you already committed the merge)
    git reset --hard HEAD~1  # undo last commit

    # 2. Ensure clean state
    git status  # should show "nothing to commit, working tree clean"

    # When merged and happy ...
    git push origin $target # Push the merge

    # Show the common ancestor (merge base):
    # Then diff each side from that:
    git diff <merge-base>..source
    git diff <merge-base>..target
    # Demo : https://chatgpt.com/share/685f4353-2090-8009-bcb8-6f646190e5c0 

## Merge source (of another project) into target
    git clone $target
    cd /to/target/project
    git remote add upstream $source_url
    git fetch upstream $source_branch
    git checkout -b $new_target_local_branch
    git merge upstream/$source_branch
    git push -u origin $new_target_local_branch

###############################################################
## Rebase source branch onto target, then merge back into target
    ## ours/theirs flips meaning !!! ours is branch rebasing into; theirs is working branch
    # Pattern for clean history
    # That's a fast-forward merge with clean, linear history; no merge commits, no forks, no clutter.
    git checkout $source
    git rebase $target # Affects only source branch (commit history is linear : target-source)
    # test, then merge source into target:
    git checkout $target
    git merge $source  # fast-forward
    git push origin $target # Push the merge

    ## When local is BEHIND/DIVERGED from remote, ...
    git checkout $branch
    git pull    # Fail: "You have divergent branches and need to specify how to reconcile them."
    git status  # Any changes (staged)?
    git reset   # Unstage if so 
    ## Option A if want remote to OVERWRITE LOCAL
    git fetch origin
    git reset --hard origin/$branch # Destroys all local changes
    ## Option B. If want to PRESERVE LOCAL changes
    git stash
    git fetch origin
    git reset --hard origin/$branch
    git stash apply

    # REBASE source branch such that its history follows target
    git checkout $source
    git rebase $target
    # Use interactive rebase to squash (all) source commits, else all are preserved.
    git rebase -i $target 

#######
## HELP 
    git help VERB    # big help; html if so @ git config
    git VERB --help  # big help
    git VERB -h      # small help; options for VERB
    man git VERB     # man page for verb AKA porcelain (high-level) command.

###############
## CLONE a repo  
    # TL;DR
    git clone git@gitlab.com:$account/$project.git
    # Details
    git clone ${PROTO}://${REPO_URI}.git                # TO ./REPONAME
    git clone ${PROTO}://${REPO_URI}.git ${FOLDER}.git  # TO a specific (new) local FOLDER
    git clone --branch ${BR} ${PROTO}://${REPO_URI}.git # TO a specifid local BRANCH 
    # Shallow : 1 commit only (most recent)
    git clone --depth=1 --branch=master ${REPO_URI}.git  # shallow; history of commits = 1
    # Git PROTOCOLs (SSH|HTTPS)
    git clone ssh://[user@]server/project.git    # ssh 
    #git clone [user@]server:project.git          # ssh : NOT @ `git clone ...`
    git clone https://[user@]server/project.git  # https
    git clone git://[user@]server/project.git    # git : fastest but NOT encrypted

    cd $project

    # Add origin : SSH mode 
    git remote add origin git@${server}:${path}.git

    # SSH login sans creds prompts
    ssh -T -i $keypath git@${server}

    # Push (securely)
    git push -u origin main # initial : -u, --set-upstream
    git push    

    # CLONE a FOLDER of a repo 
    
        # Easy way : SVN : export
        svn export $path/trunk/$folder
        
        # Else : Git : Sparse Checkout 
        git init $path
        cd $path
        git remote add origin ${proto}${server}:${acct}/${prj}.git
        git config core.sparsecheckout true
        echo "finisht/*" >> .git/info/sparse-checkout
        git pull --depth=1 origin master

#################
## INIT a PROJECT
    mkdir $prj 
    cd $prj
    vim .gitignore      # Create/Edit 
    git config --list   # Get config
    # (Re)Set local config k-v
    git config init.defaultbranch=main
    # Add local config k-v
    git config user.project ${PWD##*/}
    # Initialize
    git init --initial-branch=main
    # Order matters:
    git add -u
    git add .
    git commit -C "Init @ $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    
    # Commit pattern:
    git add -u && git add . && git commit -m "$msg @ $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    
    # Add origin : SSH mode 
    git_at_host=gitlab # If so conf'd @ ~/.ssh else, e.g., git@gitlab.com (*not* $USER@)
    git remote add origin $git_at_host:$(git config user.account)/$prj.git
    # SSH login 
    ssh -T -i ~/.ssh/gitlab_$(git config user.account) $git_at_host
    # Push
    git push origin master

    # Set network params for SSH mode
    proto='git@'
    server='gitlab.com' # Domain name of the Git-server host
    path="$(git config user.account)/$(git config user.project)"
    keypath=~/.ssh/${server%.*}_$(git config user.account)

###########
## BRANCHes 
    # Lists all branches (remote and local)
        git branch -a

    # ADD a new branch ("branch").
        git branch $name

    # DELETE a branch.
        git branch -d $name             # Local
        git push origin --delete $name  # Remote

    # RENAME a branch.
        git branch -m $old $new

    # EDIT/ADD branch DESCRIPTION (@ text editor)
        git branch --edit-description $name
        #  VIEW the description 
            git config branch.$name.description
            # Does NOT display per listing @ `git branch`. Script to do so:
            # https://github.com/bahmutov/git-branches/blob/master/branches.sh 

##########################
## CHECKOUT : AKA dispatch
    # Switch to local, else update from remote, else create new" : may create detached HEAD 
    git checkout $name  # If local exist, else clone of branch prior to command execution
    git switch $name    # Newer equivalent if local exist.
    # In full, setup remote tracking : Git sets this implicitly
    git checkout -b $name --track origin/$name
    git checkout -b $name origin/$name # Implicit : equivalent

######################
## FETCH : always safe
    # download to working copy, but don't change state of local branches
    # https://stackoverflow.com/questions/292357/what-is-the-difference-between-git-pull-and-git-fetch
    # https://www.atlassian.com/git/tutorials/syncing/git-fetch 
    git fetch origin $name
    git fetch origin # all branches
    git fetch --all  # all origins
    git fetch --dry-run 

    # Synch with remote, but NOT SAFE to local (overwrites any changes since last commit).
    git fetch origin $name
    git reset --hard origin/$name

#########################################################
## PULL : fetch + merge (or rebase, per config settings).
    # Preserve local commits; merges remote changes into local working copy
    git pull origin $name 

#########
## COMMIT 
    git commit -m 'Commit message'
    git commit --amend # Edit a (unpushed) commit msg, per default editor.
    git commit --amend -m 'New message.'  # Edit a (unpushed) commit.
    # SHA1 hash of HEAD revision (commit)
    git rev-parse HEAD
    git rev-list HEAD #... last 40 revisions (SHA1)

#######################################
## CHECKOUT : a Branch, Commit, or File
    git checkout OBJECT # Swiss Army knife
    # 1. Can revert to old version of file or earlier commit
    # 2. Switch to another branch : 
        git switch BRANCH # Equivalent though subset; only for switching branches

#################  
## DIFF : Compare  
    git diff origin/$br # Show changes between local and remote of branch $br
    git diff            # Show changes not yet staged; not yet added to git 'index'
    git diff --cached   # Show staged changes about to be committed
    git diff --staged   # Show staged changes about to be committed
    git diff HEAD       # Show changes since last commit 
    git diff HEAD^      # Show changes since the commit before the last commit.

########################################################
## SEARCH for content against (all) files of the project
    git grep PATTERN [PATH]  # e.g., ...  
    git grep 'terminal.*' */*.go  # find all occurrences of 'terminal.*' in all .go files
    git grep -e 'foo' --and \ (-and bar -and baz \)  # "foo" and "bar" or "baz"
        # Prepend line numbers @ grep search
        git config --global grep.lineNumber true  

## ORPHAN : Create a new br based on current br yet having no commit history
    git checkout --orphan $a_new_branch # New branch has no commit history
    git add -A
    git commit -m "Year Zero. This is the 1st commit."

## LOCAL WORKFLOW 

    # 1. Create feature branch
    git checkout -b $feature # create AND checkout temp development branch
    # 2. Do work : Many commit okay, but DO NOT PUSH any.
    # 3. REBASE interactively:
    # If you had 5 commits, then "HEAD~4" to squash all into one:
    git rebase -i HEAD~4
    #... in the editor, set the oldest (1st-listed) commit to "pick" and all others (below) to "squash" ("s")

    # Programmatically:
    _max_squash=$(( $( git rev-list --count HEAD ) - 1 )) # commits count less 1.
    git add .*;git add -A;git commit -m 'x'
    # Merge into main (at HEAD)
    git rebase $main
    git rebase -i HEAD~$_max_squash 
    # Example command+syntax @ vim (automatic edit, during rebase) 
    :2,7s/pick/s/g  #... to squash commits 2-7
    git checkout $main
    git merge $feature # Adds the merge-commit history to master

## CI/CD WORKFLOW 
    # MODIFY @ feature branch, NOT master branch  
        git checkout -b $feature  # i.e., clone master and modify that,  
        git add . ; git commit -m 'feature'  
        git push [origin $feature]  # push to feature (creates on push)  
        # Create Pull Request (PR) @ GitHub repo webpage  
            # Repo > Pull requests (tab) > "New pull request" (button)  
            # > "base:master <= compare:devel"  (dropdown-menus)  
            # > Create pull request  (button)  
        # Wait for (Travis) test to report success
            # Travis runs test, but no deploy, since it's not the master branch. 
            # (Is okay to instruct Travis to build only on PR).
        # Merge PR (into master) @ GitHub repo webpage
            # Repo > "Pull requests"  (tab) > Conversation >   
            # "Merge pull request"  (button)  
        # Is okay to delete feature branch afterwards.  
    # push ONLY to PUBLISH  
        # local versioning is per branching; checkout temp/disposable branches,  
        # as needed, and/or use an out-of-band copy/versioning process  
        # SQUASH (REBASE) when "done":  
            git add .* ; git add -A ; git commit -m 'x'  
            git rebase -i HEAD~$(( $( git rev-list --count HEAD ) - 1 )) # (No. of commits) - 1  
            # vi command syntax, @ auto-edit, during rebase process:  
            :2,7s/pick/s/g  # E.g., to squash commits 2-7;  
            # That is, ALWAYS leave the first (top) as 'pick'; change all others to 's'.  

## RESTORE file mod times (mtime) of all files (after git ... destroys them)
    # https://stackoverflow.com/questions/2458042/restore-a-files-modification-time-in-git/22638823#22638823 
    git log --pretty=%at --name-status --reverse \
        |perl -ane '($x,$f)=@F;next if !$x;$t=$x,next if !defined($f)||$s{$f};$s{$f}=utime($t,$t,$f),next if $x=~/[AM]/;' 

## TAG : Used @ Golang Modules  https://git-scm.com/book/en/v2/Git-Basics-Tagging 
    tag=1.2.3
    git tag                     # List tags
    git tag -l "v1.2*"          # List per filter
    git show $tag               # Show tag-related info 
    # DO : Create AFTER commit  
    git tag -a $tag $commit -m "$msg"   # Annotated Tag
    git tag $tag $commit                # Lightweight Tag
    # DON'T : Create BEFORE commit 
    git tag -a $tag -m "$msg"   # Annotated Tag
    git tag $tag                # Lightweight Tag
    # push EXPLICITLY; Tags are NOT pushed by normal `git push ...` 
    git push origin $tag    # Push this one tag to remote repo.
    git push origin --tags  # Push ALL tags to remote repo.
    # Delete 
    git tag -d $tag                  # Delete local
    git push origin --delete $tag    # Delete remote 
    git push origin :refs/tags/$tag  # Delete remote; equivalent
 
## FILESYSTEM COMMANDs  
    git mv foo.bar baz.bar     # Renaming a file.  
    git mv foo.bar ./foo/baz.b # Moving a file.  
    git mv -f fileA fileB      # Replaces a file.  

## REMOTEs (ORIGIN/UPSTREAM); TRACKED BY LOCAL branch(es)
    origin    # REMOTE repo associated with the local/current/working/tracking folder
    upstream  # Original repo if remote is FORK, else origin.
    # See "ADD UPSTREAM" section for fork corroboration.
    git remote -v  # Print remote(s) incl protocol (mode)
    # READ loacl config setting for remote 
    git config --get remote.origin.url # ${PROTO}://${REPO_URI}.git 

## REMOTE-TRACKING branches
    git ls-remote   # Show remote url + commit
    origin/master   # The (default) REMOTE-tracking branch for LOCAL master branch 
    # SHOW remote-tracking; what's tracking what 
        git remote show origin   
        git branch [-v]  # show local branches [verbose] 
        git branch -a    # show all; local + REMOTE 
        git branch -r    # show REMOTEs 
        # e.g., ...
            remotes/origin/HEAD -> origin/master  # the default clone branch 
            ...
    # SET/CHANGE remote-tracking branch 
        git branch $brLOCAL -u origin/$brREMOTE 
        git branch $brLOCAL --set-upstream-to=origin/$brREMOTE  # Equivalent
        #=> "Branch brLOCAL set up to track remote branch brREMOTE from origin."

    # SET/CHANGE remote URL per PROTOCOL/MODE  
    acct=$(git config user.account || echo FAIL) 
    ## Note at SSH mode, if the Git host is configured @ ~/.ssh/config, 
    ## then replace "git@github.com" with just the NAME declared at that `Host NAME`.
    ## E.g., if ssh config has `Host gitlab`, then use: `git ... origin gitlab:${acct}/...`
    git remote set-url origin git@github.com:${acct}/${PWD##*/}.git     # SSH mode
    git remote set-url origin https://github.com/${acct}/${PWD##*/}.git # HTTP mode
    # ADD remote ORIGIN per PROTOCOL/MODE
    git remote add origin git@github.com:${acct}/${PWD##*/}.git         # SSH mode 
    git remote add origin https://github.com/${acct}/${PWD##*/}.git     # HTTP mode
    # ADD UPSTREAM (to corroborate @ FORK) 
    git remote add upstream https://github.com/$original_acct_slash_repo.git
    # REMOVE upstreams
    git remote rm upstream  # remove ALL remote upstreams
    # VERIFY/SHOW remote(s)
    git remote -v 

    # PUSH NEW branch (set new upstream) 
    # (Note: "upstream" @ `push` has different context from that of `git remote add upstream`)
    git push --set-upstream origin brName  # push brName, setting its "upstream" (REMOTE)  
    git push -u origin brName              # EQUIVALENT 

######
## LOG 
    git log --oneline     # succinct list
    git log -n $N         # last $N commits
    git log  -p           # differences per commit; detailed
    git log --stat        # differences per commit; summary
    git log --merges      # only commits of merges
    git log --pretty=oneline
    git log --pretty=format:"%h - %an, %ar : %s" # https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History#pretty_format

    git reflog      # HEAD and branch references
    git shortlog    # current commits by current user in chronological order
    git shortlog -s # Number of commits by current user

##################################################################################
## REVISION SELECTION  https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection
    # show revision 
        git log --pretty=oneline  # show list of all revisions
        git show hhhhhhh          # by its (partial) hash
        git show branchName       # by its branch name

####################################
## ROLLBACK (REVERT) to PRIOR commit 
    # TEMPORARY
    git checkout $commitSHA1  # TEMPORARY; "detached HEAD" state
    git checkout -            # End that temporary "detached HEAD" checkout 
    # DO not commit changes while in this state. 

    # PERMANENT
    git checkout $commitSHA1 .   # This will apply changes to the whole tree. 
    # Execute @ git project root. If @ sub dir, then changes only that
    # Else CAN commit thereafter.

    # UNDO (If BEFORE commit of this rollback.)
    git reset --hard  # Undo 

##################################
## ROLLBACK (hard) to PRIOR commit 
    git reset --hard HEAD         # To the most recent commit
    git reset --hard HEAD~10      # 10 commits back
    git reset --hard $commitSHA1  # Specify per hash (hex) of the commit

#########################
## META / IGNORING FILES 
    .gitignore
        **/assets/* # ignore all /assets/ subfolders; 
    .gitattributes  # file @ root to inform, e.g., ...
        # used to FIX GitHub's mis-reporting of LANGUAGE 

######################
## CONFIG : READ/WRITE
    # Default: list all; locals are last
    git config --list [--system|--global|--local] 
    # Get/Set config k-v 
    git config [--global] user.name "YOUR NAME"
    git config [--global] user.email "YOUR_EMAIL"
    # Add new k-v pair
    git config --add any.foo "bar value"

    # SEE : 3 levels of config      
    .git/config     # per repo    : --local
    ~/.gitconfig    # per user    : --global
    /etc/gitconfig  # per system  : --system

        # --global @ Git-for-Windows
        "%USERPROFILE%\AppData\Local\GitHubDesktop\app-0.7.2\resources\app\git\mingw64\etc"
        # --global @ Cygwin 
        "~/.gitconfig"
        # --system @ Git-for-Windows
        "%ProgramFiles%\Git\mingw64\etc"

    git config --global push.default current  
    # so, ... 
    git push -u # infers `git push -u origin current-branch`

    # Global gitignore 
    git config --global core.excludesfile  '~/.gitignore_global'

    # set editor
    # DEFAULT is set by shell $EDITOR Env. Var. [UNSET @ Cygwin]
    git config --global core.editor vim
    git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -nosession"

    # git diff : spaces-per-tab; set to 3 (it uses less utility)
    git config --global core.pager 'less -x1,3'

    # set line-endings 
    # Linux/Mac
    git config --global core.autocrlf input
    git config --global core.safecrlf true
    # Windows
    git config --global core.autocrlf true
    git config --global core.safecrlf true
    # Mingw64 (Git-for-Windows) + Cygwin 
    git config --global core.autocrlf false
    git config --global core.safecrlf false  # else, on 'git add...', err:
        "fatal: LF would be replaced by CRLF in README.md"

    # Help [also @ irc.freenode.net]
    git help <verb>
    git <verb> --help
    man git -<verb>

    git config --list
    git help config

    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com

###########################################################
## SSH PKI SETUP : https://docs.gitlab.com/ee/user/ssh.html 
    # Generate key pair
    ssh-keygen -t ed25519 -C "$(git config user.email)" -f $keypath

    # Re(Set) passphrase 
    ssh-keygen -p -P $old -P $new -f $keypath

    # Fingerprint (fpr)
    # Show fpr of any key (public/private have common fpr)
    ## -v show visual in addition to the hash.
    ssh-keygen [-E md5|sha1(default)] -l[v] -f $keypath
    # Show fpr of (remote) host(s) : VALIDATE host ON FIRST CONNECT
    ssh-keygen [-E md5|sha1(default)] -l[v] -f $keypath

    # Copy/Paste user's PUBLIC key (*.pub) to remote:
    # Web GUI @ https://gitlab.com/-/profile/keys

    # LOGIN : Create SSH tunnel for Git traffic (Must disable TTY/PTY allocation; -T) 
        ssh -Ti $keypath git@github.com # -v[v[v[v]]]; verbosity (levels)
        ssh -T gitlab # If ~/.ssh/config has "Host: gitlab" having "IdentifyFile ~/.ssh/gitlab_acct_foo"
        # Optionally setup git config : Requires Git 2.10+
        git config core.sshCommand "ssh -o IdentitiesOnly=yes -i $keypath -F /dev/null"

#################################################
## Bundle : git bundle : Migrate repo to new host
# 1. At source : Create bundle file from source host.
git bundle create $repo.bundle --all # All branches (refs) and tags
# 1.b. Verify 
git bundle verify $repo.bundle || echo ERR : $? # Full check: format, prerequisites, coverage
git bundle list-heads $repo.bundle # Smoke test : List bundle content else fail 
# 2. At destination : Clone (Extract from) bundle and push to destination host.
git clone $repo.bundle $repo
cd $repo
git remote add origin https://new-remote.example.com/$repo.git
git push -u origin --all
git push origin --tags

# Other git operations on a *.bundle
# Clone a repo from local bundle (instead of from remote origin)
git clone $repo.bundle $repo  # Clone a repo from bundle
# Fetch (not merge) updates from bundle
git fetch ../$repo_updates.bundle main
# Pull latest from bundle's main; merging it into current branch.
git pull ../$repo_updates.bundle main

##########################################################
## Mirror : git clone --mirror : Backup/Sync/Mirror a repo
# 1. At source
git clone --mirror https://example.com/$repo.git
# 2. At destination 
git remote set-url origin https://new-remote.example.com/$repo.git
git push --mirror origin 

############################################
## Bare : git clone --bare : Hosting repo(s)
# Bare is like mirror, but only all refs/heads/* and refs/tags/* ; no edge-case or meta 
# 1. At the Git host (git01.lime.lan)
# Setup : RUN AS root
# - Idempotent 
dnf install -y git
alt=/srv/git
id git || adduser --system --shell /usr/bin/git-shell --create-home --home-dir $alt git
# --system: system account (UID < 1000)
# --shell git-shell: disables login shell; only Git commands allowed
# --home-dir /home/git : Sets user's HOME dir 
# Configure a non-standard ($alt) HOME for local user that SELinux treats as it would those of /home
seVerifyHome(){
    ## Verify SELinux fcontext EQUIVALENCE
    semanage fcontext --list |grep "$1" |grep "$1 = /home"
}
export -f seVerifyHome
seVerifyHome $alt || {
    ## Force SELinux to accept SELinux declarations REGARDLESS of current state of SELinux objects at target(s)
    semanage fcontext --delete "$alt(/.*)?" 2>/dev/null # Delete all rules; is okay if no rules exist.
    restorecon -Rv $alt # Apply the above purge (now).
    ## Declare SELinux fcontext EQUIVALENCE : "$alt = /home"
    semanage fcontext --add --equal /home $alt
    restorecon -Rv $alt # Apply the above rule (now).
}
# Make the repos root and SSH dirs for user git
sudo -u git mkdir -p $alt/{repos,.ssh/authorized_keys}
sudo -u git chmod 700 /home/git/.ssh
sudo -u git chmod 600 /home/git/.ssh/authorized_keys
# SSH-mode setup : The git admin appends clients' key(s) to authorized keys file of this Git host (git@host)
sudo -u git cat id_ed25519.pub >> ~/.ssh/authorized_keys
# Add content                                                   Use Case
# -----------                                                   --------
sudo -u git git init --bare    $alt/repos/$repo.git             # New, empty repo
sudo -u git git clone --bare   https://example.com/$repo.git    # Existing repo : Start fresh
sudo -u git git clone --mirror https://example.com/$repo.git    # Existing repo : Backup/Migrate/Sync
# Test access : mock a `git clone ...` request 
sudo -u git git-upload-pack /srv/git/$repo.git
# 2. At remote client(s) : `git clone|pull|push|... `
ssh -T git@$host 'git --version'        # Smoke test access 
git ls-remote git@a0.lime.lan:/srv/git/repos/age.git
git clone git@$host:/srv/git/$repo.git  # Clone the repo from remote (origin) to local host

#########################################################
## Reset : Branch Re-pointing : Promote source to target, 
## so target is bit-for-bit identical to source (incl history)
# "This (target) is a release commit : Don't care how we got there."
git checkout $target
git reset --hard $source
git push --force

#######
## META
    # Git was designed as a filesystem; adopted for use as SVC/SCM.
    # Git manages and manipulates THREE TREES (repo versions) in its normal operation
    # All LOCAL and per branch https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified
        Tree                Role  
        -----------------   ---------------------------------  
        HEAD                Last commit snapshot, next parent  
        Index               Proposed next commit snapshot  
        Working Directory   Sandbox  

        # ORIGIN : origin is the alias referencing the REMOTE (upstream) repo. 
            origin  # Declared, usually during project setup: `git remote add origin URL.git`

        # Plumbing (lower-level) commands
            git cat-file -p HEAD
            git ls-tree -r HEAD
            git ls-files -s

        # Git Internal Environment Variables
        ## https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables

    winpty bash  # @ mintty; sets up a TTY; (Git for Windows)
    # Git Concepts   https://zwischenzugs.com/2018/03/14/five-key-git-concepts-explained-the-hard-way/
        # Reference: a string that points to a commit.
        # 4 main types: HEAD, Tag, Branch, Remote Reference

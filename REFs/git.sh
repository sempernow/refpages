#!/usr/bin/env bash
exit
# CHEATSHEET : https://training.github.com/downloads/github-git-cheat-sheet/ 
# GitHub Help https://help.github.com/
# Pro Git  https://git-scm.com/book/en/v2
# git-for-windows [tutorial] 
# https://github.com/git-for-windows/git/blob/master/Documentation/gittutorial.txt
winpty bash  # @ mintty; sets up a TTY; (Git for Windows)
# Git Concepts   https://zwischenzugs.com/2018/03/14/five-key-git-concepts-explained-the-hard-way/
    # Reference: a string that points to a commit.
    # 4 main types: HEAD, Tag, Branch, Remote Reference

# Git was designed as a filesystem, but was adopted for use as a (very complicated) source version control.
# Git manages and manipulates THREE TREES (repo versions) in its normal operation
# All LOCAL and per branch https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified
    Tree                Role  
    -----------------   ---------------------------------  
    HEAD                Last commit snapshot, next parent  
    Index               Proposed next commit snapshot  
    Working Directory   Sandbox  

    # ORIGIN : origin is the alias referencing the REMOTE (upstream) repo. 
    # It must have been added earlier per `git remote add origin ...`. (See below.)
        origin 

    # Plumbing (lower-level) commands
        git cat-file -p HEAD
        git ls-tree -r HEAD
        git ls-files -s

# SSH LOGIN [see details @ REF.GitHub.sh] 
    ssh -T git@github.com

# HELP 
    git help VERB  # html if so @ git config
    man git -VERB  # man page

# CLONE a repo  
    git clone ${PROTO}://${REPO_URI}                 # TO ./REPONAME
    git clone ${PROTO}://${REPO_URI} ${FOLDER}       # TO a specific (new) local FOLDER
    git clone --branch ${BR} ${PROTO}://${REPO_URI}  # TO a specifid local BRANCH 
    # SANS .git; sans download of history thereof
    git clone --depth=1 --branch=master ${REPO_URI}  # shallow; history of commits = 1
    rm -rf ${PROTO}://${REPO_DIR}/.git  # removes .git
    # BARE|MIRROR : read-only (sans working dir); bare not functional for push/updates
    git clone [-bare|-mirror]

    # PROTOCOLs (SSH|GIT|HTTP[S])
    git clone ssh://[user@]host.xz[:port]/${REPO_PATH}.git/  # ssh 
    git clone git://host.xz[:port]/${REPO_PATH}.git/         # git 
    git clone http[s]://host.xz[:port]/${REPO_PATH}.git/     # http[s]
    # (The `.git/` suffix isn't necessary, but all references use it.)
        
# CLONE a FOLDER of a repo 
    # Easy way (svn utility)
    svn export ${REPO_PATH}/trunk/${FOLDER}
    # git "Sparse Checkout" 
    git init <repo>
    cd <repo>
    git remote add origin <url>
    git config core.sparsecheckout true
    echo "finisht/*" >> .git/info/sparse-checkout
    git pull --depth=1 origin master

# INIT (locally) : SSH Mode
    mkdir $_REPONAME 
    pushd $_REPONAME
    # Initialize
    git init
    git add .
    git commit -C "Init"
    # Add origin : SSH mode : git@{gitlab,github}.com : Note USER is "git", *not* $_USERNAME
    git remote add origin git@gitlab.com:$_USERNAME/$_REPONAME.git
    # If upstream already set per HTTPS mode, then switch to SSH mode by set-url :
    git remote set-url origin git@github.com:${_USERNAME}/${PWD##*/}.git
    git remote -v  # verify (remote) origin
    # Login : SSH mode : MUST have PKI + Host configured @ ~/.ssh/config
    ssh -T git.gitlab.com # Tunnel sans tty allocation.
    # OR
    . github ssh   # custom script; otherwise
    # Push : set upstream (-u)
    git push -u origin master # TO origin (remote) FROM master (local)

# INIT (locally) : HTTPS Mode
    # Same as SSH mode, except for replacing "git@HOST:" with "https://HOST/"
    # and login by password (prompt).

# BRANCHes 
    # Lists all branches (remote and local)
        git branch -a

    # ADD a new branch ("branch").
        git branch NEWbr

    # DELETE a branch.
        git branch -d brFoo             # Local
        git push origin --delete brFoo  # Remote

    # RENAME a branch.
        git branch -m CURRENTname NEWname

    # EDIT/ADD branch DESCRIPTION (@ text editor)
        git branch --edit-description NAME
        #  VIEW the description 
            git config branch.NAME.description
            # Does NOT display per listing @ `git branch`. Script to do so:
            # https://github.com/bahmutov/git-branches/blob/master/branches.sh 

    # MERGE source into target (if BOTH COMMITs up-to-date)
        git checkout TARGET; git merge SOURCE

# CHECKOUT ("dispatch")
    git checkout BRANCH

# COMMIT 
    git commit -m 'Commit message'
    git commit --amend # Edit a (unpushed) commit msg, per default editor.
    git commit --amend -m 'New message.'  # Edit a (unpushed) commit.
    # SHA1 hash of HEAD revision (commit)
    git rev-parse HEAD
    git rev-list HEAD #... last 40 revisions (SHA1)

# WORKFLOW to MINIMIZE repo HISTORY (noise) when modifying Master  

    # NEVER PUSH lest change is significant; to push is to PUBLISH. 
    # Save local versions per new branching and/or out-of-band process;
    # work @ branches dev1, dev2, ...; leave master unchanged (until end/merge).
        git checkout -b dev1 # create AND checkout temp development branch
        # OR
        git pull origin dev1
        git commit #... now in synch with remote dev1
        # ... do work ..., then ...
        _max_squash=$(( $( git rev-list --count HEAD ) - 1 )) # commits count less 1.
        git add .*;git add -A;git commit -m 'x'
        git rebase -i HEAD~$_max_squash 
        # Example command+syntax @ vim (automatic edit, during rebase) 
        :2,7s/pick/s/g  #... to squash commits 2-7
            # LONG WAY ...
                # SQUASH commit history/log; (re)write summary commit message (@ dev br)
                # per `HEAD~N` or HASH of `pick`; see `SQUASH per REBASE` section for details 
                git rebase -i HEAD~N  # all commits/log-entries back to original  (@ dev1); 
                # ...keep 1st (oldest) entry; `pick`; change all others (newer) to `s` (squash); 
                # The 2nd menu is vim/edit of the squashed rebase-commit message. 
                git checkout master; git merge dev1  # adds merge-commit history to master

        # SHORTer WAY ...
        # ... for zero additional history, from a clean branch, 
        # delete then recreate master (locally) 
        git branch -D master; git checkout -b master
        # IF REMOTE master is messy, see "To DELETE REMOTE `master`" section
        git push --force-with-lease  # safely force; 
        # need to force because origin (remote) will be "ahead" after squashing commits 

# CI/CD WORKFLOW 

    # MODIFY @ feature branch, NOT master branch  
        git checkout -b 'feature'  # i.e., clone master and modify that,  
        git add . ; git commit -m 'feature'  
        git push origin 'feature'  # push to feature (creates on push)  
        # Create Pull Request (PR) @ GitHub repo webpage  
            # Repo > Pull requests (tab) > "New pull request" (button)  
            # > "base:master <= compare:devel"  (dropdown-menus)  
            # > Create pull request  (button)  
        # Wait for Travis test to report success
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

# RESTORE file mod times (mtime) of all files (after `git ...` destroys them)
    # https://stackoverflow.com/questions/2458042/restore-a-files-modification-time-in-git/22638823#22638823 
    git log --pretty=%at --name-status --reverse \
        | perl -ane '($x,$f)=@F;next if !$x;$t=$x,next if !defined($f)||$s{$f};$s{$f}=utime($t,$t,$f),next if $x=~/[AM]/;' 

# TAG : Used @ Golang Modules  https://git-scm.com/book/en/v2/Git-Basics-Tagging  
    git tag                         # List tags
    git tag -l "v1.4*"              # List per filter
    git show v1.4.2                 # Show tag-related info 
    # Create BEFORE commit : don't
    git tag -a v1.4.3 -m "big fix." # Annotated Tag
    git tag v1.4.3                  # Lightweight Tag
    # Create AFTER commit  : do
    git tag v1.4.3                  # Lightweight Tag
    # push EXPLICITLY; Tags are NOT pushed by normal `git push ...` 
    git push origin v1.4.3  # Push this one tag to remote repo.
    git push origin --tags  # Push ALL tags to remote repo.
    # Delete 
    git tag -d v1.4.3                  # Delete local
    git push origin --delete v1.4.3    # Delete remote 
    git push origin :refs/tags/v1.4.3  # Delete remote; equivalent
 
# FILESYSTEM COMMANDs  
    git mv foo.bar baz.bar     # Renaming a file.  
    git mv foo.bar ./foo/baz.b # Moving a file.  
    git mv -f fileA fileB      # Replaces a file.  

# SEARCH @ repo  
    git grep PATTERN [PATH]  # e.g., ...  
    git grep 'terminal.*' */*.go  # find all occurrences of 'terminal.*' in all .go files
    git grep -e 'foo' --and \ (-and bar -and baz \)  # "foo" and "bar" or "baz"

    git config --global grep.lineNumber true  # prepend line numbers @ grep search

# REMOTEs (ORIGIN/UPSTREAM); TRACKED BY LOCAL branch(es)
    origin  # REMOTE repo associated with the local/current/working/tracking folder
    "upstream"  # original repo; GitHub default when repo was FORKED 
    "origin"    # your repo (perhaps fork); GitHub default when repo was CLONED 
    # thus IDENTICAL if NOT forked; see "ADD UPSTREAM" section for fork corroboration.
    git remote -v  # verify remote(s)/protocol/mode
    # READ current remote repo url/mode from git config (@ `./.git`)
    git config --get remote.origin.url

# REMOTE-TRACKING branches
    git ls-remote       # Show 
    ${REMOTE}/${BRANCH} # This is the syntax
    origin/master # The (default) REMOTE-tracking branch for LOCAL master branch 
    # SHOW remote-tracking; what's tracking what 
        git remote show origin   
        git branch [-v]  # show local branches [verbose] 
        git branch -a    # show all; local + REMOTE 
        git branch -r    # show REMOTEs 
        # e.g., ...
            remotes/origin/HEAD -> origin/master  # the default clone branch 
            ...
    # CHANGE remote-tracking branch 
    git branch $brLOCAL -u origin/$brREMOTE 
    git branch $brLOCAL --set-upstream-to=origin/$brREMOTE  # Equivalent
    "Branch brLOCAL set up to track remote branch brREMOTE from origin."

    # CHANGE remote URL per PROTOCOL/MODE   
    git remote set-url origin git@github.com:${GITUSER}/${PWD##*/}.git  # ssh mode
    git remote set-url origin https://github.com/USERname/REPOname.git  # http mode
    # ADD remote ORIGIN per PROTOCOL/MODE
    git remote add origin git@github.com:${GITUSER}/${PWD##*/}.git      # ssh mode 
    git remote add origin https://github.com/USERname/REPOname.git      # http mode
    # ADD UPSTREAM (to corroborate @ FORK) 
    git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git
    # REMOVE upstreams
    git remote rm upstream  # remove ALL remote upstreams
    # VERIFY/SHOW remote(s)
    git remote -v 

    # PUSH NEW branch (set new upstream) 
    # (Note: "upstream" @ `push` has different context from that of `git remote add upstream`)
    git push --set-upstream origin brName  # push brName, setting its "upstream" (REMOTE)  
    git push -u [origin brName]            # EQUIVALENT 

# MERGE branch (dev) into master
    git checkout master
    git pull origin master
    git merge dev
    git push origin master

# COMMON COMMANDs @ workflow
    mkdir ${REPONAME}          # create repo container                
    git init                   # create local repo
    git status                 # should be empty
    git add FILE1 FILE2        # add file[s]
    git rm FILE --cached       # Remove from git, but NOT from filesystem.
    git status                 # now git is watching these files for changes!
    git commit -am "a message" # saved a snapshot of repo [ONLY those files 'add'-ed]
    git status                 # should be clean
    git push                   # Push commit to origin (remote)

# LOG 
    git log --oneline     # succinct list
    git log -n $N         # last $N commits
    git log  -p           # differences per commit; detailed
    git log --stat        # differences per commit; summary
    git log --merges      # only commits of merges
    git log --pretty=oneline
    git log --pretty=format:"%h - %an, %ar : %s" # https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History#pretty_format

    # RefLog : HEAD and branch references  
    git reflog 
    
    git shortlog    # current commits; per USERNAME (#): list [per message]
    git shortlog -s # current commits; per # USERNAME 
    
# COMPARE 

    git diff               # show changes not yet staged; not yet added to git 'index'
    git diff --cached     # show staged changes about to be committed
    git diff --staged      # show staged changes about to be committed
    git diff HEAD         # changes since last commit 
    git diff HEAD^        # changes since the commit before the latest commit.

# REVISION SELECTION  https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection

    # show revision 
        git log --pretty=oneline  # show list of all revisions
        git show hhhhhhh          # by its (partial) hash
        git show branchName       # by its branch name

# ROLLBACK (REVERT) to PRIOR commit 
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

# ROLLBACK (hard) to PRIOR commit 
    git reset --hard HEAD         # To the most recent commit
    git reset --hard HEAD~10      # 10 commits back
    git reset --hard $commitSHA1  # Specify per hash (hex) of the commit

# META / IGNORING FILES 
    .gitignore

    .gitattributes  # file @ root to inform, e.g., ...
        assets/* linguist-vendored  # ignore all /assets/ subfolders; 
        # used to FIX GitHub's mis-reporting of LANGUAGE 

# CONFIG
    git config --list --global
    git config --list --local

    # 3 levels of config 
    .git/config     # per repo (`./.git` is dir @ current repo, created per `git init`)
    ~/.gitconfig    # per user
    /etc/gitconfig  # per system

    git config ... # writes to ...
        --local   # per repo; @ `.git/config`
        --global  # per user; @ `~/.gitconfig`; `%USERPROFILE%\.gitconfig`
        --system  # per platform; @ PLATFORM_PREFIX/etc/gitconfig; `%ProgramFiles%\Git\mingw64\etc`

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
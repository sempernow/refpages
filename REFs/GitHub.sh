exit
# GitHub Desktop NO LONGER INSTALLS gui/cli `-ms` apps
# So is GUI only. Use Git-for-Windows app for CLI.
# 
# GitHub Desktop 
#   GUI [Electron] https://desktop.github.com/
#   CLI  https://git-scm.com/
# 
# SETUP :: Share SSH creds @ Cygwin 
#   - Rename or delete the Git-installed '.ssh' @ %UserProfile%
#   - SYMLINK.bat "%UserProfile%\.ssh" "C:\Cygwin\home\USERNAME\.ssh"
#         See "_ssh_CREATE_OR_TEST_SYMLINKD@UserProfile.bat" 
#             @ C:\Cygwin\home\USERNAME\.ssh
#
# Cyber Wizard Institute https://github.com/cyberwizardinstitute/workshops/blob/master/git.markdown
# Fork; collaborate on existing GitHub projects
# https://github.com/cyberwizardinstitute/workshops/blob/master/git.markdown#collaborating-on-existing-github-projects-no-push-access

# New repo
touch README.md
git init
gc # (See script) ... or ...
git add .
git commit -m "first commit"
# then ...
git branch -M master
git remote add origin git@github.com/${user_name}/${repo_name}.git      # SSH mode
git remote add origin https://github.com/${user_name}/${repo_name}.git  # HTTPS mode
#... if already added; to switch modes:
git remote set-url origin ${PER_MODE}github.com/${user_name}/${repo_name}.git # "git@" OR "https://""
git push -u origin master # Push local to remote master 

# Creating a PULL REQUEST FROM a FORK  https://help.github.com/articles/creating-a-pull-request-from-a-fork/

# ssh login [see details below] 
ssh -T git@github.com

# git-for-windows [tutorial] 
# https://github.com/git-for-windows/git/blob/master/Documentation/gittutorial.txt

# Switching Protocols [MODES] :: SSH or HTTPS [remote URLs] 

    # Verify current mode, from local repo ...
    git remote -v  
        # if SSH ...
            #=> origin  git@github.com:USERNAME/REPOSITORY.git (fetch)
            #=> origin  git@github.com:USERNAME/REPOSITORY.git (push)
            
        # if HTTPS ...
            #=> origin  https://github.com/USERNAME/OTHERREPOSITORY.git (fetch)
            #=> origin  https://github.com/USERNAME/OTHERREPOSITORY.git (push)

    # (re)set|add : ssh protocol  
    git remote set-url origin ${sshKeyUser}@${sshKeyHost}:${_USERNAME}/${PWD##*/}.git
    git remote add origin ${sshKeyUser}@${sshKeyHost}:${githubUser}/${githubRepo}.git 
    # E.g., 
    git clone ssh://git@github.com/f06ybeast/test-ignores
    
  # (re)set protocol [to https] and/or repo ...  
    git remote set-url origin https://github.com/$_USERNAME/OTHERREPOSITORY.git

# basic maintenance ops whilst @ local repo
git init|status|add|commit|log

# GUI 
  gitk # visualize git repo structure 
  gitk HEAD..FETCH_HEAD  # visualize fetch vs. local head
      
# Clone
  # per https
  git clone https://github.com/$_USERNAME/$_REPONAME.git
  # per ssh
  git clone git@github.com:$_USERNAME/${PWD##*/}.git
  git clone git@github.com:$( git config --global user.name )/${PWD##*/}.git

# Change remote associated with local repo; remote must exist
  
  # per https 
  git remote add origin https://github.com/USERNAME/REPONAME.git
  # per ssh
  git remote add origin git@github.com:USERNAME/REPONAME.git # private
  
    # ??? solution to bogus "fatal: remote origin already exists." msg ???
    git remote set-url origin git@github.com:USERNAME/REPONAME.git
    
# Publish local commits ...
  git remote -v # show remote repo currently associated with this local
  
  # Pushing Remotely :: push local changes to remote; update remote [origin]
    # remote repo is 'origin', local is 'master'; '-u' is remember source/target 
    git push                         # from local CURRENT branch to remote
    git push [-u] origin master      # defaults
    git push [-u] origin <remoteBr>  # push to remote branch named <remoteBr>

    # set/specified remote branch
      git push --set-upstream origin <newBr>
      git push --set-upstream origin <remoteBr>
      git push   # thereafter pushes to the set/specified remote branch

      # if push: 'fatal: The current branch master has no upstream branch'
      git push --set-upstream origin master
      
      # if push: '! [rejected]        master -> master (non-fast-forward)'
      git push --set-upstream origin master --force-with-lease

  # Pulling Remotely :: pull remote into local; update local [master]
  git pull origin master # defaults


# GitHub Pages :: https://USERNAME.github.io 
  # Jekyll, Custom URLs
  # https://pages.github.com/ 
  # https://jekyllrb.com/docs/quickstart/
  git init # start fresh project/repo [local @ PWD]
  # clone new repo per REPONAME = USERNAME.github.io
  git clone https://github.com/$_USERNAME/$_REPONAME
  # add index.html
  pushd "$_USERNAME.github.io"
  echo 'GitHub Pages foo' > 'index.html'
  git add .  # or `-A` 
  git commit -m 'initial'
  # URL @ ... 
  https://$_USERNAME.github.io/

  `gh-pages` # SPECIAL BRANCH NAME 
  # if `gh-pages` @ `repoName`, 
  # then `username.github.io/repoName` is the associated GitHub Pages
  # So, @ new local/remote repo
  git init  # @ local ./repoName 
  git remote add origin git@github.com:username/repoName.git 
  git push -u origin master 
  git branch gh-pages  # create; the special branch name for GitHub Pages 
  git push origin gh-pages 
  # CUSTOM DOMAIN Name 
  echo 'domainName' > CNAME  # create CNAME file; insert domain name
  git add .; git commit -m 'cname'  
  git checkout gh-pages 
  git merge master 
  git push  # push CNAME file to gh-pages branch 
  # Jekyll for nicer UI/UX; requires Ruby  
  jekyll new blog  # create dir & init Jekyll project 
  cd blog 
  jekyll serve     # creates site & server; CTRL+C to exit 
  # static site @ 
  ./blog/_site 


  # SSH Key-pair Naming Convention
  /c/Users/${USERNAME}/.ssh/github_${_USERNAME}
  /c/Users/${USERNAME}/.ssh/github_${_USERNAME}.pub

  # Generate SSH key pair
  ssh-keygen -t ed25519 -C  $_USER_EMAIL_ADDRESS # use GitHub user/email account
    # Enter file in which to save the key; ~/.ssh/PVT_KEY_FNAME
    # Next, you'll be asked to enter a passphrase.
    # https://help.github.com/articles/working-with-ssh-key-passphrases/
    #=> Enter passphrase (empty for no passphrase): [Type a passphrase] # LEFT IT BLANK
    #=> Enter same passphrase again: [Type passphrase again]
    # @ GitHub : https://github.com/settings/keys
        # Copy content of the public key file (.pub) we just generated into the apropos box @ GitHub
        # GitHub will display its title and FINGERPRINT as a reference:
            # 2023-05-14
            # SHA256:40rMcBvUa2Zi/tDfO8PCIeLTdoK8oLiQeRgMBPCa3IQ 
  
  # Get fingerprint of public/private ssh key ... 
    # sans -E, output is in SHA256; -B for blather
    ssh-keygen -lf  FILE_PATH         # SHA256
    ssh-keygen -E md5 -lf FILE_PATH   # md5
    ssh-keygen -t ecdsa -lf FILE_PATH # specify key type ecdsa = elip-rsa
    ssh-keygen -E md5 -lf /c/Users/USERNAME/.ssh/id_rsa   # public/private are same
    ssh-keygen -t ecdsa -lf /c/Users/USERNAME/.ssh/id_rsa # specify key type ecdsa = elip-rsa

  # Add public key to GitHub account; paste @ account admin 'SSH KEYS'
    cat $_PUBLIC_SSH_KEY_PATH
    #=> ssh-rsa AAAAB3QzaC1ycQ ... ss8AtZd8UgoU= user@host.domain
    
  # Connect [automatically]; @ 1st try [unknown_hosts], asks; yes/no verification
    # (OR use script @ ~/.bin/github)
    # Add your new key to the ssh-agent:
    # start the 'authentication agent' [ssh-agent] in the background
    eval "$(ssh-agent -s)" # ssh-agent handles passphrase entry
    #=> Agent pid {#}
    # Add private key identities to the authentication agent
    ssh-add $_PRIVATE_SSH_KEY_PATH
    ssh -T git@github.com # '-i' :: identity [private-key] file; default [v.2] is 'id_rsa'

# Create new REMOTE REPO from command line per HTTPS
# UPDATE : FAILs ...
  # per GitHub API [uses JSON]  https://developer.github.com/v3/repos/#create
  # OR
  # per Curl
  curl -u 'USER:PASS' https://api.github.com/user/repos -d '{"name":"REPONAME", "description":"New repo per Curl."}'

  # AFTER created ... 
  git init
  git commit -m "first commit"

  git remote add origin git@github.com:$_USERNAME/$_REPONAME.git  # ssh mode
  git push -u origin master  # publish local repo to new GitHub repo [default; remember: -u]


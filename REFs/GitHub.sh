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
    git remote set-url origin ${sshKeyUser}@${sshKeyHost}:${username}/${PWD##*/}.git
    git remote add origin ${sshKeyUser}@${sshKeyHost}:${githubUser}/${githubRepo}.git 
    # E.g., 
    git clone ssh://git@github.com/f06ybeast/test-ignores
    
  # (re)set protocol [to https] and/or repo ...  
    git remote set-url origin https://github.com/$username/OTHERREPOSITORY.git

# basic maintenance ops whilst @ local repo
git init|status|add|commit|log

# GUI 
  gitk # visualize git repo structure 
  gitk HEAD..FETCH_HEAD  # visualize fetch vs. local head
      
# Clone
  # HTTPS mode
  git clone https://github.com/$username/$reponame.git
  # SSH mode
  git clone git@github.com:$username/${PWD##*/}.git
  git clone git@github.com:$( git config --global user.name )/${PWD##*/}.git

# Change remote associated with local repo; remote must exist
  
  # HTTPS mode
  git remote add origin https://github.com/USERNAME/REPONAME.git
  # SSH mode
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
  # clone new repo : REPONAME = USERNAME.github.io
  git clone https://github.com/$username/$reponame
  # add index.html
  pushd "$username.github.io"
  echo 'GitHub Pages foo' > 'index.html'
  git add .  # or `-A` 
  git commit -m 'initial'
  # URL @ https://$username.github.io/

  # `gh-pages` # SPECIAL BRANCH NAME 
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
  /c/Users/${USERNAME}/.ssh/github_${username}
  /c/Users/${USERNAME}/.ssh/github_${username}.pub

  # Generate SSH key pair
  ssh-keygen 
    # https://help.github.com/articles/working-with-ssh-key-passphrases/
    # https://github.com/settings/keys

  # Get fingerprint of public/private ssh key ... 
    # sans -E, output is in SHA256; -B for blather
    ssh-keygen -lf  FILE_PATH         # SHA256
    #... Copy/Paste the public key into form at your GitHub account
    
  # Connect [automatically]; @ 1st try [unknown_hosts], asks; yes/no verification
    # (OR use script @ ~/.bin/github)
    # Add your new key to the ssh-agent:
    # start the 'authentication agent' [ssh-agent] in the background
    eval "$(ssh-agent -s)" # ssh-agent handles passphrase entry
    #=> Agent pid {#}
    # Add private key identities to the authentication agent
    ssh-add $private_key_path
    ssh -T git@github.com # '-i' :: identity [private-key] file; default [v.2] is 'id_rsa'

# Create new REMOTE REPO from command line
# UPDATE : FAILs ...
  # use GitHub API [uses JSON]  https://developer.github.com/v3/repos/#create
  # OR
  # use Curl
  curl -u 'USER:PASS' https://api.github.com/user/repos -d '{"name":"'$reponame'", "description":"'$description'"}'

  # AFTER created ... 
  git init
  git commit -m "first commit"

  git remote add origin git@github.com:$username/$reponame.git  # ssh mode
  git push -u origin master  # publish local repo to new GitHub repo [default; remember: -u]


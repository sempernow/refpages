exit
# https://learnxinyminutes.com/docs/git/
$ git init

# Prints and saves some basic configuration variables. (Overall)
$ git config --global user.email
$ git config --global user.name

$ git config --global user.email "corre@gmail.com"
$ git config --global user.name "name"

# A quick view of available commands.
$ git help

# Check all available commands
$ git help -a

# Get help specific to a command - user manual
# git help <command>
$ git help add
$ git help commit
$ git help init

# Show the "branch", files without adding repo, changes and other Differences
$ git status

# Returns help on the status command.
$ git help status

# Add a file to the current working directory.
$ git add FooBar.java

# Add a file under a directory.
$ git add /directory/file/Foo.c

# Support for regular expressions!
$ git add ./*.py

# Lists all branches (remote and local)
$ git branch -a

# Add a new branch ("branch").
$ git branch branchNew

# Delete a branch.
$ git branch -d branchFoo

# Rename a branch.
# git branch -m <previous> <new>
$ git branch -m youngling padawan

# Edit the branch description.
$ git branch master --edit-description

# Dispatch a repository. - By default the master branch. (The main branch called 'master')
$ git checkout
# Dispatch a specific branch.
$ git checkout padawan
# Create a new branch and switch to it, it's the same as using: "git branch jedi; git checkout jedi"
$ git checkout -b jdei

# Clone the jquery repo.
$ git clone https://github.com/jquery/jquery.git

# Commit and add a message.
$ git commit -m "jedi anakin wil be - jedis.list"

# Displays the difference between a working directory and the index.
$ git diff

# Shows the difference between the index and the most recent commits.
$ git diff --cached

# Shows the difference between the working directory and the most recent commit.
$ git diff HEAD

# Thanks to Travis Jeffery for sharing the following.
# Allows to display line numbers in grep output.
$ git config --global grep.lineNumber true

# Perform a more readable search, including grouping.
$ git config --global alias.g "grep --break --heading --line-number"

# Search for "unVariable" in all .java files
$ git grep 'unaVariable' '* .java'

# Look for a line that contains "ArrayName" and "Add" or "Remove"
$ git grep -e 'Array_name' --and \ (-and add -and remove \)

# Displays all commits.
$ git log

# Displays an x ​​number of commits.
$ git log -n 10

# Show only the commits that have been combined in the history.
$ git log --merges

# Combines the specified branch into the current branch.
$ git merge jediMaster

# Always generate a single merge commit when using merge.
$ git merge --no-ff jediMaster

# Renaming a file.
$ git mv HolaMundo.c AdiosMundo.c

# Moving a file.
$ git mv HelloOtraVezMundo.c ./nuevo/directorio/NewArchivo.c

# Replaces a file.
$ git mv -f fileA fileB

# Updates the local repository, combining the new changes
# Of the remote branches "origin" and "master".
# git pull <remote> <branch>
$ git pull origin master

# Send and combine changes from a local repository to a remote repository
# Called "origin" and "master", respectively.
# git push <remote> <branch>
# git push => default is the same as put => git push origin master
$ git push origin master

# Integrate branchExperiment inside branch "master"
# git rebase <basebranch> <topicbranch>
$ git rebase master experimentBranch

# Restart the main area, with the last change registered. (leave them
# Directories unchanged)
$ git reset

# Restart the main area, with the last change registered, and rewrite the
# Working directory.
$ git reset --hard

# Moves the current branch to the specified commit (does not make changes to the
# Directories), all changes still exist in the directory.
$ git reset 31f2bb1

# Moves the current branch returned to a specified commit, as well as the
# Directory (deletes all changes that were not registered and all
# Changes made after the specified commit).
$ git reset --hard 31f2bb1

# Remove FooBar.c
$ git rm FooBar.c

# Delete a file from a directory.
$ git rm /directory/file/FooBar.c


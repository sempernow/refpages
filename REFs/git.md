# [`git`](https://git-scm.com/ "git-scm.com") | [`REF.git.sh`](REF.git.sh) | [Reference](https://git-scm.com/docs "git-scm.com/docs")

## GitHub connectivity script @ `~/.bin/github`

```bash
# Init SSH session (ssh-agent; long-lived)
. github ssh
git config --list # List all
# Set globally
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
# Add origin (run once)
git remote add origin $_USERNAME/$_REPONAME.git 
```

## `git` Functions/Aliases @ `~/.bash_functions`

```bash
# Status 
gs
# Logs 
gl
# Commit : Default message is is name of newest file 
gc [MESSAGE]
# Rebase
gr
# Push : git push --force-with-lease (required after rebase)
gpf
# Restore all mtimes (git ... destroys them)
gmtime 
# Add all source files
ga 
# List all branches
gb
# Checkout branch; create if not exist; default NAME: %H.%M.%S
gch [NAME]
# Delete branch
gbd NAME
```

## Workflow

```bash
# Login per ssh : See github script @ ~/.bin
. github ssh

# Version (Tag) a commit
git tag -a v0.1.2 $commit

# Push the current commit 
git push origin master
# Push the version (info)
git push origin v0.1.2

# Delete a version
git tag -d v0.1.1                  # Delete local
git push origin --delete v0.1.1    # Delete remote

# Branch : Checkout else Create
gch [NAME] # defaults to new; NAME=MM:SS

# Branch : Delete 
git branch -d NAME             # Local
git push origin --delete NAME  # Remote

# Repo : Rebase
_max_squash=$(( $( git rev-list --count HEAD ) - 1 ))
git rebase -i HEAD~$_max_squash
```
- The `git rebase ...` command automatically opens the meta file with editor declared @ `.gitconfig`

@ `vim` | [`REF.vim.sh`](REF.vim.sh)

```plaintext
# To squash commits 2-7 
:2,7s/pick/s/g
# Then delete/add/edit commit message
# Then exit edit mode, then save and exit vim
ESC
ZZ
```

Then push to remote; origin (remote) is "ahead" after squashing commits, so force is required.

```bash
git push --force-with-lease 
```

## Self

### `REF.git` ([MD](REF.vim.sh)

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->


# [`git`](https://git-scm.com/ "git-scm.com") | [`git.sh`](git.sh) | [Reference](https://git-scm.com/docs "git-scm.com/docs")

## EOL (End Of Line)

There are two types:

- __LF__ (Line Feed), which uses one: `\n`
    - This is used by all apps on all systems across the planet, 
    with the exception of all those built by Microsoft Corporation, of course.
- __CRLF__ (Carriage Return *and then* Line Feed), which uses two characters/codes as implied : `\r\n`
    - Used exclusively by Microsoft Corporation. 
      On purpose.

__Force LF (`\n`) always, everywhere.__ 

Always. 

Everyhwere. 

This works always and everywhere, even on all modern Windows applications.
Contrarily, any file having any line ending(s) of type CRLF (`\r\n`) 
will cause failure(s) at almost all Linux file-processing utilities and pipelines.

How to force EOL of type LF:

@ `~/.gitattributes`

```ini
* text=auto eol=lf
# Declare otherwise-questionable binary type(s) to ensure they are ignored (unmodified) by above:
*.gif  binary 
*.webp binary 
*.tiff binary 
*.png  binary 
*.jpg  binary 
*.jpeg binary 
*.pdf  binary 
```

Absent that setting, 
Git (silently) __modifies all files per environment__ 
(Linux/Mac or Windows). 
So, any file subsequently extracted may or may not be restored,
depending upon where/how that file was obtained.

## Git connectivity script 

If SSH key is protected by passphrase

```bash
account=sempernow
key=~/.ssh/github_$account
# Enable SSH agent (cache passphrase)
eval "$(ssh-agent -s)"
ssh-add "$key"
```

Then/Else

```bash
## Create SSH tunnel sans terminal allocation 
ssh -T git@github.com
git config --list # List all
# (Re)Set identity globally
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
project=${PWD##*/} # If at project root
# Add origin (once)
git remote add origin $account/$project.git 
# (Re)Set access mode : HTTPS|SSH(prefer)
git remote set-url origin git@github.com:$account/$project.git          # SSH
# Else if "Host github" and "User git" is so configured for this host at ~/.ssh/config
git remote set-url origin github:$account/$project.git                  # SSH
git remote set-url origin https://github.com/$account/${PWD##*/}.git    # HTTPS

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

@ `vim` | [`vim.sh`](vim.sh)

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

### `git` ([MD](vim.sh)

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


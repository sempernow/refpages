# [`git`](https://git-scm.com/ "git-scm.com") | [`git.sh`](git.sh) | [Reference](https://git-scm.com/docs "git-scm.com/docs")


## Branching Strategies

__Listed from easiest to hardest to maintain__

### 1. Trunk Based Development

For superheros and those who don't care about reliability of production deployment.

- Single branch (__mainline__)
- Requires mature/senior team;   
  experienced team members
- Requires __toggles__/flags;  
  app admins can enable/disable each feature 
- Continuous __deployment__; [vs. faking it](https://www.youtube.com/watch?v=0ivcSjpUzl4)
    - Continuous Testing: A lie; testing is not a separate process.
    - Continuous Integration : A lie; merging devs' features into mainline __multiple times per day__, 
      so trusting the __automated__ build/package/test.
    - Continuous Deliver: A lie; Everything between post-CI (pushed to mainline) 
      and promotion to production (release/deployment) is fully automated (so fully trusted).
    - Continuous Deployment: Every successful build is pushed to production (automatically);
      no business decision to promote to prod;  
      hence trunk-based branching strategy is effectively a requirement to achieve this.

### 2. Feature Branching AKA GitHub Flow

For small self-sufficient teams and small applications.

- One branch __per feature__;  
  on MR per feature into mainline
- Short delivery cycles; hours
- Continuous Delivery;   
  feature toggles are useful but not essential
- Merge/Pull Requests;   
  as soon as the feature developer is ready for feedback.

### 3. Forking Strategy

For open-source (OSS) projects.

- Fork repositories; versus branching;   
  otherwise is much like the Feature Branching strategy
- Mostly for OSS project; MR created when ready

### 4. Release Branching

For projects requiring support of multiple releases.

- One branch __per release__
- Low frequency deployments; Waterfall (vs. Agile)
- No continuous integration
- Support for previous releases

### 5. Git Flow

- Branches, branches, branches, and more branches;   
    feature branches merge into dev;   
    dev branch merges into release branches;   
    release branches merge to both mainline and back into dev. 
- Release Manager(s);  
  job security

### 6. Environment Branching

- Environment branches;  
  dev, staging, integ, prod, releases, features, hotfixes ;   
  all merges to all;
  - Makes no sense because releases are what get deployed to environments.

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

@ __`~/.gitattributes`__

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
ssh -T git@$host
git config --list # List all
# (Re)Set identity globally
git config --global user.name "$(id -un)"
git config --global user.email $(id -un)@$(hostname -f)
project=${PWD##*/} # If at project root
# Add origin (once)
git remote add origin $account/$project.git 
# (Re)Set access mode : HTTPS|SSH(prefer)
git remote set-url origin git@$host:$account/$project.git       # SSH
git remote set-url origin https://$host/$account/${PWD##*/}.git # HTTPS

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

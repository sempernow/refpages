# Golang Modules : `go mod ...`

## Init / Maintain 

@ PRJ root directory

```bash
# Init (once) | GO111MODULE="on"
go mod init 'github.com/sempernow/uqc'
# 1st time and whenever thereafter
go mod tidy
go mod vendor
```
- Generates: `/go.mod` and `/go.sum` files, and `/vendor` directory containing the required packages/versions; "vendoring".
- The required packages must already be @ `GOPATH`. (See `go get` section below.) 
- To __update__ a package version, must MANUALLY CHANGE @ `go.mod`; versions are set @ 1st run.

## Versioning/Module Incompatibilities of `git`/`go`

Deleting cache (@ `GOPATH`) does nothing for versioning. Git tags (versions) are immutable; entirely orthogonal to, and override, commits. For example, even if an old tag (version) is deleted from its commit (both locally and at origin) and then added back to a newer commit, the old commit remains hard welded thereto regardless. The only way to update its imported Golang package (@ `/vendor`) to the new commit is to either update the version number (@ `git`) and manually change to it at `go.mod`, not use `git` versioning (tags) at all, or "version" per repo name, e.g., `repo/v3`. That last method gets declared at `go.mod` as `v0.0.0-...-<SVN-reference>`. Note also that `go get ...` behavior changes per `GO111MODULE` setting; to include that it may or may not download to `GOPATH` if `on`, and that declaring the version (per `path@version` syntax) is forbidden if `off`.

## `go get ...`

Anywhere __not__ @ PRJ directory

```bash
# Download the latest repo
GO111MODULE="off" go get -u 'github.com/sempernow/uqc'
```
- Behavior of `go get` tool varies with that and other `go env` settings, the command's working directory, and `-u` .

## `git` : Versioning Workflow

@ PRJ root 

```bash
# Init SSH session (ssh-agent; long-lived)
. github ssh
# Add origin (run once)
git remote add origin $_USERNAME/$_REPONAME.git 
```
```bash
# Status 
gs
# Logs 
gl
# Commit
gc

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
- The `git rebase ...` command ___automatically opens___ the meta file with editor declared @ `.gitconfig`

@ `vim`

```bash
:2,7s/pick/s/g #... to squash commits 2-7
#... then delete/add/edit the commit message
ESC
ZZ
```

Push to remote; must force because `origin` (remote) will be "ahead" after squashing commits.

```bash
git push --force-with-lease 
```


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


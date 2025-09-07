#!/usr/bin/env bash
exit
# CHEATSHEET : https://training.github.com/downloads/github-git-cheat-sheet/ 
# GitHub Help https://help.github.com/
# Pro Git  https://git-scm.com/book/en/v2

############################################
## Bundle : git bundle : Migrate to new host
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
#
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
## HTTPS-mode setup
# Requires a server configured for Git : https://chatgpt.com/c/6867e783-d7d4-8009-9202-33a9437846ac  

## GitLab API : Create namespace for a project : /group-1/sub-2/prj-x
# 3. Verify using GitLab API
GET /api/v4/projects/$target_namespace
# Get ID if namespace exist
GET /api/v4/namespaces?search=$target_namespace 
# Create if not
POST /api/v4/projects
{
    "name": "newproject",
    "namespace_id": [namespace_id],
    "visibility": "private" // or "public" or "internal"
}

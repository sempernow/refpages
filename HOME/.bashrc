# source .bashrc || source /etc/profile.d/${USER}-01-bashrc.sh

# Aliases

# Meta
alias ffmpeg='ffmpeg -hide_banner'
alias goclean='go clean -i -r -cache -testcache -fuzzcache'
alias gpg=GnuPG
alias os='cat /etc/os-release'
alias pip='python3 -m pip'
alias python=python3
alias vi=vim

# FS
alias ls='ls -hl --color=auto --group-directories-first'
alias ll='ls -AhlrtL --time-style=long-iso' 
ll >/dev/null 2>&1 || alias ll='ls -AhlrtL --group-directories-first'
alias df='df -hT'
alias du='du -h'
alias lsblk='lsblk -o SIZE,LABEL,NAME,MAJ:MIN,TYPE,FSTYPE,MOUNTPOINT,UUID'
alias tree='tree -I vendor --dirsfirst'
alias copy='cp -up'
alias update='cp -urpv'
alias edit=openedit
alias open=openedit
alias isdos=isDOS

# Text
alias cls=clear
alias grep='grep --color'                       # show differences in colour
alias grepb='grep -B10'
alias grepa='grep -A10'
alias grepba='grep -B5 -A5'
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
alias jq='jq -C'
alias sha2=sha256

# End here if not bash 
[[ true ]] || { . ~/.bash_functions; return; }

# Network
ip -c addr > /dev/null 2>&1 && alias ip='ip -c'

# End here if previously sourced
[[ "$isBashrcSourced" ]] && return
isBashrcSourced=1

# Test for GNU Bourne-Again SHell (bash)
[[ -n "${BASH_VERSION}" ]] && isBash=1 || unset isBash
[[ "$PATH" =~ 'Windows' ]] && isWindows=1 || unset isWindows
[[ "$(type -t wsl.exe)" ]] && hasWSL=1 || unset hasWSL

# If at bash and syntax not POSIX, then abide other (e.g., Process Substitution)
[[ "$isBash" ]] && set +o posix 

# Source global definitions
[[ -f /etc/bashrc ]] && source /etc/bashrc 

# User specific environment
[[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]] \
    || PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# History Options
#
# Ignore duplicates and statements starting with space(s)
export HISTCONTROL=ignoreboth
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
#export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
[[ "$isBash" ]] && {
    shopt -s histappend
    shopt -s checkwinsize
}

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# Source sibling configs unless already configured or configuring at all-users directory
[[ "$BASH_SOURCE" =~ "/etc/profile.d" ]] || {
    [[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"
    [[ -f "${HOME}/.bash_functions" ]] && source "${HOME}/.bash_functions"
    for file in $(find $HOME -maxdepth 1 -type f -iname '.bashrc_*'); do 
        [[ -f "$file" ]] && source "$file"
    done 
}

# End here if not interactive
#[[ "$-" != *i* ]] && return 0
[[ -z "$PS1" ]] && return 0

# Enable programmable completion features.
# May already be enabled in /etc/bash.bashrc,
# which is sourced by /etc/profile.
[[ $(type -t shopt) ]] && [[ ! "$(shopt -oq posix)" ]] && {
    [[ -f /usr/share/bash-completion/bash_completion ]] \
        && source /usr/share/bash-completion/bash_completion || {
            [[ -f /etc/bash_completion ]] && source /etc/bash_completion
    }
}
# Source all completions that abide compspec.
# See man bash "Programmable Completion" section.
_completion_loader(){
    source "/etc/bash_completion.d/$1.sh" >/dev/null 2>&1 && return 124
}
[[ "$(type -t complete)" ]] \
    && complete -D -F _completion_loader -o bashdefault -o default

#export TZ='America/New_York'

########
# Prompt

# Source git-prompt.sh, which exports all required by 
# Git's conditional prompt function: __git_ps1. See PS1.
[[ "$isBash" ]] && {
    git_prompt="${HOME}/.git-prompt.sh"
    [[ -f "$git_prompt" ]] && source $git_prompt || {
        git_prompt=/usr/share/git-core/contrib/completion/git-prompt.sh
        [[ -f "$git_prompt" ]] && source $git_prompt
    }
}

#os="$(os |grep NAME |head -n1 |cut -d'=' -f2 |sed 's/"//g')"
#ver="$(os |grep VERSION_ID |head -n1 |cut -d'=' -f2 |sed 's/"//g')"

#################################################################
##  MUST escape and hardcode ANSI code, else fails silently;
##  revealed only on certain keypress, and only sometimes.
##  For example, up-arrow keypress may not clear prior content.
#################################################################
PS1=''
[[ $isWindows ]] && {
    [[ "$_OS" ]] && {
        PS1='\[\e]0;$_OS\007\]'                                                 # Window title
        PS1="$PS1"'\n'                                                          # newline
    } || {
        PS1='\[\e]0;\u@\h\007\]'                                                # Window title
        PS1="$PS1"'\n'                                                          # newline
    }
}
[[ "$_OS" ]] && {
    PS1="$PS1"'\[\e[1;34m\]$_OS'                                            # + $_OS
} || {
    PS1="$PS1"'\[\e[1;34m\]\u\[\e[1;30m\]@\[\e[1;34m\]\h'                   # + $USER@$(hostname)
}
[[ $( type -t __git_ps1 ) ]] && PS1="$PS1"'\[\e[1;97m\]`__git_ps1`'         # + Show "(BRANCH)"            (@ ./.git)
#PS1="$PS1"'\[\e[1;30m\] [$os$ver] [\t] [$SHLVL] [#\j]\[\e[0m\]'            # + [$os$ver] [HH:mm:ss] [$SHLVL] [jobs]
[[ "$isBash" ]] && PS1="$PS1"'\[\e[1;30m\] [\t] [$SHLVL] [#\j]\[\e[0m\]'    # + [HH:mm:ss] [$SHLVL] [jobs] (@ bash)
[[ "$isBash" ]] || PS1="$PS1"'\[\e[1;30m\] [\t] [$SHLVL] \[\e[0m\]'         # + [HH:mm:ss] [$SHLVL]        (@ sh)
PS1="$PS1"'\[\e[1;32m\] \w\[\e[0m\]'                                        # + /full/path/of/pwd
# + newline + prompt + whitespace :
[[ "$(id -u)" == '0' ]] && {
    PS1="$PS1"'\n\[\e[1;91m\]# \[\e[0m\]'                                   # @ root/sudo user : #
} || {                                                                      # @ regular user : ...
    [[ "$isBash" ]] && [[ "${LANG,,}" =~ 'utf-8' ]] && {
        PS1="$PS1"'\n\[\e[1;32m\]'$'\u2629'' \[\e[0m\]'                     # @ Bash : Multi-byte Unicode char
    } || {
        PS1="$PS1"'\n\[\e[1;32m\]$ \[\e[0m\]'                               # Otherwise : $
    }
}

#################################################################
## Using variables for ANSI codes fails silently.
## Imporperly escaped ANSI codes cause terminal errors. 
#################################################################

# NC='\[\e[0m\]'
# BLUE='\[\e[1;34m\]'
# GREEN='\[\e[1;32m\]'
# WHITE='\[\e[0;37m\]'
# WHITE='\[\e[1;97m\]'
# GREY='\[\e[1;30m\]'
# YELLOW='\[\e[1;93m\]'
# RED='\[\e[1;91m\]'

## Window title
# PS1='\[\e]0;\u@\h\007\]'                           # Window title
# PS1="$PS1"'\n'                                     # newline

# PS1="$PS1""$BLUE\u$GREY@$BLUE\h"                                # $USER@$(hostname)
# [[ $( type -t __git_ps1 ) ]] && PS1="$PS1""$WHITE`__git_ps1`"   # + Show "(BRANCH)"            (@ ./.git)
# #PS1="$PS1""$GREY [$os$ver] [\t] [$SHLVL] [#\j]$NC"             # + [$os$ver] [HH:mm:ss] [$SHLVL] [jobs]
# [[ $isBash ]] && PS1="$PS1""$GREY [\t] [$SHLVL] [#\j]$NC"       # + [HH:mm:ss] [$SHLVL] [jobs] (@ bash)
# [[ ! $isBash ]] && PS1="$PS1""$GREY [\t] [$SHLVL] $NC"          # + [HH:mm:ss] [$SHLVL]        (@ sh)
# PS1="$PS1""$GREEN \w$NC"                                        # + /full/path/of/pwd
# PS1="$PS1"'\n'"$GREEN$prompt $NC"                               # + newline + prompt + whitespace

#[[ $BASH_SOURCE ]] && echo "@ ${BASH_SOURCE##*/}"
[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"

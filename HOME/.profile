# .profile
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read if ~/.bash_profile or ~/.bash_login exists.

# The default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

## End here if not interactive
#[[ "$-" != *i* ]] && return
[[ -z "$PS1" ]] && return

[[ $BASH_SOURCE ]] && echo "@ ${BASH_SOURCE}"

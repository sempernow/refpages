# source .bash_profile

# Get the aliases and functions
[[ -f ~/.bashrc ]] && source ~/.bashrc

## End here if not interactive
#[[ "$-" != *i* ]] && return 0
[[ -z "$PS1" ]] && return 0

#[[ "$BASH_SOURCE" ]] && echo "@ ${BASH_SOURCE##*/}"
[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"

# User specific environment and startup programs

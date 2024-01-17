# source .bash_functions || source /etc/profile.d/${USER}-02-bash_functions.sh

[[ "$isBashFunctionsSourced" ]] && return
isBashFunctionsSourced=1

# End here if functions already exist (run once)
#[[ "$(type -t now)" ]] && return 

set -a  # EXPORT ALL ...

[[ "$_PID_1xSHELL" ]] || _PID_1xSHELL=$( ps |grep 'bash' |sort -k 7 |awk '{print $1;}' |head -n 1 )

######
# Date

today(){
    # YYY-MM-DD
    t="$(date +%F)";echo "$t"
    #[[ ! "$1" ]] && { REQUIREs putclip ; putclip "$t"; } 
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
now(){ 
    # HH.mm.ss
    t="$(date +%H.%M.%S)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
todaynow(){ 
    # YYY-MM-DD_HH.mm.ss
    t="$(date +%F_%H.%M.%S)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
utc(){ 
    # YYY-MM-DDTHH.mm.ss
    t="$(date '+%Y-%m-%dT%H:%M:%S')";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
utcz(){ 
    # YYY-MM-DDTHH.mm.ssZ
    t="$(date -u '+%Y-%m-%dT%H:%M:%SZ')";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
alias gmt=utcz;alias zulu=utcz
iso(){
    # YYY-MM-DDTHH.mm.ss+/-HH:mm
    t="$(date --iso-8601=seconds)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}
isoz(){
    # YYY-MM-DDTHH.mm.ss+00:00
    t="$(date -u --iso-8601=seconds)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; } 
}

####
# FS

path() { 
    # Parse and print $PATH 
    clear ; echo ; echo '  $PATH [parsed]'; echo
    declare IFS=: ; printf '  %s\n' $PATH
}
[[ $(type -t pushd) ]] && {
    push() { 
        # ARGs: DIR-(REL)PATH || DRIVE-LETTER
        [[ "$@" ]] || { echo " NO push (no param)"; return 99; } 
        [[ -d "$*" ]] && { pushd "$*" > /dev/null 2>&1 ; return; } || {
            (( ${#1} == 1 )) && { push "$1"; return; }
        } 
        echo "=== DIR '$*' NOT EXIST"
    }
    pop() { popd > /dev/null 2>&1 ; }
    up(){ push "$(cd ..;pwd)" ; }
    root(){ push / ; }
    home(){ push "$HOME"; }
    temp(){ push "$TMPDIR"; }
}
mode(){ 
    # ARGs: [DIR(Default:$PWD)]
    # OCTAL HUMAN FNAME
    [[ -d "$@" ]] && pushd "$@" > /dev/null
    printf "\n%s\n\n" " @ '$PWD'" 
    find . -maxdepth 1 -type d -execdir stat --format=" %a  %A  %n" {} \+ |sed 's/\.\///'
    find . -maxdepth 1 -type f -execdir stat --format=" %a  %A  %n" {} \+ |sed 's/\.\///'
    [[ -d "$@" ]] && popd > /dev/null
    printf "\n"
}
alias perms=mode
owner(){ 
    # ARGs: [DIR(Default:$PWD)]
    # OWNER[UID] GROUP[GID] PERMS[OCTAL] FNAME
    [[ -d "$@" ]] && pushd "$@" > /dev/null
    printf "\n%s\n\n" " @ '$PWD'" 
    find . -maxdepth 1 -type d -execdir stat --format=" %U[%u]  %G[%g]  %A[%a]  %n" {} \+ |sed 's/\.\///' |sed 's/Administrators/Admns/'
    find . -maxdepth 1 -type f -execdir stat --format=" %U[%u]  %G[%g]  %A[%a]  %n" {} \+ |sed 's/\.\///' |sed 's/Administrators/Admns/'
    [[ -d "$@" ]] && popd > /dev/null
    printf "\n"
}

#######
# Utils

grepall(){ [[ "$@" ]] && find . -type f -exec grep -il  "$@" "{}" \+ ; } 
randa(){ 
    # ARGs: [LENGTH(Default:32]
    cat /dev/urandom |tr -dc 'a-zA-Z0-9' |fold -w ${1:-32} |head -n 1
}

md5()    {( algo=$FUNCNAME ; _hash "$@" ; )}
sha()    {( algo=$FUNCNAME ; _hash "$@" ; )}
sha1()   {( algo=$FUNCNAME ; _hash "$@" ; )}
sha256() {( algo=$FUNCNAME ; _hash "$@" ; )}
sha512() {( algo=$FUNCNAME ; _hash "$@" ; )}
rmd160() {( algo=$FUNCNAME ; _hash "$@" ; )}
_hash() {
    # ARGs: PATH|STR
    print_hash(){   
        #REQUIREs putclip 
        printf "%s" "${@:(-1)}" # print last positional-param only
    #     [[ "$_HASH_QUIET" ]] || { 
    #         [[ $(type -f putclip) ]] && putclip "${@:(-1)}" # to clipboard unless '-q'
    #     }
    }  
    # quiet mode on '-q' (prepended to input)
    [[ "${1,,}" == '-q' ]] && { _HASH_QUIET=1 ; shift ; } || unset _HASH_QUIET
    
    if [[ "$@" && "$algo" ]]
    then
        if [[ -f "$@" ]] 
        then 
            # -- file --
            [[ "$_HASH_QUIET" ]] || echo $algo "[FILE] '${@##*/}' ..."
            print_hash $( openssl $algo "$*" )
        else  
            # -- string --
            [[ "$_HASH_QUIET" ]] || {
                echo $algo "[STR] '$@' ..." >&2
            }
            print_hash $( echo -n "$*" |openssl $algo )
        fi
    else
        REQUIREs errMSG
        [[ ! "$@"    ]] && errMSG "$FUNCNAME FAIL @ null input"
        [[ ! "$algo" ]] && errMSG "$FUNCNAME FAIL @ null 'algo'"
    fi
}
woff2base64() { [[ "$(type -t base64)" && -f "$@" ]] && base64 -w 0 "$@"; }

#####
# ssh

alias fpr='ssh-keygen -E md5 -lvf'
alias fprs='ssh-keygen -lvf'
hostfprs() { 
    # Scan host and show fingerprints of its keys to mitigate MITM attacks.
    # Use against host's claimed fingerprint on ssh-copy-id or other 1st connect.
    [[ "$1" ]] && {
        ssh-keyscan $1 2>/dev/null |ssh-keygen -lf -
    } || {
        printf "\n%s\n" 'Usage:'
        echo "$FUNCNAME \$host (FQDN or IP address)"
    }
    printf "\n%s\n" 'Push key to host:'
    echo 'ssh-copy-id -i $keypath $ssh_user@$host'
}

######
# Meta

colors() {
    # Each is a background color and contrasting text color.
    # Usage: colors;printf "\n %s\n" "$green MESSAGE $norm"
    [[ "$TERM" ]] || return 99
    normal="$( tput sgr0 )"                       # reset
    red="$(    tput setab 1 ; tput setaf 7 )"
    yellow="$( tput setab 3 ; tput setaf 0 )"   # blk foreground
    green="$(  tput setab 2 ; tput setaf 0 )"   # blk foreground
    greenw="$( tput setab 2 ; tput setaf 7 )"   # wht foreground
    blue="$(   tput setab 4 ; tput setaf 7 )"
    gray="$(   tput setab 7 ; tput setaf 0 )" ; alias grey=gray
    aqua="$(   tput setab 6 ; tput setaf 7 )"
    aqux="$(   tput setab 6 ; tput setaf 6 )"   # hidden text
    zzz="$normal"  
    norm="$normal" 
    
}
errMSG() { 
    # ARGs: MESSAGE
    [[ "$TERM" ]] && {
        colors;printf "\n $red ERROR $norm : %s\n" "$@"
    } || { 
        printf "\n %s\n" " ERROR : $@"
    }
    return 99
}
REQUIREs(){ 
    # ARGs: FUNCNAME1 [FUNCNAME2 ...]
    # function[s] exist test; exit on fail; $? is 86 on fail, else 0
    declare flag
    for func in "$@"
    do  # exist-test ; append flag on fail
        [[ "$( type -t $func )" ]] || flag="${flag}'${func}', "
    done
    [[ "$flag" ]] && { # inform of calling-function and non-existent functions
        flag="${flag%,*}" ; errMSG "'${FUNCNAME[1]}' REQUIREs function[s] that do NOT EXIST ..."
        printf '\n %s\n' "$flag"
        # return|exit [86] on fail per @ 1x-bash or not
        #[[ $PPID -eq $_PID_1xSHELL ]] && return 86 || exit 86 # nope; pppppids are a clusterfuck
        return 86
    }
    return 0
}
putclip() { 
    # ARGs: STR
    # $@ => clipboard [erases it on null input]
    if [[ ! "$_CLIPBOARD" ]] # set clipboard per OS, once per Env.
    then 
        # Win7: clip; Linux: xclip -selection c; OSX: pbcopy; Cygwin: /dev/clipboard
        for i in clip xclip pbcopy
        do 
            [[ "$( type -t $i )" ]] && _CLIPBOARD="$i"
        done
        [[ "$OSTYPE" == 'cygwin' ]]    && _CLIPBOARD='/dev/clipboard'
        [[ "$OSTYPE" == 'msys' ]]      && _CLIPBOARD='/dev/clipboard'
        [[ "$_CLIPBOARD" == 'xclip' ]] && _CLIPBOARD='xclip -i -f -silent -selection clipboard' 
        # '-i -f -silent' and null redirect is workaround for command-sustitution case ['-loop #' bug]
    fi
    # validate clipboard; rpt & exit on fail
    [[ "$_CLIPBOARD" ]] || { errMSG "$FUNCNAME[clipboard-not-exist]" ; return 86 ; }
    # put :: $@ => clipboard
    [[ "$@" ]] && { 
        [[ "$OSTYPE" == 'linux-gnu' ]] && { printf "$*" | $_CLIPBOARD > /dev/null; true; } || { printf "$*" > $_CLIPBOARD; true; } 
    } || { 
        [[ "$OSTYPE" == 'linux-gnu' ]] && { : | $_CLIPBOARD > /dev/null; true; } || { : > $_CLIPBOARD; } 
    } 
}
x(){ 
    # Exit shell; show post-exist shell lvl;
    # clear user history if @ 1st shell
    clear #; shlvl
    [[ "$BASHPID" == "$_PID_1xSHELL" ]] && { 
        history -c; echo > "$_HOME/.bash_history" # clear history
        github ssh kill # kill all ssh-agent processes
    }
    exit > /dev/null 2>&1
}
shlvl(){ 
    # ARGs: [{msg}]
    # Show shell level [and message]
    colors; [[ "$@" ]] && _msg=": $@" || unset _msg
    [[ "${FUNCNAME[1]}" == 'x' ]] && _shlvl=$(( $SHLVL - 1 )) || _shlvl=$SHLVL
    [[ "$_shlvl" == "1" ]] && [[ "$PPID" == "$_PID_1xSHELL" ]] && { printf "\n %s\n" "$red $(( $_shlvl ))x ${SHELL##*/} $norm $_msg" ; } || { printf "\n %s\n" "$(( $_shlvl ))x ${SHELL##*/} $_msg" ; }
}
envsans(){
    # Print environment variables without functions
    declare -p |grep -E '^declare -x [^=]+=' |sed 's,",,g' |awk '{print $3}'
    printf "\n\t(%s)\n" 'Environment variables containing special characters may not have printed accurately.'
}

set +a  # END export 

## End here if not interactive
# [[ "$-" != *i* ]] && return
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"

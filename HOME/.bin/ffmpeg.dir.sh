#!/bin/bash
# ------------------------------------------------------------------------
#  Calls ffmpeg.sh as background (co)process on each target. 
# 
#  Processes target(s) at arg path (file or folder), else all at PWD. 
#  If target is folder then processes only one (scripted) target-type.
# 
#  ARGs: [PATH]
# ------------------------------------------------------------------------
_target_type='avi'

_ffmpeg() { # ARGs: PATH
    ffmpeg.sh "$@" &
}
export -f _ffmpeg # make available to subshell @ `find ... -exec ...`
# process (validated) file or folder path(s), per arg
unset _dir
[[ -f "$@" ]] && _ffmpeg "$@"
[[ -d "$@" ]] && _dir="$@"
[[ ! "$@"  ]] && _dir='.'
[[ "$_dir" ]] && find "$_dir" -maxdepth 1 -iname '*.'$_target_type -exec /bin/bash -c '_ffmpeg "$@"' _ "{}" \;

exit

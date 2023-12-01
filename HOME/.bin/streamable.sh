#!/bin/bash
# --------------------------------------------------------------
#  FFmpeg :: Make an H.264 (mp4) video streamable; 
#            playsable whilst downloading. 
# 
#  Process ALL mp4 @ PWD
# --------------------------------------------------------------
REQUIREs ffmpeg ; (( $? )) && exit 86

_ffmpeg() {
    _streamable='-movflags faststart'

    ffmpeg -i "$@" $_streamable -c:v copy -c:a copy "${@%.*}-streamable.mp4"
}
export -f _ffmpeg

find . -iname '*.mp4' -exec /bin/bash -c '_ffmpeg "$@"' _ "{}" \;
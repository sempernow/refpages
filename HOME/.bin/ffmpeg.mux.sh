#!/bin/bash
# ---------------------------------------------------------------------------
#  A/V mux using sources that differ in length, FPS, and play speed.
#  Tested with sources of Aeon Flux S02E01 'Gravity' episode, from two sets. 
# 
#  AC-3 5.1 audio, from the '720x480 [mpg]' set, muxed
#  with video from the transcoded 720x576 [VOB] set.
# 
#  The '[VOB]' video source is shorter/faster 
#  than the '[mpg]' audio source.
# 
# Presentation TimeStamp (PTS) filter; changes that of each video frame.
# http://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video
# ---------------------------------------------------------------------------
REQUIREs ffmpeg ; (( $? )) && exit 86
[[ ! -f "$@" ]] && { printf "\n  %s\n" "Is NOT a file: '$@'"; exit 99; }
#
_HW_Accel='-hwaccel qsv'
#_HW_Accel='-init_hw_device qsv:hw -hwaccel qsv'  # does nothing
_g="-threads 0 -y -hide_banner $_HW_Accel"

_ci='-c:v mpeg2_qsv' # Souce MUST be MPEG-2 (H.262)
#_ci='-c:v h264_qsv'  # Souce MUST be MPEG-4 (H.264)
#_ci='-c:v vp8_qsv'   # Souce MUST be VP8 

#_QSV_opts='-load_plugin hevc_hw -preset:v slow -global_quality 21'
_QSV_opts='-preset:v slow -global_quality 21'
_co="-c:v h264_qsv $_QSV_opts -an" 
#_co="-c:v hevc_qsv $_QSV_opts" 

#_co='-c:v libx264 -tune animation -crf 21'
#_co="-c:v libx265 -x265-params crf=21" 
#_co='-c:v libvpx -tune animation -deadline best -quality best'

#_co="$_co -c:a copy"
# _co="$_co -c:a aac"
# _co="$_co -c:a ac3"

# TEST MODE 
# =========
# Uncomment for short clip
#_TEST='-ss 00:00:00 -to 00:02:30' ; _t='-test'
#_TEST='-ss 00:19:00' ; _t='-test'

# TRANSCODE (mpg => mp4)
# ======================
# Finding the stretch-factor: 
# 22:29/21:31 => 22.483/21.517 = 0.9570342036205133  1/1.044894734396059
# setpts :: video PTS method
_filter="-filter:v setpts=1.044894734396059*PTS"
#_filter="-r 29.97" 

# atempo :: audio tempo method
#_filter="-filter:a atempo=1.044894734396059" 

[[ "$_filter" && "$_t" ]] && _t="${_t}-vf"
ffmpeg $_g $_ci -i "$@" $_TEST $_filter $_co "${@%.*}${_t}.mp4"

# A/V Mux per FPS
# ffmpeg $_g $_ci -i "$@" -i "${@%.*}.audio.mp4" \
# $_TEST $_filter $_co -strict experimental \
# -map 0:v:0 -map 1:a:0 -shortest "${@%.*}${_t}-muxd.mp4"

# A/V Mux
# ===================
#_g='-threads 0 -y -hide_banner'
_ci= # sans HW-accelerated decoder; required for filtering
_co="-c:v h264_qsv $_QSV_opts -c:a ac3"
_filter=


# Mux A/V; mute V
#ffmpeg -i Video.mp4 -i Audio.FLAC -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 Muxed.mp4

# Streched audio
ffmpeg $_g $_ci -i "${@%.*}${_t}.mp4" -i "${@%.*}.audio.mp4" \
$_TEST $_filter $_co -strict experimental \
-map 0:v:0 -map 1:a:0 -shortest "${@%.*}${_t}-muxd.mp4"

exit
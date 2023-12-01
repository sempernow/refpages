#!/bin/bash
# -----------------------------------------------------------------
#  FFmpeg :: transcode/filter, e.g., mpg (H.262) => mp4 (H.264)
#  
#  ARGs: PATH              ( Callable from 'ffmpegdir.sh' )
# -----------------------------------------------------------------
REQUIREs ffmpeg ; (( $? )) && exit 86
[[ ! -f "$@" ]] && { printf "\n  %s\n" "Is NOT a file: '$@'"; exit 99; }
#
_HW_Accel='-hwaccel qsv'
#_HW_Accel='-init_hw_device qsv:hw -hwaccel qsv'  # does nothing
_g="-threads 0 -y -hide_banner $_HW_Accel"

#_ci='-c:v mpeg2_qsv' # Souce MUST be MPEG-2 (H.262)
_ci='-c:v h264_qsv'  # Souce MUST be MPEG-4 (H.264)
#_ci='-c:v vp8_qsv'   # Souce MUST be VP8 

# _QSV_opts='-preset:v slow -global_quality 24'
# _QSV_opts='-profile:v high -level 4.2 -global_quality 24'
# _co="-c:v h264_qsv $_QSV_opts" 

# _QSV_opts='-load_plugin hevc_hw -preset:v slow -global_quality 24'
# _co="-c:v hevc_qsv $_QSV_opts" 
_co="-c:v copy" 

#_co='-c:v libx264 -tune animation -crf 21'
#_co="-c:v libx265 -x265-params crf=21" 
#_co='-c:v libvpx -tune animation -deadline best -quality best'

_co="$_co -c:a copy"
# _co="$_co -c:a aac"
# _co="$_co -c:a ac3"

# TEST MODE 
# =========
# Uncomment for short clip
#_TEST='-ss 00:00:00 -to 00:02:30' ; _t='-test'
_TEST='-ss 02:01:29 -to 02:39:14' ; _t='-test'

# TRANSCODE (mpg => mp4)
# ======================
# QSV FILTERing per `vpp_qsv`  https://github.com/Intel-FFmpeg-Plugin/Intel_FFmpeg_plugins/wiki  
# Most filtering is NOT ALLOWed if HW-accel decoding, except per mysterious `vpp_qsv`
# Trial & error method; `vpp_qsv` filter has NO REFERENCEs @ FFmpeg.org 

# DEINTERLACE
#_ci=
#_filter="-vf yadif,hqdn3d,$_eq"  # de-interlace, denoise, eq
#_filter="-vf yadif"              # de-interlace
#_filter="-vf bwdif"              # bob weaver de-interlace https://ffmpeg.org/ffmpeg-filters.html#bwdif 

# SUCCESS:
#_filter="-vf vpp_qsv=denoise=40"
#_filter="-vf vpp_qsv=eq=contrast=1.25:saturation=1.4"
#_filter="-filter:v setpts=1.035*PTS" 
#_filter="-filter:a atempo=1.044894734396059" 
# 22:29/21:31 => 22.483/21.517 = 0.9570342036205133  1/1.044894734396059
# FAIL: (no: eq=gamma, hqdn3d)
#_filter="-vf vpp_qsv=yadif"
#_filter="-vf vpp_qsv=eq=gamma=1.5" 
#_filter="-vf vpp_qsv=hqdn3d"
#_filter="-r 30" 
[[ "$_filter" && "$_t" ]] && _t="${_t}-vf"
ffmpeg $_g $_ci -i "$@" $_TEST $_filter $_co "${@%.*}${_t}.mp4"

exit 

# FILTER (mp4 => mp4)
# ===================
#_g='-threads 0 -y -hide_banner'
_ci= # sans HW-accelerated decoder; required for filtering
_strm='-movflags faststart'
#_eq='eq=contrast=1.25:gamma=1.5:saturation=1.4' 
#[[ "${@/AF.S03E02//}" != "$@" ]] && _eq='eq=contrast=1.1:gamma=1.2:saturation=1.35' 
#[[ "${@/AF.S03E03//}" != "$@" ]] && _eq='eq=contrast=1.1:gamma=1.2:saturation=1.3' 
_filter="-vf hqdn3d,$_eq" # denoise, eq
#_filter=-vf hqdn3d,$_eq,unsharp=3:3:1:3:3:1" # denoise, eq, sharpen

ffmpeg $_g $_ci -i "${@%.*}${_t}.mp4" $_strm $_filter $_co "${@%.*}${_t}-vf.mp4"

exit 

# TRANSCODE + FILTER (mpg => mp4)
# ==============================
# Generates repeated error messages ...
# '[h264_qsv @ 000001f71dfe6080] Warning during encoding: incompatible video parameters (5)'

#ffmpeg $_g $_ci -i "$@" $_TEST $_strm $_filter $_co "${@%.*}${_t}.mp4"

exit 


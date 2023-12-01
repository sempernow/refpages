#!/bin/bash
# -----------------------------------------------------------------
#  FFmpeg :: TEST/DEV
# -----------------------------------------------------------------
exit 

# TEST/DEV 
# ========

alias ffmpeg='ffmpeg -hide_banner' 

# Show all PARAMs available for specified encoder
ffmpeg -? encoder=h264_qsv 
ffmpeg -? encoder=libx264 
ffmpeg -? encoder=libvpx 
ffmpeg -? encoder=hevc_qsv

# mpg => mp4 :: MPEG-2 => MPEG-4 H.264 AVC
# 20MB => 9MB  (same quality); much more efficient encoding
ffmpeg -i IN.mpg -c:v libx264 -preset slow -crf 22 -c:a copy OUT.mp4

# VP9/WebM; constant quality  https://trac.ffmpeg.org/wiki/Encode/VP9
ffmpeg -i IN.mpg -c:v libvpx-vp9 -crf 30 -b:v 0 OUT.webm

# -vf (video filters)
# eq  https://ffmpeg.org/ffmpeg-filters.html#eq
_eq='eq=contrast=1.2:gamma=1.4:saturation=1.3'
_codec='libx264 -preset slow -crf 22'
ffmpeg -i IN.mpg -c:v $_codec -c:a copy -vf $_eq OUT.mp4

# pp (post processing) autolevels  https://ffmpeg.org/ffmpeg-filters.html#pp
ffmpeg -i IN.mpg -c:v $_codec -c:a copy -vf pp=al OUT.mp4

# pp (post processing) default (better)
ffmpeg -i IN.mpg -c:v $_codec -c:a copy -vf pp OUT.mp4
ffmpeg -i IN.mpg -c:v $_codec -c:a copy -vf pp=hb/vb/dr/al OUT.mp4

# pp + eq ; mutliple filters using `-vf`; comma-separate the filters
_eq='eq=contrast=1.2:gamma=1.4:saturation=1.3' 
_eq='eq=contrast=1.25:gamma=1.5:saturation=1.4'

_pp='pp'
_pp='pp=hb/vb/dr/al'
_pp='pp=de/-al'

_codec='libvpx-vp9 -deadline best -quality best' # VP9 is very slow.
_codec='libvpx-vp9 -crf -1' # ba
_codec='libx264 -crf 21 -tune animation' # very mild effect
# @ QSV ...
# neither -maxrate nor -bufsize are shown as hevc_qsv params @ `ffmpeg -? encoder=hevc_qsv`
# neither is -global_quality, BUT explicitly @ https://ffmpeg.org/ffmpeg-codecs.html#QSV-encoders
#_QSV_opts='-load_plugin hevc_hw -preset:v slow -profile:v main -global_quality 21 -maxrate 960k -bufsize 960k' 
_QSV_opts='-load_plugin hevc_hw -preset:v slow -global_quality 21'
_codec="h264_qsv $_QSV_opts" # `-look_ahead_depth 3` :: did nothing
_codec="hevc_qsv $_QSV_opts"

_filter="$_pp, $_eq" # pp is generating noise !
_filter="$_eq"
_filter="hqdn3d,$_eq"

ffmpeg -i IN.mpg -c:v $_codec -vf "$_filter" -c:a copy OUT.mp4

# clip; test
ffmpeg -i IN.mpg -ss 00:32 -to 00:40 -c:v $_codec -vf "$_filter" -c:a copy OUT.mp4
ffmpeg -i IN.mpg -ss 00:00 -to 00:20 -c:v $_codec -vf "$_filter" -c:a copy OUT.mp4
# process clip per ...
_filter="nlmeans" # SLOW; artifacts
_filter="hqdn3d"  # FAST; nice!
ffmpeg -i OUT.mp4 -c:v $_codec -vf $_filter -c:a copy $_filter.mp4

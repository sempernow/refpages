#!/bin/bash
# -------------------------------------------------------------
#  ImageMagick :: SVG to PNG @ HEIGHT (sized proportionally) 
# 
#  ARGs: FILE HEIGHT 
# -------------------------------------------------------------
[[ ! "$2" ]] && { script_info "$0" ; exit; }
# magick convert -size x$2 "$1" "${1%.*}.png"
convert -size x$2 "$1" "${1%.*}.png"
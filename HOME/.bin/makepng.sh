#!/bin/bash
# --------------------------------------------------
#  ImageMagick :: Convert JPG|GIG|BMP|... to PNG
# 
#  ARGs: FILE 
# --------------------------------------------------
magick convert "$1" "${1%.*}.png"
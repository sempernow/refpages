#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Process image files using FFmpeg @ Git-for-Windows (MINGW64) terminal.
# -----------------------------------------------------------------------------

# Convert from PNG to WebP using FFmpeg
. ffmpeg 
find . -type d -exec /bin/bash -c \
    'find "$@" -type f -print0|xargs -0 -I X ffmpeg -i X -q:v 90 -vf scale=800:-1 X.webp' _ {} \+

# Delete source *.png files
find . -type f -iname '*.png' -exec /bin/bash -c 'rm "$@"' _ {} \+

# Rename result, from *.png.webp to *.webp
find . -type f -iname '*.png.webp' -exec /bin/bash -c \
    'mv "$@" "$( sed "s/.png//g" <<< "$@" )"' _ {} \;

# Fix/Reset timestamps 
export ref='./zzz.cbr'
find . -type f -iname '*.webp' -exec /bin/bash -c 'touch -r "$ref" "$@"' _ {} \+

#!/bin/bash
# ------------------------------
#  *.jpg => *.png => * [d].png 
# ------------------------------
find -name '*.jpg' -exec /bin/bash -c 'ffmpeg -i "$@" "${@%.*}.png"' _ {} \;
find -name '*.png' ! -name '* [d].png' -exec /bin/bash -c 'magick convert -despeckle "$@" "${@%.*} [d].png"' _ {} \;

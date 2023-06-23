#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  normalize refpages : for use @ Makefile 
# -----------------------------------------------------------------------------

find ./REFs -type f -iname '*.html' -exec rm "{}" \+
find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
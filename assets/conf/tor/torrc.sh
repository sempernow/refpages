#!/usr/bin/env bash
###############################################################################
# Makefile : make torcfg : strip all lines but for active.
###############################################################################

sed '/#/d' ./etc.tor.torrc |sed '/^[[:space:]]*$/d' > ./torrc

exit 0

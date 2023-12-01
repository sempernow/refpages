#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  View CBS.log :: Results of `sfc /verifyonly` command. Filter out the cruft.
# -----------------------------------------------------------------------------

_cbsView() {
    cat "$@" | grep -v 'Error: Overlap: Duplicate ownership' | grep -v 'Warning: Overlap:' | grep -v 'Info'
}

_cbsView "$@"

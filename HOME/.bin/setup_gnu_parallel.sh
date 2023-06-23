#!/bin/bash

# FAILs to install; won't fully function @ Cygwin anyway due to `sem` [dependency] behavior
# https://cygwin.com/ml/cygwin/2017-03/msg00189.html

# ===  FAILed to install; executed [after `cd ...` mod], but no binary added to Cygwin ===

# SCRIPT https://gist.github.com/drhirsch/e0295105a36039aa38ce936f39b26301
# GNU    https://www.gnu.org/software/bash/manual/bashref.html#GNU-Parallel

# useful for platforms such as Cygwin that don't currently have GNU Parallel in their repo.
# prerequisite: make
(
wd=$(mktemp -d)
wget -nc -P $wd ftp://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2

cd $wd
tar -xf parallel-latest.tar.bz2
# cd parallel-* # FAILed [returns multiple paths]
cd "$( find -mindepth 1 -maxdepth 1 -type d )" # solution
./configure && make && make install
)
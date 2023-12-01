#!/bin/bash
# ================================================================================
# STREAM PROCESSor (generalized)
# foo is the (big/slow) process; requires specified minargs (args per process).
# N controls stream-window shift; foo may want to overlap, skip, or whatever; 
# to calculate a moving average, a differential, downsampling, etc
# 
# E.g., say foo does some kind of differential between adjacent args; 
#   that is, it wants `foo (n-1) (n)`  
#   so minargs is 2 and N=1 (overlap 1); stream is then processed per 
#   `foo 1 2`, `foo 2 3`, ..., `foo (n-1) (n)`.
# ================================================================================
foo(){
    sleep 1; printf "%s\t%s\t%s\n" "[$1]" "[$2]" "[$3]"
}
streamArgs() { 
    # set number of args per window (minargs), and window shift (N) 
    _foo_MINARGS=3; _N=2
    (( $# < $_foo_MINARGS )) && return  
    # spawn bkgnd `foo` process; lop N args; recurse
    ( foo "$@" & ); shift $_N; $FUNCNAME "$@" 
}
export -f streamArgs # must export so subshell @ `find` can access
export -f foo        # must export so subshell @ `find` can access 

[[ ! -e "$TMP/foo" ]] && mkdir $TMP/foo; touch $TMP/foo/{a..z}bar
find $TMP/foo -execdir /bin/bash -c 'streamArgs "$@"' _ {} \+
seq 9 | xargs /bin/bash -c 'streamArgs "$@"' _ 

# If window and arg sizes are same (N = minargs), then stream directly to foo
seq 9 | xargs -n 2 /bin/bash -c 'foo "$@" &' _  # spawning background process(es)

exit  

# minargs:3; N:3
[1]     [2]     [3]
[4]     [5]     [6]
[7]     [8]     [9]

# minargs:3; N:1
[1]     [2]     [3]  
[2]     [3]     [4]  
[3]     [4]     [5]  
[4]     [5]     [6]  
[5]     [6]     [7]  
[6]     [7]     [8]  
[7]     [8]     [9]  

# minargs:3; N:2
[1]     [2]     [3]
[3]     [4]     [5]
[5]     [6]     [7]
[7]     [8]     [9]
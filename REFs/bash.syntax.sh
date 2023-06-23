#!/bin/bash
# ---------------------------------------------------------
#  shell scripting reference
# 
#  http://www.gnu.org/software/bash/manual/bashref.html
#  http://wiki.bash-hackers.org/start
#  http://ss64.com/bash/
#  http://tldp.org/LDP/abs/html/index.html
#
#  ***  DO NOT EXECUTE  ***
# ---------------------------------------------------------
exit

# SCRIPTING
    # Shebang variations ...
    ### #!/usr/bin/env bash     # Per-user default binary. (Some systems have no /bin/bash binary.)
    ### #!/usr/bin/bash         # Explicity set the binary.

    /bin/bash                             # launch subshell
    /bin/bash -c "cmd1 $a b;cmd2 $x"      # run command(s) at subshell then exit
    /bin/bash -s < script.sh $arg1 $arg2  # run script with args at subshell then exit
    /bin/bash -x script.sh arg1 arg2      # debug mode
    /bin/bash -v ...                      # debug; print script lines as they are read

    # rbash : RESTRICTED SHELL; forbid dir change, redirects, ...; see `man rbash`
    /bin/rbash 
    /bin/bash -r  

    # SSH ( See REF.Network.SSH.sh )
    ssh -i ${_PRIVATE_KEY} ${user}@${host_name_OR_public_ip}
    # Remotely run LOCAL script and args (environment) through a secure shell
    ssh ... "/bin/bash -s" < /any/local/path/script.sh $arg1 $arg2
    #... per commands : allows partial preprocessing; escapes required in script
    ssh ... "/bin/bash -c '$(</a/local/path/script.sh)' _ $arg1 $arg2"
    #... advantage over HEREDOC scheme is preservation of semantic highlighting @ code editor.
    # UPLOAD a file SANS "file upload" utility (rsync, scp, ftps):
    # Reads local (SSH client) file into string as writes it to remote (SSH host) file
    ssh ... "printf '$(</any/local/path/src.foo)' > /any/remote/path/dst.foo"

    # Modifying Shell Behavior  https://www.gnu.org/software/bash/manual/html_node/Modifying-Shell-Behavior.html#Modifying-Shell-Behavior
    set setopt 
        
    export foo bar               # Export VARIABLE(s) into shell Env.
    export -f [name[=value] ...] # Export FUNCTION(s) into shell Env.
    export -n [name[=value] ...] # Remove variable OR function from Environment; Un-export
    export -p    # list all exported variables.
    export -f    # list all exported functions.
    export       # list all Env. Vars. 

    # Exit Codes : 0-255; 126-255 Reserved 
    #  126: the requested command (file) can't be executed (but was found)
    #  127: command (file) not found
    #  128: (questionable) report an invalid argument to the exit builtin
    #  128 + N: the shell was terminated by the signal N
    #  255: wrong argument to the exit builtin (see code 128)

    # CTRL+C == terminate script
    # CTRL+D == exit shell

    # METACHARACTER; a char that, when unquoted, separates words; 
    #  space, tab, newline, '|', '&', ';', '(', ')', '<', or '>'.

# BUILTIN; a command implemented internally by the shell itself, 
    # rather than by an executable @ file system such as @ ~/.bin folder. 
    # Shell Builtin Commands  https://www.gnu.org/software/bash/manual/html_node/Shell-Builtin-Commands.html#Shell-Builtin-Commands
    # Bash Shell Builtins 
        : . break cd continue eval exec exit export getopts hash pwd readonly return shift 
        test [ ! () times trap umask unset   
        # man test (1)  https://linux.die.net/man/1/test 
    # Special Builtin; shell builtin command classified as special by the POSIX standard
        : . break continue eval exec exit export readonly return set
    # Bash Builtins  
        alias bind builtin caller command declare echo enable help let local logout mapfile 
        printf read readarray source type typeset ulimit unalias 

# FUNCTIONs [ name can NOT start w/ an integer ]
    name { command-list; }           # sh 
    name () { command-list; }        # C syntax; more portable
    function name { command-list; }  # alt; note no parens @ name 

    # @ subshell; SANDBOX/JAIL; vars local
        name () {( command-list; )}    # no need for 'local VAR'; POSIX-portable

    # stream process; recurse thru args; req. 'export -f' to use w/ pipes: ... | xargs ... foo
        foo()
        { 
            process() { echo "1[$1] 2[$2]"; }
            (( $# == 1 )) || {
                process "$@"; shift; $FUNCNAME "$@";
        }	}	
        foo "$@"

        $ foo 1 2 3 4 # => stdout ...
            1[1] 2[2]
            1[2] 2[3]
            1[3] 2[4]

    # Bash FORK BOMB (AKA rabbit virus AKA wabbit), where ":" is just the function name 
        :(){ :|:& };:  # f(){f|f&};f
         # So, the function calls itself, piping to itself, 
         # recursively spawning bkgnd processes, DEPLETING available RESOURCES; CRASHING the SYSTEM.

# GROUPING commands in a subshell
    (LIST)      # subshell; includes non-exported vars of parent; operators "(", ")"
    { LIST; }   # not sub-shell; spaces required; reserved words "{", "}"

# BACKGROUND PROCESS
    /bin/bash $_CMD_or_SCRIPT & 
    # Sans STDOUT and STDERR
    /bin/bash -c "$_CMD_or_SCRIPT arg1 arg2" >/dev/null 2>&1 &
    # Alternative, but quirky; shell-specific behavior:
    nohup $_CMD_or_SCRIPT arg1 arg2 & # Ignore HANGUP signal(s) (SIGHUP)
    #... + multiple commands (in bkgnd process), and sans any output to anywhere:
    nohup /bin/bash -c "sleep 30 && $_CMD_or_SCRIPT arg1 arg2 &" >/dev/null 2>&1

# PROCESS SUBSTITUTION (PS) Operators : NOT well supported per POSIX; use pipes
    # STDOUT (of command) to FILE
    # http://wiki.bash-hackers.org/syntax/expansion/proc_subst
    <(command1)  # Command STDOUT sent as if from file; connects per /dev/fd/# 
    >(command1)  # Command takes STDIN; useful TO AVOID SUBSHELL of pipe

    # E.g., when command2 requires FILE
    command2 <(command1) 
    #... may fail because PS is *not* POSIX compliant.

# PIPEs : FIFO (Named pipe) : POSIX compliant ALTERNATIVE to PS : See man fifo(7), pipe(7)
    # Unidirectional INTER-PROCESS COMMUNICATION CHANNEL (IPC; byte stream); has a write end and a read end. 
    # Data written to the write end of a pipe can be read from the read end of the pipe.
    mkfifo pipe1       # Make FILE of zero bytes; a FIFO (first-in first-out special file)
    command1 > pipe1 & # WRITE to it PER BKGRND PROCESS (blocks only until other end is opened)
    command2 < pipe1   # READ from it (open other end of this FIFO; blocks until data)
    command3 < pipe1   # READ from it by another processes
    #... multiple processes may read from it; concurrently if reads are each bkgrnd process.
    rm pipe1           # Delete afterwards

# COMMAND SUBSTITUTION; subshell (ephemeral)
    $(command1)     # preferred
    `command1`      # equivalent; old way
    # DO NOT escape (outer) quotes nested therein
    echo "$(echo "shell level: $SHLVL")" # subshell yet same shell level

    # Show PARENT ($$) v. CURRENT ($BASHPID) PROCESS : 
    echo $$-$BASHPID                # 17-17   (no subshell)
    ( echo $$-$BASHPID )            # 17-7391 (subshell)
    echo $( echo $$-$BASHPID )      # 17-7395 (subshell)

    $( (command1) ) # RIGHT @ command substitution
    $((command1))   # WRONG @ command substitution (collides w/ arith-subst. syntax)

    # FILE (read) to STDIN (string) per REDIRECT @ subshell 
     $(<FILE) # Faster than $(cat FILE)

    # FILE PROCESSING thru SSH tunnel (local==>remote) per COMMAND SUBSTITUTION of REDIRECT:

        # Run LOCAL SCRIPT at REMOTE SHELL, passing in LOCAL ENVIRONMENT per positional params
        ssh ... '/bin/bash -s' < /a/local/path/script.sh $arg1 $arg2 ...
        # or with partial preprocessing (escapes required in script)
        ssh ... "/bin/bash -c '$(</a/local/path/script.sh)' _ $arg1 $arg2 ..."
        #... advantage over HEREDOC scheme is preservation of semantic highlighting (code editor).

        # UPLOAD static file sans "file upload"
        # Read local file into string and write it to a remote file per redirected echo.
        ssh ... "echo '$(<foo.yml)' > foo.yml"

# Run LOCAL SCRIPT at REMOTE SHELL injecting LOCAL ENVIRONMENT per positional params
# ARITHMETIC SUBSTITUTION
    $(( expr1 ))  

# CONDITIONAL EXPRESSION / TEST CONSTRUCT http://tldp.org/LDP/abs/html/testconstructs.html 
    [ expr1 ]    # INTEGER/STR/FILE/ ... '[' is builtin command
    [[ expr1 ]]  # INTEGER/STR/FILE/ ... '[[' is a keyword [extended test] @ bash >= 2.02
    (( expr1 ))  # ARITHMETIC : If expr1 evaluates to 0|false, then exit code ($?) is non zero.
    #... man test (1) https://linux.die.net/man/1/test

    [[ $var ]]     && echo 'True'  || echo 'False'

    (( $? ))       && echo 'Error' || echo 'Okay' 
    (( $a - $b ))  && echo 'Not 0' || echo 'Zero'

    # ARITHMETIC EXPANSION & EVALUATION  http://tldp.org/LDP/abs/html/dblparens.html
        (( $a == $b ))
        (( $a <= $b ))

    # STRING COMPARISONS http://tldp.org/LDP/abs/html/comparison-ops.html#ICOMPARISON1
        [[ "$a" < "$b" ]]  # less than in ASCII alphabetical order
        [ "$a" \< "$b" ]   # less than in ASCII alphabetical order
        
    # MIXED EXPRESSION & EVALUATION ( Arithmetic & String )
        [[ (( $? > 0 )) || "$1" == "x" ]]
        [[   $? -gt 0   || "$1" == "x" ]]  # Equiv; alpine linux

    # CONDITIONAL EXPRESSION OPERATORS : used inside "[[ ]]" (Conditional Expression)
        (expr1)          # Return value of expression
        ! expr1          # NOT
        expr1 && expr2   # AND
        expr1 || expr2   # OR  

        # E.g., silence all stdout; inform on error
        command > /dev/null || echo 'command FAILed'

    # COMPOUND expr and GROUPING ...
        [[ expr1 && ( expr2 || expr3 ) ]]            && echo yes || echo no
        [[ (( $foo < 2 )) && ( "$bar" || "$baz" ) ]] && echo yes || echo no
        [[ ( $foo -ge 2 ) || ( "$baz" != "$dog" ) ]] && echo yes || echo no
        [[ $foo -ge 2 || "$baz" != "$dog" ]]         && echo yes || echo no  # Equiv; alpine linux 

    # note consistent arith/condl logic, and relative to that of exit[err] code
        (( 0 < 1   )) && echo "TRUE[$?]" || echo "FALSE[$?]"  # => TRUE[0]
        [[ 0 -lt 1 ]] && echo "TRUE[$?]" || echo "FALSE[$?]"  # => TRUE[0]
        [[ 0 -lt 1 ]] && echo "TRUE[$?]" || echo "FALSE[$?]"  # => TRUE[0]

    # *** WARNING!!! *** this idiom ... 
    [[ expression ]] && { commands1 } || { commands2 }
    # ... is NOT an if/then/else statement.
    #     Execution depends on exit code of the '&& {...}' block
    #       the 'or' command (commands2) ALSO EXECUTES 
    #       unless 'and' command (commands1) exit code is 0
    # Example ...
        [[ true ]] && { echo 'True'; false; } || { echo 'False'; } # BOTH are exectued
        (( 1 ))    && { echo 'True'; false; } || { echo 'False'; } # BOTH are exectued

        # true/false are shell builtin, NOT boolean value
        true  ; echo $?         # 0 {TRUE}
        false ; echo $?         # 1 {FALSE}

        # set vs. evaluate 
        
            # @ set ...
                _foo=0 ; echo $?        # 0
                _foo=1 ; echo $?        # 0
                
            # @ evaluate ...
                (( 0 )) ; echo $?       # 1 {FALSE}
                [[ 0 ]] ; echo $?       # 0 {TRUE}
                 
            # @ set AND evaluate ... [let AND C-style are EQUIVALENT]
                let _foo=0 ; echo $?    # 1
                let _foo=1 ; echo $?    # 0
                 
                (( _foo=0 )) ; echo $?  # 1
                (( _foo=1 )) ; echo $?  # 0
                
                _inc=-2
                (( _inc+=1 )); echo $?  # 0 
                (( _inc+=1 )); echo $?  # 1
                (( _inc+=1 )); echo $?  # 0 

        # NEW exit code upon result of test 
        (( $? )) && echo "TRUE[$?]" || echo "FALSE[$?]"  # $?=1 => TRUE[0] ; $?=0 => FALSE[1]
        (( 1 ))  && echo "TRUE[$?]" || echo "FALSE[$?]"  # TRUE[0]
        
    [[ -e "bogus-path" ]] ; echo $?  # => 1 {FALSE}
    [[ "$@" ]] && { echo "if positional param[s] exist" ; } || { echo "if no positional param[s]" ; }

    # using w/ if ... 
    if [[ "$v1" -gt "$v2" ]] || [[ "$v1" -lt "$v2" ]] && [[ -e "$filename" ]]; then ...
    
    # Depricated AND / OR 
        expr1 -a expr2  # AND - Do NOT use, unless w/ "test" variant of Test Command
        expr1 -o expr2  # OR  - Do NOT use, unless w/ "test" variant of Test Command

    # Test Command (old/classic) : returns Exit Code "0" on TRUE, "1" on FALSE
        [ expression ]    # Preferred
        test expression   # Equivalent (old method)

    # INTEGER EXPRESSION; TRUE if ...  (-eq -ne -lt -le -gt -ge)
        [[ 1 -gt 0 ]] && echo 'TRUE'
        [ 1 -gt 0 ]   && echo 'TRUE' 
        test 1 -gt 0  && echo 'TRUE'

    # ARITHMETIC EXPRESSION
        (( expr1 )) 
        (( 0 < 1 )) ; echo $?   # => 0 {TRUE}
        (( count += 1 ))        # increment count 
        (( t = a<45?7:11 ))     # C-style trinary operator.
        #       ^  ^ ^     ... If a < 45, then t = 7, else t = 11.

    # COMMA OPERATOR; links together a series of arithmetic operations.
    (( expr1, expr2, expr3 ))  # All are evaluated, but only the last one is returned. 

        # Set "a = 9" and "t2 = 15 / 3"
        let "t2 = (( a = 9, 15 / 3 ))"  # bash 1.0
        t2="$(( a = 9, 15 / 3 ))"       # bash 2.02+
    
    # STRING EXPRESSION; TRUE if ...
        string        # str NOT nul 
        -n string     # str length NOT 0
        -z string     # str length is 0
        str1  = str2  # strings are equal  
        str1 == str2  # strings are equal
        str1 != str2  # strings are NOT equal

    # REGULAR EXPRESSION [RegEx] MATCHING OPERATOR, '=~', 
    # used w/ double-parens test-syntax, [[...]]
    [[ "$zipCode" =~ ^[0-9]{5}$ ]]

    # shell option : nocasematch enable/disable [s/u] ; see "help shopt"
    shopt -s nocasematch  
    shopt -u nocasematch 

    # REGULAR EXPRESSIONs [RegEx]  https://en.wikipedia.org/wiki/Regular_expression
        ^   # Start of string
        $   # End of string
        .   # Any char except newline
        |   # Alteration (either)
        {}  # Explicit # of prceeding char 
        []  # Explicit set of chars match
        ()  # Group of chars 
        *   # 0 or more of preceeding char
        +   # 1 or more of preceeding char
        ?   # 0 or 1 of preceeding char

        # E.g., implement `"*"` per RegEx 
        "(.+)"  # any grouping of one or more of any chars, enclosed in double-quotes

# ARRAYs  http://wiki.bash-hackers.org/syntax/arrays
    ARRAY=()            # declare INDEXED array; initialize to empty [for existing array too]
    ARRAY[N]=VALUE      # set Nth el of INDEXED array.
    ARRAY=(E0 E1 …)     # set elements of INDEXED array

    ARRAY[STRING]=VALUE # set element of ASSOCIATIVE array 
    ${ARRAY[N]}         # access Nth value
    ${ARRAY[@]}         # access indices; keys if assoc. array.

    declare -a ARRAY    # declare INDEXED array. An existing array is not initialized.
    declare -A ARRAY    # declare ASSOCIATIVE array; THE ONE AND ONLY WAY

    # E.g., 
        args=(
            --host foo
            --username bar
            --dbname db1
            --quiet --no-align --tuples-only
        )
        echo ${args[@]}  # --host foo --username bar --dbname db1 --quiet --no-align --tuples-only 

    # ITERATE over ARRAY
        funcOn(){ echo "foo $1"; }; export -f funcOn 
        ARRAY=('foo' 'bar')

        # @ Values
        for i in "${ARRAY[@]}"; do; funcOn "$i"; done
        #=> foo foo 
        #=> foo bar
        
        # @ Indices
        for i in "${!ARRAY[@]}"; do; funcOn "$i"; done
        #=> foo 0 
        #=> foo 1

# FILE DESCRIPTOR (FD); a number which refers to an open file. 
#  Each process has its own private set of FDs
#  FDs are inherited by child processes from the parent process.
#  Every process should inherit 3 open FDs from its parent: 
#    0 ("standard input"), open for reading
#    1 ("standard output")  
#    2 ("standard error"), open for writing
    
    # FILE TEST OPERATORS http://tldp.org/LDP/abs/html/fto.html
    # FILE TYPE EXPRESSION; True if ...
    # http://mywiki.wooledge.org/BashGuide/TestsAndConditionals
        -b FILE   # file is a block device [HDD, SDD, CD-drive]
        -c FILE   # file is a character device [keyboard, modem, soundcard]
        -d FILE   # file is a Directory.
        -e FILE   # file Exists.
        -f FILE   # file is a regular file [NOT a dir].
        -r FILE   # file is readable by you.
        -s FILE   # file size > 0 ; exists and is not empty.
        -t FD     # FD is opened on a terminal; stdin (FD=0), stdout (FD=1), stderr (FD=2)
        
            # PIPEd args : scripts & functions can accept EITHER piped OR stdin args ..
            [[ -t 0 ]] && echo 'FD 0 open - stdin [NOT pipelined]' || echo 'PIPEd' 

                # to process piped input ...
                [[ ! -t 0 ]] && xargs -I {} command {} 
                        
                f(){ # function accepting EITHER piped OR stdin args [very brittle syntax]
                    [[ -t 0 ]] && echo "$@" || xargs -I {} $FUNCNAME {}
                }

            # other examples of '-t FD' usage
            [[ -t 1 ]] && echo 'FD 1 open - stdout'
            [[ -t 2 ]] && echo 'FD 2 open - stderr'
            
        -w FILE 	# file is writable by you.
        -x FILE 	# file is executable by you. 
        file1 -nt file2 # file1 is newer than file2.
        file1 -ot file2 # file1 is older than file2.

# LISTs; a sequence of one or more pipelines separated by one of the operators ‘;’, ‘&’, ‘&&’, or ‘||’, and optionally terminated by one of ‘;’, ‘&’, or a newline. 
# https://www.gnu.org/software/bash/manual/bashref.html#Lists

    command1 &               # Run command in background process [subshell]
    command1 ; command2      # Run command1 and then command2
    command1 && command2     # Run command2 only if command1 is successful
    command1 || command2     # Run command2 only if command1 is NOT successful
    
# PIPELINES & REDIRECTION Operators 
##  When referring to COMMANDs, the redirect is called PIPE
##  When referring to FILEs, the redirect is called REDIRECT.

# PIPELINE syntax ... if 'time', show runtime stats, if -p, format time per ... 
# https://www.gnu.org/software/bash/manual/bashref.html#Pipelines

    [time [-p]] [!] command1 [ | or |& command2 ] …	
        
    command1 | command2      # Redirect stdout of command1 to stdin of command2
    command1 |& command2     # Redirect stderr of command1 to stdin of command2
    command1 2>&1 | command2 # ... same; above is shorthand for this 
    
    # Redirect command1 into filename AND command2
    command1 | tee filename | command2  

    # Redirect stdout of command1 to MULTIPLE commands 
    command1 | ( command2 ; command3 ; ... )
    
    # &&, || : Conditional Execution
    command1 && comamnd2 || command3  
    # similar to if-then-else, HOWEVER, ... 
    # ... command3 is executed, or not, per command2 EXIT CODE !!!

# REDIRECTION : stdin (0), stdout (1), stderr (2), i.e., NAME (FD)

    # https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirections
    # http://ss64.com/bash/syntax-redirection.html
    # http://wiki.bash-hackers.org/howto/redirection_tutorial

    command1 < filename      # Redirect a file to stdin of command1
    command1 > filename      # Redirect stdout of command1 to filename
    command1 > filename 2>&1 # Redirect stdout & stderr of command1 to filename [good]
    command1 &> filename     # Redirect stdout & stderr of command1 to filename [bad]
    command1 2> filename     # Redirect stderr to a file
    command1 > /dev/null     # Discard stdout of command1
    command1 2> /dev/null    # Discard stderr of command1

    # in redirects, bash handles several filenames specially ...
        /dev/fd/n    # FD 'n' is duplicated. [@ bash, n =< 9]
        /dev/stdin   # FD 0 is duplicated.
        /dev/stdout  # FD 1 is duplicated.
        /dev/stderr  # FD 2 is duplicated.
        /dev/tcp/host/port # open the corresponding TCP socket.
        /dev/udp/host/port # open the corresponding UDP socket. 

    # HERE DOCUMENT (HEREDOC); redirect [MULTI-LINE] WORD to STDIN of COMMAND as if a FILE (DOC); instructs shell to read input from the current source (all text that follows) until a line containing only WORD (the delimiting identifer, with no trailing blanks) is seen. All of the lines read up to that point are then used as the COMMAND's STDIN (or its FD 'n' if 'n' is specified).  https://en.wikipedia.org/wiki/Here_document
    
        COMMAND [n]<<[-]WORD   # Disable leading TABs with ` <<-WORD `
                here-document line1
                here-document line2 ...
        WORD    # Disable expansion (of any var in text str) by quoting the label, e.g., ` << 'EOH' `

        # E.g., Multi-line string to FILE
            cat <<-EOH > FILE
                These contents will be written to FILE.
                The leading TABs are ignored, per `-` preceeding the delimiting identifier (EOH).
            EOH

            cat > FILE <<-EOH  # EQUIVALENT
                ...

        # E.g., Multi-line string to VARiable
            IFS='' read -r -d '' _VAR <<-"EOH"
                $_VAR will be set to this text block; no need to escape (unbalanced) quotes or apostrophes. 
                Quotes around the delimiting identifier (EOH) prevents the text from undergoing parameter expansion. 
                The `-d ''` causes it to ignore newlines. 
                `read` is a Bash built-in, so no need for `cat` utility.
            EOH

        # E.e., Multi-line string to STDOUT 
            cat <<- EOX 

                PostgreSQL server container (${image}) session
                
                1) Bash shell

                    $ su - postgres
                    $ pushd /home 

                2) Interactive psql
            EOX
            read q1
            case $q1 in
                # ...
            esac

        # HEREDOC to file
		cat <<-EOF >> $channels
			(
			    (SELECT view_id FROM views WHERE vname = 'chn-view'), 
			    (SELECT user_id FROM users WHERE handle = '${obj}'), 
			    'Mirror', msgform_long(),'Mirror', 'Proxy', '${url}'
			),
		EOF

        # HEREDOC + NAMED PIPE : "Upload" DYNAMIC file CONTENT sans file upload
            mkfifo # FIFO special file  https://linux.die.net/man/3/mkfifo

            # 1. @ ./foo.conf.sh
            #    Read/write dynamic content through pipe, 
            #    writing to STDOUT, per script:
    
                #!/usr/bin/env bash
                mkfifo pipe1
                cat <<-EOH > pipe1 &
                ########################################
                ###  AUTO-GENERATED @ ${0##*/} : ...
                ########################################
                foo_config_param1 = $(date -u +"%Y-%m-%dT%H:%M:%SZ")
                foo_config_param2 = $_DYNAMIC_LOCAL_ENV_VAR_X
                #... to configure remote nodes with dynamic 
                # content per local environment injected herein.
                EOH
                cat < pipe1
                rm pipe1

                #... not seen here, this method loses code editor's semantical highlighting;
                #    everything is highlighted identically (read as a literal). 

            # 2. Execute script @ subshell (COMMAND SUBSTITUTION), 
            #    reading the written pipe (as a string) into a variable.
            tgt_file='foo.conf'             # Target file
            src_str="$(./${tgt_file}.sh)"  # Source string (local file)

            # 3. Write the source string to target file @ (remote) shell.
            ssh user@host -i ~/.ssh/foo.pem /bin/bash -c "
                echo '${src_str}' > ${PATH_ABS_CTNR}/${tgt_file}
            "

        #... OR ... Alternatively ...
        # Run LOCAL SCRIPT at REMOTE SHELL passing in LOCAL ENVIRONMENT
        ssh ... '/bin/bash -s' < /a/local/path/script.sh $param1 $param2 ...
        #... advantage over HEREDOC scheme is preservation of semantic highlighting (code editor).

    # HERE STRING (HERESTR) : a [MULTI-LINE] WORD supplied as a single STRING (with NEWLINE appended)  
    # to COMMAND on its STDIN (or its FD 'n' if 'n' is specified).  https://www.tldp.org/LDP/abs/html/x17837.html

        COMMAND [n]<<< WORD 

        # E.g., Multi-line VARIABLE : Search/Test for substring therein.
            [[ $( grep "foo" <<< $_VAR ) ]] && echo 'The MULTI-LINE VARIABLE, `$_VAR`, contains "foo"'

    # DUPLICATING File Descriptors [FILE is path of a file]

        COMMAND [n]<&FILE # redirection operator; FILE is copied to stdin [or FD n].

        COMMAND [n]>&FILE # redirection operator; stdout [or FD n] is copied to FILE.
        
    # MOVING File Descriptors

        COMMAND [n]<&digit- # moves FD digit to FD stdin [or n]

        COMMAND [n]>&digit- # moves FD digit to FD stdout [or n]

    # OPENING File Descriptors for Reading and Writing

        COMMAND [n]<>FILE # redirection operator; FILE is opened for both reading and writing on stdin [or FD n]; FILE is create if not exist.

# SHELL EXPANSION; Brace/Tilde/Parameter/Arithmatic
# http://wiki.bash-hackers.org/syntax/expansion/intro
# http://ss64.com/bash/syntax-expand.html

    # BRACE EXPANSION; {}; 'globbing'; generate all possible combos [FAST]
        {str1,str2,...,strN}          # mkdir /home/foo/{bar,baz,dog}  =>  makes all three dirs
        {<alpah-start>..<alpha-end>}  # echo {s..v}     =>  s t u v
        {<num-start>..<num-end>}      # echo {003..5}   =>  003 004 005
        {<START>..<END>..<INCR>}      # echo {d..x..3}  =>  d g j m p s v
        <pre-str>{...}<post-str>      # concat   echo _{44..46}bar  =>  _44bar _45bar _46bar
        {...}{...}                    # combine  echo {A..Z}{0..9}  =>  A0 A1 A2 ... Z7 Z8 Z9  (260 strings)

        # Globbing is FAST; bash is designed to stream-process (pipeline) data
        # E.g., for-loop vs. command-GLOB
            for i in $( seq 10  900 ); do printf "%03d\t" "$i"; done  # time ... real  0m0.008s
            printf "%03d\t" {10..900}                                 # time ... real  0m0.001s
            # EACH produces IDENTICAL stdout => 
            010     011     012     013 ...     900

        # E.g., concatenate several VOB files (DVD-ripped) into one file 
            cat VTS_01_{1..8}.VOB > VTS_01_ALL.VOB  # works better than ffmpeg.exe

    # PARAMETER EXPANSION 
        $$     # PID [Process ID] of current shell
        $!     # PID of most recently executed BACKGROUND PROCESS; 'COMMAND &'
        $PPID  # Parent PID
        $_     # last argument of the most recently executed command.
        $?     # exit code of the most recently completed foreground command.

        # HISTORY EXPANSION  https://www.thegeekstuff.com/2011/08/bash-history-expansion/
            history   # list the HISTORY OF COMMANDS; numbered list
            !!        # last command 
            !44       # command #44 of history [list]
            !-3       # 3 commands ago
            !$        # last argument of last command
            !1-$      # all arguments of last command
            !foo      # last command that starts with `foo` 


    # PARAMETER EXPANSION per BRACE EXPANSION ${...} ; works w/ Positional Parameters too
    # http://wiki.bash-hackers.org/syntax/pe
    # https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html 

        # STRINGs  https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
            $PWD #=> /s/foo/bar
            ${PWD[@]:0:2}    #=> /s
            ${PWD[@]:0,-5}   #=> o/bar
    
        # Protects ...
            ${PARAM}s       # delimit otherwise ambiguous names
            ${12}           # access positional parameters beyond $9 
            ${PARAM:?msg}   # display msg if unset
            # absent braces, it fails, i.e., => 'These PARAMs'
            echo "These ${PARAM}s" # => 'These VALUEs' 

        # POSITIONAL PARAMETERS 
            $0             # script path; but it varies per ./script, . script, ...
            $1 … $9       # argument (parameter) list elements 1 - 9
            ${10} … ${N}  # higher # elements require Brace Expansion syntax
            $#             # number of positional parameters currently set.
            "$@"           # ALL the positional parameters, PRESERVED
            "$*"           # ALL the positional parameters, CONCATENATED per IFS

                # Unquoted 
                $*   # => $1 $2 $3 … ${N}   # $* == $@  (identical)
                $@   # => $1 $2 $3 … ${N}   # $* == $@  (identical)
                # Quoted
                "$*" # => "$1c$2c$3c…c${N}"      # where 'c' is first char of IFS
                "$@" # => "$1" "$2" "$3"…"${N}"  # PRESERVES PARAMETERS !!!  

                    $ foo(){ printf "1:'%s'   2:'%s' \n" "AMP[$@]" "AST[$*]"; }
                    $ foo "x y" "p q"
                    1:'AMP[x y'   2:'p q]'
                    1:'AST[x y p q]'   2:''

            # Brace Expansion on Positional Parameters
                ${*:START:COUNT}   # start (offset) index corresponds to arg#
                ${@:START:COUNT}   # start (offset) index corresponds to arg#
                ${*:START}         # offset only
                ${@:START}         # offset only
                ${@:(-START)}      # offset only
                ${@:(-END)}        # offset backward; start from last one
                ${@:START:(-END)}  # from START to end-of-string minus END chars

                "${*:START:COUNT}" 
                "${@:START:COUNT}" # quoting works its magic here too; pos. params preserved

                # Example
                test1() { echo -"${1}" ["${2}"] "${@:3}"; }
                test1 a1 "b c d" e f  # => -a1 [b c d] e f 

        # ARRAYs; always use braces
        # http://wiki.bash-hackers.org/syntax/arrays
            ${array[5]}
            ${array[*]}
            ${array[@]}

        # substring EXTRACTION
            ${PARAM:offset}         # to end
            ${PARAM:offset:length}  # index starts @ 0
            ${PARAM:0:(-2)}         # insert parens around negative numbers

        # substring REPLACEMENT
            ${PARAM/find/replace}   # first match only, e.g., ${PWD/${HOME}/'$HOME'}
            ${PARAM//find/replace}  # all matches
            ${PARAM/#find/replace}  # match/repl if @ BEGINNING only
            ${PARAM/%find/replace}  # match/repl if @ END only

        # substring DELETION
            ${PARAM/find}   # first match only
            ${PARAM//find}  # all matches

        # DEFAULT/EMPTY/(UN)SET
            ${PARAM:-word}  # USE DEFAULT when unset or empty
            ${PARAM-word}   # USE DEFAULT when unset only
            ${PARAM:=word}  # ASSIGN when unset or empty 
            ${PARAM=word}   # ASSIGN when unset only
            ${PARAM:+word}  # USE ALTERNATIVE when set
            ${PARAM+word}   # USE ALTERNATIVE when set or empty

        # LEADING substring DELETION
            ${PARAM#word}   # first match only
            ${PARAM##word}  # all matches
            ${PARAM#*word}  # Ex.: remove 1st "word" and everything preceeding it.

            ${PARAM#"$var"} # some hairy stuff in $var needs this notation; must leave the entirety unquoted

        # TRAILING substring DELETION
            ${PARAM%word}   # last match only
            ${PARAM%%word}  # all matches

        # E.g., @ Positional-Params
            ${@:2:1}        # second positional-param only
            ${@:(-1)}       # last positional-param only
            
            ${@%/*}    # parent path (lopp off last slash and all chars after.)
            ${@##*/}   # basename; fname.ext (lopp off all slashes and all chars preceding them.)
            ${@##*.}   # ext  [unchanged if no '.']
            ${@%.*}    # everything sans .ext

            "$( echo "${@##*/}" | rev | cut -f 2- -d '.' | rev )" # fname only [FAILS if no '.']
            
            # E.g., append string to fname [before .ext if exist] ...
            [[ "${1##*.}" != "${1%.*}" ]] && echo "${1%.*}.signed.${1##*.}" || echo "${1%.*}.signed"

            # E.g., get script (self) basename
            ${BASH_SOURCE0##*/} 

        # string length
            ${#PARAM}		# expanded to its length

        # UPPER/lowercase
            PARAM=foo
            ${PARAM^} 	=> Foo			# UPPERCASE 1st letter
            ${PARAM^^} 	=> FOO			# UPPERCASE all letters
            ${PARAM,} 	=> lowercase	# lowercase 1st letter
            ${PARAM,,} 	=> lowercase	# lowercase all letter
            ${PARAM~} 	=> reverse		# reverse the case (first letter) [~~ is goofy]

        # Variable Name Expansion
            ${!WORD*}	=> <list>   # list of all matching [& defined] var names; WORD is PREFIX
            ${!WORD@}	=> <list>   # list of all matching [& defined] var names; WORD is PREFIX
 
            # Indirection
            PARAM=cat
            cat=motorcycle
            ${!PARAM} # value of param whose name is the value of $PARAM
                                # => motorcycle 
    
            # Using INDIRECTION [instead of eval] to set variable per variable-name
                echo "$p"'='"'${!p}'"
               # UNSET all variables named APP_*
                    unset ${!APP_@}

            # w/ variable [works, but not documented anywhere] ... 
            ${PARAM%$var}
            ${PARAM%"$var"} # quotes required for some special chars

            # OPERATOR [TRANSFORMATION/INFORMATION]
            ${PARAM@OP}
            # expansion is a transformation or information about PARAM; OP is one letter:
                Q  # string value of parameter QUOTED in a format that can be REUSED AS INPUT. 
                E  # string value of parameter with BACKSLASH ESCAPE SEQUENCES expanded
                P  # string result of expanding the value of parameter as if it were a PROMPT STRING
                A  # string in the form of an ASSIGNMENT STATEMENT or declare command
                a  # string consisting of flag values representing parameter’s attributes. 
                # If parameter is ‘@’ or ‘*’, the operation is applied to each positional parameter in turn, and the expansion is the resultant list. If parameter is an array variable subscripted with ‘@’ or ‘*’, the operation is applied to each member of the array in turn, and the expansion is the resultant list. 
                    # E.g., 
                    foo=' bar baz '
                    ${foo@Q}  #=> ' bar baz'
                    ${foo@A}  #=> foo=' bar baz '

    # PATHNAME EXPANSION [GLOBBING] 
    #  "Glob" - a set of GNU/shell-specific features that match or expand specific types of patterns. 
    #  a.k.a. Wildcards, Pattern Matching, Pattern Expansion, Filename Expansion, ...
    #  http://tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm
    #  http://mywiki.wooledge.org/glob  
    #  https://en.wikipedia.org/wiki/Glob_(programming)#Unix


        # TILDE EXPANSION 	http://wiki.bash-hackers.org/syntax/expansion/tilde
        ~          # expands to the home-directory of the current user
        ~USERNAME  # expands to $HOME directory of the user
        ~+         # expands to $PWD value; CWD [currect working directory]
        ~-         # expands to $OLDPWD ; PREVIOUS WORKING DIRECTORY, or literal if none
        # e.g. ...
            PATH=~/mybins:~peter/mybins:$PATH

        *             # Matches any string, of any length
        *x*           # Matches any string containing x; beginning OR middle OR end
        *.[ch]        # Matches any string ending containing .c OR .h
        foo?          # Matches foot OR foo$ but NOT fools 
        [abcd]        # Matches a OR b OR c OR d
        [a-d]         # same as above if C OR POSIX
        [!aeIU]       # Matches any character except a, e, I, U
        [[:alnum:]]   # Matches any alphanumeric char
        [[:space:]]   # Matches any whitespace character
        [![:space:]]  # Matches any character that is NOT whitespace
        [[:digit:]_.] # Matches any digit, OR _ OR .

        "foo."*[!'.bar']  # Matches any foo.* except '.bar'

        # Ex. print $1 if integer else nul ...
        [[ ( "$1" != *[!0-9]* ) && "$1" ]] && printf "$1"
        # ... equiv [sans globbing] ...
        [[ -z "${1//[0-9]}" ]] && printf "$1"

        shopt -s nocaseglob  # Case-insensitive 

        shopt -s extglob     # Extended Globs : adds Regular Expression [RegEx] support
        # EXTGLOB
            ?(PATTERN-LIST)  # Matches zero or one occurrence of the given patterns. 
            *(PATTERN-LIST)  # Matches zero or more occurrences of the given patterns. 
            +(PATTERN-LIST)  # Matches one or more occurrences of the given patterns. 
            @(PATTERN-LIST)  # Matches one of the given patterns. 
            !(PATTERN-LIST)  # Matches anything except one of the given patterns. 

            # To remove ALL files in folder except *.jpg and *.gif and *.png:
            rm !(*.jpg|*.gif|*.png)

            # To TRIM leading and trailing WHITESPACE from a variable
            x=${x##+([[:space:]])}; x=${x%%+([[:space:]])} 
            # I.e., ${x} => ${x##}

            # To copy all the MP3 songs except one to your device
            cp !(04*).mp3 /mnt

# QUOTING AND ESCAPING  http://wiki.bash-hackers.org/syntax/quoting
    foo=bar
    echo $foo    # => bar
    echo \$foo   # => $foo  {PER-CHARACTER ESCAPING; backslash}
    echo '$foo'  # => $foo  {STRONG QUOTING; single-quotes; NOTHING interpreted}
    echo "$foo"  # => bar   {WEAK QUOTING; double-quotes; mostly interpreted}

    # so, what gets passed ...
        "bar baz"   # => bar baz
        'bar baz'   # => bar baz
        '"bar baz"' # => "bar baz"
        "'bar baz'" # => 'bar baz' ; double-quotes turned single-quotes into literal

        "\$foo"     # => $foo
        '$foo'      # => $foo 
        '\$foo'     # => \$foo 

            # Syntax element quotes are NOT same as quotes passed to command line (as text)
            echo \"bar baz\"    * => "bar baz"
            echo \'bar baz\'    # => 'bar baz'

            foo=\"bar baz\"        # => bash: baz": command not found {bash error message}
            foo=\'bar baz\'        # => bash: baz': command not found {bash error message}
            
# echo : options 
    echo -e "Suppress trailing new line \c"
    echo -e " \a\t\tfrom this string\n"

    # read : get/take user input

        # With default 
        read -p "Do the thing? [Y/n]: " q
        q=${q:-Y};echo
        echo "Got: '$q'"

        # Alt, sans default
        echo -n 'Enter a param: '
        read q
        echo -e '\nYou entered "'$q'"\n'

    # quoting; okay to mix
        echo '!%$*&'"$foo"

# printf  http://wiki.bash-hackers.org/commands/builtin/printf
#         http://linuxconfig.org/bash-printf-syntax-basics-with-examples
    printf 
    printf "string"         # prints string; NO newline
    printf "%s\n" "$STR"    # prints string followed by newline
    printf "%30.40s" "$STR" # MIN.MAX width
    printf "%-22s"          # left-justify
    printf "%b" "\x23\n"    # prints ASCII char of hex '23', '#', followed by newline
    printf "%b" "\041\n"    # prints ASCII char of octal '041', '!', followed by newline
    printf "%s\t%s\n" "1" "2 3" "4" "5" 
    1       2 3
    4       5
    printf "-%MIN.MAXs"     # left-justified, "-", min.max collumn width; for fixed width, e.g., 30.30
    
    # ASCII http://www.ascii-code.com/  0-255  {oct[000-377]}  
        printf "\041"   # => !
        printf '\041'   # => !
        printf '\u0021' # => !
        printf '\033c'  # => <clear screen>

# ANSI C Quoting; another bash quoting mechanism
    # http://www.gnu.org/software/bash/manual/bashref.html#ANSI_002dC-Quoting
    # ASCII http://www.ascii-code.com/ 	0-255	{oct[000-377]}  
    $'<ANSIcode>' #  http://www.ascii-code.com/

    # ANSICode   Meaning
    # --------   ------------
        \"         double-quote
        \'         single-quote
        \\         backslash
        \a         terminal alert character (bell); (ASCII code 7 decimal)
        \b         backspace
        \e         escape (ASCII 033)
        \E         escape (ASCII 033) \E is non-standard
        \f         form feed
        \n         newline
        \r         carriage return
        \t         horizontal tab
        \v         vertical tab
        \?         ?
        
        \cA        <CTRL>-A ; e.g., $'\cZ' prints  control sequence: Ctrl-Z (^Z)

        \nnn       ANSI octal code; control-chars (000-037), and printable (040-177)
        \0nnn      ANSI octal code; control-chars (000-037), and printable (040-177)
        
        \xHH       ANSI 2-digit hex code
        \xHHH      ANSI 3-digit hex code
        \uXXXX     ANSI 4-digit hex code
        \UXXXXXXXX ANSI 8-digit hex code
    
        echo $'\041'    # => !
        echo $'\x21'    # => !
        
# Unicode / UTF-8  http://www.utf8-chartable.de/

    # U+2627 = e2 98 a7 = ☧  CHI RHO
        echo $'\u2627'          # => ☧
        echo -e "\xE2\x98\xA7"  # => ☧  

# COMPOUND COMMANDS [BUILT-IN STUCTURES] https://www.gnu.org/software/bash/manual/bashref.html#Compound-Commands

    # Looping Constructs 

        until test-commands; do consequent-commands; done
        
        while test-commands; do consequent-commands; done
        
        for name [ [in [words …] ] ; ] do commands; done
        # for (( initial; cond; incr)) ... a.k.a. C-style for-loop
        for (( expr1 ; expr2 ; expr3 )) ; do commands ; done # expr[#] are ARITHMATIC 
        # 1 is init; 2 evaluate til 0; expr3 evaluated if expr2 is not 0
        for (( i = 0 ; i <= 8; i+=1 ))  ; do commands ; done
        for i in {1..6..2} ; do commands ; done       # 1 3 5
        for i in $(seq 1 2 $_n) ; do commands ; done  # 0 3 5 ... $_n
        
            ... ; do ... break     # end looping
            ... ; do ... continue  # skip this loop

        # E.g., repeat 100 times, SLEEP 3s between iterations
        for i in {1..100};do sleep 3;printf "%02d\n" $i;done

    # Conditional Constructs 

        # if then fi
        if condition1; then { commands; } fi

        # if then elif else fi
        if test-commands; then
          consequent-commands;
        elif more-test-commands; then
          more-consequents;
        else alternate-consequents;
        fi

        # case in esac
        case word in [ [(] pattern [| pattern]…) command-list ;;]… esac
        
        select name [in words …]; do commands; done
        
        (( expression )) # $? : returns 0 if NON-zero, else returns 1
        
        [[ expression ]] # $? : returns 0 if true; else returns 1

    # EXAMPLEs 
        
        # case
        case $var in
            "name1") commands;;
            a | b  ) commands;;      # a or b
            "name3") commands;;
            [4-9]|1[0-7]) commands;; # 4 - 17
            *) default-commands;;
        esac 

        # select
        select name [in words …]; do commands; done

        select fname in *; # enumerates all files and dirs @ PWD
        do
            echo you picked $fname \($REPLY\)
            break;
        done
        
        select fname in foo "bar none" baz;
        do
            echo you picked $fname \($REPLY\)
            break;
        done

        # for var-name in list
        for varname in 'item1' "$item2" 'item 3' ; do commands; done
        for param in foo bar baz ; do [[ $1 == $param ]] && echo $1 ; done
        for i in $(seq -f "%02g" 0 59)  ; do commands ; done
        # for all '.7z' in in $PWD, using glob [safe given whitespaces]
        for f in *'.7z'; do { echo "$f" ; } done

        # REPLACE `for` loop with PIPELINE per `xargs`
            # if all args on one line, e.g.,  
            seq -s ' ' 3 \
            | xargs -d ' ' -I {} printf "  [%s]" "{}"
            # => [1]  [2]  [3]

            # if one arg per line, e.g.,  
            seq 3 \
            | xargs -I {} printf "  [%s]" "{}"
            # => [1]  [2]  [3]

                # NOTE: may not need `-d` and/or `-I` options, 
                #  depending on the function accepting xargs

        # monitor if user $1 logged in; send email to root on login
            until users | grep $1 > /dev/null 
            do; sleep 15; done 
            mail -s "$1 just logged in" root < . 

    # monitor process $1; show/stream its `ps` status @ tty11; write to syslog on stop
      while ps aux | grep $1 | grep -v grep | grep -v bash > /dev/tty11 
      do; sleep 1; done 
      logger $1 has stopped.  # send to syslog; `/var/log/messages`

        # parse options [args] per `getopts`, such as '-x', passed to the script 
            while getopts ":mnopq:rs" Option
            do
                case $Option in
                m     ) echo "option -m-   [OPTIND=${OPTIND}]";;
                n | o ) echo "option -$Option-   [OPTIND=${OPTIND}]";;
                p     ) echo "option -p-   [OPTIND=${OPTIND}]";;
                q     ) echo "option -q- with argument \"$OPTARG\"   [OPTIND=${OPTIND}]";;
                #  Note that option 'q' must have an associated argument,
                #+ otherwise it falls through to the default.
                r | s ) echo "Scenario #5: option -$Option-";;
                *     ) echo "Unimplemented option chosen.";;   # Default.
                esac
            done
            shift $(($OPTIND - 1)) # decrement argument pointer, so now $1 is next 
            
        # reads a line of input from stdin and stores the result in var
        # line must be terminated by newline, end of file, or error condition 
        IFS= read -r var  # http://www.etalabs.net/sh_tricks.html
        
        # "while read" to read & process input, like a file, line by line ...

        # read from input like a file, per Here String [$*]
        while IFS='' read line
        do
            echo "$line"
        done <<< "${*}" # Here String syntax

        # if no varname given, then bash sets varname ...
        echo "$REPLY"
        
        # ... into ARRAY [NOTE NO 'IFS=']
        while read -a tokens
        do
            echo "${tokens[@]}"
        done <<< "${*}" # Here String syntax

        # read from multiline VAR, per Here String [bash/ksh/zsh] of a Command Substitution
        while read line
        do
            echo "$line"
        done <<< "$var" # e.g., var=$( find . ... ); list of paths

        # read & process a multiline VAR, into an ARRAY
        while IFS='' read -a tokens
        do 
            echo "${tokens[0]}  ${tokens[1]}"
        done <<< "$var"

        # read multi-line VAR, per Pipe ...
        printf "%s\n" "$var" | while IFS='' read -r line
        do
            echo "$line"
        done

        # read multi-line VAR, per Process Substitution [NOT well supported by POSIX]
        while IFS='' read -r line
        do
            echo "$line"
        done < <(jobs)

        # read & process a FILE, line by line, per Redirect [POSIX compliant] ...
        while IFS='' read -r line || [[ -n "$line" ]] # needed here to handle if last-line is NOT newline
        do
            echo "$line"
        done < "$file"
        
        # read & process a FILE, line by line, per Pipe and Command Subsitution of Redirect ...
        # HOWEVER, NO vars set inside loop are available outside loop
        printf "%s\n" "$( <"$file" )" | while IFS= read -r line
        do
            echo "$line"
        done
        
        # SIMPLER; same as above, but piping "cat" command ; 
        cat "$file" | while IFS='' read -r line || [[ -n "$line" ]]
        do
            echo "$line"
        done

        # accept args by EITHER stdin or pipeline
        [[ "$1" ]] && {
            command "$1"            # by stdin 
        } || {
            while read -r -t 1 piped  
            do 
                command "$piped"    # by pipeline
            done
        }
        
        # BETTER : test if FD 0 (STDIN) is open 
        [[ -t 0 ]] && {
            command "$@"            # by stdin
        } || { 
            xargs -I {} command {}  # by pipeline; this example expects newline delimiter
        }
        

# COPROCESS [executes asynchronously in sub-shell]
# https://www.gnu.org/software/bash/manual/bashref.html#Coprocesses
# http://unix.stackexchange.com/questions/86270/how-do-you-use-the-command-coproc-in-bash
    coproc [NAME] command [redirections] 
    # similar to 'command &', background execution, 
    #+ but with two-way pipe established btwn coprocess & current, executing shell

    # default name/syntax if coprocess is unnamed; handles only 1 coprocess per shell
        echo xxx >&"${COPROC[1]}" # Feed data to co-process
        read var <&"${COPROC[0]}" # Read data from co-process
    # naming coprocesses allows for more than one at at time
        echo xxx >&"${Cofoo[1]}" # Feed data to 'Cofoo' co-process
        read var <&"${Cofoo[0]}" # Read data from 'Cofoo' co-process
        

# GNU Parallel
# https://www.gnu.org/software/bash/manual/bashref.html#GNU-Parallel
# can replace xargs or feed commands from its input sources to several different instances of Bash. 
    # replace xargs to gzip all html files in the current directory and its subdirectories
    find . -type f -name '*.html' -print | parallel gzip

# m4 : Macro Processor ; str delimited w/ `str' (backtick @start & apostrophe @end)
# http://en.wikipedia.org/wiki/M4_%28computer_language%29
    m4 

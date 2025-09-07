#!/usr/bin/env bash
# ---------------------------------------------------------
#  shell scripting reference
#
#  https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
#  http://www.gnu.org/software/bash/manual/bashref.html
#  http://wiki.bash-hackers.org/start
#  http://ss64.com/bash/
#  http://tldp.org/LDP/abs/html/index.html
#
#  >>>  DO NOT EXECUTE  <<<
# ---------------------------------------------------------
exit

# SCRIPTING
    # Shebang variations ...
        #!/usr/bin/env bash     # Per-user default binary. (Some systems have no /bin/bash binary.)
        #!/usr/bin/bash         # Explicity set the binary.

    /bin/bash                               # Launch subshell
    /bin/bash "cmd1 && cmd2 $a1;cmd3"       # Execute Bash command(s) at subshell
    /bin/bash -c "cmd1 a1 a2 a3"            # cmd1 becomes $0, a1 becomes $1, ...
    cat script.sh |/bin/bash -s - a1 a2     # Execute `script.sh a1 a2` : -s flag to accept pipe, redirect, or HEREDOC

	# Similar, using HEREDOC syntax : Quote delimiter (EOH) to prevent pre-pipe expansion.
	cat <<-'EOH' |/bin/bash -s - a1 a2
	echo "[$1] [$2]"
	EOH

    # REMOTEly execute LOCAL script through a secure shell, injecting both local and remote environments
    # Useful for remote (SSH) admin without pushing script(s) to target(s):
    cat script.sh |ssh -T /bin/bash -s - a1 a2

    # Similar, using REDIRECT syntax, BUT MAY ERR by "ambiguous rediect", i.e., script vs. positional param(s)
    /bin/bash -s < script.sh $arg1 $arg2

    /bin/bash -x script.sh arg1 arg2        # Debug mode.
    /bin/bash -v ...                        # Debug; print script lines as they are read.

    # rbash : RESTRICTED SHELL; forbid dir change, redirects, ...; see `man rbash`
    /bin/rbash
    /bin/bash -r

    # METACHARACTER : Any character that separates words :
        # ' ', '\t', '\n', '|', '&', ';', '(', ')', '<', or '>'.

    # BUILTIN : A command implemented internally by the shell itself,
        # rather than by an executable binary file.
        # Shell Builtin Commands  https://www.gnu.org/software/bash/manual/html_node/Shell-Builtin-Commands.html#Shell-Builtin-Commands
        # Bash Shell Builtins
            # : . break cd continue eval exec exit export getopts hash pwd readonly return shift
            # test [ ! () times trap umask unset
            # man test (1)  https://linux.die.net/man/1/test
        # Special Builtin; shell builtin command classified as special by the POSIX standard
            # : . break continue eval exec exit export readonly return set
            # set : Builtin : Modify Shell Behavior
            # https://www.gnu.org/software/bash/manual/html_node/Modifying-Shell-Behavior.html
            set [-abefhkmnptuvxBCEHPT] [-o option-name] [--] [-] [argument …] # Set option-name   (-)
            set [+abefhkmnptuvxBCEHPT] [+o option-name] [--] [-] [argument …] # UNset ootion-name (+)

            set -e          # Exit on fail; on non-zero exit ($?) of command or pipe
                            #... WARNing: This command : "ls /foo/bar || echo NOT EXIST" would trigger exit from script.
            set -a          # Export all
            set +a          # End export all
            set +o posix    # Abide non-POSIX syntax.

        # This combination is commonly used in CI/CD pipelines, production scripts,
            # or any environment where reliability and transparency are critical.
            # It forces scripts to fail fast, exposes issues clearly,
            # and helps developers debug problems efficiently.
            set -uo pipefail # Enable strict error handling and debugging

                -e  # Exits the script immediately if any command fails (non-zero exit status)
                    #... WARNing: This command : "ls /foo/bar || echo NOT EXIST" would trigger exit from script.
                -u  # Treat unset variables as errors and exit the script.
                -x  # Verbose; print each command and its arguments to the terminal before execution
                -o pipefail # Ensures that a pipeline fails if any command in the pipeline fails.

        # Bash Builtins : May VARY per DISTRO (allowable options, syntax, ...)
            # alias bind builtin caller command declare echo enable help let local logout mapfile
            # printf read readarray source type typeset ulimit unalias
            alias gl='git log --oneline'   # Alias
        # Bash user-defined functions
            aFunc(){ echo "aFunc body"; }  # Function definition

    # Export per ...
    export foo bar               # Export VARIABLE(s) into shell Env.
    export -f [name[=value] ...] # Export FUNCTION(s) into shell Env.
    export -n [name[=value] ...] # Remove variable OR function from Environment; Un-export
    export -p    # list all exported variables.
    export -f    # list all exported functions.
    export       # list all Env. Vars.

    # EXIT CODEs : 0-255; 126-255 Reserved
        1       # general errors
        2       # misuse of shell builtins (according to Bash documentation)
        126     # command invoked cannot execute
        127     # command (binary) not found
        128     # invalid argument to exit, e.g., exit 333
        128+n   # fatal error signal "n"
        130     # script terminated by Control-C
        255     # exit status out of range (See code 128)

    # CTRL+C == terminate script
    # CTRL+D == exit shell

# FUNCTIONs : Name must start with a letter (of either case).
    name { command-list; }           # sh
    name () { command-list; }        # C syntax is more portable; most spaces and all newlines are optional.
    function name { command-list; }  # Alternate syntax.

    # @ Subshell : isolated environment
        name () {( command-list; )} # no need for 'local VAR' : is POSIX portable

    # Bash FORK BOMB (AKA rabbit virus AKA wabbit), where ":" is just the function name
        :(){ :|:& };:  # f(){f|f&};f
         # So, the function calls itself, piping to itself,
         # recursively spawning bkgnd processes, DEPLETING available RESOURCES; CRASHING the SYSTEM.

# GROUPING commands in a subshell
    (LIST)      # subshell; includes non-exported vars of parent; operators "(", ")"
    { LIST; }   # not sub-shell; spaces required; reserved words "{", "}"

# BACKGROUND PROCESS
    /bin/bash $_CMD_or_SCRIPT &
    # Sans stdOUT and stdERR
    /bin/bash -c "$_CMD_or_SCRIPT arg1 arg2" >/dev/null 2>&1 &
    # Alternative, but quirky; shell-specific behavior:
    nohup $_CMD_or_SCRIPT arg1 arg2 & # Ignore HANGUP signal(s) (SIGHUP)
    #... + multiple commands (in bkgnd process), and sans any output to anywhere:
    nohup /bin/bash -c "sleep 30 && $_CMD_or_SCRIPT arg1 arg2 &" >/dev/null 2>&1

# PROCESS SUBSTITUTION (PS) Operators
    # Allows input or output to be referred to using a filename
    ## >>>  NOT POSIX compliant; NOT available at sh
    ##      Requires support of Named Pipes
    # https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Process-Substitution
    # https://tldp.org/LDP/abs/html/process-sub.html
    # http://wiki.bash-hackers.org/syntax/expansion/proc_subst
    # https://ss64.com/bash/syntax-redirection.html
    set +o posix # Bash shell MUST be configured to abide non-POSIX syntax.

    # stdOUT of command1 redirected to command2 as FILE-like object (path).
    command2 <(command1)  # command2 takes FILE (arg), i.e., path; connects per /dev/fd/#
        # E.g., source the bash-completion script generated by the kubectl statement.
        source <(kubectl completion bash)

    # STDOUT of command1 to STDIN of command2 as with a pipe.
    command1 >(command2)  # command2 takes STDIN (arg); useful to AVOID SUBSHELL of pipe

    # REDIRECT of PROCESS SUBSITITION:
        # STDOUT of command1 redirected to STDIN of command2
        # This is NOT POSIX compliant;
        # requires `set +o posix` (bash setting) else fails.
        command2 < <(command1)
            # E.g.,
            while read i
            do
                echo $i
            done < <( echo "this string" )
            #> this string

# PIPEs : FIFO (Named pipe) : POSIX compliant ALTERNATIVE to PS : See man fifo(7), pipe(7)
    # Unidirectional IPC channel (a per-shell byte stream) that has a write end and a read end.
    mkfifo pipe1       # Make FILE of zero bytes; a FIFO (first-in first-out special file)
    command1 > pipe1 & # WRITE to it in a BKGRND PROCESS (blocks only until other end is opened)
    ## Read statement is BLOCKed until data is available:
    command2 < pipe1   # READ from it
    command3 < pipe1   # READ from it concurrently by other process(es) if write is at background process.
    rm pipe1           # Delete afterwards

    # Example : Null byte in stdOUT of wsl.exe, but want to grep (filter) that.
    # This scheme handles that sans persistent bash warning otherwise.
    mkfifo p1
    wsl.exe -l -v >p1 &
    [[ $(cat <p1 |tr -d '\000' |grep ${_OS} |awk '{print $NF}' |grep 2) ]] && {
        # Only if at WSL 2 terminal
        export DISPLAY=$(grep nameserver /etc/resolv.conf |awk '{print $2}' |head -n 1):0.0
    }
    rm p1

# COMMAND SUBSTITUTION; subshell (ephemeral; same SHLVL)
    $(command1)     # preferred
    `command1`      # equivalent; legacy sytax
    # Subshell is not interpereted at current shell; do not escape quotes lest nested thereunder:
    echo "$(echo "shell level: $SHLVL")" # SHLVL of the "subshell" is that of current shell.

    # Show PARENT ($$) v. CURRENT ($BASHPID) PROCESS :
    echo $$-$BASHPID                # 17-17   (no subshell)
    ( echo $$-$BASHPID )            # 17-7391 (subshell)
    echo $( echo $$-$BASHPID )      # 17-7395 (subshell)

    $( (command1) ) # RIGHT @ command substitution
    $((command1))   # WRONG @ command substitution (collides w/ Arithmetic-Subsitution syntax)

    # FILE to STDIN (string) per REDIRECT @ subshell
     $(<FILE) # Faster than $(cat FILE)

# ARITHMETIC SUBSTITUTION
    $(( expr1 ))

# CONDITIONAL EXPRESSION / TEST CONSTRUCT http://tldp.org/LDP/abs/html/testconstructs.html
    [ expr1 ]    # INTEGER/STR/FILE/ : '[' is builtin command
    [[ expr1 ]]  # INTEGER/STR/FILE/ : '[[' is keyword (extended test); bash >= 2.02
    (( expr1 ))  # ARITHMETIC
    #... man test (1) https://linux.die.net/man/1/test

    [[ -v $any ]]  && echo "Variable is SET"
    [[ $var ]]     && echo 'True'  || echo 'False' # Zero-character string is False.
    (( $? ))       && echo 'Error' || echo 'Okay'
    (( $a - $b ))  && echo 'Not 0' || echo 'Zero'
    #... Error-code ($?) semantics of ARITHMETIC test is INVERTED:
    # "Okay" (0) is "False" case; "Error" (non-zero) is "True" case.

    # ARITHMETIC EXPANSION & EVALUATION  http://tldp.org/LDP/abs/html/dblparens.html
        (( $a == $b )) && echo T || echo F # True if equal
        (( $a <= $b )) && echo T || echo F # True if a <= b

    # STRING COMPARISONS http://tldp.org/LDP/abs/html/comparison-ops.html#ICOMPARISON1
        [[ "$a" < "$b" ]]  # less than in ASCII alphabetical order (lexicographically)
        [ "$a" \< "$b" ]   # less than in ASCII alphabetical order (lexicographically)

        [[ -z $str ]] && echo "String length is ZERO"
        [[ -n $str ]] && echo "String length is NOT zero"

    # MIXED EXPRESSION & EVALUATION ( Arithmetic & String )
        [[ (( $? > 0 )) || "$1" == "x" ]]
        [[   $? -gt 0   || "$1" == "x" ]]  # Equiv; alpine linux

    # CONDITIONAL EXPRESSION OPERATORS : used inside "[[ ]]" (Conditional Expression)
        (expr1)          # Return value of expression
        ! expr1          # NOT
        expr1 && expr2   # AND
        expr1 || expr2   # OR

        # E.g., silence all stdOUT; inform on error
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
        $str          # str NOT nul
        -n $str       # str length NOT 0
        -z $str       # str length is 0
        str1  = str2  # strings are equal
        str1 == str2  # strings are equal
        str1 != str2  # strings are NOT equal

    # REGULAR EXPRESSION [RegEx] @ test, [[...]]
        # https://en.wikipedia.org/wiki/Regular_expression
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

        # MATCHING OPERATOR, '=~'
            [[ "$zipCode" =~ ^[0-9]{5}$ ]]  # True IIF $zipCode is any five digits.
            [[ "$PATH" =~ "$path" ]]        # True IIF $PATH has $path.

        # CASE option : nocasematch : See man bash : /shopt
            shopt -s nocasematch  # Enable  : Tests are case-INSENSITIVE
            shopt -u nocasematch  # Disable : Tests are case-SENSITIVE

# ARRAYs  http://wiki.bash-hackers.org/syntax/arrays
    ARRAY=()            # declare INDEXED array; initialize to empty [for existing array too]
    ARRAY[N]=VALUE      # set Nth el of INDEXED array.
    ARRAY=(E0 E1 …)     # set elements of INDEXED array

    ARRAY[STRING]=VALUE # set element of ASSOCIATIVE array
    ${ARRAY[N]}         # access Nth value
    ${ARRAY[@]}         # access value of all indices; keys if assoc. array.

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
        f(){ echo "x: $1"; }; export -f f
        ARRAY=('foo' 'bar')

        # @ Values
        for i in "${ARRAY[@]}"; do; f "$i"; done
        #=> x: foo
        #=> x: bar

        # @ Indices
        for i in "${!ARRAY[@]}"; do; f "$i"; done
        #=> x: 0
        #=> x: 1

    # ITERATE over N (+stateful)
        N=4;export count=0;for i in $(seq $N); do
            ((count++))
            (( $count != 2 )) && echo "@ $i"
        done

# FILE DESCRIPTOR (FD); a number which refers to an open file.
    #  Each process has its own private set of FDs
    #  FDs are inherited by child processes from the parent process.
    #  Every process should inherit 3 open FDs from its parent:
    #    0 ("standard INPUT"), open for reading
    #    1 ("standard OUTPUT")
    #    2 ("standard ERROR"), open for writing

# FILE TEST OPERATORS http://tldp.org/LDP/abs/html/fto.html
    # FILE TYPE EXPRESSION; True if ...
        # http://mywiki.wooledge.org/BashGuide/TestsAndConditionals
        -b FILE   # file is a BLOCK DEVICE [HDD, SDD, CD-drive]
        -c FILE   # file is a CHARACTER DEVICE [keyboard, modem, soundcard]
        -d FILE   # file is a DIRECTORY (folder).
        -e FILE   # file EXISTS.
        -f FILE   # file is a regular FILE [NOT a dir].
        -r FILE   # file is READABLE by user.
        -s FILE   # file SIZE > 0 ; exists and is not empty.
        -t FD     # FD is OPEN : stdin (FD=0), stdOUT (FD=1), stdERR (FD=2)

    # PIPEd args test
    [[ -t 0 ]] && echo 'NOT PIPEd (FD 0 is open)' || echo 'PIPEd'

        # to process piped input ...
        [[ ! -t 0 ]] && xargs -I {} COMMAND {}

    # other examples of '-t FD' usage
    [[ -t 1 ]] && echo 'FD 1 open - stdout'
    [[ -t 2 ]] && echo 'FD 2 open - stderr'

    -w FILE 	# file is writable by you.
    -x FILE 	# file is executable by you.
    file1 -nt file2 # file1 is newer than file2.
    file1 -ot file2 # file1 is older than file2.

# LISTs; a sequence of one or more pipelines separated by one of the operators
    # ‘;’, ‘&’, ‘&&’, or ‘||’, and optionally terminated by one of ‘;’, ‘&’, or a newline.
    # https://www.gnu.org/software/bash/manual/bashref.html#Lists

    command1 &               # Run command in background process [subshell]
    command1 ; command2      # Run command1 and then command2
    command1 && command2     # Run command2 only if command1 is successful
    command1 || command2     # Run command2 only if command1 is NOT successful

# PIPELINES & REDIRECTION Operators
    ##  When referring to COMMANDs, the redirect is called PIPE
    ##  When referring to FILEs, the redirect is called REDIRECT.

    ## PIPELINE syntax ... if 'time', show runtime stats, if -p, format time per ...
        ## https://www.gnu.org/software/bash/manual/bashref.html#Pipelines

        [time [-p]] [!] command1 [ | or |& command2 ] …

        command1 | command2      # Redirect stdOUT of command1 to STDIN of command2
        command1 |& command2     # Redirect both stdOUT and stdERR of command1 to STDIN of command2
        command1 2>&1 | command2 # ... same as above, which is shorthand for this at bash 4+ .

        # Redirect stdOUT of command1 to FILE AND to command2
        command1 | tee FILE | command2

        # Redirect stdOUT of command1 to MULTIPLE commands (FANOUT)
        command1 | ( command2;command3; ... )

        # Redirect stdOUT of MULTIPLE commands to commandX (FANIN)
        ( command1;command2; ... ) | commandX
        ( command1;command2; ... ) |xargs ... commandX
        #... Depending upon commandX expectations.

        # Whitespace is optional with pipes:
        command1|command2 # Okay.

        # &&, || : Conditional Execution
        command1 && comamnd2 || command3
        # SIMILAR to an if-then-else structure,
        # HOWEVER, exit code of command2 matters;
        # command3 executes if command1 has no error (exit 0) but command2 has error.
        # So, to implement an if-then-else requires:
        command1 && { command2;true; } || command3

    ## REDIRECTION : stdin (0), stdOUT (1), stdERR (2), i.e., NAME (FD)
        # https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirections
        # http://ss64.com/bash/syntax-redirection.html
        # http://wiki.bash-hackers.org/howto/redirection_tutorial
        # FILE DESCRIPTORs (FD) : in redirects, bash handles several FILEs specially:
            /dev/fd/n    # FD 'n' is duplicated. [@ bash, n =< 9]
            /dev/stdin   # FD 0 is duplicated.
            /dev/stdout  # FD 1 is duplicated.
            /dev/stderr  # FD 2 is duplicated.
            /dev/tcp/host/port # open the corresponding TCP socket.
            /dev/udp/host/port # open the corresponding UDP socket.

        # DUPLICATING FDs (FILE references path to a file)

            COMMAND [n]<&FILE # redirection operator; FILE is copied to stdin [or FD n].

            COMMAND [n]>&FILE # redirection operator; stdOUT [or FD n] is COPIED to FILE.

        # MOVING FDs

            COMMAND [n]<&$fd- # moves FD $fd (single digit) to FD stdin [or FD n]

            COMMAND [n]>&$fd- # moves FD $fd (single digit) to FD stdOUT [or FD n]

        # OPENING FDs for Reading and Writing

            COMMAND [n]<>FILE # redirection operator; FILE is opened for both reading and writing on stdin [or FD n]; FILE is create if not exist.

            # Redirect output of command1 :
            command1 < FILE      # Redirect FILE to stdin
            command1 > FILE      # Redirect stdOUT to FILE
            command1 2> FILE     # Redirect stdERR to FILE
            command1 > FILE 2>&1 # Redirect all out to FILE
            command1 2>&1        # Redirect all out to stdOUT
            command1 1>&2        # Redirect all out to stdERR
            command1  >&2        # Redirect stdOUT to stdERR
            command1 > /dev/null      # Discard stdOUT
            command1 2> /dev/null     # Discard stdERR
            command1 > /dev/null 2>&1 # Discard sdtOUT and sdtERR

            # REMOTEly run LOCAL script and args (environment) through a secure shell
            ssh ... "/bin/bash -s" < /any/local/path/script.sh $arg1 $arg2

        # HEREDOC : HERE DOCUMENT; redirect [MULTI-LINE] WORD to stdin of COMMAND as if a FILE (DOC); instructs shell to read input from the current source (all text that follows) until a line containing only WORD (the delimiting identifer, with no trailing blanks) is seen. All of the lines read up to that point are then used as the COMMAND's stdin or other FD (n) if specified.  https://en.wikipedia.org/wiki/Here_document

		COMMAND [n]<<-WORD   # Disable leading TABs with ` <<-WORD `
			here-document line1
			here-document line2 ...
		WORD    # Disable expansion (of any var in text str) by quoting the label, e.g., ` << 'EOH' `

        # EXAMPLES BELOW : Indentation (tabs) removed
        # else editor replaces with spaces, confusing code highligter.


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
            printf '%03d\n'  {10..100} # 010\n...100\n
            printf '%s\n'  {c..q} # c\n...q\n
            # Concatenate ripped video files of a sequence into one
            cat VTS_01_{1..8}.VOB > VTS_01_ALL.VOB 

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

            # Remove ALL files in folder except *.jpg and *.gif and *.png:
            rm !(*.jpg|*.gif|*.png)

            # copy all files having declared extension excluding declared pattern.
            cp !(04*).$ext /to/here/

            # TRIM leading and trailing WHITESPACE from string
                # Using extglob
                shopt -s extglob # REQUIREd @ non-interactive (e.g., scripts)
                trim(){ local x="${@##+([[:space:]])}"; x="${x%%+([[:space:]])}"; printf "%s" "$x"; }
                # Using awk : multiple spaces between words are *not* preserved
                trim() { awk '{$1=$1; print}' <<< "$*"; }

                trim '  foo bar ' #> 'foo bar'

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
        #     http://linuxconfig.org/bash-printf-syntax-basics-with-examples
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
        printf '\033c'  # => <clear screen>
        printf '\041'   # => !

    # UNICODE / UTF-8  http://www.utf8-chartable.de/
        # UNICODE (hex) : Bash '\u' and '\U' ESCAPE SEQUENCE RULEs :
            # \u : Exactly 4 hex digits (pads if shorter)
            # - fewer than 4 digits, it pads with zeros to the right
            # - more than 4 digits, it takes the first 4 and treats the rest as literal characters
            # \U : Exactly 8 hex digits (for larger code points)
        # For 1-3 digits: let bash pad with zeros
        printf '\u21'      # → U+0021 = !
        printf '\u3F'      # → U+003F = ?
        printf '\u100'     # → U+0100 = Ā
        # For exactly 4 digits: use as-is
        printf '\u0021'    # → U+0021 = !
        printf '\u00A9'    # → U+00A9 = ©
        printf '\u263A'    # → U+263A = ☺
        # For 5+ digits: use \U with 8 digits
        printf  '\U0001F9EA'    # → U+1F9EA = 🧪
        printf  '\U0001F600'    # → U+1F600 = 😀
            # To use echo instead requires -e or $'...'
            echo   $'\U0001F600'    # → U+1F600 = 😀
            echo -e '\U0001F600'    # → U+1F600 = 😀
        # VARIATION selector → U+FE0F (COLORFUL, if supported)
        printf  '\U26A0\UFE0F'  # ⚠️
        printf '\U1F6E0\UFE0F'  # 🛠️  # U+1F6E0 → \U1F6E0 : 🛠 (wrench emoji)
            # \U is ALWAYS SAFE for all Unicode, so always use that.
            # All these produce the same result: U+0021 = !
            printf '\U21'        # 2 digits → pads to U+00000021 = !
            printf '\U021'       # 3 digits → pads to U+00000021 = !  
            printf '\U0021'      # 4 digits → pads to U+00000021 = !
            printf '\U00021'     # 5 digits → pads to U+00000021 = !
            printf '\U000021'    # 6 digits → pads to U+00000021 = !
            printf '\U0000021'   # 7 digits → pads to U+00000021 = !
            printf '\U00000021'  # 8 digits → exactly U+00000021 = !

    # \xXX : 2-digit Hex Escapes
        # Each \xXX represents ONE BYTE (8 bits) of RAW DATA
        # Purpose: Represent INDIVIDUAL BYTES using HEXADECIMAL VALUES
        # Uses: 
        # - UTF-8 byte sequences
        # - Binary data
        # - Specific byte values
            # UTF-8 byte sequence : Encoding of rune (glyph) "☧" : Unicode code point : U+2627 : "CHI RHO"
            printf '\xE2\x98\xA7'   # As 2-digit hex seq : E2 98 A7 : 3 bytes  : "☧" 
            printf '\xE2\x98\xA7\n' # Equivalent 3 bytes: 0xE2, 0x98, 0xA7 : "☧" 
            printf '\u2627'         # As 4-digit hex : "☧" 

    # ANSI C Quoting; another bash quoting mechanism
        # http://www.gnu.org/software/bash/manual/bashref.html#ANSI_002dC-Quoting
        # ASCII http://www.ascii-code.com/ 	0-255	{oct[000-377]}
        $'<ANSIcode>' #  http://www.ascii-code.com/

        # ANSICode   Meaning
        # --------   ------------
        # \"         double-quote
        # \'         single-quote
        # \\         backslash
        # \a         terminal alert character (bell); (ASCII code 7 decimal)
        # \b         backspace
        # \033       escape (octal)
        # \e         escape (ASCII 033)
        # \E         escape (ASCII 033) \E is non-standard
        # \f         form feed
        # \n         newline
        # \r         carriage return
        # \t         horizontal tab
        # \v         vertical tab
        # \?         ?

        # \cA        <CTRL>-A ; e.g., $'\cZ' prints  control sequence: Ctrl-Z (^Z)

        # \nnn       ANSI octal code; control-chars (000-037), and printable (040-177)

        # \xHH       ANSI 2-digit hex code
        # \xHHH      ANSI 3-digit hex code
        # \uXXXX     ANSI 4-digit hex code (NOT of Unicode context)
        # \UXXXXXXXX ANSI 8-digit hex code (NOT of Unicode context)

        # echo $'\041'    # => !
        # echo $'\x21'    # => !

        # ANSI Escape Codes for Colors
            \033[<CODE>m # Octal
            \e[<CODE>m   # Equivalent

            # Code SEQUENCEs allowed by SEMICOLON delimiter:
            \e[<CODE1>;<CODE2>m
            # E.g., \e[4;30;45mThis text is underlined black on magenta background.\e[0m

            # Text Colors (Foreground):

            #     Black:    30
            #     Red:      31
            #     Green:    32
            #     Yellow:   33
            #     Blue:     34
            #     Magenta:  35
            #     Cyan:     36
            #     White:    37

            # Background Colors

            #     Black:    40
            #     Red:      41
            #     Green:    42
            #     Yellow:   43
            #     Blue:     44
            #     Magenta:  45
            #     Cyan:     46
            #     White:    47

            # Text Styles

            #     Reset:     0 (resets everything back to default)
            #     Bold:      1
            #     Underline: 4
            #     Reversed:  7 (swaps foreground and background colors)

            # Example:
            echo -e '\e[1;31mThis text is bold red!\e[0m'   # Interperet backslash escapes
            echo $'\e[1;31mThis text is bold red!\e[0m'     # Equivalent

            # Color output
            printf '\e[31mRed Text\e[0m\n'
            printf '\u001b[32mGreen Text\u001b[0m\n'

            # Cursor movement
            printf '\e[2J'          # Clear screen
            printf '\e[1;1H'        # Move to top-left

(
# COMPOUND COMMANDS [BUILT-IN STUCTURES]
    # https://www.gnu.org/software/bash/manual/bashref.html#Compound-Commands

    # LOOPING constructs

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

    # CONDITIONAL constructs

        # if then fi
        if condition1; then { commands; } fi

        # if then elif else fi
        if test-commands; then
          consequent-commands;
        elif more-test-commands; then
          more-consequents;
        else alternate-consequents;
        fi

        (( expression )) # $? : returns 0 if NON-zero, else returns 1

        [[ expression ]] # $? : returns 0 if true; else returns 1

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

        # PIPE to REPLACE a `for` loop
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

    # READ USER INPUT
        # reads a line of input from stdin and stores the result in var
        # line must be terminated by newline, end of file, or error condition
        IFS= read -r var  # http://www.etalabs.net/sh_tricks.html

        # "while read" to read & process input, like a file, line by line ...

        # read from input like a file, per Here String [$*]
        while IFS='' read line
        do
            echo "$line"
        done <<< "${*}" # Here String syntax

            # if no varname given @ `read ...`, then bash sets to REPLY
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
            printf "%s\n" "$var" | \
                while IFS='' read -r line
                do
                    echo "$line"
                done

        # read multi-line VAR by Redirect of Process Substitution to STDIN
            # NOT POSIX; requires `set +o posix`, i.e., "Use other if not POSIX".
            while IFS='' read -r line
            do
                echo "$line"
            done < <(jobs)

        # read & process a FILE, line by line by (POSIX compliant) Redirect ...
            # Use the "|| ..." if last-line is NOT newline
            while IFS='' read -r line || [[ -n "$line" ]]
            do
                echo "$line"
            done < "$file"

        # read & process a FILE, line by line by Pipe and Command Subsitution of Redirect ...
        # HOWEVER, loop is subshell, so no vars set inside are available outside.
            printf "%s\n" "$( <"$file" )" | \
                while IFS= read -r line
                do
                    echo "$line"
                done

        # SIMPLER; same as above, but pipe (STDOUT) to read ...
            cat "$file" | \
                while IFS='' read -r line || [[ -n "$line" ]]
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

        # BETTER : test if FD 0 (stdin) is open
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

    # Default name/syntax if coprocess is unnamed; handles only 1 coprocess per shell
    # Naming coprocesses allows for more than one at at time
        echo xxx >&"${COPROC[1]}" # Feed data to co-process
        read var <&"${COPROC[0]}" # Read data from co-process

    # GNU Parallel
        parallel COMMAND # Use as a sort of xargs replacement
        # https://www.gnu.org/software/bash/manual/bashref.html#GNU-Parallel
        # E.g., gzip all html files in the current directory and its subdirectories
        find . -type f -name '*.html' -print |parallel gzip

# m4 : Macro Processor ; str delimited w/ `str' (backtick @start & apostrophe @end)
    # http://en.wikipedia.org/wiki/M4_%28computer_language%29
    m4

# HEREDOC to FILE : Content between two instances of any delimiter piped to FILE
cat <<-EOH > FILE # EQUIV: cat > FILE <<-EOH
    These contents will be written to FILE. Use of $vars okay. They are expanded.
    The leading TABs (NOT whitespaces) are ignored if hyphen ("-") preceeds delimiter (EOH).
EOH

# HEREDOC to COMMAND INPUT
## Redirect a (multi-line) string as a file (to command that takes a file).
ssh $host /bin/bash -s <<-EOH
echo "=== Local host: $(hostname)"
echo "=== USER @ local machine: $USER"
EOH

## SINGLE-QUOTE the 1st delimiter (EOH) to pass HEREDOC as LITERAL
ssh $host /bin/bash -s <<-'EOH'
echo "=== Remote host: $(hostname)"
echo "=== USER @ remote machine: $USER"
EOH

# HEREDOC + NAMED PIPE
mkfifo # FIFO special file  https://linux.die.net/man/3/mkfifo
## Push any/dynamic/mixed file CONTENT to remote sans file-upload utility.
## 1. Create local file having HEREDOC content redirected through a NAMED PIPE
vi local.file
    #!/usr/bin/env bash
    mkfifo pipe1
    # >>>  PRESERVE TABs of HEREDOC  <<<
	cat <<-EOH > pipe1 &
	# Content
	local_now = $(date -u +"%Y-%m-%dT%H:%M:%SZ")
	remote_runtime = \$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	local = $(hostname)
	remote = \$(hostname)
	EOH
    cat < pipe1
    rm pipe1
## 2. Pipe or redirect locally-processed local.file CONTENT
##    to remote.file using COMMAND SUBSTITUTION
chmod 0755 local.file
ssh $host "echo '$(bash local.file)' |tee remote.file"
## OR
ssh $host "echo '$(bash local.file)' > remote.file"
# Verify
ssh $host cat remote.file
    # # Content
    # now = 2022-03-05T01:52:20Z
    # runtime = $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    # local = XPC
    # remote = $(hostname)

# HERESTR : HERE STRING : a lesser HEREDOC
    # https://www.tldp.org/LDP/abs/html/x17837.html
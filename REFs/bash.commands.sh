#!/usr/bin/env bash
# ---------------------------------------------------------
#  Shell scripting reference
#
#  https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
#  http://www.gnu.org/software/bash/manual/bashref.html
#  http://wiki.bash-hackers.org/start
#  http://ss64.com/bash/
#  http://tldp.org/LDP/abs/html/index.html
#  https://github.com/Idnan/bash-guide      (GitHub)
#
#  Linux Commands
# 
#  http://www.linfo.org/command_index.html
# 
#  >>>  DO NOT EXECUTE  <<<
# ---------------------------------------------------------
exit
# SHEBANG: '#!/usr/bin/env bash' is more portable than '#!/bin/bash'
# The former does NOT rely on a 'bash' binary in the '/etc' folder, 
# but rather uses the first 'bash' binary (executable) found in PATH.
# (NOT ALL PLATFORMS have a 'bash' binary in '/etc'.)

# TERMINAL COMMANDs
    CTRL+C           # terminate currently running process
    CTRL+D           # 'exit'
    CTRL+Z           # PAUSE job and send it to background

    CTRL+L           # clear screen
    CTRL+A           # beginning of line
    CTRL+E           # end of line
    TAB              # autocomplete
    CTRL+R [STRING]  # cycle through previous commands
    ARROW.UP         # previous commands

# HELP per COMMAND/UTILITY
    man CMD          # man page; see man page section below
    CMD -h           # for info/help
    CMD --help       # for info/help
    info CMD         # for more info/help
    CMD -v           # verbose; display what's executing
    CMD --verbose    # verbose; display what's executing

# BOOT PROCEDURE : systemd  >>>  See 'REF.RHEL7.config.sh'
    dmesg  # read boot messages AFTER boot 
 
# VIRTUAL CONSOLEs
    CTRL+ALT F1|F2|F3|... # Open/switch
    # @ CentOS 6 ...
    # console keystrokes   contents 
    # 1   CTRL+ALT+f1   graphical display [GUI]
    # 2   CTRL+ALT+f2   shell prompt
    # 3   CTRL+ALT+f3   install log (messages from installation program)
    # 4   CTRL+ALT+f4   system-related messages
    # 5   CTRL+ALT+f5   other messages

    who # @ bash in tty1|tty4 after log in as root @ tty4
        root     tty4         2017-01-20 13:32
        u1       tty1         2017-01-20 10:44 (:0)
        u1       pts/0        2017-01-20 12:35 (:0.0)
        u1       pts/1        2017-01-20 12:59 (:0.0)

            tty   # native terminal device; hardware|kernel emulated.
            pty   # pseudo terminal device; emulation per userland app, e.g., xterm, screen, ssh
            pts   # pseudo terminal slave
            ?     # background process
    
    winpty  # cmd @ bash; run Windows console programs @ POSIX shell (Cygwin/MSYS/MINGW)
        winpty aws-shell  # run aws-shell app @ MINGW64 (Git-for-Windows) terminal 


# USER : UID GID Groups wheel context ... 
    id # =>
        uid=500(u1) gid=500(u1) groups=500(u1),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

    id -u   UID
    id -un  USERNAME
    id -g   GID
    
    # SUBSTITUTE (SWITCH) USER
        su      # switch user to root;  keep current Env.Vars
        su foo  # switch user to 'foo'; keep current Env.Vars
        
        sudo -E su  # preserve environment (switching to root user)

        # Enable globbing in sudo execution
        # 1. Use subshell
        sudo bash -c 'ls -hl /path/*.yaml'
        # 1. Use find
        sudo find . -name '*.yaml' -exec ls -hl {} \;

        # invoke LOGIN-SHELL : clears all Env.Vars
        su - foo        # login-shell, user 'foo'
        su -l foo       # login-shell, user 'foo'
        su --login foo  # login-shell, user 'foo'
        su -            # login-shell, root user
        # su... switching back to prior-user; use exit, else shell(s) nest
        exit

    # Execute 1 command as another user 
        sudo COMMAND 
        sudo su  # switch user to root

    # reset terminal; fix vim fubar
        reset 
    
    # (re)set tab-stops
        tabs -2 # set to 2 spaces
        tabs -8 # reset to standard

# META COMMANDs 
    more                # show one page
    less                # show file (q to exit)
    whereis COMMAND     # find path
    which COMMAND       # find/validate-exist command
    # HISTORY of executed commands
        history                     # Show history of commands; one per line
        history -c                  # Clear history
        history |awk '{print $2}'   # Sans line numbers
        # HIDE a COMMAND from history
            # @ All commands at current shell
                unset HISTFILE
            # @ One command : type at least one space before the command
                export HISTCONTROL=ignoreboth  # Already set in /etc/profile at most default configurations
                echo "password_hide" |docker login -u duser --password-stdin 
    
    yes  # output a string repeatedly until killed : DEFAULT to 'y'
        yes This string sent TO STDOUT REPEATEDLY UNTIL PROCESS KILLED 
        yes |sudo apt install PKG1 PKG2 ... # Answer 'y' to all user queries.

# TERMINAL TEXT EDITORs (ubiquitous)
    vi[m]       # text editor
    nano        # text editor

# Bash shell Process ID (PID)
    $PPID       # PARENT SHELL PID 
    $BASHPID    # CURRENT SHELL PID

# PARAMETER EXPANSIONs
    $$          # CURRENT SHELL Process ID (PID); NOT that of subshell
    $!          # PID of most recently executed BACKGROUND process; 'COMMAND &'
    $_          # last argument of the most recently executed command.
    $?          # EXIT CODE of the most recently completed foreground command.

    # POSITIONAL PARAMETERS 
    $0             # script path; but it varies per ./script, . script, ...
    $1 … $9       # argument (parameter) list elements 1 - 9
    ${10} … ${N}  # higher # elements require Brace Expansion syntax
    $#             # number of positional parameters that are currently set.

    $*   # => $1 $2 $3 … ${N}   # unquoted, $* == $@  (identical)
    $@   # => $1 $2 $3 … ${N}   # unquoted, $* == $@  (identical)

    "$*" # => "$1c$2c$3c…c${N}"      # quoted; where c is first character of IFS
    "$@" # => "$1" "$2" "$3"…"${N}"  # quoted; preserves parameters !!!

# ENVIRONMENT VARIABLES (useful ones) + Bash Variables
    # http://www.gnu.org/software/bash/manual/bashref.html#Bash-Variables

    PATH
    PWD
    OLDPWD

    HOME=/home/me
    USER
    USERNAME
    UID
    LOGNAME

    FUNCNAME         # Current function name; self
    _:               # The most recent previously executed command.
    IFS=$' \t\n'     # Internal File Separator
    BASHOPTS         # list of options that were used when bash was executed. 
        shopt        # List some bash options
        shopt -o     # List some other bash options and their settings
    BASH_VERSION
    SHELL=/bin/bash
    SHELLOPTS        # Shell options that can be set with the set option.
    
    SHLVL            # Bash shell (nesting) level; unchanged @ per-command subshell
    PPID             # PARENT SHELL PID 
    BASHPID          # CURRENT SHELL PID

    # PS1 : Prompt String 1 : The primary command prompt definition. 
        # chars  http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html
        # colors  https://en.wikipedia.org/wiki/ANSI_escape_code#3/4_bit  
        # Fore: LtGreen:92, Magenta:35, Red:91, Yellow:33, DkGray:90, LtGray:37, Restore:0
        # Back: LtGreen:102, DkGray:100    
        # https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal#558308
        PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ ' # default @ cygwin,mingw64,msys
        PS1=$'\[\e[35m\\]\u2627\\[\e[0m\\] \[\e[92m\]\w\[\e[0m\]  \[\e[90m\\][$SHLVL:$MSYSTEM] [\u@\h] [\\T]\\[\e[0m\\]\n\$ '
        # color-escape-seqence: \[\e[91m\\]__CHAR__\\[\e[0m\\]
        PS2='> '         # Secondary prompts for when a command spans multiple lines.

    # mintty TITLE 
    echo -ne "\e]0;someTitle\a"

    HOSTNAME=lmde
    HOSTTYPE=x86_64
    MACHTYPE=x86_64-pc-linux-gnu
    OSTYPE=linux-gnu

    TERM=xterm
    LINES           # number of lines in the terminal
    XDG_CURRENT_DESKTOP=GNOME

    # TEST if script is SOURCEd
    [[ "$0" != "$BASH_SOURCE" ]] && echo 'SOURCEd' || echo 'NOT'

    # Bash CONFIG files 
    
        # System-wide
            /etc/environment     # per user, per ALL sessions; LOCAL & REMOTE.
            /etc/profile         # per user, per LOGIN session; REMOTE only. 
            /etc/profile.d/*.sh  # per user, per LOGIN session.
            /etc/bash.bashrc     # per user, per ALL sessions; LOCAL only. 
            /etc/bashrc          # per user, per ALL sessions; LOCAL only. 
            
        # User-wide, @ ~/
            .bash_profile        # LOGIN session; REMOTE only, e.g., ssh
            .profile             # LOGIN session; REMOTE only. 
            .bash_login          # LOGIN session; LOCAL & REMOTE.
            .bashrc              # ALL sessions; LOCAL only.

        # NOTEs: 
        .bashrc  # may be several, at several locations; applied per hierarchy ...
            /etc/profile.d/*.sh  # ALL SCRIPTS THEREIN ARE SOURCED upon bash launch
            /etc/.bashrc         # edit as su; available to all users
            $HOME/.bashrc        # edit as user; available to current user
            # ... the nearer to user (conceptually), the higher the precedent

            # So, 
            /etc/profile.d/foo.sh # to CUSTOMISE bash CONFIG for ALL users
            ~/.bashrc             # to CUSTOMISE bash CONFIG for CURRENT user
            
            # E.g., source a protected (755) config script (yet available to all users) 
                echo source /home/u1/etc/foo.cfg > /etc/profile.d/foo.custom.sh

        # run script in CURRENT (shell) process (context), NOT child process 
            source SCRIPT_PATH [ARGs] # per `source` command
            . SCRIPT_PATH [ARGs]      # `.` is equivalent to `source`
           # TEST if running as source 
              [[ $_ != $0 ]] && echo "running as SOURCE" || echo "NOT running as source"
           
            # auto-run function @ script, basename 'somefunc', and 'RETURN' whatever ...
                somefunc() { CODE ... ; _RETURN=VALUE ; CODE ... } # define
                somefunc "$@" > /dev/null 2>&1                     # execute
                printf "%s" "$_RETURN"                             # stdout (if desired)

# PERSISTENT (low resource) PROCESS
    # @ Containers : Override default process (PID 1)
    sleep 1d
    # OR
    tail -f /dev/null
    # Monitor something
    watch COMMAND # Repeately run COMMAND; default once per second.

# SHELL/EXE/SCRIPTs META
    # MAN PAGES; manuals per utility; online @ https://linux.die.net/man/
        man [Section-#] COMMAND    # man page of COMMAND
        man -k STR                 # all man pages containing "STR"
        man -k '^COMMAND'          # all man pages on "COMMAND...", per section number 
            #      Sections 
            1      User Commands
            2      System Calls
            3      C Library Functions
            4      Devices and Special Files
            5      File Formats and Conventions
            6      Games et. al.
            7      Miscellanea
            8      System Administration tools and Daemons
            
        # @ man page, search for "STR" using `/STR` ; quit using `q`

    # Bash Builtin Commands
        # http://www.gnu.org/software/bash/manual/bashref.html#Bash-Builtins
        # FIND a COMMAND ...
            which COMMAND    # command (executable file) path 
            type COMMAND     # command info; show the function, builtin, alias, ...
            type -t COMMAND  # single word or nothing; alias|function|file|builtin|...
            whereis COMMAND  # location, man page 

        set # Bash builtin : options : useful options @ sourced script ...
            set                 # List all Environment Variables
            set -a              # EXPORT ALL     
            set +a              # END export all 
            set -o posix        # Abide only POSIX syntax; suppress funcs on `set`
            set +o posix        # Abide alt syntax if differ from POSIX; 
                                #... required to allow redirect of process substition:
                                #    reader < <(statement)
            # set positional params 
            set -- first second third
                $1 # 'first'
                $3 # 'third'

        export # Export ...
            export -p           # list all exported variables and functions.
            export -f           # list all exported shell functions.
            export -f funcName  # Export a shell function; can be list of names.
            export -n varName   # Un-export varName; remove from environment
            export -nf funcName # Un-export funcName; remove from environment.

        unset # Unset environment ...
            unset varName       # Unset varName; remove from environment
            # unset a (csv) list of var names 
            unset $( printf $_csv |tr "," " " |awk '{ print toupper($0) }' )

        env # Run a program in a modified environment 
            env                 # List all environment variables
            env -u k1           # Unset k1
            env k1=v1 k2=v2 foo # Set env var(s) before running foo
            env –i /bin/bash    # Ignore; run subshell having empty environment.

# Wildcards/Globbing 
    * # anything
    ? # any 1 char 
    ! # not (bang)

# Brace Expansion
    [ac]  # a,c 
    [a-c] # a,b,c
    ?oo.txt # start w/ any one char followed by 'oo.txt'
    [ab]*   # starts w/ 'a' or 'b' 
    [!ab]*  # starts w/ anything but 'a' or 'b' 
    
    # Wildcards ( note that "^" is equivalent to "!" )
    ls -l [pa]*
    ls -l [^n-q]*
    ls -l i?fo*
    # Glob : list full-paths, all in $PWD
    ls -rtd "${PWD}/"*

# PROCESS MANAGEMENT  
    # See 'REF.Linux.SysAdmin.sh' 

# STORAGE : BLOCK DEVICEs
    # See 'REF.RHEL.Storage.sh'  

    mount [-t TYPE] [DEVICE DIRECTORY]       # TYPE (FS); ext3/xfs/ntfs/...
    mount [-t TYPE] [PARTITION MOUNT_POINT]  # device per UUID, not '/dev/...' 

    lsblk -o SIZE,LABEL,NAME,TYPE,FSTYPE,MOUNTPOINT,UUID   # list block devices  

    df -haT DIR  # disks info; include FS type; human readable sizes
    du -hs DIR   # foldersize
    file FILE    # meta info

    # Mount USB (@ WSL)
    sudo mkdir /mnt/g
    sudo mount -t drvfs g: /g

    # Monitor I/O    
        sar # System activity info
            type -t sar || sudo dnf install -y sysstat &&
                sudo systemctl enable --now sysstat
            sudo sar 
        
        iostat # CPU and I/O stats for DEVICEs and PARTITIONs
            iostat -hm # -m for MB else KB 

        iotop # I/O monitor 
            sudo iotop -k  # KB/s, else B/s
            sudo iotop -ko # I/O (actually) only
 
        dstat # System resource stats : vmstat + iostat + ifstat
            dstat -tdD total,sda,sdb,sdc,md1 60

    # IOPS : IOPS / Bandwidth / Throughput 
        fio # See iops-test.sh : https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

        hdparm  # HD Parameters : get/set SATA/IDE device parameters
            # https://man7.org/linux/man-pages/man8/hdparm.8.html
            device=/dev/nvme0n1
            sudo hdparm -t --direct $device # Read speed (MB/sec)

    # COPY BLOCK DEVICES  https://wiki.archlinux.org/index.php/disk_cloning 
        dd  # The only standard command which can safely read EXACTLY ONE BYTE of input
            # with a guarantee that no additional bytes will be buffered and lost.
            # Convert and copy a file (EXACTLY; bit by bit)
        dd if=/dev/$src of=/dev/$dst bs=128K conv=noerror,sync status=progress  # partitions
            bs=128K       # Block size; default is 512 BYTES (slowest); faster (per machine; 64K-1M) 
                          # ERRORs per bs; bigger is faster, but error will ruin more.        
            conv=noerror  # Continue operation on read errors.
            sync          # Add input blocks with zeroes ON ERRORS, so data offsets synced (SORT OF).
            skip=$blocks  # Start reading from $blocks
            seek=$blocks  # Resume (write) @ $blocks(default); useful if interrupted; set lower than interrupt
            oflag=seek_bytes  # seek by bytes not blocks(default)

        # LEGACY TOOL; was useful for tape media (where block size is critical).   
        # Still useful for: 
        #   1.) Read/Write the first N bytes of a stream.
        #   2.) Overwrite/truncate a file at any point/seek.

        # Backup + compression 
        dd if=$src |gzip -9 > $dst.gz
        # Restore 
        zcat $dst.gz |dd of=$src

        # Resume an interrupted backup; seek < interrupt point
        dd if=$if of=$of bs=512K seek=415341762000 oflag=seek_bytes

        # Truncate a file to 12345 bytes
        dd if=/dev/null of=/file/to/truncate seek=1 bs=12345 

        # Overwrite (Zero out) the 2nd 1KB block in a file (i.e. bytes 1024 to 2047)
        dd if=/dev/zero of=/path/to/file bs=1024 seek=1 count=1 conv=notrunc

        # Clone partition 1 of PD sda to partition 1 of PD sdb (PD='physical disk') 
        # ERRORS per bs, so while bigger is faster, errors ruin more than if smaller.
        dd if=/dev/sda1 of=/dev/sdb1 bs=128K conv=noerror,sync

        # Backup a partition table
        # https://wiki.archlinux.org/index.php/Fdisk#Backup_and_restore_partition_table  
        
        # copy USB drive (input-file) to output-file @ current dir (HDD)
        dd if=/dev/sdb of=keydrive.img

        # a.img to USB drive
        dd if=a.img of=/dev/da0 bs=1M conv=sync

        # Write a.ISO to a USB drive
        cp a.iso /dev/sdb
        # Bootable
        dd if=a.ISO of=/dev/sdb1 bs=512M; sync

        # Rip a CD to ISO file
        cat /dev/cdrom > a.ISO
        
        # copy DVD to ISO
        dd if=/dev/sr0 of=/root/foo.ISO

        # /dev/zero : create a file of ANY SIZE, filled with the NULL char (U+0000; 0x00) 
        dd if=/dev/zero of=file.txt count=1024 bs=1024  # 1 MB

        # Write NOTHING to NOWHERE; used in system analysis/testing
        dd if=/dev/zero of=/dev/null 
                
        # Generate ENTROPY @ BKGND PROCESS ...
        dd if=/dev/sda of=/dev/null &
        TASK_PID=$!
        # ... and do whatever requires that entropy.
        # Afterwards, kill the bkgnd entropy-generator process.
        kill $TASK_PID
            # 1 (HUP)   - Reload a process.
            # 9 (KILL)  - Kill a process.
            # 15 (TERM) - Gracefully stop a process.

        # Generate 32-bit base64 key, bit-by-bit; e.g., for ChaCha20 Encryption Algo
        dd status=none if=/dev/urandom of=/dev/stdout bs=1 count=32 |base64 -w 0 - # or use base32

        # Generate Random ASCII (1 char = 1 byte)
        dd if=/dev/urandom bs=1024 count=1 of=ASCII.dd.dev.urandom.1024 # ASCII of 1024 chars (bytes)
        head -c 16 /dev/urandom |od -An -t x |tr -d ' '                 # token of 32 hex chars (512 binary)

    ddrescue  # https://wiki.archlinux.org/index.php/disk_cloning  
        # Cloning and recovery 
        ddrescue -f -n /dev/sdX /dev/sdY rescue.log

    e2image # @ e2fsprogs pkg; @ ext2, ext3, ext4 ONLY; Efficiently copy; blocks used  
        # https://wiki.archlinux.org/index.php/disk_cloning
        e2image -ra -p /dev/sda1 /dev/sdb1

# STORAGE : FOLDERs / FILEs 

    # ARCHIVE tar/cpio/dd/gzip/bzip2/[7z|7za] 

        gzip  # Create/Extract a gzipped (html|image); THE standard for files over internet/web-servers 
            gzip -9 < /dev/sdb > /tmp/foo.gz  # compress volume '/dev/sdb'
            gzip foo.img                      # compress 'foo' (to *.gz), and erase original

            gunzip foo.img.gz                 # uncompress (to foo.img) 

        # Parallel Implementation of GZip; used w/ Netcat (nc)  http://www.zlib.net/pigz/
        pigz  # file|STDIN compressed to file.gz|STDOUT; 
            tar -cf - BIGfile |pigz > BIGfile.tgz 
            tar -c --use-compress-program=pigz -f BIGfile.tgz BIGfile  # equiv; sans redirect

        bzip2 foo.img # compress (newer algo)

        # 7zip 
        7za a [-p"$_PASS_PHRASE"] "$_ARCHIVE_PATH" "$_SOURCE_PATH"
            -stl # set archive TIMESTAMP to newest file therein

        7za x [-p"$_PASS_PHRASE" [-mhe=on] ] [-o"$_TARGET_DIR"] "$_ARCHIVE_PATH"
            -so  # to stdout instead of output file
                     # as if ...
                     cat {contents of ARCHIVE}
                
        # extract all .7z and .zip archs, full depth dirs, and del archive files 
        find . \( -iname '*.7z' -or -iname '*.zip' \) -execdir bash -c '/bin/7z x -bd -y "${0}" -o"${0%.*}";rm -f "${0}"' '{}' \;
        
        cpio # create/extact archive of files
        ls |cpio -o > ../arch_name.cpio # create per ls
        find . -name "*.zip" |cpio -o > ../all_zips.cpio # create per find filter
        cpio -id < ../arch_name.cpio # extract; recreate folder structure

        tar # The workhorse of Linux archiving (originally "tape archive"):
            # Compress/archive; recurses through dir tree by default.
            # EXT: tgz, txz, tar, gz, tar.gz, bzip2, lzip, lzop, lzma, xz, ...
            # - Informal name of a (compressed) tar archive is "tarball".
            # - Take care if extracting; check its root path using `tar -tavf ARCHIVE`.

            ##################################
            #>>>  ORDER of flag(s) matter  <<< 
            ##################################

            -a, --auto-compress # Infer archive type from EXT (Compression Hinting)
            -c, --create
            -t, --list
            -x, --extract
            -f ARCHIVE # Path to target archive (source or result)
            -O, --to-stdout
            -v, --verbose
            -f, --file=ARCHIVE
            -j, --bzip2         # .tar.bz2 is .tbz2
            -z, --gz            # .tar.gz  is .tgz
            -J, --xz            # .tar.xz  is .txz
            -C PARENT # Place BEFORE all other flags, especially on create
            --newer-mtime=DATE # Work on files whose data changed after DATE.  
            # If DATE starts with '/' or '.', then treated as file; DATE is mtime. 
            # Exclude certain folders|files; multiple such excludes okay
            --exclude=PATTERN  # IIF flag is before SOURCE, then excude PATTERN; MULTIPLE use okay
            --exclude='.*'
            --exclude-from <(find foo -size +1M)  # Exclude files in foo larger than 1 MB
            --dereference  # Include reparse points; SYMLINKs/Junction Points/...

            # Algorithm vs. EXT
                # tar.bz2 = tbz = tb2 = tbz2 
                # tar.gz  = tgz
                unzip --help
 
            # Create tarball : Relative path allows for extraction to anywhere.
                cd /parent 
                tar -cavf a.tgz ./a  # Use relative paths

            # Create tarball from ANYWHERE
                tar -C /parent -cavf a.tgz ./a
                
                # From source root, dumping archive to parent and preserving ./source as its root.
                tar -C .. -cavf ../source.tgz ./source

            # Extract tarball to its relative location (under /parent)
                cd /parent 
                tar -xavf a.tgz

            # Extract a SINGLE FILE (preserving relative location under /anywhere)
                tar -xavf a.tgz ./a/file
            
            # Extract files of a pattern (preserving relative locations under /anywhere)
                tar -xavf a.tgz --wildcards ./a/b/c/2025-*.log

            # Extract a SINGLE FILE to PWD (strip relative path) : N = Number of slashes
                tar -xavf a.tgz ./a/file --strip-component=$N # N=2

            # Extract tarball to ANYWHERE (preserving relative locations under /anywhere)
                tar -C /anywhere -xavf a.tgz    # Good semantics 
                tar -Cxavf /anywhere a.tgz      # Bad semantics, but commonly used

            # List archive content : Names only (a); Verbose; ls -hl (v)
                tar -tavf a.tgz

            # Create archive of PWD that extracts to PWD (don't)
                tar -cavf "./../${PWD##*/}.tgz" .  
            
            # PIPEd input per `-` (stdin)
            ... |tar [OPTIONS] -

                # Extract/Install all archived (tgz) bin/* files to /usr/local/bin/*
                curl -sSL https://source.com/set_of_binaries.tar.gz |
                    sudo tar -C /usr/local -xzf - 

                # Create archive of all dot files @ root dir
                find . -maxdepth 1 -type f -iname '.*' -print0 |
                    tar --null -caf dots.tgz --files-from - 

    # LIST FOLDERs/FILEs
        ls -al     # all files; long-listing format
        ls -hlRtgG # all files in ALL SUBDIRS, NEWEST FIRST

            -1  # list one file per line; file basename only
            -a  # show hidden files
            -h  # human-readable file-sizes
            -l  # long-listing format; also shows file-type; '-F'
            -n  # UID,GID
            -g  # like -l, but sans owner
            -G  # like -l, but sans group
            -t  # sort by mtime, newest first 
            -r  # reverse sort
            -R  # recurse thru subdirs
            -F  # file type (1st letter @, e.g., '-rwxrwx---+' )
            -i  # inodes

            # File types in a long list
                Symbol  Meaning
                ------  -------------
                -       Regular file
                d       Directory
                l       Link
                c       Special file
                s       Socket
                p       Named pipe
                b       Block device

            # preferred rendering; newest last
            #ls -hlrtgG --color=auto --time-style=+"%Y-%m-%d %H:%M" --group-directories-first
            ls -hlrt --color=auto --time-style=long-iso --group-directories-first

            # size   fname.ext (first and last fields, tab delimited).
            ls -ahlrst --group-directories-first \
                |awk '{printf ("%s\t%s\n",$1,$NF)}'

            # show perms in octal
            ls -1 |xargs stat --format=" %a  %n" 

            # show newest file 
            ls -lrt |tail -n 1 
        
            # DUPLICATES : Delete all files of target dir that match (basename) any of reference dir
            ls -hl $reference_dir |awk '{print $9}' |xargs -I{} rm $target_dir/{}
        
        lsof  FILE  # File info
        lsof -U     #... of all UNIX Domain Sockets

        file FILE  # report file meta; type, e.g., "Bourne-Again shell script, ASCII text executable"
        file *     # ... for ALL per glob/wildcard

    # DIR TREE
        # CLONE DIRECTORY TREE from $src to $tgt
            find ${src} -type d \
                |sed "s#${src}##" \
                |xargs -I{} mkdir -p ${tgt}{} 

        # List tree
            tree                    # List directory tree with files 
            tree -d                 # List directories only
            tree -L 2               # 2 levels only : $PWD and all 1st-child subdirs
            tree -I 'vendor|media'  # Exclude pattern(s) : /vendor and /media dirs (and files thereunder)
            
    # PERMISSIONs : chmod(1) man page https://linux.die.net/man/1/chmod
        chmod 755 DIR   drwxr-xr--  
        chmod 744 FILE  -rwxr--r--
        chmod 644 FILE  -rw-r--r--
        chmod 400 FILE  -r--------

        # SET group permissions to those of user (recurse)
        chmod -R g=u /mnt/assets

        chown USER:GRP FILE 
        chown -R USER:GRP DIR           # Recurse; all thereunder
        chown -R $(id -u):$(id -g) DIR  #... same, with UID:GID of $USER 

        # MEANINGs :     File  OR  Dir
                          ----      -------
            4 Read        open      list
            2 Write       modify    add/del
            1 Execute     run       cd

        # PERMISSIONs MASK a.k.a. 'file mode creation mask'
            umask       # display current umask setting
            
            #  PERMISSIONS = 0777 - <UMASK> 

            # Change per SESSION; to persist, edit @ ~/.profile)
            umask 0022  # Default; e.g.,  0755  u=rwx,g=rx,o=rx
            umask 0077  # User only;      0700 
            
            umask -S u=rwx,g=rx,o=rx # 0022 => 0755

            # See REF.RHEL.Storage.sh

        # Defang a docker image : remove the suid bit  http://redhatgov.io/workshops/security_containers/exercise1.3/
        find / -xdev -perm +6000 -type f -exec chmod a-s {} \;

    cp # Copy; overwrite.
        cp SOURCE TARGET 

        # copy : preserve attr (mtime, etc); recurse (subdirs too); updated (newer) only 
        cp -pru SOURCE/. TARGET/  # copy CONTENTs of SOURCE to TARGET root (update mode)

        # copy all files & subfolders @ $PWD to current-user's "$HOME/Downloads/DATA" dir  
        cp -r *  ~/Downloads/DATA

    scp # Secure Copy per ssh(1)
        -r      # Recursive copy; else ignores all files under any directory
        -p      # Preserve mtime 
        -C      # Compress during transfer
        -i      # ssh identity file
        -o      # ssh(1) options
        -q      # Quiet; sans progress
        -T      # Disable strict filename checking; mitigate per-distro quirks in file-handling conventions

        # E.g., {PUSH,PULL} the {local,remote} SOURCE directory content to TARGET: 
        scp -rpC -i ~/.ssh/key2  SOURCE  user2@host2:TARGET  # PUSH : local source, remote target
        scp -rpC -i ~/.ssh/key1  user1@host1:SOURCE  TARGET  # PULL : remote source, local target
        # Where ~/.ssh/key{2,1} is the private key of user{2,1} at host{2,1} during {PUSH,PULL} 

    rsync #  a fast, versatile, remote (and local) file-copying tool; 
        # `ROBO /MIR ...` <==> `rsync -rtu --delete ...`
        # https://www.digitalocean.com/community/tutorials/how-to-copy-files-with-rsync-over-ssh 
        # https://en.wikipedia.org/wiki/Rsync#Examples
        # https://rsync.samba.org/examples.html
        # https://www.howtogeek.com/175008/the-non-beginners-guide-to-syncing-data-with-rsync/
        rsync [OPTION]... SRC [SRC]... DEST
        # connect via remote shell
        rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST  # PUSH
        rsync [OPTION]... [USER@]HOST:SRC [DEST]         # PULL
        #... inherently utilizes SSH keys (sans password) if [USER@]HOST is so configured @ ~/.ssh/config 
        # per rsync daemon; require SRC or DEST to start with a module name.

        # ********************************************************************
        # >>>  MUST add TRAILING SLASH to source; target trailer is optional.
        #      Else, unlike cp, rsync copies source dir to SUBDIR of target.
        # ********************************************************************
        
        # E.g., mirror source at target
        rsync -rtu --delete $source/ $target # Creates target if not exist

        # E.g., copy root files only; preserve perm & mtime
        rsync -tp $source/ $target  # target MUST EXIST

        # options
            -a  # archive mode; equals `-rlptgoD` 
            -c  # per checksum (slower), NOT timestamp (mtime), comparisons
            -i  # info-summary only
            -l  # symlinks as symlinks 
            -r  # recurse 
            -p  # preserve perms
            -t  # preserve mod-times 
            -A  # preserve ACLs
            -C  # per CVS auto-ignore rules
            -n  # dry-run; lists abs-paths
            -e  # specify the remote shell (+ its config) 
            -u  # update; skip newer @ target 
            -v  # verbose 
            -z  # compress during transfer (uncompress @ DEST) 
            --delete   # del extras @ target
            --partial  # keep partially transferred files

                # E.g., MIRROR (without overwriting newer @ DEST)
                    -auz --delete 
                # E.g., CLONE 
                    -az --delete

            # filtering >>>  WARNING: VERY TRICKY SYNTAX; triple test before using.  <<<
                --exclude  # UNDOCUMENTED option (except for an example) 
                -F --exclude=PATTERN  # note various different syntaxes for these; see below
                -F --include=PATTERN  
                --filter=RULE
                --prune-empty-dirs
                # E.g.,
                    --exclude '/.git/*'  # VERY tricky syntax; TRIPLE TEST before using 
                    -F --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} 
                    -F --include=*.png
                    -F --include='*/*_???_StAtIc*'
                    --filter=-! */       # exclude all else; ALWAYS USE with `--include=...`
            # other options 
                --modify-window=SECONDS  # reduce accuracy @ timestamp comps; e.g., `2` for FAT

                --files-from="$_REL_PATHS_LIST"
                    # READ paths FROM FILE; very limited/rigid requirement; 
                    #   MUST be of rel-paths; MUST SHARE ONE PARENT,
                    #   and rebuilds entire source dir hierarchy at target
                    rsync -itu --files-from="$_REL_PATHS_LIST" "${_PARENT_PATH}/" "${_TARGET}/"

            # TRAILING BACKSLASH required, 
            #   else source copies to SUBDIR @ target, i.e., 
            #   /source  => target/source
            #   /source/ => /target 

        # PUSH to AWS VM : from local $PWD to remote $HOME/assets/ 
        #... dst dir, `~/assets`, is CREATED if not exist.
        _PRIVATE_KEY=~/.ssh/swarm-aws.pem
        _USER='ubuntu'  
        _HOST='54.234.246.103'

        # source owner/perms/acls preserved
        rsync -auvz -e "ssh -i $_PRIVATE_KEY" ${SOURCE_DIR}/ ${_USER}@${_HOST}:${TARGET_DIR}/

        # target owner/perms/acls unchanged
        rsync -rlDtuvz -e "ssh -i $_PRIVATE_KEY" ${SOURCE_DIR}/ ${_USER}@${_HOST}:${TARGET_DIR}/

        # MIRROR (without overwriting newer @ target)
        rsync -auz --delete "${SOURCE}/" "${TARGET}/"

        # CLONE
        rsync -az --delete "${SOURCE}/" "${TARGET}/"

        # copy root files only; no sub-dirs
        rsync -itu "${_SOURCE}/"* "${TARGET}/"

        # copy ONE FILE (create/update; preserve-mtime; pre-alloc space) ...
        rsync -itu --preallocate "${_SOURCE}/$_FILE" "${TARGET}/"
        
        # REMOTE per SSH
            # if SSH keys/creds validated; password-less connect 
            # dirs
            rsync -atuz "${_SOURCE}/" ${_USER}@${_HOST}:"$_TARGET/"  # push
            rsync -atuz ${_USER}@${_HOST}:"${_SOURCE}/" "$_TARGET/"  # pull
            # one file
            rsync -atvz "$_SOURCE" ${_USER}@${_HOST}:"$_TARGET"  # push
            rsync -atvz ${_USER}@${_HOST}:"$_SOURCE" "$_TARGET"  # pull

            # if SSH identity etal required
            rsync -atuz -e "ssh -i $_ID_FILE ..." ...

            # MIRROR DIRS
            # Push (Upload)
            rsync -atuz --delete --progress -e "ssh -i $_ID_FILE" "${_SOURCE_DIR}/" ${_USER}@${_HOST}:"${_TARGET_DIR}/"
            # Pull (Download)
            rsync -atuz --delete --progress -e "ssh -i $_ID_FILE" ${_USER}@${_HOST}:"${_SOURCE_DIR}/" "${_TARGET_DIR}/"

                # Purportedly needed under certain SSH configs ...
                "ssh -i $_ID_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

        # copy one file-type ($_TYPE)
        rsync -irtu --include="*/" --include="*.$_TYPE" --exclude="*" "${_FROM}/" "$_TO/"
    
        # CHANGEd files only; per checksum, not timestamp 
        rsync -rcnC --out-format="%f" "${_OLD}/" "$_NEW/" # OLDer; Deleted or (pre)Modified
        rsync -rcnC --out-format="%f" "${_NEW}/" "$_OLD/" # NEWer; Added or (post)Modified

    rclone  # rsync for cloud storage services 
        rclone [COMMAND] [FLAGS]  # sans arg, it lists commands
        # Install  https://rclone.org/downloads/  
        curl https://rclone.org/install.sh |sudo bash  
        # Config; interactive; provides URL that returns OAuth token 
        rclone config  # 'rclone.conf' stored @ ~/.config/rclone/ 
        # Synch; skip per checksum (-c), not  mtime, match
        rclone sync $_SRC $_REMOTE:$_DST -c 
            # E.g., between local path & Google Drive 
            _SRC='/d/foo/dog'  # Local path 
            _REMOTE='goog'     # Config name @ rclone.conf 
            _DST='bar/cat'     # Remote path
        # Download from cloud 
        rclone copy $_REMOTE:$_SRC $_DST  # DST is container (parent) 


    # Reset all FOLDERs' mtime per newest therein : REQUIREs newest()
        find . -maxdepth 1 -type d ! -iname '.' -exec /bin/bash -c 'touch -r "$(newest "$1")" "$1"' _ {} \;

    # Move/Rename one target FILE/FOLDER
        mv FROM TO      # Move/rename file/folder FROM path TO path
        mv PATH DIR/    # Move file/folder to DIR; if folder, then all thereunder (recursively)
        mv * ..         # Move all files at PWD to parent dir.
        mv ../*.yaml .  # Move all *.yaml files of parent dir to PWD.

    # Move/Rename a SET of FILEs/FOLDERs using WILDCARDs 

        # FILEs
            # rename : STRIP PREFIX from all such files @ PWD
            find . -type f -name 'PREFIX*' -execdir /bin/bash -c 'mv "$@" "${@/PREFIX/}"' _ {} \;

            # rename : REPLACE SUBSTR with a whitespace
            find . -type f -name '*SUBSTR*' -execdir /bin/bash -c 'mv "$@" "${@/SUBSTR/ }"' _ {} \;
            # for f in *SUBSTR*; do mv "$f" "$(echo "$f" |sed 's/SUBSTR/ /')" ; done

            # rename : SERIALIZE a set of files : (filter) | (build rename command) | (run per bash)
            find -name '*.jpg' |awk 'BEGIN{ a=1 }{ printf "mv %s PREFIX-%04d.jpg\n", $0, a++ }' |bash

        # FOLDERs 
            # Test
                find . -type d -name '* \[dev\]' -exec /bin/bash -c 'sed "s#\[.*\]##g" <<< "$@"' _ {} \;  # remove ' [dev]'
                find . -type d -name '*\(\)*'    -exec /bin/bash -c 'sed "s#()##g" <<< "$@"' _ {} \;      # remove '()'

            # Do 
                find . -type d -name '* \[dev\]' -exec /bin/bash -c 'mv "$@" "$( sed "s#\[.*\]##g" <<< "$@" )"' _ {} \;
                find . -type d -name '*\(\)*'    -exec /bin/bash -c 'mv "$@" "$( sed "s#()##g" <<< "$@" )"' _ {} \

        # More on`find` below at "# GNU FINDUTILS : FIND, LOCATE, XARGS"

    # DELETE (REMOVE) files/folders
        rm FILE     # remove/delete 
        rm /foo/bar/{fname1,fname2,fname3} # remove three files, per glob, per fname.
        rm -i FILE  # interactive/prompt: -i
        rm -rf DIR  # recursively remove folder and all subfolders and files therein

        # Remove multiple files, but allow user VERIFY before delete ...
            find ... -exec rm ...       # See `find` below at "# GNU FINDUTILS : FIND, LOCATE, XARGS" 
            ... |xargs rm               # Remove the NEWLINE-delimited list of (verified) target files.
            ls |grep -i "PATTERN"       # Per pattern
            rm $(ls |grep -i "PATTERN") # Per pattern
            rm $(!!)                    # Per previous-command list

        # Delete + overwrite
        shred FILE          # Overwrite the specified FILE(s) repeatedly
            -s, --size=N    # shred this many bytes (suffixes like K, M, G accepted)

        rmdir $PATH  # remove/del (empty) dir
        
    # CREATE files/folders

        mkdir NAME  # make dir 
        mkdir -p $_PRJ/a/b/{admin,public}/d/{js,css,img} # create intermediaries as needed. 

        touch FILE  # CREATE empty file; update mod-time if file exist

    # RESET DATE/TIME (mtime) of TARGET to that of REF path
        touch -r  REF TARGET        # per mtime of REF
        touch -rh REF TARGET        # per mtime of REF if SYMLINK
        touch -t MMDDhhmm TARGET    # per MMDDhhmm : explicilty per format 
        # Ex. : At EST TZ (GMT -5:00) ...
            touch -t 01020344 foo       
            ls --full-time foo #=> ... 2023-01-02 03:44:00.000000000 -0500 foo

# PIPE helpers

    tee # Pipe STDOUT to BOTH console (STDOUT) AND a file 
        ls |tee FILE
        # append STRING to file(s)
        echo "STRING" |tee -a *.txt > /dev/null  # silently

# GNU FINDUTILS : FIND, LOCATE, XARGS
    # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Introduction
    # ISSUEs @ find ... |xargs   http://www.etalabs.net/sh_tricks.html

    locate # like 'find' utility, but processes the special filenames DATABASE; 
        locate [option...] pattern... # VERY FAST, but updated only once per day or so.
        updatedb # force locate-database update
        # CONFIGURE 
            /etc/updatedb.conf 
            # To exclude from locate (ubdatedb) search: /etc/updatedb.conf
                PRUNEPATHS="/tmp /var/spool ..." 
                PRUNEFS="NFS nfs ..."   
        
        # Wildcards; print all fnames ending with ‘Makefile’ or ‘makefile’. 
         locate '*[Mm]akefile' # Wildcard handling differs from that of `find` utility. 

    find # very useful; very configurable; however, lots of syntax quirks ...
        # - Does NOT recognize Brace Expansion
        # - Globbing : UNLIKE bash, must quote to protect from shell-expansion, e.g., 'foo*'
        #   Also, UNLIKE bash, '*' matches both ‘/’ and leading dots in paths
        # http://mywiki.wooledge.org/UsingFind
    
        find            # List relative paths of all folders & files @ $PWD
        find /abs/path  # Specify top-level search by ABSOLUTE path
        find ./rel/path # Specify top-level search per RELATIVE path
        
        find . -ipath '*/new */foo bar.txt'  # case insensitive path search within PWD & below
        find . -iname 'foo*'                 # print ./fname.ext; 1 per line; all foo*
        
        find "$dir" -iname "foo*bar"  # find all @ subdirs within $dir & below
        find . -name "[a-m]*.*"       # find per globbing
        find . -size +5M              # find files bigger than 5MB
        find . -type l                # find symbolic links (symlinks); regular files (f); dirs (d)

        # Set depth of search 
            find -mindepth 1 -maxdepth 1  # PWD only; files & folders
            find -mindepth 2 -maxdepth 2  # 1st-child only; files and folders

        # Follow SYMLINKs, else not.
            find -L "$DIR" -iname 'foo*'  

        # Exclude set of FNAMEs
            find . -type f ! -iname '*\[s\].7z' \( -iname '*.7z' -or -iname '*.zip' \) 
        
        # Exclude set of specific FNAMEs and/or PATHs : DO NOT MIX `-or` with `!`
            find . -name 'REF.*' -or -iname '*.lnk' -or -iname '*.xyz' -not -path '*/.git/*' ... 
            find . -name 'REF.*' ! -iname '*.lnk' ! -iname '*.xyz' ! -path '*/.git/*' ... # Equivalent

            # E.g., find all *.md OR *.txt larger than 100 KB 
            find . -type f  \( -iname '*.html' -or -iname '*.txt' \) -size +100k -printf "%k [%s] %p\n"

        # RUN COMMANDS against the resulting list
            #  DELIMITERs `;` or `+` : they must be either ESCAPED or QUOTED : `\;` OR `';'`
            # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Run-Commands
            
            # ONE FILE per delimt : `;` : One per, regardless of subsequent pipelining.
            # `{}` is/are replaced by CURRENT FILE in process; multiple `{}` okay
                find ... -exec[dir] command args '{}' [args] \;
                find ... -exec[dir] command args '{}' [args] ';'  # EQUIVALENT
            
            # MAX FILES per delimit : `+` is a true pipeline; is MUCH FASTER than `;`. 
                # Pipelines the maximum capacity per thread (set per environment).

                find ... -exec[dir] command args '{}' [args] \+
                find ... -exec[dir] command args '{}' [args] '+'  # EQUIVALENT

                # invoke subshell ...
                find ... -exec[dir] /bin/bash -c 'command "$@" ... "${@}"' _ {} \+
                    # E.g., 
                    find -exec /bin/bash -c 'printf "\t%s\n" "${@##*/}"' _ {} \+
                    # `_` can be any string; it "consumes" the subshell name ($0).

                # -print0 handles whitespace in file-path:
                    # Inserts nul separator instead of NEWLINE.
                    find ... -print0 |xargs -0 command 
                    # e.g., handle one arg/path per line
                    find -print0 |xargs -0 -I {} command {}
                    
                # -exec is better than xargs method if command handles arg parsing
                    find ... -exec /bin/bash -c 'command "$@"' _ {} \+     

                # -execdir is more secure, but slower than -exec 
                    find ... -execdir /bin/bash -c 'command "$@"' _ {} \+  

                # remove the prepending `./` if find statement passes one path per line.
                    find ... |sed -n 's|./||p'  
                    find ... |sed -n 's/\.\///p'  # equiv
                
                # invoke subshell; multiple commands; access path-expansion
                find ... -exec /bin/bash -c 'command "${@##*/}" $arg2 ...' _ {} \+  
                # NOTE: @ subshell, use `$@` and replace `{}` with `_ {}`, else `$0` is the proxy for `$@`
                #+      also, FUNCs + VARs must be EXPORTed to be accessible @ subshell, e.g., ... 
                    export -f aFunc  # else aFunc (function) is NOT available @ subshell
                    find ... bash -c 'aFunc ...' 

                # IF need to SORT (per NEWLINE), BUT then process ALL (per NULL)
                find -iname '*.jpg' |sed 's/\n//g' |xargs -0 -I {} bash -c 'command "$@"' _ {}
                # See below for more on xargs subshell
    
        # COMMA OPERATOR : multiple commands in one traversal (each must incl any: -name, -type, ...)
            find . \( -execdir command {} \; \) , \( -exec command {} \; \) # command called once per file
            find . \( -execdir command {} \+ \) , \( -exec command {} \+ \) # multiple files per command call
            # Alt method:
            find . \( -name 'REF.*' ! -iname '*.lnk' ! -iname '*~' \) -type f \
                -exec /usr/bin/bash -c '{ 
                    echo "${@##*/}"
                    cp -upv "$@" "$_SMB_FOLDER/REFs" 
                    cp -upv "$_SMB_FOLDER/REFs/${@##*/}" "$@" 
                }' _ {} \;
            
        # NUL SEP instead of NEWLINE; to handle whitespaces
            find ... -print0  

        # List FOLDER SIZE of EACH folder; sum(s) of all subfolders therein ( + folder path) 
            find . -type d -exec du -bhs "{}" \; 
        # SUM of ALL folder sizes ( + folder path)  
            find . -type d -exec du -bs "{}" \; |awk '{ x += $1 } END { print x/1024" KB" }' 
            # or (much faster @ WSL)
            find . -type f -printf "%s\n" |awk '{ x += $1 } END { print x/1024" KB" }' 

        # FORMAT DIRECTIVES : -printf 
            # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Format-Directives
            %p   # absolute path
            %f   # fname
            %P   # relative path
            %h   # parent folder IF abs path, else '.'
            %k   # size in 1K blocks; %s/1024
            %s   # size in bytes
            %m   # file MODE (octal)                     755
            %#m  # file MODE (octal) w/ leading zero    0755
            %M   # file MODE (symbolic)           -rwxr-xr-x
            %t   # mtime; 'Tue Sep 18 16:46:03.1093750000 2007'
            %Tk  # mtime per format 'k' ... 
                     # %T@ => 1463830176.0000000000 # UNIX-TIME; seconds since 1970
                     # %TD => 'YY/MM/DD'
                     # %TY-%Tm-%Td %TH:%TM:%.2TS %TZ => YYYY-MM-DD HH:MM:SS EDT
                     
                find -printf "%TD\t%k\t%P  \n" 
                # 09/18/07        504     FNAME.EXT
                
                find -printf "%TY-%Tm-%Td %TH:%TM %P\n"
                # 2015-06-10 21:06 FNAME.EXT

                find -type f -iname 'REF.*' -printf "%TY-%Tm-%Td %TH:%TM\t%f\n" |sort        
                # 2017-09-22 12:11        REF.zoobar.ext
                # 2017-09-22 17:28        REF.foobar.ext
                # 2017-09-24 20:45        REF.barfoo.ext 
             
                find "$PWD"  # abs-path 
                find         # rel-path; './RELPATH'

                # print all files w/out ".???" ext @ HOME dir; NO subdirs; print abs-path.
                find "$HOME" -maxdepth 1 -type f ! -name '*.???' -printf "%p\n"
                
                # print all 1st children of PWD; perms in octal, and fname 
                find . -mindepth 1 -maxdepth 1 -printf "%f\n" |xargs stat --format=" %a  %n" 
                     775  .
                     770  foo.bar
                     775  scripts
                     775  samba

                # print all basename(s) sans ext (strip prepending `./`), all @ one line (per `\+` vs. `\;`) 
                find . -maxdepth 1 -execdir /bin/bash -c 'echo ${@%.*}' _ {} \+ |sed 's/\.\///g'

                # newest file under $PWD (full-path) ...
                find . -type f -printf "%T@ $PWD/%P\n" |sort -n |tail -1 |cut -f2- -d" "

                # abs-path w/ newline
                    find . -iname '*.sh' -printf "$PWD/%P\n" 

                # Show abs-path in strong-quotes, and mod-time:
                    # UNIX time, e.g., 1399327799.0000000000
                        find "$_dir" -iname "$_target" -printf "'$_dir/%P' %T@\n" |tail -1
                        # same as above, but remove fractional-time part
                        find "$_dir" -iname "$_target" -printf "'$_dir/%P' %10.10T@\n" |tail -1

        # EXECUTE on the LIST : -exec ... {} ... ;
            # Copy all target files in and under PWD to folder "$@"; 
            # target set is any fname of pattern REF.* except REF.*.lnk; 
            # use pattern matching (glob)
            find \( -name 'REF.*' ! -iname '*.lnk' \) -type f -exec cp '{}' "$@" \;

        # COMBINE Primaries and Operators
            # \( expr1 ! expr2 \)
            # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Finding-Files
                find \( -name 'REF.*' ! -iname '*.lnk' \) -type f -exec cp '{}' "$@" \;

        # TIMESTAMPS : RESET
            # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Updating-A-Timestamp-File

            # reset timestamps of all extracted folders to mtime of their source *.txz archive
            find -maxdepth 1 -type f -iname '*.txz' -execdir bash -c 'touch -r "${@}" ${@/.txz/}' _ {} \;

            # reset timestamps of all 1st-child folders with mtime of newest file therein 
            find -mindepth 1 -maxdepth 1 -type d -exec bash -c 'touch -r "$(newest "$@")" "$@"' _ {} \;
            
                # same, except do all dirs/depth, and print folder names 
                find -type d -exec bash -c 'touch -r "$(newest "$@")" "$@"; echo " ./${@##*/}"' _ {} \;

                # where `newest()` finds newest file within a folder; its engine:
                find -type f -printf "%T@ %p\n" |sort -n |tail -n 1 |cut -f2- -d' '
            
            # -atime, -mtime, -ctime 
            find -atime +5 # OLDER; find all accessed more than 5 DAYS ago
            find -mtime -5 # NEWER; find all modified (content) less than 5 DAYS old

            # reset mtime of *.sh to that of its *.7z sibling, at all dirs hereunder 
            find . -iname '*.7z' -exec /bin/bash -c 'touch -r "$@" "$( find "${@%/*}" -iname '*.sh')"' _ {} \;

        # DELETE FOLDERs/FILEs per age
            # https://www.gnu.org/software/findutils/manual/html_mono/find.html#Worked-Examples

            # Ex. Delete older than 10 minutes 
                find . -mmin +10 -exec rm {} \;

            # EX : Delete old files -mtime +90 is NINETY DAYS 

                # BEST METHOD to delete, say GNU guys; `-delete` is from BSD guys
                find -mtime +90 -delete

                # slow way; forks child process per file-delete 
                find -mtime +90 -exec /bin/rm {} \;
                # ... faster using command expansion ...
                /bin/rm $(find -mtime +90 -print)
                
                # ... but all files on one line; one var; limited size, so use xargs ...
                find -mtime +90 -print |xargs /bin/rm
                # ... which will automatically break it up separate command lines, as needed; 
                #     run the 'rm' command as many times as needed.
                # to handle white-spaces in path ...
                find -mtime +90 -print0 |xargs -0 /bin/rm
                # ... but -print0 is not as universally supported, so back to -exec w/ '+' ...
                find -mtime +90 -exec /bin/rm {} \+
                # '+' : find builds up a long command line and then issues it
                # ... more secure; operates per dir ...
                find -mtime +90 -execdir /bin/rm {} \+
            
        # find by AGE
            find -mmin +0 -mmin -10 # by age (minutes)
            find -name *hawaii*     # by name
            
        # Find NEWER : -newer (mtime) OR -newerXY (X is target, Y is reference)
            # @ -newerXY : X, Y can be ...
            #   a   The access time of the file reference
            #   B   The birth time of the file reference
            #   c   The inode status change time of reference
            #   m   The modification time of the file reference
            #   t   reference is interpreted directly as a time
            find -newer REF_PATH # find files in current dir (PWD) newer than REF_PATH (mtime)
                
        # find by glob-set, *[SAMPLEs].url, and overwrite contents, per 'sed -i ...', in each file found ...
            find '/cygdrive/d/1 Data/Fonts' -iname '*\[SAMPLEs\].url' -exec sed -i "s/TypeFace/[SAMPLEs]/g" {} \;

            # STRING SEARCH every -name file in dir; PRINT FILENAME 
            find . -type f -name '*.bat' -exec grep -l 'Find This String' {} \+

        # Prepend LINE_OF_TEXT in all files matching PATTERN
            find . -type f -name 'PATTERN' -exec sed -i '1s;^;LINE_OF_TEXT\n;' {} \;

    xargs [option...] [command [initial-arguments]]
        # xARGS as in "combine arguments"; pronounced EX-args
        # Converts piped STDOUT of command1 to args ($@) of command2
        #  https://www.gnu.org/software/findutils/manual/html_mono/find.html#Common-Tasks
        #  xargs builds and executes command lines by gathering  
        #  arguments it reads from stdin; smartly filling a pipeline 
        #  per options AND machine capacity.
        xargs -n MAX-ARGS     # max args (#) per command line
        xargs -I {}           # 1 arg per, regardless of -n; {} is arg; useable only once lest sh -c '...'
        xargs -L MAX-LINES    # max lines (#) per command line 
        xargs -d '\t'         # '\t'; TAB-delimited args
        xargs -P 10           # run 10 processes max, CONCURRENTLY

        # Build and execute command lines from standard input
        # CONVERTS PIPED STDOUT of command1 TO STDIN (args) for command2
            command1 |xargs command2 # Use when command2 does NOT accept piped STDIN 
            # E.g., gzip all dot-file files at root of HOME dir:
            find "$HOME" -maxdepth 1 -type f -name '.*' |xargs gzip 
            # (See `find` at "GNU FINDUTILS" section below for more detail)

        # LOOP (faster) : pass each index (1, 2, ..., $n) to COMMAND, as arg, once per.
            seq $n |xargs -I {} COMMAND {} # {} is the canonical token; any unique CONTIGUOUS STR okay.
        # LOOP SECURELY (mitigate command injection) by using SUBSHELL:
            # - Use single quotes to prevent interpretation.
            # - Allows for access to positional params (multiple useage); brace expansion
            # - Allows for injecting variable(s) without affecting args order 
            #   by replacing "_" (dummy for token $0) with it.
            seq $n |xargs     /bin/bash -c 'command1 $2;command2 "$@";...' _  
            seq $n |xargs -IX /bin/bash -c 'COMMAND "$@"' $v X
            # PASS N args per line
            seq 3  |xargs -n2 /bin/bash -c 'foo "$@"' _ 
                # [1] [2]
                # [3]
   
        # Require arg(s)
            ...|xargs --no-run-if-empty command

        # Handle ...

            # WHITESPACE : implies ONE (first) ARG per command line
                ...|xargs -I {} command {}       # If piped '\n' (newline) DELIMITED
                ...|xargs -0 -I {} command _ {}  # If piped '\0' (null) DELIMITED
                
            # NULL-DELIMITed : allows WHITESPACE args; process @ SUBSHELL; `-0 -I {} ...`; 
                find . ... -print0 |xargs -0 command 
    
            # NULL-DELIMITed allows WHITESPACE args; process @ SUBSHELL; `-0 -I {} ...`; 
                ...|xargs -0 -IX /bin/bash -c 'command "$@"' _ X
                # LIMITATION: one (first) null-delimited arg per line; KILLS STREAMING
            # STREAMING `$_N` args per subshell ...
                ...|xargs -0 -n $_N /bin/bash -c 'command "$@"' _ 
    
            # STDIN or PIPELINE arg(s) by test for FD 0 (STDIN) open:
                [[ -t 0 ]] && command "$@"            # If FD 0 is open, then args are of STDIN 
                [[ -t 0 ]] || xargs -I {} command {}  # If FD 0 is not open, then args are by PIPE

            # CONCURRENTly, @ max 10 per line to process \n delimited paths (list)
                ... |xargs -d '\n' -P 10 -I {} /bin/bash -c 'fooProcess "{}"'
                # concurrently/background fooProcess ...
                ... |xargs -d '\n' -P 10 -I {} /bin/bash -c 'fooProcess "{}" &'

            # STREAM PROCESSor (generalized)
                foo(){ echo "[$1] [$2] [$3]"; }
                streamArgs() { 
                    # set args per window (process) and window shift 
                    foo_MINARGS=3; _N=3 #... simplest case; sequential with no overlap
                    #... Overlap processing if _N < foo_MINARGS
                    (( $# < $foo_MINARGS )) && return
                    # spawn bkgnd `foo` process; lop N args; recurse
                    ( foo "$@" & ); shift $_N; $FUNCNAME "$@" 
                }
                export -f streamArgs # must export so subshell @ `find` can access
                export -f foo        # must export so subshell @ `find` can access
                # Stream process and control max concurrent processes 
                seq 8 |xargs -P 20 /bin/bash -c 'streamArgs "$@" &' _ 
                # [1] [2] [3]
                # [4] [5] [6]

                # Stream process files
                find . -execdir /bin/bash -c 'streamArgs "$@"' _ {} \+

# TEXTUTILS (package); Process text streams using filters ...

    # Newline / EOL / Line Feed / Line Ending / Line Break
        # https://en.wikipedia.org/wiki/Newline
        # Win/DIS-formatted newlines interfere with POSIX/GNU programs/utilities/tools
        # Win/DOS uses Carriage-Return + Line-Feed (CRLF), whereas POSIX is (now) LF only.
        Win/DOS         CRLF   \r\n     0x0D 0x0A   13 10
        Mac (early)     CR     \r       0x0D        13
        Unix            LF     \n       0x0A        10

    # REGULAR EXPRESSIONs (RegEx)   https://en.wikipedia.org/wiki/Regular_
        # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions  
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

        "(.+)"  # E.g., any grouping of one or more of any chars, enclosed in double-quotes
        # E.g., see grep, below
        # E.g., TEST; str ($1) match a given glob pattern ($2) 
        fnmatch () { case "$2" in $1) return 0 ;; *) return 1 ;; esac ; }
        if fnmatch 'a??*' "$str" ; then echo 'Match!' ; fi
        
    seq n # SEQUENCEs generator; print 1, 2, ..., n; default \n separator 
        seq 3                     # 1\n2\n3\n
        seq 3 -1 1                # 3\n2\n1\n
        seq -s ' : ' 0 3 9        # 0 : 3 : 6 : 9
        seq -s ',' -f %03g 8 100  # 008,009,...,100

        # CREATE 56 empty `NNN.log` FILES; 000.log ... 055.log
        seq -f %03g 0 55 |xargs -I {} touch "{}.log"

        # REPEAT COMMAND n times (ignore args `$n`)
        seq $n |xargs -Iz COMMAND ARG1 ARG2 ...

        # SEQUENCE per GLOB
            echo {4..7}               # => 4 5 6 7 
            printf "%s " {4..7}       # => 4 5 6 7

        # Count occurrences of a character  http://www.etalabs.net/sh_tricks.html
        tr -dc "$char" |wc -c        # may fail @ non-char bytes
        tr $char\\n \\n$char |wc -l  # more robust trick
        
    grep  # PATTERN match 

         grep PATTERN FILE  # per line(s) in FILE; newline-delimited 
         ... |grep PATTERN  # per piped PATTERN(s); newline-delimited 

        --  # Flag END of ARGs, so PATTERN can have LEADING DASH(es)
        -i  # ignore case
        -r  # recurse
        -v  # select non-matching lines
        -E  # extended grep; understands ALL RegEx
        -P  # Perl RegEx 
        -n  # prepend line number
        -f  # ANY PATTERN in FILE; one pattern per line
        -F  # PATTERN is a set of newline-delimited strings
        -x  # force PATTERN to match only WHOLE LINES; --line-regexp
        -f  # obtain PATTERN from FILE
        -a  # ASCII; force to treat binary file as text; purportedly useful @ text files too.
            # https://utcc.utoronto.ca/~cks/space/blog/unix/GNUGrepForceText  

        # Allow pattern having LEADING DASH(es)
        ... |grep -- '-foo-bar'

        # Filter thru EITHER pattern
        ... |grep -e This -e That

        # Any pattern listed in FILE (one pattern per line)
 		cat <<-EOH > FILE
		500
		501
		503
		504
		EOH
        seq 1000 |grep FILE
        # 500
        # 501
        # 503
        # 504
        rm FILE

        # Strip NULL chars else grep treats FILE as BINARY; 
        ## '\000' is octal representation of NULL char (U+0000)  
            cat FILE |tr -d '\000' |grep ...

            # E.g., Search for PATTERN in all *.reg files , which ontains NULL chars.
            cat $(find . -iname '*.reg') |tr -d '\000' |grep PATTERN

        # LIST (-l) ALL FILES in $dir (recurse; -R) containing PATTERN (case insensitive; -i)
        grep -Ril 'PATTERN' $dir

        # grep recognizes *some* RegEx by default:
            grep -Pv '^\t'   # does NOT START with TAB; per Perl RegEx
            grep ^PATTERN    # STARTS with PATTERN
            grep PATTERN$    # ENDS with PATTERN
            grep .PATTERN    # ANY CHAR followed by PATTERN
            grep PATTERN.    # ANY CHAR prepended by PATTERN

        # EXTENDED grep; ALL RegEx; same as `egrep` (?)  
            grep -E '^(foo|bar)baz'      # BEGINS w/ EITHER 'foo' OR 'bar' FOLLOWED by 'baz'
            grep -E '^[a-k]foo'          # BEGINS w/ a,b,...k FOLLOWED by 'foo'
            grep -E '^([a-k]|[A-K])foo'  # +EITHER CASE of a-k

        # search for PATTERN in FILE 
            grep PATTERN FILE      
            grep -ni PATTERN FILE    # +prepend line number; case-insensitive
            grep -c PATTERN FILE     # print only the COUNT (number of matching lines)
            cat FILE |grep PATTERN  # per pipe
            
        # find (non)matching LINES in 2 files; for non-matching, add `-v` option
            grep -nFxf FILE1 FILE2       # FAST; NOT symmetric; use `comm` or `diff` utility
            cat FILE1 |grep -f - FILE2  # much slower; `-`:FD is stdin 

        # list ALL FILES in $_DIR containing PATTERNING
            grep PATTERN $_DIR/*                    # print all occurrences of PATTERN in all files in $_DIR folder
            grep -liR PATTERN $_DIR/* 2> /dev/null  # case-insensitive, RECURSE, filter out stderr 

        fgrep  # fast grep; literal strings; does NOT recognize ANY regex
        egrep  # extended grep; recognize ALL RegEx; same (?) as grep -E

    fold # Wraps each input line to fit specified (character) width. Breaks words.
        ... |fold -w n # folds (character wraps) every line at n characters.

    cut # Remove sections from EACH LINE of FILE
        cut -f1 FILE        # Filter thru COLLUMN 1 if tab delimited (DEFAULT)
        cut -d :  -f1 FILE  # Filter thru COLLUMN 1 if colon delimited
        cut -d" " -f2 FILE  # Filter thru COLLUMN 2 if space delimited
        cut -c 2,4,5 FILE   # Filter thru those CHARS (count whitespace too)
        ...|cut -d" " -f2-  # If by pipe (take STDIN "-")

    awk  # field-oriented pattern-processing LANGUAGE; C-style syntax; gawk (GNU version);
         # data-driven; a set of actions taken against streams of textual data
         # EXAMPLEs (GitHub)  https://github.com/learnbyexample/Command-line-text-processing/blob/master/gnu_awk.md
         # http://www.tldp.org/LDP/abs/html/sedawk.html  

        awk STATEMENT FILE   # process FILE 
        ... |awk STATEMENT  # process pipelined input

            -F  # Field Separator (Column Separator) 
            NR  # number of records (line); first is 1
            NF  # number of fields; last field (token, or collumn) 

        # print FIRST and LAST fields, per DELIMITER (FIELD SEPARATOR) `:`
        awk -F ':' '{print $1, $NF}' FILE
        # print 3rd field of first row only
        awk 'NR == 1 {print $3}' FILE 
        # printf : print certain fields, formatted
        awk '{printf "%s\t%s  %s\n", $5, $1, $3}' FILE
        # filter OUT multiple patterns (anywheee)
        awk "!/str1|str2|str3|.../" FILE
        # FIND text and print entire line
            awk "/$find/ {print}" FILE
        # FIND/REPLACE : gsub(/PATTERN/,REPLACE,COL_NUM)
            awk '{gsub(/PATTERN/,"REPLACE")}' FILE
            awk '{gsub(/patteRn/,"REPLACE",COL_NUM)}' FILE
                # E.g., replace 1 with 0 on column 1 only.
                awk '{gsub(/1/,"0",$1);}' FILE
        # per DELIMITER; process CSV file; print 2nd field only; note field separator
        awk -F "\"*,\"*" '{print $2}' csvFILE  # (???)
        awk -F ',' '{print $2}' csvFILE        # This works too 
        # print 2nd field; that is, 2nd space-delimited word of $str
        printf '1 2 3 4' |awk '{print $2}'  # '2' 
        # Filter output of a command 
        COMMAND |awk '{print $1,$4}'  # prints columns 1 and 4 only.
        # filter-out (exclude) field 5 
        awk '{ $5=""; print }' FILE
        # prepend 'foo ' to every line
        awk '{print "foo " $0}' FILE
        # convert doc-type : tab-delimited fields record to YAML (prepend+append)
        awk '{print $1":\n" "  user: "$2"\n"  "  pass: "$3"\n"}' CREDS_FILE
        # Sum 3rd column (integers) of FILE (X00% faster than Python equivalent)
        awk '{ x += $3 } END { print x }' FILE
        # IF 3rd field is > 0, print field 1 and product of fields 2 and 3;
        awk '$3 > 0 { print $1, $2 * $3 }' FILE
        # IF its 2nd-from-last field is '200', print the entire line 
        awk '{if ($(NF-2) == "200") {print}}' FILE
        # Print field 1 if field 2 is gt 35; ignore first record (row)
        awk '$NR>1 && $2>35{print $1}' FILE
        # Print fields 5 thru to the last, i.e., print all, however many, but for the first 4. 
        awk '{ s = ""; for (i = 5; i <= NF; i++) s = s $i " "; print s }' FILE
        # Transform a CSV list of names to upper-case.
        printf $_csv |tr "," "\n" |awk '{ print toupper($0) }'

        # SUM size of ALL sub-FOLDERs in KB
            find . -type d -exec du -bs "{}" \; |awk '{ x += $1 } END { print x/1024" KB" }' 
            # or (much faster @ WSL)
            find . -type f -printf "%s\n" |awk '{ x += $1 } END { print x/1024" KB" }' 

        # XOR per lines (lines not in both)
        awk 'FNR==NR {a[$0]++; next} !a[$0]' file1 file2

    JsonPath # XPath for JSON : A language library : https://jsonpath.com/
        # https://kubernetes.io/docs/reference/kubectl/jsonpath/
        
        # Get flat list of all images of all containers running in the cluster across all namespaces
        kubectl get pod -A -o jsonpath='{.items[*].spec.containers[*].image}' |tr ' ' '\n' |sort -u

        # COMMON PATTERN using its array filter "?()" :
        # Get value of subkey keyX of an object (element of anArrayKey) having a parent keyY that is set to a *declared value*.
        # SYNTAX: $.anArrayKey[?(@.keyY=="foo bar")].keyX
        # EXAMPLE: Get/parse TLS certificate (and extract Subject) of a declared config.users.user:
        user=kind-kind # See config.users[] at `kubectl config view`
        kubectl config view --raw -o \
            jsonpath='{.users[?(@.name=="'$user'")].user.client-certificate-data}' \
            |base64 -d |openssl x509 -text -noout
            # OR just one field, e.g., Subject:
            |base64 -d |openssl x509 -subject -noout
            #=> subject=O = kubeadm:cluster-admins, CN = kubernetes-admin

    jq|yq # Process JSON to YAML
        # Convert items[] els to "---" delimited YAML docs
            # Example has 1st-order per-el key "apiVersion"
            cat $json |jq -Mr [.items[]] |yq eval .[] -P - |sed '1!s/^apiVersion/---\napiVersion/'

    jq # JSON Processor
        # https://jqlang.github.io/jq/tutorial/
        # https://jqlang.github.io/jq/manual/
        
        -r # Raw out; unquoted.
        -c # Compact (vs. pretty print)
        -C # Colorized; subsequent pipe may FAIL due to CTRL chars.
        -M # Monochrome; fix for aformentioned pipe fail: -Mr 
        -R # Raw (string) input

        ## Handle bad (sub)key names.
            # a:
            #   key.has.dots: {}
            ... |jq -Mr '."key.has.dots"'

        ## Filter out all but (sub)keys, of/to valid JSON.
            # Deletes ALL the STRING array els and key values, recursively.
            ... |jq -Mr 'walk(
                    if type == "object" then
                        with_entries(.value |= if type == "object" or type == "array" then . else "" end)
                    elif type == "array" then
                        map(select(type != "string"))
                    else
                        .
                    end
                )'

        # Filter all selected keys-values at some layer of the hierarchy:
            docker volume inspect $(docker volume ls -q)|jq -Mr .[].CreatedAt 
                # List both Name and CreatedAt
                ...|jq '.[] | .Name, .CreatedAt'

        # Access key having slash or other problematic characthers
            echo '{"a/b": 1}' |jq '."a/b"'                   #=> 1
            echo '{"a/b": 1,"c": {"a/b": 2}}' |jq '.c."a/b"' #=> 2
            echo '{"a/b": 1,"c": {"a/b": 2}}' |jq '{A|B: ."a/b", C: .c}'
                # {
                #      "A|B": 1,
                #      "C": {
                #          "a/b": 2
                #      }
                # }

        # SLURP a flat list of JSON OBJECTS into a valid JSON struct (array).
            cat flat-list-of-json-objects.txt |
                jq -Mr . --slurp # -s

        # MAP a flat list of STRINGs to JSON array
            cat flat-list-of-strings.txt |
                jq -R -s -c 'split("\n") | map(select(length > 0))'
            # OR (if string delimiter is newline)
            cat flat-list-of-strings.txt |
                jq -Rn '[inputs]'

        # MAP/REFACTOR object having array to flat list
            echo '[ 
                {"name": "redhat/ubi8", "tags": ["8-8.9-1136", "8.8-1067-source"]},
                {"name": "bbox", "tags": ["1.32.0-musl"]}
            ]' |jq -Mr '.[] | .tags[] as $tag | "\(.name):\($tag)"'
                # redhat/ubi8:8-8.9-1136
                # redhat/ubi8:8.8-1067-source
                # bbox:1.32.0-musl

        # Iterate over any array SAFELY (allow for possible null or empty)
            ...|jq '.k1 | .[]?'
            ...|jq '{"k1": .k2 | .[]? } | {...}'
            ...|jq '{"k1": (.k2 // []) | map(.k3)}'
            ...|jq '[.k1.k2[]? | select(. != null and .k3 != null) | {K3: .k3}]' 

        # Filter key names 

            # @ Array : Using keys (obj to arr operator)
            echo '{ "k1": [{"/api/k2a": 11}, {"/api/k2b": 22}, {"/api/kxb": 86}, {"/api/k2c": 33}]}' |
                jq '.k1[] | select(keys[] | test("^/api/k2"))'
                # OR, to get filtered key names only : Using keys operator
                jq -Mr '.k1[] | keys[] | select(test("^/api/k2"))'

            # @ Object : Using to_entries (obj to arr of its k-v pairs) |...| from_entries (arr to obj)
            echo '{ "k1": { "/api/k2a": 11, "/api/k2b": 22, "/api/kxb": 86, "/api/k2c": 33 }}' |
                jq '.k1 | to_entries | map(select(.key | test("^/api/k2"))) | from_entries'
                # OR, to get filtered key names only : Using keys operator
                jq -Mr '.k1 | keys[] | select(test("^/api/k2"))'

            # Filter out subkey(s) under unknown key name(s) : Using walk()
                |jq '. |walk(if type == "object" then del(.keynam1, keyname2, keyname3) else . end)'
                # If keynames are dynamic
                |jq --argjson keys '["keyname1", "keyname2", "keyname3"]' 'walk(if type == "object" then {($keys[]): .[]} else . end)'

            # GET all content of container registry, both repos and images lists, 
            # in both JSON and flat-list formats.
                curl -s http://$registry/v2/_catalog |
                    tee catalog.json |
                    jq -Mr .[][] |
                    tee catalog.repositories.log |
                    xargs -I{} curl -s http://$registry/v2/{}/tags/list |
                    jq -Mr . --slurp |
                    tee all.tags.list.json |
                    jq -Mr '.[] | .tags[] as $tag | "\(.name):\($tag)"' |
                    tee all.images.log

        # List selected keys and values, refactoring into another valid JSON obj:
            docker network ls -q |xargs docker network inspect $1 |
                jq -Mr '.[] | select(.Name != "none") | {Name: .Name, Type: .Driver, Address: .IPAM.Config}' |
                jq --slurp .

        # Filter all selected keys-values at various layers of the hierarchy
            aws ec2 describe-volumes |
                jq '.Volumes | .[].Attachments | .[] | .Device, .VolumeId'

            # ... as key:val pairs
                ...|jq '{Mtime: .LastModified, Size: .ContentLength, MIME: .ContentType}'
            # ... natively, sans jq 
                --query "{Mtime:LastModified,Size:ContentLength,MIME:ContentType}"

        # SYNTAX: ".[]" is ARRAY operation; all nodes of all indices therein; "[0]" is first index
            ...|jq .[].foo.bar.baz    # get "baz" field VALUEs
            ...|jq .[].baz            # equivalent

            ...|jq -r .keyX           # keyX VALUE; RAW output (unquoted)
            ...|jq -r .               # ALL key-val pairs, unfiltered; RAW output

            ...|jq  '.P[] | .X, .W'  
            #... Get all values of keys X and W in the array of objects under key P 

                # Example ...
                aws route53 list-hosted-zones |jq  '.HostedZones[] | .Name, .Id'
                    # =>
                    "foo.com."
                    "/hostedzone/Z2H0UGL2BNA1BN"
                    "bar.org."
                    "/hostedzone/Z03607453CJ16NGTHYTYE"

        # Filter and process an ARRAY of OBJECTS ...

            printf '{
                "a": [{"foo":"1", "bar":"2"},{"foo":"999", "bar":"77"}]

            }' |jq .a[].bar
                # "2"
                # "77"
            ...|jq -r .a[].bar  # JOIN (raw)
                # 2
                # 77
            ...|jq .a[1]        # PER INDEX; second el
            # {"foo": "999","bar": "77"}
            ...|jq -c '.a[] | .foo, .bar' 
            #... All values of keys foo: and bar: in the array under key a:
                # "1"
                # "2"
                # "999"
                # "77"

            # Functions

                # Filter ARRAY ELEMENTS by a KEY
                    ...|jq '.[] |select(.aKey == "aVal")'

                    ...|jq '.a[] | select(.foo | contains("999"))'  

                # Sum 'price' field
                    # {"foo":"999","bar":"77"} 
                    ...|jq 'map(.price) | add'  

        # Transform list of STRINGs to ARRAY
            ...|jq -Rn '[inputs]' # If string delimiter is newline

        # Transform ARRAY to Tab Separated Values : @tsv filter, or @csv, @html, ..
            printf '[{
                        "name": "George",
                        "id": 12,
                        "email": "george@domain.example"
                    }, {
                        "name": "Jack",
                        "id": 18,
                        "email": "jack@domain.example"

            }]' |jq -r '["NAME","ID"],["------","--"],(.[] | [.name,.id]) | @tsv'

                # NAME    ID
                # ------  --
                # George  12
                # Jack    18

    yq  # jq for YAML : https://github.com/mikefarah/yq 

        # Convert JSON to YAML
            yq eval -P -o yaml $a.json |tee $a.yaml
        # Access a key name having spaces, hyphens and/or such
            lscpu |yq  '.["Vulnerability Spectre v1"]'
        # Convert items[] to "---" delimited YAML documents 
            # If 1st 1st-order key is "apiVersion" 
            yq '.items | .[]' $yaml |sed '1!s/^apiVersion/---\napiVersion/'
            # E.g., Capture all ConfigMaps (cm) of a Namespace
            yq '.items | .[]' <(kubectl get cm -o yaml) |sed '1!s/^apiVersion/---\napiVersion/'
        # Filter array elements : Get .secret at array element (object) having .name equal to $name
            yq '.[] |select(.name == "'$name'").secret' $keys_array_yaml
        # Extract one YAML document (.kind) from a (K8s) manifest having many documents: 
            yq 'select(.kind == "'$kind'")' $manifest 
            # E.g., Compare app versions (blue/green manifests) at a particular resource (kind) 
                doc(){ yq 'select(.kind == "'$1'")' $2; }
                diff <(doc $kind $blue) <(doc $kind $green)
        # Helm chart images
            template=helm.template
            helm -n $ns template $chart |tee $template.yaml
            rm $template.images
            for kind in DaemonSet Deployment StatefulSet; do
                yq 'select(.kind == "'$kind'") |.spec.template.spec.containers[].image' $template.yaml |
                    tee -a $template.images
                yq 'select(.kind == "'$kind'") |.spec.template.spec.initContainers[].image' $template.yaml |
                    tee -a $template.images
            done

    envsubst # Environment Substitution : Substitutes environment variables contained in a file
        # Use to process templates safely (sans regex) and declaratively.
        envsubst < /path/to/template > /path/to/artifact  
        # For in-place processing of target file, pipe to sponge (moreutils)
        envsubst < target |sponge target # Sponge reads *all* piped input, *then* writes out
        # Example 1 : Parameterized values
        export v1=22
        tee a.yaml.tpl <<-'EOH'
		creds:
		  user: $USER
		  home: $HOME
		k1: $v1
		EOH
        envsubst < a.yaml.tpl
        # creds:
        #   user: u1
        #   home: /home/u1
        # k1: 22
        #
        # Example 2 : Parameterized keys and values
		tee app.oci.tpl <<-'EOH'
		FROM alpine:latest
		...
		ENTRYPOINT ["app"]
		CMD ["--help"]
		LABELS $OCI_NAMESPACE.built: $BUILT
		LABELS $OCI_NAMESPACE.author: $AUTHOR
		EOH
        export OCI_NAMESPACE=lan.lime
        export BUILT=$(date -Is)
        export AUTHOR=$(git config --get user.account)
        envsubst < app.oci.tpl > app.oci
        # ...
        # LABELS lan.lime.built: 2025-12-05T11:28:59-05:00
        # LABELS lan.lime.author: gd8n

    sed  # Stream EDitor; line-oriented text-file editor; "non-interactive", i.e., source file is unaffected 
         # MANUAL      https://www.gnu.org/software/sed/manual/html_node/The-_0022s_0022-Command.html#The-_0022s_0022-Command
         # CheatSheet  https://gist.github.com/ssstonebraker/6140154 
         # sed/awk     http://www.tldp.org/LDP/abs/html/sedawk.html  

        sed EXPRESSION FILE     # FILE unchanged
        # OVERWRITE source (FILE)
        sed -i     EXPRESSION FILE  # -i; in-place; overwrite target file
        sed -i.bak EXPRESSION FILE  # -i; in-place; overwrite target file; BACKUP FIRST

        sed -n    ... FILE  # -n; quiet; usually UNNECESSARY 
        sed -e SCRIPT FILE  # -e; script; usually UNNECESSARY 

        # PIPE FILE (fname upon which to operate)
        ... |xargs sed ...

        # Run foo N times (xargs -Iz; ignore piped value)
        sed N |xargs -Iz foo  

        # PIPE STRING instead of source file
        ... |sed ...
        
        sed 's:// .*::' FILE # STRIP FILE of ALL COMMENTS: "// ...NOTE space else 'http://' too"
        sed '3p'   FILE         # p; print line 3
        sed '2d'   FILE         # d; delete 2nd line
        sed '2i foo bar' FILE   # i; insert line: 'foo bar' @ line 2; prepends, so l2 pSushed to l3   
        sed '2,4!d'  FILE       # !d; delete all lines except 2-4
        sed '2,4p' FILE         # p; print lines 2 thru 4
        sed '5,10d;12d'   FILE  # d; delete lines 5-10 and 12
        sed '/PATTERN/d'  FILE  # d; delete lines containing PATTERN
        sed '\,PATTERN,d'  FILE # Same as above, but delimiting with "," (backslash oddly required for d, but not s)
        sed '/SEARCH/c\REPLACE' # c\; replace lines containing SEARCH str with REPLACE str
        sed 's/foo/bar/'  FILE  # s; subst 'foo' for 'bar'; FIRST/ONCE
        sed 's/foo/bar/I' FILE  # s/I; case Insensititve; FIRST/ONCE
        sed 's/foo/bar/g' FILE  # s/g; search and replace ALL
        sed 's/foo/bar/4' FILE  # s/4; replace only 4th instance in a line
        sed 's/foo//'     FILE  # s; delete 'foo'; FIRST/ONCE
        sed "s/$foo//Ig"  FILE  # s/Ig; delete ALL $foo, case Insensitive; (NOTE double quotes)
        sed '/^[\t]["]/d' FILE  # Remove lines that START WITH TAB followed by a double-quotes char.
        sed 's/PATTERN.*$//' .. # Remove all lines START WITH OR APPENDED WITH PATTERN
        sed '/^$/d' FILE        # Remove all BLANK/EMPTY LINES
        sed '/^\s*$/d' FILE     # Remove all BLANK/EMPTY LINES and those with only whitespace

        sed -i 's/.html//g; s/REF.//g' "names.log" # in-place; MULTIPLE EXPRESSIONs (delimited by `;`)
        sed 'n;n;s/./x/'  FILE  # Substtute every 3rd line w/ 'x'
                                # `.` is `*`, and `n` is line/command to skip
        sed 's/.$//'      FILE  # Delete LAST CHAR 
        sed '/^\s*$/d'    FILE  # Remove all BLANK/EMPTY lines
        sed '/^[#]/d'     FILE  # Remove all lines START w/ comment (#) only if it is FIRST CHAR
        sed '/^ *#/d'     FILE  # Remove all lines START w/ comment (#) even w/ ONLY SPACES prepending
        sed 's/\t/  /g'   FILE  # Replace TAB w/ 2-spaces
        sed 's/\n//g'     FILE  # Delete all NEWLINE chars *** USE: tr -d '\n'
        sed 's/[][]//g'   FILE  # Strip square-brackets
        printf "%s" "$@" |sed 's/[][]//g' # `[foo[.bar]z[oo]too` => `foo.barzootoo`

        # STRIP all COMMENTS (appended-inline too) and EMPTY LINES from a Bash file
            ... |sed -E '/^[[:space:]]*#/d; s/[[:space:]]+#.*$//' |sed '/^[[:space:]]*$/d'

        # REPLACE LINEs having matching PATTERN
            sed '/PATTERN/s/.*/REPLACEMENT/' FILE
                # E.g., 
                sed "s#file:///d:/1%20Data/IT.*/##g" REF.Ai.md

        # DELETE all EMPTY LINES
            sed '/^[[:space:]]*$/d' FILE 

        # DELETE all LINEs having FIRST CHAR "#"
            sed '/^[[:space:]]*#/d'

        # Remove non-word (neither letter, digit, nor underscore) characters
            sed 's/\W//g' FILE

        # Remove ANSI color codes and (some?) control characters
            sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g' FILE
            # OR
            sed -r 's/[[:cntrl:]]\[[0-9]{1,3}m//g' FILE

        # Remove control characters 
            sed -e "s/\x1b\[.\{1,5\}m//g" FILE
                
        # Remove SUBSTR (ALL instances)  per DELIMITERs L and R (all content btwn the two)  
            sed -e 's/L.*R//' FILE > RESULT  # I.e., per "wildcard" with delimiters

        # OTHER Delimiters okay; here use '#' instead of '/', so paths can be processed
            sed 's#/foo/bar#/alpha/bravo#g' FILE

        # HANDLE WHITESPACE; 'Fo BaR' => 'fbar'
            sed s/foo[[:space:]]bar/fbar/Ig FILE 
        
        # STRIP PREPENDING `./` from PATH(s)
            find . ... |sed 's/\.\///g' # `./foo bar/baz` => `foo bar/baz`
            sed -r 's/^(.)\///'  # per RegEx
            sed -n 's|./||p'     # per Extended RegEx, `p`; quiet, `-n`, else repeated twice

        # Delete line containing PATTERN in all files 
            find . ... -exec sed -i '/PATTERN/d' "{}" \+ 

        # RegEx 
            sed -re ... # RegEx (-r), edit (-e)
            sed -re 's/^([a-k]|[A-K])searchFoo/replacementFOO/' FILE
            sed -n 's|./||p'  # Extended RegEx

        # REPLACE 4 SPACES with 2 SPACES at (start) indent
            sed -e 's/^/~/' -e ': r' -e 's/^\( *\)~    /\1  ~/' -e 't r' -e 's/~//' FILE
        # REPLACE 2 SPACES with 4 SPACES at (start) indent
            sed -e 's/^/~/' -e ': r' -e 's/^\( *\)~  /\1    ~/' -e 't r' -e 's/~//' FILE

        # STRIP CHARS per their (ASCII) decimal representations; over a range thereof
            LANG=C sed 's/[\d128-\d255]//g' FILE  # strip all above Basic Latin, i.e., above alpha-num + sp-char
            LANG=C sed 's/[\d000-\d031]//g' FILE  # strip all control chars

        # PREPEND a LINE_OF_TEXT
            xargs sed -i '1s;^;LINE_OF_TEXT\n;' FILE 

        # Process SOURCE file; store results to TARGET file
            sed EXPRESSION < SOURCE > TARGET # source file remains unmodified

        # Parse PATH Env.Var.  
            echo $PATH |sed 's/:/\n/g'  # parsed into one path per line, repl. `:` with `\n`

        # Windows to POSIX path CONVERSION : C:\FOO\bAr => /c/FOO/bAr
            echo "/${path,}" |sed 's/\\/\//g' |sed 's/://' 
            # As a function:
            win2posix() { printf "/%s" "${@,}" |sed 's#\\#/#g' |sed 's#:##' ; }

            # if ESCAPED : C:\\FOO\\bAr => /c/FOO/bAr
            echo "/${path,}" |sed 's#\\\\#/#g' |sed 's#:##'
            # As a function:
            win2posix() { printf "/%s" "${@,}" |sed 's#\\\\#/#g' |sed 's#:##' ; }

        # SEARCH/REPLACE : PATTERN MATCH; Process ALL FILEs @ current DIR+subdirs  

            # ALL FILES in $PWD; OVERWRITE matching file(s)
            # Note: sans grep, sed touches ALL FILES (mtime), not only those matching/overwritten
            # replace all 'Apple Pie' with 'big fluffy waffle' (inexplicably fails sometimes @ subdirs)
            grep -l 'Apple Pie' * 2> /dev/null |xargs sed -i 's/Apple Pie/big fluffy waffle/g' 
            # ... same but recurse dirs; delete per line(s) containing PATTERN
            grep -liR PATTERN * 2> /dev/null |xargs sed -i '/PATTERN/d' 

            # Parameterize, and use `#` delimiter; to search and replace paths containing forward slash(es)
            grep -l "$_srch" * 2> /dev/null |xargs sed -i "s#$_srch#$_repl#g" 
            # much BETTER; more reliable @ recurse (subdirs) ... 
            find . -type f -exec grep -l "$_srch" "{}" \+ |xargs sed -i "s#$_srch#$_repl#g"

    sort # sort "fname", line-by-line, write result to "sorted"
        -z, --zero-terminated    # line delimiter is NUL, not newline
        -n, --numeric-sort       # compare according to string numerical value
        -k KEYDEF, --key=KEYDEF  # target single field/collumn; KEYDEF = FIELD.CHAR; both start @ 1 
        -h, --human-numeric-sort # compare human readable numbers (e.g., 2K 1G)
        -n, --numeric-sort       # compare according to string numerical value 
        -u, --unique             # sort and make unique; remove duplicates
        -f, --ignore-case 
        -r, --reverse  
        -R, --random-sort        # Randomize

        # sort `ll` command per 6th key (collumn)
        ll |sort -k 6

        # sort FILE
        sort < FILE > sorted
        sort > sorted < FILE  

        # sort SPACE-DELIMITED string; cnvrt nwln-to-whtspc and back  
        printf "%s " "$STR" |tr ' ' '\n' |sort |tr '\n' ' '
        # sort per Mth char of Nth key (field/collumn) of FILE and convert to space-delimited string
        sort --key=$Nth.$Mth FILE |tr '\n' ' '  # sans `.$Mth` DEFAULTS TO FIRST CHAR of Nth field

        # sort and make uniq; remove duplicates
        sort -u FILE

        # filter per sort/uniq
        sort < unfiltered |uniq > filtered 

        # Sort; remove duplicates (UNIQUE); prepend frequency (NUMBER OF OCCURENCES) 
        sort FILE |uniq -c

    uniq  # remove/count duplicated lines
        uniq FILE     # remove duplicates 
        uniq -c FILE  # prepend FREQUENCY to each line
        uniq -d FILE  # show only duplicated lines
        uniq -u FILE  # show only unique lines

    column  # delimiter to table (columnar)
        column -t -s 'DELIMITER' FILE

        cat CSVfile  #=>
            #  id,name,count
            #  31232,test-1,21
            #  2121,update-attributes,432
        column -t -s ',' CSVfile  #=>
            #  id     name               count
            #  31232  test-1             21
            #  2121   update-attributes  432
        
    tr  # translate (convert|delete|strip|trim|squeeze)
        tr OPTIONs < FILE  # per file input
        ...|tr OPTIONs    # per pipeline input
        # [:alnum:]       all letters and digits
        # [:alpha:]       all letters
        # [:blank:]       all horizontal whitespace
        # [:cntrl:]       all control characters
        # [:digit:]       all digits
        # [:graph:]       all printable characters, not including space
        # [:lower:]       all lower case letters
        # [:print:]       all printable characters, including space
        # [:punct:]       all punctuation characters
        # [:space:]       all horizontal or vertical whitespace
        # [:upper:]       all upper case letters
        # [:xdigit:]      all hexadecimal digits
        # [=CHAR=]        all characters which are equivalent to CHAR
        
        # Strip all non-printable characters from $_bad_str
        echo "$_bad_str" |tr -dc '[[:print:]]'
        # Equivalent:
        tr -dc '[[:print:]]' <<< "$_bad_str"

        # Convert (translate) all NEWLINE to whitespace
        tr '\n' ' '  < FILE     

        # Delete all NEWLINE and WHITESPACE chars
        ...|tr -d '\n' |tr -d ' '

        # xargs : 2 input lines per 1 output line
        cat "$file" |tr ' ' '\n' |xargs -l2
        # Equivalent
        tr ' ' '\n' < "$file" |xargs -l2 

        # Convert (translate) lowercase (existing file) to UPPERCASE (create file)
        tr '[:lower:]' '[:upper:]' < lowerFILE > upperFILE  

        ...|tr '[A-Z]' '[a-z']          # Alt syntax (uppercase to lowercase)
        ...|tr ':' '\n'                 # replace colons with newline
        ...|tr -d L                     # delete all 'L' chars
        ...|tr -s L                     # squeeze (multiple to one)

    head -$N FILE # Filter out all but FIRST N lines of FILE 
        -c $bytes  # Bytes instead of lines.
        -z         # NULL delimited instead of NEWLINE.
    tail -$N FILE # filter out all but LAST N lines of FILE
        tail +20 < unfiltered |head -n30 > filtered 

    groff  # front-end for the groff document formatting system  https://www.gnu.org/software/groff/

# JSON processor
    jq  # like sed, but for JSON data : https://stedolan.github.io/jq/  

    node # Node.js at commandline : Read JSON file using require(PATH)
        # > var data = require('./images.json')
        # undefined
        # > data
        # [ { image: 'busybox', tags: [ 'latest', '1.32.0' ] },
        # { image: 'nginx/nginx', tags: [ '1.17.0', '1.88.2', '1.19.1' ] } ]
        # > data.map(x =>x.image)
        # [ 'busybox', 'nginx/nginx' ]

# EVALUATE EXPRESSIONS per `expr`
    expr EXPRESSION  # Evaluate EXPRESSION; print its VALUE to STDOUT  
    # a GNU Core Util  https://www.gnu.org/software/coreutils/manual/html_node/expr-invocation.html
    # Expressions:
         ARG1 |ARG2               # ARG1 if it is neither null nor 0, otherwise ARG2 
         ARG1 & ARG2               # ARG1 if neither argument is null or 0, otherwise 0 
         ARG1 < ARG2               # ARG1 is less than ARG2 
         ARG1 <= ARG2              # ARG1 is less than or equal to ARG2 
         ARG1 = ARG2               # ARG1 is equal to ARG2 
         ARG1 != ARG2              # ARG1 is unequal to ARG2 
         ARG1 >= ARG2              # ARG1 is greater than or equal to ARG2 
         ARG1 > ARG2               # ARG1 is greater than ARG2 
         ARG1 + ARG2               # Arithmetic sum of ARG1 and ARG2 
         ARG1 - ARG2               # Arithmetic difference of ARG1 and ARG2 
         ARG1 \* ARG2              # Arithmetic product of ARG1 and ARG2 
         ARG1 / ARG2               # Arithmetic quotient of ARG1 divided by ARG2 
         ARG1 % ARG2               # Arithmetic remainder of ARG1 divided by ARG2 
         STRING : REGEXP           # Anchored pattern match of REGEXP in STRING 
         match STRING REGEXP       # Same as STRING : REGEXP 
         substr STRING POS LENGTH  # Substring of STRING, POS counted from 1 
         index STRING CHARS        # Index in STRING where any CHARS is found, or 0 
         length STRING             # Length of STRING 
         + TOKEN                   # Interpret TOKEN as a string, even if it is 
                                   # a keyword like 'match' or an operator like '/'
        # E.g., 
            expr 'ss64' : 'ss6'    # 3   
            expr 5 + 2             # 7
            expr substr 'foo' 1 2  # fo


# FILE PROCCESSING UTILITIES

    # WORD COUNT : Count newlines, words, ...
    ## Works on either a file or piped string.
        wc FILE     #=> #newlines #words #bytes fname
        wc < FILE   #=> #newlines #words #bytes
        wc -l FILE  #=> #newlines FILE
        wc -m FILE  #=> #chars FILE

        # E.g., Get the number of commits in a Git repo
        cn=$(git log --oneline |wc -l)

    file FILE  # info; ASCII or binary
    
    diff FILE1 FILE2  # compare FILEs, line by line
    diff -ENwburq dir1 dir2  # list ALL FILES that differ BTWN TWO DIRS 
    # List paths of PATHS_NEW file (--left-column) that differ (mtime) from PATHS_OLD
    find . -type f -printf "/%P %T@\n" |awk '{printf "%s\t%s" $2,$1}' > PATHs_OLD
    #... and again later, same dir, redirecting to PATHs_NEW ...
    diff -y --suppress-common-lines -W 1000 --left-column PATHs_NEW PATHs_OLD |awk '{print $2}'

    comm file1 file2  # compare SORTED FILEs, match line by line; 3 collums out; unique to 1, 2, both (3)
    cmp  file1 file2  # compare FILEs, byte by byte; '-s' silent; $? = 0|1 ; idential|NOT
    COMMAND |cmp - file2  # compare ... where 'file1' is stdout of COMMAND

    # CONVERT LINE ENDINGS; DOS to UNIX; `-k` to keep modtime 
        dos2unix -k FILE outFILE 
        dos2unix < FILE  # STDIO mode (FILE unchanged; prints to stdout)
        cat FILE |dos2unix > /dev/stdout  # write to stdout
        # TEST; dos (CRLF) or unix (LF); $? is '1' if DOS; '0' if UNIX
            dos2unix < FILE |cmp -s - FILE 
            # or 
            file FILE |grep 'CRLF'

    # CONVERT/process GRAPHICS files ("REF.Apps.ImageMagick.sh")
        convert IN.jpg  \
            # Proportional SCALING (pixels)
            -scale 1500 \
            # Black TRANSPARENT OVERLAY
            -fill black -colorize 50% \
            OUT.png  
    # CONVERT/process VIDEO files ("REF.Apps.FFmpeg.sh")
        ffmpeg -ss 01:08:30 -i IN.mp4 -t 00:25:42 -c copy OUT.mp4  # CUT/CLIP (start/duration)

    # CONCATENATE/Print 
        cat {foo,bar}.txt  # concat file(s); print to STDOUT; '^M$' @ dos, '$' @ unix
        cat -e FILE     # show line-endings of ASCII files; $M
        cat -n ...         # prepend LINE NUMBERS

        nl FILE  # prepend number-lines
        pr FILE  # print file per page(s), w/ date-time, fname, pg# header

        # UNION/INTERSECTION (AND|OR) files
        cat a b |sort |uniq > c       # c is a union b   (sum)
        cat a b |sort |uniq -d > c    # c is a intersect b   (common) 
        cat a b b |sort |uniq -u > c  # c is positive residual of a - b  (diff) 
        # XOR (lines not in both)
        awk 'FNR==NR {a[$0]++; next} !a[$0]' file1 file2
    
        echo FILE |cat -  # READ from STDIN; useful TO FORM PIPES 
        echo FILE |cat    # read from stdin; same;
        var=$(cat)        # SET VAR to STDIN

    # PRINT
        less FILE  # print to STDOUT file PER PAGE; vi cmds; search/find @ '/<string>'; 'q' to quit
        head [-n 2] FILE  # FIRST 2 LINES of file; DEFAULT is 10 LINES
        head -n 20 FILE |tail -n 1  # line 20 
        tail [-n 5] FILE  # LAST 5 LINES of file; DEFAULT is 10 LINES
        tail -f FILE      # follow (LIVE monitor); last 10 lines of file 

    # MERGE/SPLIT; LINE by LINE (cut-n-paste)
        join FILE bar.txt  # merge 2 SORTED files (data-series) per common field (collumn]

        paste FILE bar.txt        # MERGE files line by line
        paste -d '' FILE bar.txt  # merge 2 files line by line; concat per specified delimiter 

        split -l 2 FILE    # split file into files (xaa, xab, xac, ...]; n lines per file
        split -b 512 FILE  # split file into files; n bytes (chars] per file

    # FILTER Chars/Lines

        expand FILE       # convert tabs to spaces (one to many; preserve alignment]
        unexpand -a FILE  # convert spaces to tabs; initial default; all (-a)

        fmt -w 20 FILE # format text to 20 chars per line; strip out new-line etc

        # Dump FILE in octal or other formats
        od FILE     # octal dump; e.g., look @ binary having non-printable chars
        od -c FILE  # char dump; show non-printable chars, new-lines etal
        od -o FILE  # dump FILE in octal

# calendar
    cal    # this month
    cal -3 # 3 months 
    cal -y # whole year
    
# factor
    factor 12345
    # => 12345: 3 5 823

# number format
    numfmt --to=iec 4123412312312 # 3.8T

# I/O (IO)  http://www.etalabs.net/sh_tricks.html

    # Copy FILE CONTENT to Clipboard per Xclip; if installed
        cat FILE |xclip -i 

    # echo options 
    echo -e "Suppress trailing new line \c"
    echo -e " \a\t\tfrom this string\n"

    echo -n "Suppress trailing new line"
    echo -e " \a\tfrom this string, AND add new line here ...\n"

    # read : get input from user
    echo -n 'Enter a param: '
    read param1
    echo -e '\nYou entered "'$param1'"\n'

    # colors
    echo -e "\033[1;31m$@\033[0;39m"  # $@ printed in red

    echo -e "\033[1;32m$@\033[0;39m"  # $@ printed in green

    echo "$foo" |...  # NEVER USE echo like this, to pipe; behavior varies per platform/environment 

    tput # COLOR AND CURSOR MOVEMENTS utility (handles ANSI Escape Sequences (below)
        # http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
        # http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux/20983251#20983251
        tput setab [0-7] # BACKGROUND colour using ANSI escape
        tput setaf [0-7] # FOREGROUND colour using ANSI escape

        tput smul    # Enable underline mode
        tput rmul    # Disable underline mode

        tput smso    # Enter standout (bold) mode
        tput rmso    # Exit standout mode

        # tput : bold red text
        echo "$(tput bold)$(tput setaf 1)This is the Affected Text"
        # underlined text / green background
        echo "$(tput smul)$(tput setab 2)This is the Affected Text"
        # reset all attributes
        echo -e -n "$(tput sgr 0)"
        # show colors
        for (( i = 0; i < 9; i++ )); do echo "$(tput setaf $i)This is ($i) $(tput sgr 0)"; done

        # tput : init, clear, reset
        tput init; 
        echo init ; read bogus
        tput setab 2 
        echo setab 2 ; read bogus
        tput clear
        echo clear ; read bogus
        tput reset
        echo reset ; read bogus

    printf  # FORMAT (ARGUMENT)
        #   http://wiki.bash-hackers.org/commands/builtin/printf
        #   http://linuxconfig.org/bash-printf-syntax-basics-with-examples

        printf "%03d\t" {7..10} 
        007   008   009   010

        printf 'f%.1s ' {8..11}
        f8 f9 f1 f1

        printf %s\\n  "$var"  # print var + newline
        printf "%s\n" "$var"  # equiv

        printf "\\%.3o"   "$foo"         # 3 digit octal code; '\ooo'
        printf "%30.40s" "computerhope" # MIN.MAX width  See 'REF.syntax.sh'
        printf "%-22s"                  # left-justify; right @ `+`
        printf "%s\t%s\n" '1' '2 3' 4 "5"   # strings
        1       2 3
        4       5
        printf "%d\n" "255" '0xff' 0377      # integers 
        255
        255
        255
        printf "%.1f\n" 255 0xff 0377 3.5   # floating-point
        255.0
        255.0
        377.0
        3.5
        printf "\n\n\t %s -- String \n\t \"%s\" -- Quote-formatted \n\t %d -- Number Format \n\t %05d -- Number Format \n\t %#x -- 255 in Hex \n\t%5.2f -- Float \n\t %u. -- Unsigned Value \n" 'foo' 'bar' '123456' '89' '255' '3.14159' '250'
                 foo -- String
                 "bar" -- Quote-formatted
                 123456 -- Number Format
                 00089 -- Number Format
                 0xff -- 255 in Hex
                 3.14 -- Float
                 250. -- Unsigned Value

        for i in $( seq 1 10 ); do printf "%03d\t" "$i"; done
        001     002     003     004     005     006     007     008     009     010
        printf "%03d\t" {1..10}
        001     002     003     004     005     006     007     008     009     010

        # print 1 random ASCII char (stupid slow way)
        printf "%b" "$( printf "\\%.3o" "$(( ( RANDOM % 255 ) ))" )"

    # UNICODE : ASCII/ANSI (CODE) compatible (ASCII is subset of Unicode)
        #   ASCII is 7-bits (128 chars); ANSI is 8 bit, "ASCII Extended" (Latin-1 Table (ISO 8859-1))
        #   ... all of which is typically referred to as "ASCII"
        #   https://en.wikipedia.org/wiki/Unicode
        # UTF-8 (Unicode Transformation Format; 8-bit/byte) 
        #   an 8-bit variable-width encoding which maximizes compatibility with ASCII;
        #   https://en.wikipedia.org/wiki/UTF-8
        # ASCI/ANSI Character Set
        # http://www.ascii-code.com/      0-255  {oct[000-377]}    256  [224 printable]
        #   ASCII control [unprintable]:   0-31  {oct[000-037]}     32 
        #   ASCII printable characters:  32-127  {oct[040-177]}     96
        #   ASCII extened character:    128-255  {oct[200-377]}    128
        # E.g., '!' = 33 [decimal], 041 [octal], x21 [hex], u0021 [Unicode]
        #
        # ANSI NOTATION; ANSI Escape Sequences: Colours and Cursor Movement (sans 'tput' utility)
        #   http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/c327.html

        # octal notation '\0ooo'
        printf "\041"  # => !
        printf '\041'  # => !
        echo  $'\041'  # => ! {uses ANSI notation}
        # hex notation '\xHH'
        printf '\x21'  
        echo  $'\x21'  
        # UNICODE notation '\uHHHH' 
        printf '\u0021'  
        echo  $'\u0021' 

        # Unicode vs. Hex
        '\u0950' == '\xe0\xa5\x90'  # ॐ (DEVANAGARI OM)

        # %b - expand backslash escape sequences  
        printf "\n%b\n" ' 0- \u002A - \u007E \u2122 \u2120 \u2627'
        # => 0- * - ~ ™ ℠ ☧
        
        # print all ASCII chars ...
        for (( i = 0 ; i <= 255; i++ )) ; do _ASCII="$( printf "\\%.3o" "$i" )" ; printf "%b\t%s\n" "$_ASCII" "[$i]"  ; done

    base64 FILE # Encode/Decode(-d) FILE; https://en.wikipedia.org/wiki/Base64 
    base64 -w 0 FILE #... encode sans line wrap, ELSE ADDS NEWLINE CHARACTERS
    ... |base64 -w 0 - > FILE.base64 # Encode STDIN and redirect STDOUT to FILE.base64
    # Base64 URL replaces '+' with '-' and '/' with _', and strips (trailing) padding '='
    # Used @ HTTP Basic Authentication header : 'Authorization: ...' or 'WWW-Authenticate: ...'
    base64URL="$(printf $user:$pass |base64 |sed 's/+/-/g' |sed 's#/#_#g' |sed 's/=//g')"
    authHeader="Authorization: Basic $base64URL"
    # ... some implementations wrongly replace padding with '.', which introduces vulnerability.
    base32 FILE # Encode/Decode FILE; per alphabet (e.g., RFC4648); https://en.wikipedia.org/wiki/Base32

    xxd  # make a hexdump or revert (to binary).
    xxd [options] [infile [outfile]]
        -r[evert] [options] [infile [outfile]]
        -p  # Postscript continuous (plain) style

        # E.g., generate SHA384 hash for CSP/SRI 
        printf "sha384-$(shasum -b -a 384 "$@" \
            |awk '{ print $1 }' |xxd -r -p |base64)"

    # Text to ASCII Art 
    figlet TEXT

    # colors : show full fore/back color grid
        for fg_color in {0..7}; do
            set_foreground=$(tput setaf $fg_color)
            for bg_color in {0..7}; do
                set_background=$(tput setab $bg_color)
                echo -n $set_background$set_foreground
                printf ' F:%s B:%s ' $fg_color $bg_color
            done
            echo $(tput sgr0)
        done

    # Print FILE mtime 
    date -r FILE "+%Y-%m-%dT%H:%M:%S"  # YYYY-MM-DDTHH:MM:SS
    date -r FILE "+%F %a %H.%M.%S.%N"  # YYYY-MM-DD DAY HH.MM.SS.nnnnnnnnn

    # GET USER INPUT ...
        read _SET_THIS_VAR
        # example ...
        read [-ers] [-u fd] [-t timeout] [-a aname] [-p prompt] [-n nchars] [-d delim] [name ...]

        printf "\n %s" '  Create hosts file [Y] ' ; read -n 1 _query ; echo
        # ... same thing ...
        read -n 1 -rp '  Create hosts file [Y] ' _query

        # READ a LINE of input from STDIN; store result in var
        # line must be terminated by newline, end of file, or error condition 
        IFS= read -r var  # http://www.etalabs.net/sh_tricks.html

        # One common pitfall is trying to read output piped from commands, such as:
        # http://www.etalabs.net/sh_tricks.html
            foo | IFS= read var

            # POSIX allows any or all commands in a pipeline to be run in subshells, and which command (if any) runs in the main shell varies greatly between implementations (e.g., bash/ksh). The standard idiom for overcoming this problem is to use 'HERE DOCUMENT'. E.g., ...

            # NOTE:  `-` DISABLES leading TABS, but NOT spaces; '<<-EOM'.

            # Set $var to MULTI-LINE STRING 
            #    read -r -d '' var <<-EOM
            #    github.com/uudashr/gopkgs/cmd/gopkgs
            #    github.com/nsf/gocode
            #    github.com/ramya-rao-a/go-outline
            #    EOM
            # or simply ...
                var="
                github.com/uudashr/gopkgs/cmd/gopkgs
                github.com/nsf/gocode
                github.com/ramya-rao-a/go-outline
                "
            # Write MULTI-LINE STRING to FILE
            #    cat <<-EOM > FILE
            #    These contents will be written to FILE.
            #    Derp derp.
            #    EOM

# FILE COMMANDS
    cat; chmod; cp; diff; file; find; gunzip; gzcat; gzip; head; lpq; lpr; lprm; ls; mkdir; more; mv; rm; tail; touch
    # https://github.com/Idnan/bash-guide#11-file-operations
    
    .     # $PWD
    ..    # parent dir
    .fname   # hidden file

    
    cp /a/b/* . # Copy all files (only) at root of /a/b/ to $PWD 
    rm a/b/*    # Delete all files and folder of /a/b/, but not /a/b itself.

    ln # LINKs : `man ln` refers to (created) LINK as DIRECTORY, and existing path (source) as TARGET.
        # Do NOT USE relative paths, else may err: "Too many levels of symbolic links"
        # Hard link points to TARGET; SAME INODE; NOT link between volumes (device/partition/fs)
        ln TARGET LINK     # create HARD link
        # Soft link points to TARGET (FILE|DIR); creates NEW INODE; Okay to link between volumes.
        ln -s TARGET LINK  # create SOFT link  
        ln -fs TARGET LINK # create SOFT link, forcibly (delete pre-existing)
            # .
            # └── a
            #     └── x
            ln -s a b
            # .
            # ├── a
            # │   └── x
            # └── b -> a
        # LINK TEST; is FILE is a symlink
        [[  $(stat -c %h FILE) -gt 1 ]] && echo "FILE is a Symbolic Link"
        # LINK TEST; file exists AND is a symbolic link; FLAKY BEHAVIOR  
        [[ -L "$@" ]] && echo "SYMLINKed" # -h; same
        # EXACT hardlink TEST; two *existing* files are SAME iNODE; 'ls -i' shows inode number
        [[ "$(ls -i FILE1 |awk '{print $1}')" == "$(ls -i FILE2 |awk '{print $1}')" ]] 

    # test mod/update before/after 
    _mtime="$( stat -c %Y "$@" 2> /dev/null )"
    # possibly do stuff to file $@
    (( "$( stat -c %Y "$@" 2> /dev/null )" > "$_mtime" )) && echo newer || echo not newer

    [[ $file1 -nt $file2 ]] && echo "$file1 is newer than $file2"

    (> "$@" )   # create empty file
    > "$@"      # create empty file 
    touch "$@"  # create empty file if not exist, else update atime

    # GLOBs; GLOBBING 
    ls  -1drt "$PWD/"*    # full paths, 1 path per line, newest last, @ CURRENT dir files & folders
    ls  -1drt "$PWD/"*/*  # full paths, 1 path per line, newest last, @ SUBDIRS 1 LEVEL DEEP (NOT $PWD files)

    # find newest file (fname.ext) in folder (pwd)
    ls -tr |tail -n 1
    # set var to it 
    newest=$( ls -tr |tail -n 1 )

    # $$ = PID of current process 
    echo "AVOID.insecure.tmp.namespaces.eg.$$" 
    # PID will most likely be between 1 and 33000

    mktemp # Make a semi-secure temp dir or file (and print its path)
        mktemp                                  # file @ PWD
        mktemp -d "${0##*/}.XXXXXXX"            # dir @ PWD
        mktemp -p "$TMP" -d "${0##*/}.XXXXXX"   # dir @ $TMP
        mktemp -dt                              # dir @ $TMPDIR 

        # Native linux shim for mktemp
            _tmp_dir="$TMP/${0#*/}.$$.$PPID.$(date +%H.%M.%S.%N)"
            ( umask 077 && mkdir "$_tmp_dir" 2> /dev/null ) || { printf "FAIL @ mkdir" ; }

    $(basename -s .sh $i) # remove trailing suffix ".sh"

    lsof           # list open files;
    lsof -P -g -n  # 'list apps connected to network'
    # -g: display PGID numbers; -n: no IP to hostname conversions; -P no port-number conversions

    # read : file line-by-line http://wiki.bash-hackers.org/commands/builtin/read
    while read -r; do ((i+=1)); echo "$i  "'"'$REPLY'"'; done < "$@"
    OR
    echo "$(<$0)" | while read -r; do ((i+=1)); echo "$i  "'"'$REPLY'"'; done

    # Merge and sort a selection of files
    sort -m <(zcat fname.1.gz) <(zcat fname.2.gz) ... |gzip -c > merged.gz

    # paste / join files line by line [tab delimited]
    paste fname1 fname2  # line-by-line merge of files
    join  fname1 fname2  # requires identical indices @ one collumn

    # cut : Divide a file into several parts, per field (collumn)
    cut -f2 fname           # extract 2nd field (collumn) [tab delimited]
    cut  -d' ' -f2  fname   # extract 2nd field (collumn) [space delimited]
    cut  -d' ' -f2- fname   # all but for 1st field (collumn) [space delimited]
    cat foo |cut -f2 -     # ... piped; read from stdin
    # Get all currently-connected users
    w |cut -d' ' -f 1 - |grep -v USER |sort -u  

    # tee : multiple output; send to ... file AND stdout
    ps -ax |tee tee.tmp

    ls -ld [[:CLASS:]]*    # starting w/ ... upper, lower, alnum, alpha, ...
    ls -ld [a-cx-z]*    # starting w/ ... a, c, x, or z ...

    # cat filter & equivalents
    cat set.log |grep HOSTNAME   # per pipe; better than redirect
    grep HOSTNAME < 'set.log'    # equivalent, per redirect

    cat set.log  # concatenate / show file
    cat > fname  # create file / interactive entry, CTRL-D to end
    cat fname    # cat : file to stdout
    echo "$(< fname)"    # file to stdout
    echo  $(< fname)    # file to stdout; all lines mapped to one line
    this=$(cat set.log) # assign variable w/ file contents; better than using cat command
    this=$(< set.log)   # equivalent; better/faster

    # add number to each line in file
    cat -n "$file"

    # Change directories, yet preserve prior(s) in a LIFO (push/pop) stack.
    pushd /change/to/this/dir   # push current dir to stack, and then cd
    popd                        # cd to directory popped from stack

    # Configure script to run at *its* location (PWD)  
    # regardless of how invoked, i.e., w/out explicit path.
    # Useful in scripts having relative-path reference(s).
        #!/usr/bin/env bash
        pushd ${BASH_SOURCE%/*} 2>/dev/null || pushd . || exit 
        #... Do script stuff here ...
        err=$?      # Capture the resulting error code.
        popd        # Return to folder from which caller came.
        exit $err   # Return this (informative) error code.

# SOCKET COMMANDS

    lsof -U # List all open UNIX Domain Sockets 
    lsof /tmp/demo.sock # Info on this socket only

    socat   # SOcket CAT : Multipurpose relay : "Netcat for sockets" 
            # See "Examples" @ https://linux.die.net/man/1/socat 
        socat UNIX-LISTEN:/usr/local/var/run/test/test.sock - 

    # Chat : client/server (peers) : TWO-WAY COMMS channel (STDIN/STDOUT)
        # @ Server (listener) terminal
        nc -l $port # Listen on all interface at port $port
        # @ Client terminal
        nc -N $ip $port # -N to shutdown the network socket after EOF (CTRL-D)
        #... thereafter, anything typed at one terminal is sent to the other 

    # Create a UNIX Socket 
        # -U : Unix Socket file 
        # -l : act as the server-side; listen for incoming connections.
        nc -U /tmp/demo.sock -l

    netstat -a  # Active UNIX domain sockets; list all network ports

    netperf     # Benchmark traffic between 2 hosts : Does UNIX sockets too

    ss # Socket Statistics; IP:PORT; like netstat
        -r     # resolve names
        -n     # numeric; don't resolve names
        -p     # incl. processes
        -at4r  # all-sockets, tcp, IPv4, resolve-names

        # Display all TCP sockets with process SELinux security contexts.
            ss -t -a -Z
        # Display all UDP sockets.
            ss -u -a
        # Display all established ssh connections.
            ss -o state established '( dport = :ssh or sport = :ssh )'

    # Bash can read/write (TCP) SOCKET as file descriptor
        # /dev : http://www.tldp.org/LDP/abs/html/devref1.html#NPREF
        # These are *not* files; are *not* seen by FS utilities (ls etal).
        # /dev/tcp/$host/$port

        # Get time from nist.gov
        cat </dev/tcp/time.nist.gov/13   
            # 60693 21-12-24 15:13:34 00 0 0 920.8 UTC(NIST) *
        
        # Handle app-layer (HTTP) protocol too:

            # 1. Download a root URL
            host=ifconfig.me;port=80
            exec 3<>/dev/tcp/$host/$port &&
                echo -e "GET / HTTP/1.1\r\nhost: $host\r\nConnection: close\r\n\r\n" >&3 &&
                    cat <&3
                        # HTTP/1.1 200 OK
                        # date: Mon, 18 Jan 2021 15:17:52 GMT
                        # content-type: text/plain
                        # Content-Length: 13
                        # access-control-allow-origin: *
                        # via: 1.1 google
                        # Connection: close

                        # 93.131.177.49

            # 2. HTTP Connectivity Test : A kind of ping
            host=ifconfig.me;port=80
            echo -e "GET / HTTP/1.1\r\nhost: $host\r\nConnection: close\r\n\r\n" \
                >/dev/tcp/$host/$port && echo ok


# eval ; convert a string into a command 
    # http://www.tldp.org/LDP/abs/html/internal.html#LETREF
    eval arg1 [arg2] ... # used for code generation from the command-line or within a script. 

# HARDWARE COMMANDS : ls{NAME} & modprobe

    lsmod          # show all active [loaded] kernel modules
    modprobe NAME  # install module [expect/ignore warnings]
    rmmod          # remove module 
    
    lscpu          # show CPU info
    lspci |more   # show PCI 
    lsusb          # show USB 
    lspcmcia 
    lshal
    lshw 

    modprobe MODULEname    # load module
    modprobe -r MODULEname # unload module; also unloads dependencies 

    # USB device : unmount AND eject USB device 'sdc'
        eject /dev/sdc # device 'sdc'; find/list device[s] per 'lsblk'

    # Execution time
    time COMMAND  

# NETWORK COMMANDS

    # See 'REF.Network.utils.sh' 

    host -4 myip.opendns.com resolver1.opendns.com # This machine's public IPv4 address
    ping -c 1 ROUTER_IP # test connectivity to Gateway Router
    ip help|neigh|route|addr|link
    ip addr; ip link; ip -s 
    tcpdump host foo # all traffic to/from host 'foo'
    nc # netcat; create/listen to TCP/UDP connections and servers; send UDP packets; port scanning; IPv4/IPv6
    nmap serverName  # features: Host discovery, Port scanning, Version detection, OS detection
    netstat -tulpen  # Active Internet connections; listening ports
    nslookup HOST    # DNS info
    dig HOSTNAME     # DNS info; @SUCCESS: 'status: NOERROR'; @FAIL: 'status: NXDOMAIN'
    ipcalc -h IP     # get HOSTNAME from IP
    nmcli -f NAME,DEVICE,TYPE,UUID con show # @ RHEL-7
    ssh user@host.domain
    
    curl [options] URL  # transfer date between client and server
        # Pull script quitely; follow redirects; fail on 404
        curl -fsSLO https://foo.com/path/to/a.sh
        # Pull script to /path/b.sh
        curl -fsSL https://foo.com/path/to/a.sh -o /path/b.sh
        # TLS CA : Relies on OS trust store, else any of (PEM format):
            --cacert /path/to/the/ca.crt
            --capath /path/to/ca/certs/dir
            export SSL_CERT_FILE=/path/to/the/ca.crt  # Many apps use this
            export CURL_CA_BUNDLE=/path/to/the/ca.crt # Takes precedent over SSL_CERT_FILE
            -k # Else skip CA validation

    wget [options] URL  # download web page[s]  https://www.gnu.org/software/wget/manual/wget.html

        # Download directly into install location 
        wget $url -O $destination

        # Download, extract, install a BINARY to /usr/local/bin/THIS
        wget -nv $url -O - |sudo tar -C /usr/local/bin -xzvf - 

        # Download, extract, and make (compile and install) from SOURCE tarball
            wget URL_TO_SOURCE.tarball  # download it 
            tar -xaf SOURCE.tarball     # extract it / read about it
            configure --help # show info; source dir often include a 'configure' file
            ./configure  # generates files required to build SW and setup system parameters. 
            make         # build the libraries and applications. 
            make install # install the libraries and applications. 

# ADMIN COMMANDS

    uptime      # info on this machine's server
    
    uname       # System info 
    uname -a    # --all
    uname -i    # Hardware platform  (x86_64)
    uname -m    # Machine (x86_64)
    uname -n    # Node (Machine) name (XPC)
    uname -p    # Processor (x86_64)
    uname -r    # Kernel release (4.19.128-microsoft-standard)
    uname -s    # Kernel name (Linux)
    uname -v    # Kernel version (5.3.0-1035-aws )

    whoami      # current user
    who         # who's logged in
    w           # equivalent to (uptime; who;)
    passwd      # change password

    wall "$msg"  # send message to all users logged in
    write $msg  # send message to another Linux machine
    talk  $msg  # send message to other logged in users

    top        # show CPU processes (updates); CTRL+C to quit
    free -m    # memory usage [MB] 
    free -m -s # memory usage [MB] continuous update; CTRL+C to quit 

    env    # Env. Vars.  
    printenv  # Env. Vars.

    ps -A    # all processes ???
    ps -aux  # all processes on the system
    pstree   # process tree

    ps -aux        # Show all processes on the system
    jobs           # Show background processes
    fg    %$n      # Bring background process (job) to foreground
    kill  $pid     # Kill a process by its PID
    kill -9 $pid   # Hard kill 
    kill  %$n      # Kill a background process by its job number (see jobs)
    pkill $ps      # Kill a process by its name ($ps) 
    killall $ps    # Kill all processes named $ps
    killall -0 $ps # Test if any process named $ps is running : $? is 0 if any; 1 if none.

    service $name start  # service : start / stop

    mysqldump -u root -p --all-databases > $path # mySQL DB backup 
    mkpasswd $pw $salt # generate password from $pw; salt must be 2 chars

    # Clocks : RTC (real-time; hardware) v. System (software) : Two independent clocks
        ## RTC clock may use either UTC (recommended) or local
        hwclock # RTC clock utility : See kernel interface : man rtc
        hwclock --show
        ## (Re)Initialize clocks : set one to the other (currently; not kept in sync).
        hwclock --hctosys # Set System clock to current RTC clock time
        hwclock --systohc # Set RTC clock to current System clock time
            # When chronyd (the default NTP client) is running, 
            # it periodically synchronizes the system clock with NTP servers. 
            # By default, the RTC is updated from the system clock every 11 minutes 
            # if the system clock is synchronized. (See timedatectl output).
            # The rtcsync directive in /etc/chrony.conf enables kernel-based 
            # synchronization of the RTC with the system clock. 
        chronyc tracking
        cat /etc/crony.conf
        ## System clock is:
        ## - Initialized by RTC clock
        ## - Managed by kernel
        ## - Synched to UTC 
        # TIMEZONE : systemd-timedated.service : of System Clock
            timedatectl [status] # Show current settings
            timedatectl list-timezones 
            timedatectl set-ntp $bool # yes|no : yes to synch with NTP (chronyd|ntpd); no to not.
            timedatectl set-timezone $tz # America/New_York (is *not* EST5EDT), US/Mountain, America/Los_Angeles,
            # Europe/Rome, Europe/Budapest, Europe/Moscow, Japan, Indian/Maldives, Asia/Shanghai, Asia/Macau, ...
            timedatectl set-time HH:MM:SS
            timedatectl set-local-rtc $bool # no|yes : no (UTC; recommended) OR yes (local)
                ## ... That command updates both the system time and the hardware clock. 
                ##     The result is similar to executing both "date --set" and "hwclock --systohc".
            systemctl restart systemd-timedated.service
        # DATE/TIME (current)
            date -Id          # 2020-01-07
            date -Ih          # 2020-01-07T08-04:00    
            date -Im          # 2020-01-07T08:28-04:00    
            date -Is          # 2020-01-07T08:28:50-04:00 # UTC Local : Local (offset) is Zulu -4
            date -Is -u       # 2020-01-07T12:28:50+00:00 # UTC Zulu (GMT)
            date --iso-8601=s # 2020-01-07T08:28:50-04:00 # Same as -Is
            date --rfc-3339=s # 2020-01-07 08:29:00-04:00
            # Offset +/- is WRT Zulu (GMT) : -04:00 is GMT minus 4 hours (add 4 to get GMT).
            date --rfc-3339=date    # 2020-01-07
            date '+%F'              # 2022-01-23
            date --rfc-email        # Sun, 23 Jan 2022 11:44:16 -0500
            
            date -r $file  # mtime of file
            # ISO8601/RFC3339 "specifications" allow for "date" that ... 
                ##... may (not) include whitespace(s),
                ##... may (not) include 'T',
                ##... may (not) include 'Z',
                ##... may (not) incl Timezone abbr name (EST, CET, UTC, ...).
                ## Fix:
                date -u +"%Y-%m-%dT%H:%M:%SZ"   # 2022-01-05T14:34:01Z 
                #... is Golang UTC Zulu format : aTime.Format(time.RFC3339)
                date --iso-8601=s -u            # 2022-01-05T14:34:01+00:00     (UTC Zulu)
                date --iso-8601=s               # 2022-01-05T09:34:01-05:00     (UTC offset) 

                date --rfc-3339=s               # 2022-01-05 09:35:39-05:00
                date +"%Y-%m-%dT%H:%M:%S%:z"    # 2022-01-05T09:36:25-05:00 

                date --rfc-3339=ns              # 2022-01-05 09:37:00.770083200-05:00
                date +"%Y-%m-%dT%H:%M:%S.%N%:z" # 2022-01-05T09:37:00.770083200-05:00 

                date +"%Y-%m-%dT%H:%M:%S.%N %Z" # 2021-12-01T14:09:26.358308700 EST
                date +"%F_[%H.%M.%S] %a %Z"     # 2020-12-01_[14.09:26] Sun EST
                date +"%F"                      # 2020-12-01
                    ## %z     +hhmm
                    ## %:z    +hh:mm
                    ## %::z   +hh:mm:ss
                    ## %Z     alphabetic TZ abbr (e.g., EDT)
        # Epoch : UNIX timestamp 
            date +"%s"    # Seconds        1643918591
            date +"%s%N"  # Nanoseconds    1643918591674370200
                        # Milliseconds   1643918591674
            date +"%s%N" |awk '{printf "%.13s", $1}' # Milliseconds 

# SCRIPTING COMMANDS
    :      # do nothing; $? => 0
    true    # do nothing; $? => 0
    false    # do nothing; $? => 1
    local   var=this  # make var local; allowed only in function (but use declare)
    declare var=this  # make var local @ function; can use anywhere; see options
    type -t WORD    # info per bash interpretation; "keyword", "function", "builtin"
    source SCRIPT_PATH  # add one script to environment of another.
    . SCRIPT_PATH       # same as above; alternate invocation of "source" command 

    set  # lots of options 
             # https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html 

        # Replace the contents of the “$@” array; replace positional params
        set -- foo bar baz # $1=foo, $2=bar, $3=baz
        set --             # unset all

        # EXPORT ALL enclosed FUNCs & VARs, e.g., in a (sourced) script
        set -a 
        func1(){...}  # automatically exported 
        foo=bar       # automatically exported
        ...
        set +a
        # Unless exported from the script, even if the script is sourced, 
        # functions and vars therein are NOT avaliable to other scripts.
        # I.e., if sourced, but not exported, then available only at command line. 

    export foo                   # Export variable into shell Env.
    export -f [name[=value] ...] # Export function into shell Env.
    export -n [name[=value] ...] # remove var OR function from Environment; Un-export
    export -p    # list all exported variables.
    export -f    # list all exported functions.
    export       # list all Env. Vars. 

    # Shebang variations ...
    ### #!/usr/bin/env bash     # Per-user default binary. (Some systems have no /bin/bash binary.)
    ### #!/usr/bin/bash         # Explicity set the binary.

    # Launch subshell
    /bin/bash $command $args 
    /bin/bash $script $args

    # Equivalent by reading script from stdin 
    cat $script | /bin/bash -s - $args
    # Alt, but less clear; has fail modes
    /bin/bash -s < $script $args
    # Multiple commands
    /bin/bash -c "$cmd1 $args1 && $cmd2 $args2"
        # Other flags
        -x # debug mode
        -v # debug; print script lines as they are read

    # as BACKGROUND PROCESS
    /bin/bash $command $args &
    # Sans STDOUT and STDERR
    /bin/bash -c "$command $args" >/dev/null 2>&1 &
    # Alternative, but quirky; shell-specific behavior:
    nohup $command $args & # Ignore HANGUP signal(s) (SIGHUP)

    rbash # RESTRICTED SHELL; forbid dir change, redirects, ...; see `man rbash`
        /bin/rbash 
        /bin/bash -r  

    # SSH : See REF.Network.SSH.sh 
    ssh -i $key ${user}@$host
    # Run LOCAL script REMOTELY through a secure shell
    cat $script | ssh $conn /bin/bash -s - $localArgs \$remote_arg1
    # Hacky and prone to fail modes:
        # Remotely run LOCAL script and args (environment) through a secure shell
        ssh  $conn "/bin/bash -s" < /any/local/path/script.sh $args
        #... per commands : allows partial preprocessing; escapes required in script
        ssh $conn "/bin/bash -c '$(</a/local/path/script.sh)' _ $args"
        #... advantage over HEREDOC scheme is preservation of semantic highlighting @ code editor.
        # UPLOAD a file SANS "file upload" utility (rsync, scp, ftps):
        ## Local file is stringified by redirect in a subshell (command substitution), and printed to remote file by redirect.
        ssh $conn "printf '$(</any/local/path/src.foo)' > /any/remote/path/dst.foo"

    # dialog utility : See 'man dialog' http://www.freeos.com/guides/lsst/ch04sec7.html
    dialog --common-options --boxType "Text" Height Width --box-specific-option

    # Parse Positional Params
    getopt
    getopts OPTSTRING VARNAME [ARGS...]

    # alias : use builtin instead of writing functions
    alias this='command arg1 arg2 ...'
    alias     # w/out options, it lists all aliases

    # unalias : remove an alias
    unalias this

    # trap : Run a command when a signal is set
    # exit/CTRL+D (0), CTRL+C (2), quit (3)
    # http://www.freeos.com/guides/lsst/ch04sec12.html
    trap commands signal-number-list

    # Compile
    gcc foo.c -o foo  # compile foo.c => foo.exe [@ Cygwin]
    .\foo             # run foo.exe

    g++ prog.cpp      # C++ compiler
    javac prog.java   # Java compiler

    whereis COMMAND  # path of COMMAND; using database built/maint by OS
    which   COMMAND  # path of COMMAND, if in $PATH
    whatis  COMMAND  # info on COMMAND

# SYSTEM INFO : all
    uname -a 

# BRACE EXPANSION; {} ; generate all possible combos
    echo {01..10}     =>  01 02 03 04 05 06 07 08 09 10
    echo a{d,c,b}X     =>  adX acX abX
    
    # combining, nesting
    echo {3..5}{j..l}  => 3j 3k 3l 4j 4k 4l 5j 5k 5l
    echo /usr/{ucb/{ex,edit},lib/{ex?.?*,how_ex}}
    # => /usr/ucb/ex /usr/ucb/edit /usr/lib/ex?.?* /usr/lib/how_ex

# PARAMETER EXPANSION; ex usage  http://wiki.bash-hackers.org/syntax/pe
    ${@:$N:1}    # Get Nth Positional Param (argument)    
    ${#PARAMETER}    # length
    ${PARAM:OFFSET}    # Get chars from offset to end
    ${PARAM:OFFSET:N}       # Get N chars starting at offset

    ${PATHNAME%/*}    # get parent; folder-path
    ${PATHNAME##*/}    # get lastchild; fname.ext

    ${FILENAME%.*}    # get filename w/out EXT
    ${FILENAME##*.}    # get filename EXT

# BRACE EXPANSION on arrays 
# http://www.tldp.org/LDP/abs/html/arrays.html
    arrayZ=( a b c d d e )
    "${arrayZ[0]}"    # a        : first element
    ${arrayZ[@]:2}    # c d d e  : elements 3 to <last>
    ${arrayZ[@]:1:2}  # b c      : elements 2 and 3
    ${#array[*]}      # 6        : number of elements
    ${#array[@]}      # 6        : number of elements
    ${#array[1]}      # 6        : length of 2nd element

# CONDITIONAL EXECUTION 
    test $1 -gt 4 && echo "bigger" || echo "smaller"
    [ $1 -gt 4 ]  && echo "bigger" || echo "smaller"  # equivalent
    # DANGER : exit code of command @ '&&' MUST be '0', else command @ '||' is executed

# PROCESS SUBSTITUTION  * NOT well supported
    assign () { cat "$1" >"$x"; }
    x=>(tr '[:lower:]' '[:upper:]') assign <(echo 'hi there')


# UNIQUE
    # UUID v4 random MAC
    _uuid=$(cat /proc/sys/kernel/random/uuid)  # Linux
    # 629cf98c-94d1-4470-bb07-8d7e2a6c1a92     (36 chars; 32 + 4 hyphens)
    # Unix/Epoch TIMESTAMP; sort of unique
    $(date "+%s.%N")  # e.g., 1539174436.886534100
    $(date "+%F %a %H.%M.%S.%N") # 2018-10-10 Wed 08.28.31.268750400

    # uuid utility : apt install uuid
    uuid -v4 -m  # UUID v4; random MAC
    b0cf2b3d-842b-455f-86d3-669fd4815383

    uuid -d b0cf2b3d-842b-455f-86d3-669fd4815383  # Decode
        encode: STR:     b0cf2b3d-842b-455f-86d3-669fd4815383
                SIV:     235019809725297106054232883079405458307
        decode: variant: DCE 1.1, ISO/IEC 11578:1996
                version: 4 (random data based)
                content: B0:CF:2B:3D:84:2B:05:5F:06:D3:66:9F:D4:81:53:83
                        (no semantics: random data only)

    # v5 is non-random, unique, namespaced : Use to map a name to its namespaced UUID
    uuid -v5 $namespace $name # namespace is a preset (ns:DNS|URL|OID|X500) or UUID
    uuid -v5 ns:X500 "CN=Test User,OU=Engineering,DC=example,DC=com" # Valid X.500 DN
    uuid -v5 ns:OID 1.3.6.1.4.1.8072 # Valid ISO OID : SNMP MIB, LDAP
        #... The 1.3.6.1.4.1 node of OID tree is for IANA enterprise numbers
        #... See https://en.wikipedia.org/wiki/Object_identifier
    uuid -v5 ns:URL https://foo.bar  # Valid URL
    ns=$(uuid -v4)                   # Any UUID
    uuid -v5 $ns /a/b/c;uuid -v5 $ns /a/b/x

# RANDOM 
    openssl rand -hex 32 # 64 hex characters
    mktemp --dry-run ns-XXXXX.abc   # ns-jJoqt.abc, ns-Cqh56.abc, ...
    $RANDOM  # Bash env. var. is built-in random number generator.
    printf "ns-%05d-abc" $RANDOM # ns-34858-abc, ns-26544-abc, ...
    # SHA1 | UUID 
    date "+%F %a %H.%M.%S.%N" |openssl sha1 |awk '{print $2}'  # MINGW|Linux
    dd if=/dev/urandom bs=512 count=1 |& openssl sha1 |awk '{print $2}'
    # ee3199afc2ac07e2011e7b2d7d983d64082af656 (40 chars)

    # fill disk with random ASCII
        # endlessly ...
        cat /dev/urandom > 'ASCII.cat.urandom.FOREVER'
        # 1GB ...
        cat /dev/urandom |head -c 1G > "ASCII.cat.urandowm.head.1GB"
            # ... equiv sans cat ...
            head -c 1G /dev/urandom   > "ASCII.head.1GB.urandom"

    # 1KB of ASCII (1 char = 1 byte)
        dd if=/dev/urandom bs=1024 count=1 of='ASCII.dd.urandom.1024'
        # ... equiv cat 
        cat /dev/urandom |head -c 1024     > 'ASCII.cat.urandom.head.1024'
        
    # generate 32 random PRINTABLE chars (ASCII) ...
        # alphanum
        cat /dev/urandom |tr -dc 'a-zA-Z0-9' |fold -w 32 |head -n 1
        strings /dev/urandom |grep -o '[[:alnum:]]' |head -n 32 |tr -d '\n'
        # specified char set 
        _charset='a-zA-Z0-9~!@#$%^&*_-'
        strings /dev/urandom |tr -dc "$_charset" |fold -w 32 |head -n 1

    # @ openssl
        openssl rand -base64 32 |cut -c -32 
        openssl rand -hex 32 

# math  
    bc  # An arbitrary precision calculator language

# COPROCESS  https://www.gnu.org/software/bash/manual/bashref.html#Coprocesses 
    #  executed asynchronously in a subshell, as if background process; command &
    #  but with a two-way pipe established between the executing shell and the coprocess. 
    coproc [NAME] command [redirections]

# GNU PARALLEL 
    # https://www.gnu.org/software/bash/manual/bashref.html#GNU-Parallel
    # https://www.gnu.org/software/parallel/parallel_tutorial.html
    man parallel_tutorial
    # NOT available @ Cygwin; see 'setup_gnu_parallel.sh'
    cat list |parallel do_something |process_output 

        # replaces for loop
        for x in `cat list` ; do 
        do_something "$x"
        done |process_output

    # gzip all html files in current dir and all subdirs 
    find . -type f -name '*.html' -print |parallel gzip

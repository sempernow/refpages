#!/usr/bin/env bash
# https://learnxinyminutes.com/docs/vim/
# http://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/
# Windows install: do NOT use choco; its version is incompatible with Cygwin;
#   Git-for-Windows installs with vim; 
#   Cygwin requires installing vim pkg per native Cygin's setup 
exit

# MODES

    i                # INSERT mode, BEFORE cursor position
    a                # INSERT mode, AFTER cursor position
    v                # VISUAL mode    
    ESC              # COMMAND mode
    :                # EX mode

# EXECUTE

    vim FILE         # Open FILE in vim
    :w               # Save current file
    :w newNAME       # Save as newNAME
    :wq, :x, :ZZ     # Save file and quit vim
    :q!, :ZQ         # Quit vim without saving file changes  
    :q               # Quit vim if no file changes

# ACTIONs

    # Copy / Paste 

    y                # Yank (copy) whatever is SELECTED
    yy               # Yank (copy) current LINE
    "ayy             # Yank (copy) current LINE into REGISTER "a"        "
    p                # Paste the copied text AFTER current cursor position 
    "ap              # Paste REGISTER "a" content AFTER current cursor position "
    P                # Paste the copied text BEFORE current cursor position
    dw               # Delete 1 WORD
    dd               # Delete 1 LINE
    r                # Replace 1 CHARACTER; current cursor position
    x                # Delete 1 CHARACTER; current cursor position  

    u                # Undo
    CTRL+r           # Redo 

# NAVIGATE 

    # Search for STRING (any/all ASCII chars okay; whitespace, etc.)

    /STR             # Finds all STR; forward search; press ENTER to MOVE there
    n                # Finds NEXT occurence of STR 
    N                # Finds PREVIOUS occurence of STR
    :noh             # CLEAR highlighted SEARCH 
    / STR /          # Match exactly one space on both sides
    /\sSTR\s/        # Match any space/tab on either side
    /\cSTR/          # Ignore case

    :set ignorecase  # Persistently; all subsequent patterns. 

    # Search & Replace (sed syntax)
    
    :s/foo/bar/g     # Change 'foo' to 'bar' on CURRENT line
    :2,7s/foo/bar/g  # Change 'foo' to 'bar' on LINES 2-7
    :%s/foo/bar/g    # Change 'foo' to 'bar' on EVERY line in the file
    :%s/;$//         # Remove trailing semicolon, `;`, from all lines
    :g/PATTERN/d     # Delete all lines matching a pattern
    :g/^$/d          # Delete all BLANK lines
    :g/\s*^$/d       # Delete all BLANK lines and those with only whitespace

    # Move :: L, D, U, R <==> h, j, k, l

    h                # Move LEFT one character
    j                # Move DOWN one line
    k                # Move UP one line
    l                # Move RIGHT one character

    # Move within LINE

    0                # Move to START of line
    $                # Move to END of line
    ^                # Move to FIRST NON-BLANK CHAR in line
    
    # Move by WORD

    w                # Move forward by one word
    b                # Move back by one word
    e                # Move to end of current word

    # Move to CHARacters (JUMP)

    fCHAR            # Jump forward and land on CHAR
    tCHAR            # Jump forward and land right before CHAR

    # Move by Logic

    CTRL+f           # forward; Page Down 
    CTRL+b           # back;    Page Up
    gg               # Go to the top of the file
    G                # Go to the bottom of the file 
    H                # Move to the TOP of screen;    HIGH
    M                # Move to the MIDDLE of screen; MEDIUM 
    L                # Move to the BOTTOM of screen; LOW
    :NUM             # Go to line number NUM 

# GRAMMAR

    # 'Verbs' / :<CHAR>

    d                # Delete
    c                # Change 
    y                # Yank (copy)
    v                # Visually select
    ~                # Toggle CASE of char|selection 
    3~               # Toggle CASE of next 3 chars
    g~3w             # Toggle case of next 3 words
    g~iw             # Toggle case of current word 

    # 'Nouns' / :<CHAR> / PREpend number (n) for n-occurences

    w                # Word
    s                # Sentence
    p                # Paragraph
    b                # Block

    # 'Modifiers

    i                # Inside
    a                # Around
    NUM              # Number (NUM is any number)
    f                # Searches for something and lands on it
    t                # Searches for something and stops before it  

# SAMPLE 'SENTENCES' OR COMMANDS

    xp               # Transpose 2 adjacent characters
    d2w              # Delete 2 words
    d$               # Delete to end of line
    dG               # Delete all lines, starting here, to end of file
    d$               # Delete till end of line
    :15,422d         # Delete lines 15-422
    ciw              # Change inside word  
    cis              # Change inside sentence
    ct<              # Change the text from where you are to the next open bracket
    cc               # Change (replace) entire line
    cw               # Change (replace) to the end of the word
    c$               # Change (replace) to the end of the line
    yip              # Yank inside paragraph (copy the para you're in)

# SOME SHORTCUTS AND TRICKS
  
    :retab           # Convert existing tabs to spaces.
    :.retab          # Convert current line tabs to use spaces.
    >                # Indent selection by one block
    <                # Dedent selection by one block
    :earlier 15m     # Reverts the document back to how it was 15 minutes ago
    :later 15m       # Reverse above command
    ddp              # Swap position of consecutive lines, dd then p
    .                # Repeat last ACTION
    ;                # Repeat last MOVEMENT
    :w !sudo tee %   # Save the current file as root
    
    # Prepend one character, here '#', to a block of sequential lines  
        8,17s/^/#        # sed RegEx prepended with 'FIRST,LAST' line numbers 
        ## OR use Visual mode
        v                # Enter visual mode with cursor at 1st line
        j                # Scroll cursor down to last target line
        :s/^/#           # Applies to 1st line
        ESC              # Applies to all remaining lines. WAIT.
        
    # Delete 1st character, here '#', from a block of sequential lines 
        8,17s/^#//       # sed RegEx prepended with 'FIRST,LAST' line numbers 
        ## OR use Visual mode:
        v                # Enter visual mode with cursor at 1st line
        j                # Scroll cursor down to last target line
        :s/^#//          # Applies to 1st line
        ESC              # Applies to all remaining lines. WAIT.

    # On report of "E137: Viminfo file is not writable:"
        # Fix by deleting ~/.viminfo, which is regenerated per vim startup.
        # Else track down and handle the swap file AKA backup file created during prior vi error.

# MACROS 
   
    qa               # Start recording a macro named 'a'
    q                # Stop recording
    @a               # Play back the macro

# CONFIGURING @ 
  /etc/vimrc
  ~/.vimrc 
  # For comment, start line with double-quote, '"'

:set OPTION     @ Set any option while in the vim editor.
:help OPTION    @ Get option info while in the vim editor.

:set ts=4 sw=2 sts=0 et

set expandtab                   # Always insert spaces on TAB keypress
set shiftwidth=2 smarttab       # Insert 2 spaces per TAB keypress if at start of line
set tabstop=4 softtabstop=0     # TAB width is 4 spaces (Distinguish from shiftwidth)
                                # (softtabstop is a bizarre mix; disable by setting to "0".)

set autoindent                  # indent line per preceeding line

set ignorecase                  # case insensitive search
set smartcase                   # case insensitive search if capital letters
set number                      # display line numbers
colo elflord                    # color theme
set wildmenu                    # Better command-line completion
set nocompatible                # Required for vim (improvements), else is just vi

set showmatch                   # automatically show matching brackets. works like it does in bbedit.
set vb                          # turn on the #visual bell# - which is much quieter than the #audio blink#
set ruler                       # show the cursor position all the time
set laststatus=2                # make the last line where the status is two lines deep so you can see status always
set backspace=indent,eol,start  # make that backspace key work the way it should
set background=dark             # Use colours that work well on a dark background (Console is usually black)
set showmode                    # show the current mode
set clipboard=unnamed           # set clipboard to unnamed to access the system clipboard under windows
syntax on                       # turn syntax highlighting on by default

# Function Declaration : 
# - Name must start with UPPERCASE letter
# - "function! Aname()" overwrites any pre-existing Aname() function.

function! Tabs()
  set tabstop=4     " Size of a hard tabstop (ts).
  set shiftwidth=4  " Size of an indentation (sw).
  set noexpandtab   " Always uses tabs instead of space characters (noet).
  set autoindent    " Copy indent from current line when starting a new line (ai).
endfunction

function! Spaces(n = 4)           " N whitespaces (default: 4)
  set expandtab                   " Always insert spaces on TAB keypress
  execute 'set shiftwidth=' . a:n . ' smarttab'
  set tabstop=6 softtabstop=0     " TAB width differs to distinguish from whitespace indent
  set autoindent                  " indent line per preceeding line
endfunction

function! Yaml()
  set expandtab                   " Always insert spaces on TAB keypress
  set shiftwidth=2 smarttab       " Insert N spaces per TAB keypress if at start of line
  set tabstop=6 softtabstop=0     " TAB width is N spaces (Distinguish from shiftwidth)
  set autoindent                  " indent line per preceeding line
endfunction

# Function Usage:
:call Spaces()
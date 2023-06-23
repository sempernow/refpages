#!/bin/bash
# https://learnxinyminutes.com/docs/vim/
# http://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/
# Windows install: do NOT use choco; its version is incompatible with Cygwin;
#   Git-for-Windows installs with vim; 
#   Cygwin requires installing vim pkg per native Cygin's setup 
exit

# HACKS 
  if "E137: Viminfo file is not writable:", then delete it per `rm ~/.viminfo`; it regenerates on vim startup; 'E137' error/msg began/persisted after accidentally CTRL-Z out of vim [use ZQ instead].

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
    :wq, :x, ZZ      # Save file and quit vim
    :q!, ZQ          # Quit vim without saving file changes  
    :q               # Quit vim if no file changes

# ACTIONs

    # Copy / Paste 

    y                # Yank (copy) whatever is SELECTED
    yy               # Yank (copy) current LINE
    p                # Paste the copied text AFTER current cursor position
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

    # Search & Replace (sed syntax)
    
    :s/foo/bar/g     # Change 'foo' to 'bar' on CURRENT line
    :2,7s/foo/bar/g  # Change 'foo' to 'bar' on LINES 2-7
    :%s/foo/bar/g    # Change 'foo' to 'bar' on EVERY line in the file
    :%s/;$//         # Remove trailing semicolon, `;`, from all lines

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

    # 'Verbs'

    d                # Delete
    c                # Change 
    y                # Yank (copy)
    v                # Visually select
    ~                # Toggle CASE of char|selection 
    3~               # Toggle CASE of next 3 chars
    g~3w             # Toggle case of next 3 words
    g~iw             # Toggle case of current word 

    # 'Nouns' [PREpend number (n) for n-occurences]

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
  
    >                # Indent selection by one block
    <                # Dedent selection by one block
    :earlier 15m     # Reverts the document back to how it was 15 minutes ago
    :later 15m       # Reverse above command
    ddp              # Swap position of consecutive lines, dd then p
    .                # Repeat last ACTION
    ;                # Repeat last MOVEMENT
    :w !sudo tee %   # Save the current file as root

# MACROS 
   
    qa               # Start recording a macro named 'a'
    q                # Stop recording
    @a               # Play back the macro

# CONFIGURING @ 
  /etc/vimrc
  ~/.vimrc 
  # For comment, start line with double-quote, '"'
  # Does NOT allow '# ...' comments

set ignorecase                  # case insensitive search
set smartcase                   # case insensitive search if capital letters
set autoindent                  # indent line per preceeding line
set number                      # display line numbers
set expandtab                   # spaces, not tab, on TAB keypress
set tabstop=2                   # spaces per tab when viewing
set softtabstop=4               # spaces per tab when editing
set shiftwidth=4                # spaces per tab @ reindent cmd '>>', '<<'
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


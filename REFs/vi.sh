#!/bin/bash
# LearnXinYmin   https://learnxinyminutes.com/docs/vim/
exit

    vim <filename>   # Open <filename> in vim
    :help <topic>    # Open up built-in help docs about <topic> if any exists
    :q               # Quit vim
    :w               # Save current file
    :wq              # Save file and quit vim
    ZZ               # Save file and quit vim
    :q!              # Quit vim without saving file
                     # ! *forces* :q to execute, hence quiting vim without saving
    :x               # Save file and quit vim, shorter version of :wq

    u                # Undo
    CTRL+R           # Redo

    h                # Move left one character
    j                # Move down one line
    k                # Move up one line
    l                # Move right one character

    # Moving within the line

    0                # Move to beginning of line
    $                # Move to end of line
    ^                # Move to first non-blank character in line

    # Searching in the text

    /word            # Highlights all occurrences of word after cursor
    ?word            # Highlights all occurrences of word before cursor
    n                # Moves cursor to next occurrence of word after search
    N                # Moves cursor to previous occerence of word

    :%s/foo/bar/g    # Change 'foo' to 'bar' on every line in the file
    :s/foo/bar/g     # Change 'foo' to 'bar' on the current line
    :%s/\n/\r/g      # Replace new line characters with new line characters

    # Jumping to characters

    f<character>     # Jump forward and land on <character>
    t<character>     # Jump forward and land right before <character>

    # For example,
    f<               # Jump forward and land on <
    t<               # Jump forward and land right before <

    # Moving by word

    w                # Move forward by one word
    b                # Move back by one word
    e                # Move to end of current word

    # Other characters for moving around

    gg               # Go to the top of the file
    G                # Go to the bottom of the file
    :NUM             # Go to line number NUM (NUM is any number)
    H                # Move to the top of the screen
    M                # Move to the middle of the screen
    L                # Move to the bottom of the screen

    i                # Puts vim into insert mode, before the cursor position
    a                # Puts vim into insert mode, after the cursor position
    v                # Puts vim into visual mode
    :                # Puts vim into ex mode
    <esc>            # 'Escapes' from whichever mode you're in, into Command mode

    # Copying and pasting text

    y                # Yank whatever is selected
    yy               # Yank the current line
    d                # Delete whatever is selected
    dd               # Delete the current line
    p                # Paste the copied text after the current cursor position
    P                # Paste the copied text before the current cursor position
    x                # Deleting character under current cursor position

    # 'Verbs'

    d                # Delete
    c                # Change
    y                # Yank (copy)
    v                # Visually select

    # 'Modifiers'

    i                # Inside
    a                # Around
    NUM              # Number (NUM is any number)
    f                # Searches for something and lands on it
    t                # Searches for something and stops before it
    /                # Finds a string from cursor onwards
    ?                # Finds a string before cursor

    # 'Nouns'

    w                # Word
    s                # Sentence
    p                # Paragraph
    b                # Block

    # Sample 'sentences' or commands

    d2w              # Delete 2 words
    cis              # Change inside sentence
    yip              # Yank inside paragraph (copy the para you're in)
    ct<              # Change to open bracket
                     # Change the text from where you are to the next open bracket
    d$               # Delete till end of line

    >                # Indent selection by one block
    <                # Dedent selection by one block
    :earlier 15m     # Reverts the document back to how it was 15 minutes ago
    :later 15m       # Reverse above command
    ddp              # Swap position of consecutive lines, dd then p
    .                # Repeat previous action
    :w !sudo tee %   # Save the current file as root
    :set syntax=c    # Set syntax highlighting to 'c'
    :sort            # Sort all lines
    :sort!           # Sort all lines in reverse
    :sort u          # Sort all lines and remove duplicates
    ~                # Toggle letter case of selected text
    u                # Selected text to lower case
    U                # Selected text to upper case

    # Change case (upper/lower) : at either command or visual mode
    g~w              # Toggle case; each letter of current word (if at beginning)   
    guw              # Change to LOWERcase; each letter of current word (if at beginning)   
    
    # Fold text
    zf               # Create fold from selected text
    zo               # Open current fold
    zc               # Close current fold
    zR               # Open all folds
    zM               # Close all folds

    qa               # Start recording a macro named 'a'
    q                # Stop recording
    @a               # Play back the macro 


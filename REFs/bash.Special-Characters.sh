#!/bin/bash
# -----------------------------
#   Bash Special Characters
# -----------------------------
# http://mywiki.wooledge.org/BashGuide/SpecialCharacters
# http://tldp.org/LDP/abs/html/special-chars.html
exit

# IFS (Input Field Separator) http://mywiki.wooledge.org/IFS
  IFS

# Whitespace (SPACE, TAB, & NEWLINE); word delimiters.

# Expansion character ($); used for most substitutions & expansions
  $foo

# Single Quotes (''); protect text therein from ALL expansion or interpretation
  'foo & bar ;&$?%^*\?'  # ALL is one word; a "literal"; a string

# Double Quotes (""); protect text from being split into multiple words/args, 
# but permits substitutions; prevents interpretation of MOST special chars.
  "foo"

# Backslash (\) is the ESCAPE CHARACTER; prevents interpretation, i.e., 
# "escapes" whatever char follows; everywhere EXCEPT inside SINGLE QUOTES
  printf %s\\t%s  ...  # escapes the TAB char (\t); syntax per command (quirky)
  printf "%s\t%s" ...  # equivalent [see Double Quotes, above]

# Backslash (\) FOLLOWED ONLY BY NEWLINE; interpreted as line continuation; 
# i.e., escapes newline; to beautify code; one code-line across muliple lines
  find -maxdepth 1 -type f -iname "foo*" \
    -exec sh -c 'command ...' _ {} \+
  
# Comment character (#); prevent shell from processing remainder of line.
  # foo

# Command separator (;); interpreted as newline char
  command1; command2; command3

# Tilde (~); interpreted as current user's home directory ($HOME)
  ~      # current user's home dir
  ~/     # equivalent
  ~/foo  # foo's home dir

# Redirection characters (>) and (<); used to modify (redirect) 
# stdin/stdout of a command (args okay).
  command1 < command2 > command3

# Pipeline (|); output of command1 (left) piped (as input) to command2 (right).
  command1 | command2

# Conditional Expression; evaluates Test Expression as a logical statement; 
# allowing logical operators (complex expressions); 
# returns, Exit Code ($?), "0" on TRUE, "1" on FALSE;
# Quoting NOT NEEDED; Word Splitting / Pathname Expansion are NOT performed
  [[ expression ]]

# Command Grouping; commands inside the braces are treated as though one command;
# convenient where Bash syntax requires only one command, but a function isn't warranted.
  { command1; command2; ...}

# Command Substitution; executes inner command first, then replaces w/ command's stdout
  $(command)  # PREFERRED (nestable)
  `command`   # alt 

# Subshell Execution; executes the command in a new bash shell, like a safe sandbox. 
# "current" (parent) shell env. UNAFFECTED
  (command)

# Arithmetic Command; allowing mathematical operators (+, -, * /);  
# used for assignments, e.g., ((a=b+7)) and tests, e.g., ((a < b)); 
# Note that whitespace NOT necessary.
  ((expression))

# Arithmetic Substitution; as above, but expression replaced with the result.  
  $((expression))

" $VIMRUNTIME/defaults.vim
" /etc/vim/vimrc
" /etc/vim/vimrc.local
" ~/.vimrc
"
" $HOME/.vimrc    @ Cygwin 
" /etc/vimrc      @ Git for Windows 
" :set OPTION     @ Set any option while in the vim editor.
" :help OPTION    @ Get option info while in the vim editor.
" :set ts=6 sw=2 sts=0 et ai smarttab

function! UseTabs()
  set tabstop=4     " Size of a hard tabstop (ts).
  set shiftwidth=4  " Size of an indentation (sw).
  set noexpandtab   " Always uses tabs instead of space characters (noet).
  set autoindent    " Copy indent from current line when starting a new line (ai).
endfunction

function! UseSpaces()
  set expandtab                   " Always insert spaces on TAB keypress
  set shiftwidth=4 smarttab       " Insert N spaces per TAB keypress if at start of line
  set tabstop=6 softtabstop=0     " TAB width is N spaces (Distinguish from shiftwidth)
  set autoindent                  " indent line per preceeding line
endfunction

function! Yaml()
  set expandtab                   " Always insert spaces on TAB keypress
  set shiftwidth=2 smarttab       " Insert N spaces per TAB keypress if at start of line
  set tabstop=6 softtabstop=0     " TAB width is N spaces (Distinguish from shiftwidth)
  set autoindent                  " indent line per preceeding line
endfunction

call UseSpaces()

set clipboard=unnamed           " Set clipboard to unnamed to access system clipboard @ Windows
set noswapfile                  " Prevent vim's zombie swap-file clusterfuck
set ignorecase                  " Case insensitive search
set smartcase                   " Case insensitive search if capital letters
set number                      " Display line numbers
set nonumber                    " Do not display line numbers
colo elflord                    " Color theme
set wildmenu                    " Better command-line completion
set nocompatible                " Required for vim (iMprovements), else is just vi
set showmatch                   " Automatically show matching brackets, like bbedit.
set vb                          " Turn on the 'visual bell'; much quieter than 'audio blink'
set ruler                       " Show the cursor position all the time
set laststatus=2                " Make last line (status) two lines deep, so always visible
set backspace=indent,eol,start  " Make that backspace key work the way it should
set background=dark             " Default to colours that work well on dark background 
set showmode                    " Show the current mode
syntax on                       " Turn syntax highlighting on by default
xnoremap p pgvy                 " Paste repeatedly"

" Show EOL type and last modified timestamp, right after the filename
set statusline=%<%F%h%m%r\ [%{&ff}]\ (%{strftime(\"%H:%M\ %d/%m/%Y\",getftime(expand(\"%:p\")))})%=%l,%c%V\ %P

"@ fatah/vim-go"
filetype plugin indent on

" YAML
" autocmd FileType yaml setlocal ai ts=2 sw=2 et


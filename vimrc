" ----------------------------------------------
"              Setting up Vundle
"            - Vim plugin manager -
" ----------------------------------------------
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Include plugins
Plugin 'bling/vim-airline'   	" Nice statusbar plugin
Plugin 'tpope/vim-fugitive'  	" Git wrapper
Plugin 'Rip-Rip/clang_complete' " Clang autocomplete for C and C++

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Settings for some bundles
let g:clang_library_path = "/Library/Developer/CommandLineTools/usr/lib/"

" ----------------------------------------------

"Utf-8 encoding as standard
set encoding=utf-8

"shared clipboard
set clipboard=unnamed

"what this does is allow vim to manage multiple buffers effectively.
set hidden

"activates the mouse
set mouse=nirc

"the bottom line in your editor will show you information about the current
"command going on.
set showcmd

"Tab completion for vim commands
set wildmenu
set wildmode=list:longest,full

"Keep a longer history
set history=7000

"Set to auto read when a file is changed from the outside
set autoread

"Set terminal title
set title

"Set an colorscheme
colorscheme desert
set background=dark

"Intuitive backspacing in insert mode
set backspace=indent,eol,start

" File-type highlighting and configuration.
" Run :filetype (without args) to see what you may have
" to turn on yourself, or just set them all to be sure.
syntax on
filetype on
filetype plugin on
filetype indent on

" Turns of that anoying bell sound
set noerrorbells 
set visualbell
set t_vb= 

" Visual cursor
set cursorline

" keep at least 4 lines around the cursor
set scrolloff=4

" set backup and tmp dir
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" or rather turn backup/swap off..
set nobackup
set nowb
set noswapfile

" linenumber
set number
set numberwidth=6
hi LineNr ctermfg=lightgray ctermbg=darkgray

"Statusline
let g:airline_powerline_fonts = 1

"set statusline=%t%r\ (%{FileSize()})\ Format:\ %{&ff}%=%c,%l/%L
set laststatus=2

function! FileSize()
     let bytes = getfsize(expand("%:p"))
     if bytes <= 0
         return ""
     endif
     if bytes < 1024
         return bytes
     else
         return (bytes / 1024) . "K"
     endif
endfunction

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>
nmap <leader>x :x<cr>

" When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source %

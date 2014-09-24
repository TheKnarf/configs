"   ---------------------------------------------
"-               Setting up Vundle
"              - Vim plugin manager -
"   ---------------------------------------------
set nocompatible              "  be iMproved, required
filetype off                  "  required

"   set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"   let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

"   Include plugins
Plugin 'bling/vim-airline'   	"  Nice statusbar plugin
Plugin 'tpope/vim-fugitive'  	"  Git wrapper
Plugin 'Rip-Rip/clang_complete' "  Clang autocomplete for C and C++

"   All of your Plugins must be added before the following line
call vundle#end()            "  required
filetype plugin indent on    "  required

"   Settings for some bundles
let g:clang_library_path = "/Library/Developer/CommandLineTools/usr/lib/"

"------------------------------------------------

"- Utf-8 encoding as standard
set encoding=utf-8

"- shared clipboard
set clipboard=unnamed

"- what this does is allow vim to manage multiple buffers effectively.
set hidden

"- activates the mouse
set mouse=nirc

"- the bottom line in your editor will show you information about the current
"  command going on.
set showcmd

"- Tab completion for vim commands
set wildmenu
set wildmode=list:longest,full

"- Keep a longer history
set history=7000

"- Set to auto read when a file is changed from the outside
set autoread

"- indent
set autoindent 
set noexpandtab
set tabstop=3
set shiftwidth=3


"- Set terminal title
set title

"- Set an colorscheme
colorscheme desert
set background=dark

"- Highlight text which exceed 80 chars in length
match ErrorMsg '\%>79v.\+'
"- Intuitive backspacing in insert mode
set backspace=indent,eol,start

"-  File-type highlighting and configuration.
"   Run :filetype (without args) to see what you may have
"   to turn on yourself, or just set them all to be sure.
syntax on
filetype on
filetype plugin on
filetype indent on

"- Set change folding on double click
nnoremap <2-LeftMouse> <esc>za
inoremap <2-LeftMouse> <esc>za

"- Cpp folding
augroup filetype_cpp
	autocmd!
	autocmd FileType cpp setlocal foldmethod=syntax
augroup END

"- Make c and cpp files
noremap <c-b> :wa<cr>:make!<cr>
noremap <leader><leader> :call ToggleQuickFix()<cr>
nnoremap <leader>cn :cn<cr>
nnoremap <leader>cN :cN<cr>

let g:quickfix_is_open = 0

function! ToggleQuickFix()
	if g:quickfix_is_open
		cclose
		let g:quickfix_is_open = 0
	else
		copen
		let g:quickfix_is_open = 1
	endif
endfunction

"- Abberations for paired symbols ( { [ " '
"iabbrev ( ()<left>
"iabbrev { {}<left>
"iabbrev [ []<left>
"iabbrev " ""<left>
"iabbrev ' ''<left>

"- Vimscript folding
augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=expr
	autocmd FileType vim setlocal foldexpr=VimFold()
	autocmd FileType vim setlocal foldtext=VimFoldText()
	
	function! VimFold()
 		let thisline = getline(v:lnum)			
		if match(thisline, '^"-') >= 0
			return '>1'
		else
			return "="
		endif
	endfunction

	function! VimFoldText()
		return getline(v:foldstart)
	endfunction
augroup END



"-  Turns of that anoying bell sound
set noerrorbells 
set visualbell
set t_vb= 

"- Visual cursor
set cursorline

"- keep at least 4 lines around the cursor
set scrolloff=4

"- set backup and tmp dir
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

"- or rather turn backup/swap off..
set nobackup
set nowb
set noswapfile

"- linenumber
set number
set numberwidth=6
hi LineNr ctermfg=lightgray ctermbg=darkgray

"- Statusline
let g:airline_powerline_fonts = 1

"- set statusline=%t%r\ (%{FileSize()})\ Format:\ %{&ff}%=%c,%l/%L
set laststatus=2

function! FileSize()
     let bytes = getfsize(expand("%:p"))
     if bytes <= 0
         return "- "
     endif
     if bytes < 1024
         return bytes
     else
         return (bytes / 1024) . "K"
     endif
endfunction

"- With a map leader it's possible to do extra key combinations
"  like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

"- Fast saving
nnoremap <leader>w :w!<cr>
nnoremap <leader>x :x!<cr>
nnoremap <leader>q :q<cr>
 
"- Splits
nnoremap <leader><Down> <C-W><C-J>
nnoremap <leader><Up> <C-w><C-K>
nnoremap <leader><Right> <C-w><C-L>
nnoremap <leader><Left> <C-w><C-H>

"- Open vimrc in split mode
nnoremap <leader>ev :split $MYVIMRC<cr>

"- Open header file and source file and makefiles
nnoremap <leader>eh :split %:p:h/../defs/%:t:r.h<cr>
nnoremap <leader>ec :split %:p:h/../src/%:t:r.cpp<cr>
nnoremap <leader>em :split %:p:h/Makefile<cr>

"- Pastetoggle
set pastetoggle=<leader>z

" Sudo write by w!!
cmap w!! w !sudo tee % >/dev/null

"-  When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source %

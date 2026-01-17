"   ---------------------------------------------
"-               Setting up vim-plug
"              - Vim plugin manager -
"   ---------------------------------------------
set nocompatible              "  be iMproved, required
filetype off                  "  required

call plug#begin()

if filereadable(expand("~/.vim/plugins.vim"))
	source ~/.vim/plugins.vim
endif

call plug#end()

filetype plugin indent on    "  required

"   Settings for some bundles
let g:user_emmet_mode='a'    "enable all function in all mode.

let g:typescript_indent_disable = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

"  Fern
let g:fern#renderer = "nerdfont"

"  VimWiki
let g:vimwiki_list = [
      \ { 'syntax': 'markdown', 'ext': 'md', 'path': '~/Library/CloudStorage/Dropbox/txt'},
      \ { 'syntax': 'markdown', 'ext': 'md', 'path': '~/Projects/theknarf/theknarf.github.io'}
      \]

let g:vimwiki_markdown_link_ext = 1

let g:vimwiki_global_ext = 0

"------------------------------------------------

"- Utf-8 encoding as standard
set encoding=utf-8

"- Colored output in cmake builds from vim
let $CLICOLOR_FORCE=1

"- Autoreload file that has changed
set autoread

"- Special characters
set list
set listchars=nbsp:¬,tab:  ,trail:•

"- Styling
set fillchars+=vert:\ 

"- Autowrite
set autowrite
"- shared clipboard
set clipboard=unnamed

"- What this does is allow vim to manage multiple buffers effectively.
set hidden

"- Activates the mouse
set mouse=nirc
if !has('nvim')
	if &term =~ '^screen'
		" tmux knows the extended mouse mode
		set ttymouse=xterm2
	endif
endif

"- Netrw auto clos
" Taken from: https://vi.stackexchange.com/questions/14622/how-can-i-close-the-netrw-buffer
autocmd FileType netrw setl bufhidden=wipe

"- The bottom line in your editor will show you information about the current
"  command going on.
set showcmd

"- Tab completion for vim commands
set wildmode=list:longest,full

"- Keep a longer history
set history=7000

"- Set to auto read when a file is changed from the outside
set autoread

"- indent
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2

"- Makefile use tab
autocmd FileType make setlocal noexpandtab

"- Set terminal title
set title

"- Set an colorscheme
colorscheme desert
set background=dark

"- Highlight text which exceed 120 chars in length
match ErrorMsg '\%>119v.\+'

"- Markdown
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd FileType markdown match ErrorMsg '\%>1000v.\+'
autocmd FileType markdown setlocal spell spelllang=en_us

"- Intuitive backspacing in insert mode
set backspace=indent,eol,start

"- File-type highlighting and configuration.
"  Run :filetype (without args) to see what you may have
"  to turn on yourself, or just set them all to be sure.
syntax on
filetype on
filetype plugin on
filetype indent on

"- Set change folding on double click
nnoremap <2-LeftMouse> <esc>za
inoremap <2-LeftMouse> <esc>za

"- Cpp folding
augroup filetype_cpp
"	autocmd!
"	autocmd FileType cpp setlocal foldmethod=syntax
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

"- Turns of that anoying bell sound
set noerrorbells 
set visualbell
set t_vb= 

"- Visual cursor
set cursorline

"- keep at least 4 lines around the cursor
set scrolloff=4

"- set backup and tmp dir
set backup
set backupcopy=yes
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

"- or rather turn backup/swap off..
"set nobackup
"set nowb
"set noswapfile

"- Linenumber
set number
set numberwidth=6
hi LineNr ctermfg=lightgray ctermbg=darkgray

"- Statusline
let g:airline_powerline_fonts = 1

"- Set statusline=%t%r\ (%{FileSize()})\ Format:\ %{&ff}%=%c,%l/%L
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

"- Tmux eval
"    First add the following to your .bashrc/.zshrc:
" 
" ```
" mark_pane_eval() {
"  tmux setenv -t $TMUX_PANE pane_name eval
" }
" ```
"
" and then run mark_pane_eval in a pane in tmux.
" Then the command belove should be ready:
" Script-local variable to store the user-provided pane ID
let s:storedPaneId = ""

function! SendToEvalPane(content)
    " Try to fetch the pane ID from the stored variable first
    if s:storedPaneId != ""
        let evalPaneId = s:storedPaneId
    else
        " Otherwise, attempt to find the pane marked as 'eval'
        let evalPaneId = system("tmux list-panes -F '#{pane_id} #{pane_env_pane_name}' | grep -w 'eval' | cut -d ' ' -f 1")
        let evalPaneId = substitute(evalPaneId, '\n$', '', '')
    endif

    " Check if evalPaneId is empty, indicating no matching pane was found or provided
    if evalPaneId == ""
        " Ask the user for the pane ID
        let evalPaneId = input("Pane named 'eval' not found. Please enter pane ID: ")
        if evalPaneId == ""
            echo "No pane ID provided. Aborting."
            return
        else
            " Store the user-provided pane ID for future use
            let s:storedPaneId = evalPaneId
        endif
    endif

    " Send the provided content to the identified pane
    let cmd = "tmux send-keys -t " . evalPaneId . " " . shellescape(a:content)
    call system(cmd)
endfunction

nnoremap <leader>ee "zyy :call SendToEvalPane(@z)<CR>

"- Open vimrc in split mode
nnoremap <leader>ev :e $MYVIMRC<cr>

"- Open header file and source file
nnoremap <leader>eh :e %:p:h/%:t:r.h<cr>
nnoremap <leader>ec :e %:p:h/%:t:r.c<cr>

"- Fileview
nnoremap <leader>v :Fern . -drawer -toggle<cr>
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_winsize = 25

"- Buffer switching
nnoremap <leader>bn :bn<cr>
nnoremap <leader>bp :bp<cr>
nnoremap <leader>bd :bp<bar>sp<bar>bn<bar>bd<CR>

"- Ctags
set tags=./tags;

" Jump to definition
nnoremap <C-9> <C-]>

" Pastetoggle
set pastetoggle=<leader>z

" Copy to clipboard on MacOS in visual mode
vmap <C-c> :w !pbcopy<CR><CR>

" fzf Commands
nnoremap <C-c>: :Command<CR>
nnoremap <C-g> :Rg<Cr>
nnoremap <C-f> :Files<Cr>

" Sudo write by w!!
cmap w!! w !sudo tee % >/dev/null

"- When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source %


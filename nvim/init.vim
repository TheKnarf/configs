" This should ensure that neovim loads my old vimrc file
" hopefully most of it still works in neovim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Require the file ./lua/theknarf/init.lua
" this way I can put nvim spesific setup here
lua require('theknarf')

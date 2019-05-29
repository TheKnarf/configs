Plugin 'vim-airline/vim-airline'         "  Airline
Plugin 'vim-airline/vim-airline-themes'  "  Themes for airline
Plugin 'tpope/vim-fugitive'  			     "  Git wrapper
Plugin 'tpope/vim-surround'  			     "  Vim surround
Plugin 'mattn/emmet-vim' 				     "  Zen support
Plugin 'rust-lang/rust.vim'			     "  SyntaxHighlighting for Rust
Plugin 'elzr/vim-json'					     "  JSON syntax highlighting
Plugin 'tpope/vim-dispatch'			     "  Run make or other tasks async in the background
Plugin 'reasonml-editor/vim-reason'      "  ReasonML plugin
Plugin 'theknarf/maude.vim'              "  Maude syntax highlighting
Plugin 'noahfrederick/vim-skeleton'
Plugin 'junegunn/fzf.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'editorconfig/editorconfig-vim'

if has('nvim')
  Plugin 'shougo/deoplete.nvim'
else
  Plugin 'shougo/deoplete.nvim'
  Plugin 'roxma/nvim-yarp'
  Plugin 'roxma/vim-hug-neovim-rpc'
endif

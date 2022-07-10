export PATH=/opt/homebrew/bin/:/opt/homebrew/sbin/:$PATH
if command -v brew &> /dev/null
then
. `brew --prefix`/etc/profile.d/z.sh
fi

export GOPATH=$HOME/Dropbox/golang

alias typora="open -a typora"

# Setup path
path+=(
	'/usr/bin'
	'/bin'
	'/usr/sbin'
	'/sbin'
	'/usr/local/bin'
	'/usr/local/git/bin'
	"$HOME/Dropbox/Projects/depot_tools"
	"$HOME/bin"
	"$HOME/Library/Haskell/bin"
	'./node_modules/.bin'
	'./vendor/bin'          # PHP Composer bin folder
	'~/.cargo/bin'          # Rust bin path
	'~/.cabal/bin'          # Cabal bin path
	'/usr/local/heroku/bin' # Added by the Heroku Toolbelt
	"$GOPATH/bin"
	"$HOME/.yarn/bin"
	"$HOME/.config/yarn/global/node_modules/.bin"
	'/usr/local/sbin'
	'/snap/bin'
)
export PATH

alias paths_debug="echo $PATH | sed 's/:/\n/g' | sort | uniq -c"

# Ensure that MANPATH have a : in the beginning
export MANPATH=":$MANPATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Oh my zsh
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/configs/zsh_custom
ZSH_THEME="robbyrussell_theknarf_mod"
plugins=(
	git-flow
	zsh-autosuggestions
	ssh-agent
	man-color
	bindkey-vim
	zsh-yarn-completions
	kubectl
	wasmer
	bun
	direnv
	fzf
)
source $ZSH/oh-my-zsh.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [[ ${TERM} == "screen-bce" || ${TERM} == "screen" ]]; then
	precmd () { print -Pn "\033k\033\134\033k%m[%1d]\033\134" }
	eexec () { print -Pn "\033k\033\134\033k%m[$1]\033\134" }
else
	precmd () { print -Pn "\e]0;%n@%m: %~\a" }
	eexec () { print -Pn "\e]0;%n@%m: $1\a" }
fi
S1=$'%{\e[0;32m%}%m%{\e[0m%}:%~> '
export PS1

. `brew --prefix`/etc/profile.d/z.sh

export GOPATH=$HOME/Dropbox/golang

# Setup path
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin
export PATH=$PATH:$HOME/Dropbox/Projects/depot_tools
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/Library/Haskell/bin
export PATH=$PATH:./node_modules/.bin
export PATH=$PATH:./vendor/bin  # PHP Composer bin folder
export PATH=$PATH:~/.cargo/bin  # Rust bin path
export PATH=$PATH:/usr/local/heroku/bin # Added by the Heroku Toolbelt
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# Ensure that MANPATH have a : in the beginning
export MANPATH=":$MANPATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Opam
eval `opam env --readonly`

# Oh my zsh
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/configs/zsh_custom
ZSH_THEME="robbyrussell"
plugins=(git git-flow zsh-autosuggestions ssh-agent man-color bindkey-vim)
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fzfgrep(){ grep --line-buffered --color=never -r "" * | fzf }


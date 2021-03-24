export PATH=$PATH:/opt/homebrew/bin/
if command -v brew &> /dev/null
then
. `brew --prefix`/etc/profile.d/z.sh
fi

export GOPATH=$HOME/Dropbox/golang

alias typora="open -a typora"

# Setup path
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin
export PATH=$PATH:$HOME/Dropbox/Projects/depot_tools
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/Library/Haskell/bin
export PATH=$PATH:./node_modules/.bin
export PATH=$PATH:./vendor/bin  # PHP Composer bin folder
export PATH=$PATH:~/.cargo/bin  # Rust bin path
export PATH=$PATH:~/.cabal/bin  # Cabal bin path
export PATH=$PATH:/usr/local/heroku/bin # Added by the Heroku Toolbelt
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH=$PATH:/snap/bin

# Ensure that MANPATH have a : in the beginning
export MANPATH=":$MANPATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Opam
if [[ $(command -v opam) == "" ]]; then
else
	eval `opam env --readonly`
fi

# Oh my zsh
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/configs/zsh_custom
ZSH_THEME="robbyrussell_theknarf_mod"
plugins=(git-flow zsh-autosuggestions ssh-agent man-color bindkey-vim)
plugins+=(zsh-yarn-completions)
source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fzfgrep(){ grep --line-buffered --color=never -r "" * | fzf }

# Wasmer
export WASMER_DIR="~/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


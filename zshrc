#custom stuff                                                                                                                               
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
export PATH=$PATH:$GOPATH/bin

export JBOSS_HOME=/usr/local/opt/wildfly-as/libexec
export PATH=${PATH}:${JBOSS_HOME}/bin

#other
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile

export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git git-flow)
source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin
export PATH=$PATH:$HOME/Dropbox/Projects/depot_tools
export PATH=$PATH:./node_modules/.bin

# PHP Composer bin folder
export PATH=$PATH:./vendor/bin

# Rust bin path
export PATH=$PATH:~/.cargo/bin

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# bindkey, weee, vim mode ;)
bindkey -v                                                                                    
 
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
 
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}
 
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

# The next line updates PATH for the Google Cloud SDK.
source '/Users/fl-macbook-retina/google-cloud-sdk/path.zsh.inc'

# The next line enables shell command completion for gcloud.
source '/Users/fl-macbook-retina/google-cloud-sdk/completion.zsh.inc'

# Opan Ocaml package manager
eval `opam config env`

# Google gyp stuff

export CXX=`which clang++`
export CC=`which clang`
export CPP="`which clang` -E -std=c++11 -stdlib=libc++"
export LINK="`which clang++` -std=c++11 -stdlib=libc++"
export CXX_host=`which clang++`
export CC_host=`which clang`
export CPP_host="`which clang` -E"
export LINK_host=`which clang++`
export GYP_DEFINES="clang=1 mac_deployment_target=10.9"

man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}
export PATH="/usr/local/sbin:$PATH"
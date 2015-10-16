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
source /usr/local/share/zsh/site-functions/_aws

export DOCKER_HOST=tcp://192.168.42.43:2375
#export DOCKER_HOST=tcp://192.168.59.103:2376
#export DOCKER_CERT_PATH=/Users/fl-macbook-retina/.boot2docker/certs/boot2docker-vm
#export DOCKER_TLS_VERIFY=1
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


# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-flow)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}
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


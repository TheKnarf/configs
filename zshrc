#custom stuff
if [[ ${TERM} == "screen-bce" || ${TERM} == "screen" ]]; then
  precmd () { print -Pn "\033k\033\134\033k%m[%1d]\033\134" }
  preexec () { print -Pn "\033k\033\134\033k%m[$1]\033\134" }
else
  precmd () { print -Pn "\e]0;%n@%m: %~\a" }
  preexec () { print -Pn "\e]0;%n@%m: $1\a" }
fi
PS1=$'%{\e[0;32m%}%m%{\e[0m%}:%~> '
export PS1

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

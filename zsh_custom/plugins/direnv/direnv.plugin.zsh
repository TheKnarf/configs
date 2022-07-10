# Eval direnv to dynamically load and unload enviroment variables based on different projects
if [[ $(command -v direnv) == "" ]]; then
else
	eval "$(direnv hook zsh)"
fi

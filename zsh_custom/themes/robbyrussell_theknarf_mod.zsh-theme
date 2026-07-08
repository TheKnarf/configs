# Run the prompt's git commands with Apple's git: Homebrew binaries can block
# 10-20s on Gatekeeper (syspolicyd) assessment when the system is busy, and
# this runs before every prompt. Apple-signed /usr/bin/git is exempt.
if [ -x /usr/bin/git ]; then
	__git_prompt_git() { GIT_OPTIONAL_LOCKS=0 /usr/bin/git "$@" }
fi

if [ -n "$SSH_TTY" ]; then
	SHOWHOSTNAME="$(uname -n) "
else
	SHOWHOSTNAME=""
fi

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${SHOWHOSTNAME}${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

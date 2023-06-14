# If the exa command is installed
# then update the `ls`, `ll`, and `la` commands
if command -v exa &> /dev/null
then
	alias ls='exa --grid --color auto --icons --sort=type'
	alias ll='exa --long --color always --icons --sort=type'
	alias la='exa --long --all --color auto --icons --sort=type'
fi

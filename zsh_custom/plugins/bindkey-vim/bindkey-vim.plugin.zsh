# bindkey, weee, vim mode ;)
bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
bindkey '^u' backward-kill-line
bindkey '^y' yank
bindkey '^d' delete-char-or-list

# Copy to system clipboard on yank (macOS)
if [[ "$OSTYPE" == darwin* ]]; then
    function vi-yank-clipboard {
        zle vi-yank
        echo -n "$CUTBUFFER" | pbcopy
    }
    function vi-yank-eol-clipboard {
        zle vi-yank-eol
        echo -n "$CUTBUFFER" | pbcopy
    }
    zle -N vi-yank-clipboard
    zle -N vi-yank-eol-clipboard
    bindkey -M vicmd 'y' vi-yank-clipboard
    bindkey -M vicmd 'Y' vi-yank-eol-clipboard
fi

# Ctrl-J to continue command on new line (adds trailing \ if needed)
function newline-continue {
    if [[ "$BUFFER" != *'\' ]]; then
        BUFFER="$BUFFER \\"
    fi
    BUFFER="$BUFFER
"
    CURSOR=${#BUFFER}
}
zle -N newline-continue
bindkey -M viins '^J' newline-continue
bindkey -M vicmd '^J' newline-continue

# Ctrl-X Ctrl-E to edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

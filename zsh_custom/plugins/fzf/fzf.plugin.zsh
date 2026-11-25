# fzf shell integration (key bindings and ** completion) plus custom widgets.
# Needs fzf >= 0.48 for `fzf --zsh`; install it from Homebrew on every machine
# (Debian 12's apt package is too old).

if (( ! $+commands[fzf] )); then
    print -u2 "fzf plugin: fzf not found"
    return
fi

eval "$(fzf --zsh)"

if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
    if (( $+commands[rg] )); then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
    elif (( $+commands[fd] )); then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    fi
fi

# Helper: use fzf-tmux popup if in tmux, otherwise regular fzf
_fzf_cmd() {
    if [[ -n "$TMUX" ]]; then
        fzf-tmux -p 80%,80% "$@"
    else
        fzf "$@"
    fi
}

# Ctrl+F: fuzzy find files and insert into command line. Deliberately shares
# its name with fzf's own Ctrl+T widget, so Ctrl+T runs this one too.
fzf-file-widget() {
    local cmd selected
    if (( $+commands[fd] )); then
        cmd='fd --type f --hidden --exclude .git'
    elif (( $+commands[rg] )); then
        cmd='rg --files --hidden --glob "!.git/*"'
    else
        cmd='find . -type f -not -path "*/\.git/*"'
    fi
    selected=$(eval "$cmd" | _fzf_cmd --reverse)
    if [[ -n "$selected" ]]; then
        LBUFFER+="${selected}"
    fi
    zle redisplay
}
zle -N fzf-file-widget
bindkey '^F' fzf-file-widget

# Ctrl+G: fuzzy grep file contents and insert filename into command line
fzf-grep-widget() {
    local selected file
    if (( $+commands[rg] )); then
        selected=$(rg --color=always --line-number --hidden --glob "!.git/*" "" 2>/dev/null \
            | _fzf_cmd --ansi --reverse \
                  --delimiter : \
                  --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || head -100 {1}' \
                  --preview-window '+{2}-5')
    else
        selected=$(grep -rn --color=always "" . 2>/dev/null \
            | _fzf_cmd --ansi --reverse \
                  --delimiter : \
                  --preview 'head -100 {1}')
    fi
    if [[ -n "$selected" ]]; then
        file=$(echo "$selected" | cut -d: -f1)
        LBUFFER+="${file}"
    fi
    zle redisplay
}
zle -N fzf-grep-widget
bindkey '^G' fzf-grep-widget

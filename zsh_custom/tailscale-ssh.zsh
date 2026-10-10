# Extend the standard SSH host completer without replacing its suggestions.
autoload -Uz _ssh_hosts
autoload +X _ssh_hosts
if (( ! $+functions[_tailscale_original_ssh_hosts] )); then
  functions[_tailscale_original_ssh_hosts]=$functions[_ssh_hosts]
fi

zmodload zsh/datetime

_tailscale_ssh_hostnames() {
  local output
  (( $+commands[tailscale] && $+commands[jq] )) || return 1

  # Refresh at most once a minute, including when the daemon is unavailable.
  if (( ! ${+_tailscale_ssh_checked} || EPOCHSECONDS - _tailscale_ssh_checked >= 60 )); then
    typeset -g _tailscale_ssh_checked=$EPOCHSECONDS
    typeset -ga _tailscale_ssh_hosts=()
    output=$(command tailscale status --json 2>/dev/null | command jq -r '
      .Peer[]? | (.DNSName // "") | select(length > 0) |
      rtrimstr(".") | ., split(".")[0]
    ' 2>/dev/null) && _tailscale_ssh_hosts=("${(@f)output}")
  fi
  reply=("${(@)_tailscale_ssh_hosts:#}")
  (( $#reply ))
}

_ssh_hosts() {
  local ret=1
  local -a reply
  _tailscale_original_ssh_hosts "$@" && ret=0
  if _tailscale_ssh_hostnames; then
    local expl
    _wanted hosts expl 'remote host name' \
      compadd -M 'm:{a-zA-Z}={A-Za-z} r:|.=* r:|=*' "$@" -a reply && ret=0
  fi
  return ret
}

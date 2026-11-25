# Configs

Dot files and other config files.
First time setup scritps under `os/`.

## Installation

```
./setup
```

## Machine-local settings

Settings that only apply to one machine (local paths, secrets, installer
additions) go in `~/.<file>.local`, outside this repo. Each config loads its
local file last, if it exists, so it can override the shared settings:

| Config      | Local file            |
| ----------- | --------------------- |
| `zshrc`     | `~/.zshrc.local`      |
| `vimrc`     | `~/.vimrc.local`      |
| `gitconfig` | `~/.gitconfig.local`  |
| `tmux.conf` | `~/.tmux.conf.local`  |

Installers that append to `~/.zshrc` (and `git maintenance register`, which
writes to `~/.gitconfig`) edit the repo's copy through the symlink, so move
those lines to the local file.

## Testing

You can test out the setup using Docker.

```
docker build -t dotfiles .
docker run -it dotfiles
```

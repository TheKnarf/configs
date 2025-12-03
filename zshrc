# Determine the operating system
os=$(uname -s)

# Check if the operating system is macOS
if [ "$os" = "Darwin" ]; then
    export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
elif [ "$os" = "Linux" ]; then
	if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	fi
else
    echo "Unsupported operating system: $os"
fi

if command -v brew &> /dev/null
then
. `brew --prefix`/etc/profile.d/z.sh
fi

# mise-en-plcae
if command -v mise &> /dev/null
then
  eval "$(mise activate zsh)"
fi

# Use the `man` command to view Markdown files
function mat {
	tempfile=$(mktemp)
	pandoc --to man "$1" > "$tempfile"
	man $tempfile
}

gif() {
    # Based on https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385
    output_file="${1%.*}.gif"
    ffmpeg -y -i "$1" -v quiet -vf scale=iw/2:ih/2 -pix_fmt rgb8 -r 10 "$output_file" && gifsicle -O3 "$output_file" -o "$output_file"
}

# IRC / irssi
export IRCNAME=""
export IRCNICK="knarf"
export IRCUSER="knarf"

# Setup path
path+=(
	'/usr/bin'
	'/bin'
	'/usr/sbin'
	'/sbin'
	'/usr/local/bin'
	'/usr/local/sbin'
	'/usr/local/git/bin'
	'/snap/bin'
	"$HOME/.bin"
	'./vendor/bin'          # PHP Composer bin folder
	'~/.cargo/bin'          # Rust bin path
	"$GOPATH/bin"
	"$HOME/.yarn/bin"
	"$HOME/.config/yarn/global/node_modules/.bin"
)
export PATH

alias paths_debug="echo $PATH | sed 's/:/\n/g' | sort | uniq -c"

# Ensure that MANPATH have a : in the beginning
export MANPATH=":$MANPATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Make Node prefer ipv4
export NODE_OPTIONS="--dns-result-order=ipv4first"

# https://consoledonottrack.com/
export DO_NOT_TRACK=1

# Oh my zsh
ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=$HOME/configs/zsh_custom
ZSH_THEME="robbyrussell_theknarf_mod"
plugins=(
	git-flow
	zsh-autosuggestions
	ssh-agent
	man-color
	bindkey-vim
	kubectl
	wasmer
	bun
	direnv
	fzf
	exa
  docker
)
source $ZSH/oh-my-zsh.sh

# Re-activate the canonical Ctrl-X Ctrl-E to edit-and-execute-command
autoload -Uz edit-command-line      # load the widget
zle     -N  edit-command-line       # tell ZLE it’s an editor widget
bindkey '^X^E' edit-command-line    # Emacs/Readline style binding

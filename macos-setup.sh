#!/usr/bin/env bash

echo 'Disable the "Are you sure you want to open this application?" dialog'
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo 'Set Screenshot folder to ~/Downloads'
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

# Check if Homebrew is installed
command -v brew >/dev/null 2>&1 || { \
	echo >&2 "Installing Homebrew Now"; \
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; \
}

brew_check_if_installed () {
	if brew ls --versions $1 > /dev/null; then
		echo "$1 allready installed"
	else
		echo "$1 is not installed with brew"
		read -p "Install it? [yN] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo
			echo "Installing $1"
			brew install $1
		fi
	fi
}

brew_cask_check_if_installed () {
	if brew cask ls --versions $1 > /dev/null; then
		echo "$1 allready installed"
	else
		echo "$1 is not installed with brew cask"
		read -p "Install it? [yN] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo
			echo "Installing $1"
			brew cask install $1
		fi
	fi
}


brew_check_if_installed git

brew_cask_check_if_installed iTerm2

echo 'Specify the preferences directory for iTerm2'
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.iterm2_profile"

echo 'Tell iTerm2 to use the custom preferences in the directory'
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true


# Enviroment
brew_check_if_installed z
brew_check_if_installed tmux
brew_check_if_installed fzf
brew_check_if_installed wget
brew_check_if_installed tree
brew_check_if_installed watch

# Pandoc
brew_check_if_installed pandoc
brew_check_if_installed pandoc-citeproc
brew_check_if_installed pandoc-crossref

# Programming
brew_check_if_installed node
brew_check_if_installed cmake
brew_check_if_installed rustup-init

# Other
brew_check_if_installed ansible

# Casks
brew_cask_check_if_installed google-chrome
brew_cask_check_if_installed dropbox
brew_cask_check_if_installed alfred
brew_cask_check_if_installed spotify
brew_cask_check_if_installed slack
brew_cask_check_if_installed virtualbox
brew_cask_check_if_installed vlc
brew_cask_check_if_installed sublime-text
brew_cask_check_if_installed disk-inventory-x
brew_cask_check_if_installed forklift
brew_cask_check_if_installed typora
brew_cask_check_if_installed postman
brew_cask_check_if_installed webtorrent
brew_cask_check_if_installed the-unarchiver
brew_cask_check_if_installed vagrant

# Games
brew_cask_check_if_installed minecraft
brew_cask_check_if_installed steam

#!/usr/bin/env bash

# If running MacOS under arm64 (aka M1)
if [[ `arch` == 'arm64' ]]; then
	if [[ "`pkgutil --files com.apple.pkg.RosettaUpdateAuto`" == "" ]]; then
		sudo softwareupdate --install-rosetta
	else
		echo "Rosetta is allready installed"
	fi
fi

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

echo "Update setting: expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Update setting: Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Update setting: Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo 'Disable the "Are you sure you want to open this application?" dialog'
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo 'Set Screenshot folder to ~/Downloads'
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

echo "Don't show thumbnail on screenshot"
defaults write com.apple.screencapture show-thumbnail -bool false

echo "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Finder: When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Finder: Avoid creating .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo 'Hot corners'
# defaults read com.apple.dock | grep wvous # check hot corners
# ref https://blog.jiayu.co/2018/12/quickly-configuring-hot-corners-on-macos/
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0

echo "Remove default pinned apps from Dock"
# https://stackoverflow.com/questions/56121092/applescript-to-remove-items-from-dock
defaults delete com.apple.dock persistent-apps; killall Dock

# Check if Homebrew is installed
command -v brew >/dev/null 2>&1 || { \
	echo >&2 "Installing Homebrew Now"; \
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; \
}

brew_cask_check_if_installed () {
	if brew ls --cask --versions $1 > /dev/null; then
		echo "$1 allready installed"
	else
		echo "$1 is not installed with brew cask"
		read -p "Install it? [yN] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo
			echo "Installing $1"
			brew install --cask $1
		fi
	fi
}


brew install git
brew install --cask iTerm2

echo 'Specify the preferences directory for iTerm2'
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.iterm2_profile"

echo 'Tell iTerm2 to use the custom preferences in the directory'
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true


# Enviroment
brew install \
	z \
	tmux \
	fzf \
	fd \
	rg \
	wget \
	tree \
	watch \
	fswatch \
	reattach-to-user-namespace \
	htop \
	neovim \
	jq \
	cloc \
	coreutils \
	bat

# Programming
brew install \
	node@16 \
	cmake \
	rustup-init \
	yarn \
	go

# Ensure that we have versionj 16 of node
brew link --overwrite node@16

# Casks
brew_cask_check_if_installed google-chrome
brew_cask_check_if_installed dropbox
brew_cask_check_if_installed alfred
brew_cask_check_if_installed spotify
brew_cask_check_if_installed slack
brew_cask_check_if_installed discord
brew_cask_check_if_installed vlc
brew_cask_check_if_installed sublime-text
brew_cask_check_if_installed disk-inventory-x
brew_cask_check_if_installed forklift
brew_cask_check_if_installed typora
brew_cask_check_if_installed postman
brew_cask_check_if_installed webtorrent
brew_cask_check_if_installed the-unarchiver
brew_cask_check_if_installed blender
brew_cask_check_if_installed talon

# Virtualization
brew_cask_check_if_installed virtualbox
brew_cask_check_if_installed vagrant

# Games
brew_cask_check_if_installed minecraft
brew_cask_check_if_installed steam

# Font
brew install svn # needed for cask-fonts
brew tap homebrew/cask-fonts
brew_cask_check_if_installed font-source-code-pro-for-powerline
brew_cask_check_if_installed font-consolas-for-powerline
brew_cask_check_if_installed font-fira-mono-for-powerline
brew_cask_check_if_installed font-roboto-mono-for-powerline

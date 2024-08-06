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

# Dark mode
echo "Set dark mode"
osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true"

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

brew bundle

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

echo 'Specify the preferences directory for iTerm2'
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.iterm2_profile"

echo 'Tell iTerm2 to use the custom preferences in the directory'
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

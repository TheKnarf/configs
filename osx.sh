#!/usr/bin/env bash

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Set Screenshot folder to ~/Downloads
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

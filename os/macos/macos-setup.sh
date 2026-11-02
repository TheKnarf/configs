#!/usr/bin/env bash

# --- CHECK FOR FULL DISK ACCESS ---
# Attempting to read a highly protected file that requires FDA to access.
# If Terminal doesn't have FDA, this 'plutil' test will fail.
if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null 2>&1; then
    echo "[-] Error: Terminal lacks Full Disk Access privileges."
    echo "[*] Opening System Settings to Full Disk Access..."

    # 1. Pop up a native macOS dialog explaining what to do
    osascript -e 'display dialog "This script requires Full Disk Access.\n\nPlease toggle ON the switch for Terminal in the System Settings window that just opened, then restart this script." with title "Permission Required" buttons {"OK"} default button "OK" giving up after 15' >/dev/null 2>&1 &

    # 2. Open System Settings directly to the Full Disk Access pane
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

    # 3. Abort the script safely
    exit 1
fi

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

# Activate sshd
sudo systemsetup -setremotelogin on

echo "Remove default pinned apps from Dock"
# https://stackoverflow.com/questions/56121092/applescript-to-remove-items-from-dock
defaults delete com.apple.dock persistent-apps; killall Dock

# Check if Homebrew is installed
command -v brew >/dev/null 2>&1 || { \
	echo >&2 "Installing Homebrew Now"; \
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
}

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Verify it worked before trying to use it
if ! command -v brew &> /dev/null; then
    echo "[-] Error: Homebrew installation failed or PATH could not be set."
    exit 1
fi

# Install Rust
command -v cargo >/dev/null 2>&1 || { \
  echo >&2 "Installing rustup"; \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- -y; \
}

brew bundle

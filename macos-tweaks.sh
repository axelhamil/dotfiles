#!/bin/bash

echo "🔧 Applying macOS tweaks for Dock, Finder, and Keyboard..."

# 📦 Dock settings
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1

# 🗂 Finder settings
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ⌨️ Keyboard settings
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# 🔄 Restart affected services
killall Dock
killall Finder
killall SystemUIServer

echo "✅ Done. Some changes may require you to log out or reboot."


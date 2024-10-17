#!/bin/bash

# Function to detect OS and install Firefox
install_firefox() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  else
    OS=$(uname -s)
  fi

  case $OS in
    arch | manjaro)
      echo "Detected Arch-based system. Installing Firefox via pacman..."
      sudo pacman -S --noconfirm firefox
      ;;
    ubuntu | debian)
      echo "Detected Debian-based system. Installing Firefox via apt..."
      sudo apt update && sudo apt install -y firefox
      ;;
    fedora)
      echo "Detected Fedora. Installing Firefox via dnf..."
      sudo dnf install -y firefox
      ;;
    opensuse)
      echo "Detected OpenSUSE. Installing Firefox via zypper..."
      sudo zypper install -y firefox
      ;;
    *)
      echo "Unsupported OS: $OS. Please install Firefox manually."
      exit 1
      ;;
  esac
}

# Install Firefox if not already installed
if ! command -v firefox &> /dev/null; then
  echo "Firefox not found. Installing Firefox..."
  install_firefox
else
  echo "Firefox is already installed."
fi

# Define the directory for Firefox's user profile
PROFILE_DIR="$HOME/.mozilla/firefox/custom-profile"

# Check if the pre-configured profile exists and extract if not
if [ ! -d "$PROFILE_DIR" ]; then
  echo "Extracting pre-configured Firefox profile..."
  unzip ./preconfigured-profile.zip -d "$HOME/.mozilla/firefox/"
else
  echo "Pre-configured profile already exists."
fi

# Copy the icon to a stable location
ICON_PATH="$HOME/.local/share/icons/Tailfox-icon.png"
if [ -f "./Tailfox-icon.png" ]; then
  echo "Copying custom icon..."
  cp ./Tailfox-icon.png "$ICON_PATH"
fi

# Copy custom desktop entry to user's local applications directory
DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/tailfox-browser.desktop"
if [ -f "./firefox-custom.desktop" ]; then
  echo "Installing custom desktop entry..."
  sed -i "s|^Icon=.*|Icon=$ICON_PATH|g" ./firefox-custom.desktop
  cp ./firefox-custom.desktop "$DESKTOP_ENTRY_PATH"
  chmod +x "$DESKTOP_ENTRY_PATH"
else
  echo "Custom desktop entry not found in repo. Skipping..."
fi

# Launch Firefox with the pre-configured profile
echo "Launching Tailfox Browser..."
firefox --profile "$HOME/.mozilla/firefox/custom-profile" \
  --new-instance \
  --no-remote \
  --disable-crash-reporter \
  --disable-features=UsePortal \
  >/dev/null 2>&1

# Overwrite default Firefox desktop entry with custom icon
DESKTOP_ENTRY_PATH="/usr/share/applications/firefox.desktop"
CUSTOM_ICON_PATH="$HOME/.local/share/icons/Tailfox-icon.png"

if [ -f "$DESKTOP_ENTRY_PATH" ]; then
    echo "Applying custom icon to Firefox desktop entry..."
    sudo sed -i "s|^Icon=.*|Icon=$CUSTOM_ICON_PATH|g" "$DESKTOP_ENTRY_PATH"
fi

echo "Customizations applied after Firefox launch."

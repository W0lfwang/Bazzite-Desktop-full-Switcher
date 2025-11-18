#!/bin/bash

# Check if the OS is Bazzite
if ! cat /etc/*-release | grep "Bazzite"; then
    echo "❌ This script is intended for Bazzite OS only. Exiting."
    exit 1
fi

echo "✅ Bazzite OS detected. Proceeding with installation..."

# Move the switcher script
echo "📦 Copying switcher script..."
if sudo cp scripts/bazzite_switcher.sh /usr/local/bin/bazzite_switcher.sh; then
    sudo chmod +x /usr/local/bin/bazzite_switcher.sh || {
        echo "❌ Failed to make script executable."
        exit 1
    }
else
    echo "❌ Failed to copy bazzite_switcher.sh to /usr/local/bin/"
    exit 1
fi

# Move the systemd service file
echo "🛠️ Installing systemd service..."
if sudo cp scripts/bazzite_switcher.service /etc/systemd/system/bazzite_switcher.service; then
    sudo systemctl daemon-reload || echo "⚠️ Warning: daemon-reload failed."
else
    echo "❌ Failed to copy bazzite_switcher.service to /etc/systemd/system/"
    exit 1
fi

# Try Copying the desktop launcher to system-wide location
echo "🧩  Installing desktop launcher..."
if sudo cp scripts/bazzite_switcher.desktop /usr/share/applications/bazzite_switcher.desktop 2>/dev/null; then
    echo "✅ Desktop file installed to /usr/share/applications!"
else
    echo "⚠️  Could not move to /usr/share/applications. Trying user location..."
    USERNAME=$(whoami)
    USER_APP_DIR="/home/$USERNAME/.local/share/applications"
    mkdir -p "$USER_APP_DIR" || {
        echo "❌ Failed to create user applications directory: $USER_APP_DIR"
        exit 1
    }
    if sudo cp scripts/bazzite_switcher.desktop "$USER_APP_DIR/bazzite_switcher.desktop"; then
        echo "✅ Installed to $USER_APP_DIR!"
    else
        echo "❌ Failed to copy desktop file to $USER_APP_DIR"
        exit 1
    fi
fi

# Move Icon too
echo "🖼️ Installing icon..."
if sudo cp resources/bazzite_switcher.png /usr/local/share/icons/bazzite_switcher.png; then
    echo "✅ Icon installed to /usr/local/share/icons/"
else
    echo "❌ Failed to copy icon to /usr/local/share/icons/"
    exit 1
fi

echo "🎉 Installation complete."


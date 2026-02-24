#!/bin/bash

USERNAME=$(whoami)
USER_APP_DIR="/home/$USERNAME/.local/share/applications"

# Check if the OS is Bazzite
if ! grep -qi "bazzite" /etc/os-release; then
    echo "❌ This script is intended for Bazzite OS only. Exiting."
    exit 1
fi

echo "
✅ Bazzite OS detected. Proceeding with installation...
"

# switcher script
echo "📁 Checking /usr/local/bin existence"
if sudo mkdir -p /usr/local/bin; then
    echo "✅ /usr/local/bin checked"
else
    echo "❌ /usr/local/bin Folder missing and cannot be created"
    exit 1
fi

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

# systemd service
echo "📁 Checking /etc/systemd/system existence"
if sudo mkdir -p /etc/systemd/system; then
    echo "✅ /etc/systemd/system checked"
else
    echo "❌ /etc/systemd/system Folder missing and cannot be created"
    exit 1
fi

echo "🛠️  Installing systemd service..."
if sudo cp scripts/bazzite_switcher.service /etc/systemd/system/bazzite_switcher.service; then
    sudo systemctl daemon-reload || echo "⚠️ Warning: daemon-reload failed."
else
    echo "❌ Failed to copy bazzite_switcher.service to /etc/systemd/system/"
    exit 1
fi

# desktop launcher
echo "📁 Checking /usr/share/applications existence"
if sudo mkdir -p /usr/share/applications; then
    echo "✅ /usr/share/applications checked"
    echo "🧩 Installing desktop launcher..."
    if sudo cp scripts/bazzite_switcher.desktop /usr/share/applications/bazzite_switcher.desktop 2>/dev/null; then
        echo "✅ Desktop file installed to /usr/share/applications!"
        ALTERNATIVE=0
    else 
        echo "⚠️  Could not move to /usr/share/applications. Trying user location..."
        ALTERNATIVE=1
    fi

else
    echo "❌ /usr/share/applications Folder missing and cannot be created, trying alternative"
    ALTERNATIVE=1
fi

if [ "$ALTERNATIVE" -eq 1 ]; then
    echo "📁 Checking $USER_APP_DIR existence"
    
    if mkdir -p "$USER_APP_DIR"; then
        echo "✅ $USER_APP_DIR checked"
        echo "🧩 Installing desktop launcher..."

        if cp scripts/bazzite_switcher.desktop "$USER_APP_DIR/bazzite_switcher.desktop"; then
            echo "✅ Installed to $USER_APP_DIR!"
        else
            echo "❌ Failed to copy desktop file to $USER_APP_DIR"
            exit 1
        fi

    else
        echo "❌ Failed to create user applications directory: $USER_APP_DIR"
        exit 1
    fi
fi


# Icon

echo "📁 Checking /usr/local/share/icons existence"
if sudo mkdir -p /usr/local/share/icons; then
    echo "✅ /usr/local/share/icons checked"
else
    echo "❌ /usr/local/share/icons Folder missing and cannot be created"
    exit 1
fi

echo "🖼️  Installing icon..."
if sudo cp resources/bazzite_switcher.png /usr/local/share/icons/bazzite_switcher.png; then
    echo "✅ Icon installed to /usr/local/share/icons/"
else
    echo "❌ Failed to copy icon to /usr/local/share/icons/"
    exit 1
fi

echo
echo "🎉 Installation complete."

echo "
Running the button or service will prompt for password each time, to avoid this you can edit visudo
running sudo visudo and adding this line at the end:

${USERNAME} ALL=(ALL) NOPASSWD: /bin/systemctl start bazzite_switcher.service

using vi might be confusing, please google it or see a youtube video about it."

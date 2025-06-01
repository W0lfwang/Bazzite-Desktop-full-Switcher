#!/bin/bash

if systemctl is-active gdm.service --quiet; then
    echo "Desktopmode is already running."
    sleep 2
    exit 0
fi

echo "Starting system-wide switch service..."

if ! sudo systemctl start bazzite_switch_to_desktop.service; then
    echo "Failed to start the switch-to-sddm service. Exiting without logout."
    exit 1
fi

echo "Logging out..."
gnome-session-quit --no-prompt

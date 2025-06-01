#!/bin/bash

LOGFILE="/var/log/switch-to-sddm.log"

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "$(date) - Error: No argument provided. Use 'd' for desktop mode or 'g' for game mode." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm
    exit 1
fi

# Set variables based on the argument
if [ "$1" == "d" ]; then
    NEW_DM="gdm"
    MODE="Desktop Mode"
    OLD_DM="sddm"
elif [ "$1" == "g" ]; then
    NEW_DM="sddm"
    MODE="Game Mode"
    OLD_DM="gdm"
else
    echo "$(date) - Error: Invalid argument. Use 'd' for desktop mode or 'g' for game mode." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm
    exit 1
fi

# Logging the start of the process
echo "$(date) - Starting switch to $MODE..." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm

# Disable the current display manager if it's running
if systemctl is-active "$OLD_DM".service --quiet; then
    echo "$(date) - Disabling $OLD_DM..." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm
    systemctl disable "$OLD_DM".service --now
fi

# Enable the selected display manager
echo "$(date) - Enabling $NEW_DM..." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm
systemctl enable "$NEW_DM".service --now

# Logging the completion of the process
echo "$(date) - Switch completed to $NEW_DM." | tee -a "$LOGFILE" | systemd-cat -t switch-to-sddm

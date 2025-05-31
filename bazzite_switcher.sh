#!/bin/bash

LOGFILE="/var/log/bazzite-switcher.log"

# Check the display manager running
if systemctl is-active sddm.service --quiet; then
    echo "$(date) - sddm found" | tee -a "$LOGFILE"
    SYSTEM_MODE="G"
    OLD_DM="sddm"
    NEXT_DM="gdm"
elif systemctl is-active gdm.service --quiet; then
    echo "$(date) - gdm found" | tee -a "$LOGFILE"
    SYSTEM_MODE="D"
    OLD_DM="sddm"
    NEXT_DM="gdm"
else
    echo "$(date) - Error: A display manager different from gdm or sddm is being used, nothing to do" | tee -a "$LOGFILE" | systemd-cat -t bazzite_switcher
    exit 1


# If argument is not given, that means we are user invoke, we will call the service
if [ -z "$1" ]; then
    if [ $SYSTEM_MODE == "G" && $XDG_SESSION_TYPE == "x11"];
        # This means we are in full gamemode
        if ! sudo systemctl start bazzite_switcher.service; then
            echo "$(date) - failed to start bazzite_switcher service" | tee -a "$LOGFILE" | systemd-cat -t bazzite_switcher

        exit 1

    elif [ $SYSTEM_MODE == "G" && $XDG_SESSION_TYPE == "wayland"]; then
        # This means we are in desktop mode from gamemode
    elif [ $SYSTEM_MODE == "D" ]; then
        # This means we are in desktop mode
        if ! sudo systemctl start bazzite_switcher.service; then
            echo "$(date) - failed to start bazzite_switcher service" | tee -a "$LOGFILE" | systemd-cat -t bazzite_switcher
            exit 1

    echo "Logging out..."
    gnome-session-quit --no-prompt
    exit 1
    
fi

fi

# If argument is given, that means it was invoke by system-service, so we do
# the functionality of the actual switch

# Wrong argument given
if [ "$1" == "s" ]; then
    echo "$(date) - Starting switch..." | tee -a "$LOGFILE" 
    echo "$(date) - Disabling $OLD_DM..." | tee -a "$LOGFILE"
    systemctl disable "$OLD_DM".service --now

    echo "$(date) - Enabling $NEW_DM..." | tee -a "$LOGFILE"
    systemctl enable "$NEW_DM".service --now

    echo "$(date) - Switch completed to $NEW_DM." | tee -a "$LOGFILE" | systemd-cat -t bazzite_switcher
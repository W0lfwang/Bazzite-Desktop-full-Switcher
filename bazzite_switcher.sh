#!/bin/bash

# Check the display manager running
if systemctl is-active sddm.service --quiet; then
    SYSTEM_MODE="G"
    OLD_DM="sddm"
    NEXT_DM="gdm"
elif systemctl is-active gdm.service --quiet; then
    SYSTEM_MODE="D"
    OLD_DM="sddm"
    NEXT_DM="gdm"
else
    echo "$(date) - Error: A display manager different from gdm or sddm is being used, nothing to do" | systemd-cat -t bazzite_switcher
    exit 1
fi

# If argument is not given, that means we are user invoke, we will call the service
if [ -z "$1" ]; then
    if [ "$SYSTEM_MODE" == "G" ] && [ "$XDG_SESSION_TYPE" == "x11" ]; then
        echo "$(date) - Full gamemode running" | systemd-cat -t bazzite_switcher
        if ! sudo systemctl start bazzite_switcher.service; then
            echo "$(date) - failed to start bazzite_switcher service" | systemd-cat -t bazzite_switcher
            exit 1
        fi

    elif [ "$SYSTEM_MODE" == "G" ] && [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        echo "$(date) - Desktop from gamemode running" | systemd-cat -t bazzite_switcher
        USER_CHOICE=$(zenity --list \
            --title="Mode Switch" \
            --text="You are in Desktop mode from Gamemode. What do you want to do?" \
            --radiolist \
            --column="Select" --column="Action" \
            TRUE "Return to gamemode" \
            FALSE "Go to full desktop" \
            --width=200 --height=300)

        case "$USER_CHOICE" in
            "Return to gamemode")
                echo "$(date) - Returning to gamemode..." | systemd-cat -t bazzite_switcher
                gnome-session-quit --no-prompt
                # Implement logic to return to gamemode here
                ;;
            "Go to full desktop")
                echo "$(date) - Switching to full desktop..." | systemd-cat -t bazzite_switcher
                if ! sudo systemctl start bazzite_switcher.service; then
                    echo "$(date) - failed to start bazzite_switcher service" | systemd-cat -t bazzite_switcher
                    exit 1
                fi
                gnome-session-quit --no-prompt
                ;;
        esac

    elif [ "$SYSTEM_MODE" == "D" ]; then
        echo "$(date) - Full Desktop mode running" | systemd-cat -t bazzite_switcher
        if ! sudo systemctl start bazzite_switcher.service; then
            echo "$(date) - failed to start bazzite_switcher service" | systemd-cat -t bazzite_switcher
            exit 1
        fi
        gnome-session-quit --no-prompt
    fi

# If argument is given, that means it was invoked by system-service, so we do
# the functionality of the actual switch
elif [ "$1" == "s" ]; then
    echo "$(date) - Starting switch..." | systemd-cat -t bazzite_switcher
    echo "$(date) - Disabling $OLD_DM..." | systemd-cat -t bazzite_switcher
    systemctl disable "$OLD_DM".service --now

    echo "$(date) - Enabling $NEXT_DM..." | systemd-cat -t bazzite_switcher
    systemctl enable "$NEXT_DM".service --now

    echo "$(date) - Switch completed to $NEXT_DM." | systemd-cat -t bazzite_switcher

else
    echo "$(date) - Error: Invalid argument. Expected 's'." | systemd-cat -t bazzite_switcher
    exit 1
fi

#!/bin/bash

USERNAME=$(whoami)

# --- Colors ---
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

FILES=(
    "/usr/local/bin/bazzite_switcher.sh"
    "/etc/systemd/system/bazzite_switcher.service"
    "/usr/share/applications/bazzite_switcher.desktop"
    "/home/$USERNAME/.local/share/applications/bazzite_switcher.desktop"
    "/usr/local/share/icons/bazzite_switcher.png"
)

# -------------------------------------------------------------------
#  PRECHECK: Verify sddm.service is active
# -------------------------------------------------------------------

echo -e "${BLUE}${BOLD}Checking sddm.service status...${RESET}"

if ! systemctl is-active sddm.service --quiet; then
    echo -e "
${RED}${BOLD}WARNING:${RESET} sddm.service is NOT active.
${YELLOW}This means you are probably on full desktop mode (using GNOME Display Manager)
the switcher service can make difficult for you to return Bazzite's original behavior,
I recommend that you run the switcher first before running the uninstall script

To proceed, type: ${BOLD}continue${RESET}"

    read -p "> " sddm_confirm

    if [[ "$sddm_confirm" != "continue" ]]; then
        echo -e "${RED}Aborted due to inactive sddm.service.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Continuing as requested...${RESET}"
    echo
else
    echo -e "${GREEN}sddm.service is active.${RESET}"
    echo
fi

# -------------------------------------------------------------------
#  SCAN FILES
# -------------------------------------------------------------------

found=()
not_found=()

echo -e "${BOLD}${BLUE}Scanning for files...${RESET}"

for FILE in "${FILES[@]}"; do
    if [ -e "$FILE" ]; then
        found+=("$FILE")
    else
        not_found+=("$FILE")
    fi
done

echo
echo -e "${GREEN}Files that will be removed:${RESET}"
if [ ${#found[@]} -eq 0 ]; then
    echo -e "  ${YELLOW}None found.${RESET}"
else
    for f in "${found[@]}"; do
        echo -e "  ${GREEN}$f${RESET}"
    done
fi

echo
echo -e "${YELLOW}Files not found:${RESET}"
if [ ${#not_found[@]} -eq 0 ]; then
    echo -e "  ${GREEN}All files exist.${RESET}"
else
    for f in "${not_found[@]}"; do
        echo -e "  ${YELLOW}$f${RESET}"
    done
fi
echo

# -------------------------------------------------------------------
#  EXIT HERE IF NO FILES WERE FOUND
# -------------------------------------------------------------------

if [ ${#found[@]} -eq 0 ]; then
    echo -e "${BLUE}${BOLD}No existing files were found. Nothing to remove.${RESET}"
    echo -e "${GREEN}Exiting.${RESET}"
    exit 0
fi

# -------------------------------------------------------------------
#  CONFIRMATION (Repeats if empty)
# -------------------------------------------------------------------

while true; do
    read -p "$(echo -e "${BOLD}Proceed with deletion? (y to confirm): ${RESET}")" confirm

    if [[ -z "$confirm" ]]; then
        echo -e "${YELLOW}No input detected. Please type 'y' to confirm or any other key to cancel.${RESET}"
        continue
    fi

    break
done

if [[ "$confirm" != "y" ]]; then
    echo -e "${RED}Aborted.${RESET}"
    exit 0
fi

# -------------------------------------------------------------------
#  DELETION
# -------------------------------------------------------------------

echo
echo -e "${BLUE}${BOLD}Deleting files...${RESET}"
echo

deleted=()
failed=()

for FILE in "${found[@]}"; do
    if sudo rm -f "$FILE" 2>/dev/null; then
        if [ ! -e "$FILE" ]; then
            deleted+=("$FILE")
            echo -e "✔ ${GREEN}Deleted:${RESET} $FILE"
        else
            failed+=("$FILE")
            echo -e "✖ ${RED}Failed:${RESET} $FILE"
        fi
    else
        if [ -e "$FILE" ]; then
            failed+=("$FILE")
            echo -e "✖ ${RED}Failed:${RESET} $FILE"
        fi
    fi
done

# -------------------------------------------------------------------
#  SYSTEMD RELOAD
# -------------------------------------------------------------------

echo
echo -e "${BLUE}${BOLD}Reloading systemd daemon...${RESET}"
sudo systemctl daemon-reload

echo
echo -e "${GREEN}${BOLD}Done.${RESET}"

# BAZZITE DESKTOP FULL SWITCHER
This is a script is created specifically for Bazzite where desktop environment is set to  GNOME and Steam Gaming Mode selected to yes (your computer automatically starts with steam gamemode).

![alt text](resources/Screenshot.png)

The idea of this is for you to have a simple way to convert your gaming computer/handheld into a regular desktop PC without loosing both features.

# Install Script
Download and unzip
run: `sudo chmod +x install-switcher.sh`
than you can execute install-switcher.sh, which is a simple automatically installing script.

# Uninstall Script
run: `sudo chmod -x uninstall-switcher.sh`
then you can execute install-switcher.sh, which removes everything installed before.

# Description
With this script or "button", you can change the behavior of your Bazzite computer/handheld to start in full GNOME mode instead of the steam gamemode, this will allow you to use GNOME login system and screen lock feature, making your computer to work more like a desktop instead of a console, without loosing that feature all together as you can switch between modes anytime without even needing to restart your PC.

The GNOME login and screen lock mechanism is also more secure that simply changing to desktop mode, as in the regular desktop mode you don't have any login steps after going to sleep.

## Inspiration
In my case, I have a Lenovo Legion Go that I use as my personal computer/tablet/laptop, so there are times where I don't even carry the controllers around and can spent days without gaming, I use it a lot to read comic books and code, so I rather to have something closer to a laptop login that entering Steam Menu all the time, and I feel more safe leaving my computer access behind a password.

# What exactly it does?
## Theory
Bazzite comes installed with two different display managers; SDDM ([Simple Desktop Display Manager](https://github.com/sddm/sddm/)) and GDM ([GNOME Display Manager](https://wiki.gnome.org/Projects/GDM)). SDDM takes care of all the Gamemode login and it's the only one that is normally working. So by changing the display manager to GDM, regular GNOME will start.

Bazzite uses SYSTEM_MODE = gamescope-session when running in gamemode. with this information we can choose different option for our script to do different things depending on the session we are using.

## 3 file system
We use a 3 file system to achieve our goal:

**The switcher script**
- Description: This is the script that will make the display manager switch.
- located at: `/usr/local/bin/bazzite_switcher.sh`
    
**Switch Service**
- Description: Service to that will run the script (a service is needed to be use or session will not be terminated correctly).
- located at: `/etc/systemd/system/bazzite_switcher.service`
- Run `sudo systemctl daemon-reload`

**App Drawer**
- Description: A desktop file use so the app can be launched from the GNOME app drawer.
- located at: `/usr/share/applications/bazzite_switcher.desktop` or `/home/<USER>/.local/share/applications/bazzite_switcher.desktop`
- Icon can go to `/usr/local/share/icons/bazzite_switcher.png` Make folder if you need.

## Other comments
we add `your_username ALL=(ALL) NOPASSWD: /bin/systemctl start bazzite_switcher.service` to visudo so we don't have a password prompt.

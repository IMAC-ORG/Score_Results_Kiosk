#!/bin/bash
#############################################################
# AeroJudge Score Results Kiosk - Automated Installer v1.0
# For Raspberry Pi OS (Legacy, 32-bit) Bookworm
#############################################################

set -e  # Exit on any error

echo "=========================================="
echo "AeroJudge Results Kiosk Installer v1.0"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "ERROR: Do not run this script with sudo"
    echo "Run as: ./install.sh"
    exit 1
fi

# Verify we're on the right OS
if ! grep -q 'VERSION_ID="12"' /etc/os-release; then
    echo "WARNING: This script is designed for Raspberry Pi OS Bookworm (Legacy, 32-bit)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1/10: Updating package list..."
sudo apt update

echo ""
echo "Step 2/10: Installing required packages..."
sudo apt install -y wtype chromium-browser

echo ""
echo "Step 3/10: Creating splash screen folder and copying image..."
mkdir -p ~/splashv
cp assets/splash/pisplash_v.png ~/splashv/splash.png

echo ""
echo "Step 4/10: Installing switchtab.sh script..."
cp bin/switchtab.sh ~/switchtab.sh
chmod +x ~/switchtab.sh

echo ""
echo "Step 5/10: Hiding mouse cursor..."
sudo mv /usr/share/icons/PiXflat/cursors/left_ptr /usr/share/icons/PiXflat/cursors/left_ptr.bak 2>/dev/null || echo "Cursor already hidden"

echo ""
echo "Step 6/10: Disabling gnome-keyring..."
sudo apt remove -y gnome-keyring

echo ""
echo "Step 6/10: Configuring Wayfire window manager..."
mkdir -p ~/.config
cat > ~/.config/wayfire.ini << 'EOF'
[autostart]
panel=wfrespawn wf-panel-pi
background=wfrespawn pcmanfm --desktop --profile LXDE-pi
xdg-autostart=lxsession-xdg-autostart
chromium=chromium-browser --kiosk --noerrdialogs --disable-infobars --no-first-run --disable-session-crashed-bubble --disable-features=TranslateUI --check-for-update-interval=31536000 file:///home/resultskiosk/splashv/splash.png http://192.168.8.100/kiosk/report_results.html
switchtab=bash /home/resultskiosk/switchtab.sh
screensaver=false
dpms=false

[output:HDMI-A-1]
mode=1920x1080@60000
position=0,0
transform=270

[output:HDMI-A-2]
mode=1920x1080@60000
position=0,0
transform=270

[core]
plugins=autostart vswitch
EOF

echo ""
echo "Step 7/10: Setting up auto-login..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin resultskiosk --noclear %I \$TERM
EOF

echo ""
echo "Step 8/10: Setting Wayfire as default session..."
mkdir -p ~/.config/lxsession/LXDE-pi
echo "@wayfire" > ~/.config/lxsession/LXDE-pi/autostart

echo ""
echo "Step 9/10: Configuring lightdm for Wayfire session..."
sudo sed -i 's/^autologin-session=.*/autologin-session=LXDE-pi-wayfire/' /etc/lightdm/lightdm.conf
sudo sed -i 's/^user-session=.*/user-session=LXDE-pi-wayfire/' /etc/lightdm/lightdm.conf

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "The system will reboot in 5 seconds..."
echo "After reboot, the kiosk will start automatically."
echo ""
sleep 5

sudo reboot

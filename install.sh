#!/bin/bash

################################################################################
# Score Results Kiosk - Simple Installer v1.0.0
# Assumes system is pre-configured via Raspberry Pi Imager
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Expected configuration (must match Pi Imager settings)
KIOSK_USER="resultskiosk"
EXPECTED_HOSTNAME="aerojudge"
SCORE_SERVER="192.168.8.100"
DISPLAY_ROTATION="270"  # portrait_left (90=portrait_right, 180=inverted, 270=portrait_left)

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_error() {
    echo -e "${RED}✖ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✔ SUCCESS: $1${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo ./install.sh"
        exit 1
    fi
}

################################################################################
# Pre-flight Checks
################################################################################

preflight_checks() {
    print_header "Pre-Flight Checks"
    
    # Check OS version
    print_step "Checking OS version..."
    if [ ! -f /etc/os-release ]; then
        print_error "Cannot determine OS version"
        exit 1
    fi
    
    . /etc/os-release
    
    if [[ "$VERSION_CODENAME" != "bookworm" ]]; then
        print_error "This installer requires Raspberry Pi OS Bookworm (Debian 12)"
        print_error "Detected: $VERSION_CODENAME"
        echo ""
        echo "Please flash Raspberry Pi OS (Legacy, 32-bit) using Pi Imager"
        exit 1
    fi
    
    ARCH=$(dpkg --print-architecture)
    echo "   OS: $PRETTY_NAME ($ARCH)"
    print_success "OS version check passed"
    
    # Check if user exists
    print_step "Checking for user '$KIOSK_USER'..."
    if ! id "$KIOSK_USER" &>/dev/null; then
        print_error "User '$KIOSK_USER' does not exist"
        echo ""
        echo "This installer expects the system to be pre-configured using"
        echo "Raspberry Pi Imager. Please see docs/PI_IMAGER_SETUP.md for instructions."
        exit 1
    fi
    print_success "User '$KIOSK_USER' found"
    
    # Check hostname
    print_step "Checking hostname..."
    CURRENT_HOSTNAME=$(hostname)
    if [[ "$CURRENT_HOSTNAME" != "$EXPECTED_HOSTNAME" ]]; then
        print_warning "Hostname is '$CURRENT_HOSTNAME' (expected '$EXPECTED_HOSTNAME')"
        echo "   This is OK, but you may want to update it for consistency"
    else
        print_success "Hostname is correct: $EXPECTED_HOSTNAME"
    fi
    
    # Check if running as intended user
    print_step "Verifying current user..."
    ACTUAL_USER="${SUDO_USER:-$USER}"
    if [[ "$ACTUAL_USER" != "$KIOSK_USER" ]]; then
        print_warning "Running as '$ACTUAL_USER' instead of '$KIOSK_USER'"
        echo "   This is OK, but make sure you're SSH'd in as '$KIOSK_USER'"
    fi
    
    # Check network connectivity
    print_step "Checking network connectivity..."
    if ping -c 1 8.8.8.8 &>/dev/null; then
        print_success "Network connection OK"
    else
        print_error "No network connection detected"
        echo "   Please check WiFi configuration and try again"
        exit 1
    fi
    
    echo ""
}

################################################################################
# Install Required Packages
################################################################################

install_packages() {
    print_header "Installing Required Packages"
    
    print_step "Updating package lists..."
    apt-get update -qq || {
        print_error "Failed to update package lists"
        exit 1
    }
    
    # Detect chromium package name
    print_step "Detecting Chromium package..."
    if apt-cache show chromium-browser &>/dev/null; then
        CHROMIUM_PKG="chromium-browser"
    elif apt-cache show chromium &>/dev/null; then
        CHROMIUM_PKG="chromium"
    else
        print_error "Cannot find chromium package"
        exit 1
    fi
    echo "   Found: $CHROMIUM_PKG"
    
    # Install packages
    print_step "Installing: wtype, $CHROMIUM_PKG..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq wtype "$CHROMIUM_PKG" || {
        print_error "Failed to install packages"
        exit 1
    }
    
    print_success "All packages installed"
    echo ""
}

################################################################################
# Copy Kiosk Files
################################################################################

copy_files() {
    print_header "Installing Kiosk Files"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    KIOSK_HOME="/home/$KIOSK_USER"
    
    # Create directories
    print_step "Creating directories..."
    mkdir -p "$KIOSK_HOME/splashv"
    mkdir -p "$KIOSK_HOME/.config"
    
    # Copy switchtab.sh
    print_step "Installing switchtab.sh..."
    if [ -f "$SCRIPT_DIR/bin/switchtab.sh" ]; then
        cp "$SCRIPT_DIR/bin/switchtab.sh" "$KIOSK_HOME/switchtab.sh"
        chmod +x "$KIOSK_HOME/switchtab.sh"
    else
        print_error "bin/switchtab.sh not found"
        echo "   Expected location: $SCRIPT_DIR/bin/switchtab.sh"
        exit 1
    fi
    
    # Copy splash image (using vertical version)
    print_step "Installing splash screen..."
    if [ -f "$SCRIPT_DIR/assets/splash/pisplash_v.png" ]; then
        cp "$SCRIPT_DIR/assets/splash/pisplash_v.png" "$KIOSK_HOME/splashv/splash.png"
    else
        print_error "assets/splash/pisplash_v.png not found"
        echo "   Expected location: $SCRIPT_DIR/assets/splash/pisplash_v.png"
        exit 1
    fi
    
    print_success "Kiosk files installed"
    echo ""
}

################################################################################
# Configure Wayfire Window Manager
################################################################################

configure_wayfire() {
    print_header "Configuring Wayfire"
    
    KIOSK_HOME="/home/$KIOSK_USER"
    
    print_step "Creating Wayfire configuration..."
    mkdir -p "$KIOSK_HOME/.config"
    
    cat > "$KIOSK_HOME/.config/wayfire.ini" <<EOF
[autostart]
panel=wfrespawn wf-panel-pi
background=wfrespawn pcmanfm --desktop --profile LXDE-pi
xdg-autostart=lxsession-xdg-autostart
switchtab=bash $KIOSK_HOME/switchtab.sh
screensaver=false
dpms=false

[output:HDMI-A-1]
mode=1920x1080@60000
position=0,0
transform=$DISPLAY_ROTATION

[output:HDMI-A-2]
mode=1920x1080@60000
position=0,0
transform=$DISPLAY_ROTATION
EOF
    
    print_success "Wayfire configured with auto-start and $DISPLAY_ROTATION° rotation"
    echo ""
}

################################################################################
# Hide Mouse Cursor
################################################################################

hide_cursor() {
    print_header "Hiding Mouse Cursor"
    
    CURSOR_PATH="/usr/share/icons/PiXflat/cursors/left_ptr"
    
    print_step "Renaming cursor file..."
    if [ -f "$CURSOR_PATH" ]; then
        mv "$CURSOR_PATH" "${CURSOR_PATH}.bak"
        print_success "Mouse cursor hidden"
    else
        print_warning "Cursor file not found (may already be hidden)"
    fi
    echo ""
}

################################################################################
# Configure Chromium Browser
################################################################################

configure_chromium() {
    print_header "Configuring Chromium"
    
    KIOSK_HOME="/home/$KIOSK_USER"
    CHROMIUM_DIR="$KIOSK_HOME/.config/chromium/Default"
    
    print_step "Creating Chromium configuration..."
    mkdir -p "$CHROMIUM_DIR"
    
    cat > "$CHROMIUM_DIR/Preferences" <<EOF
{
   "browser": {
      "check_default_browser": false,
      "show_home_button": false
   },
   "session": {
      "restore_on_startup": 4,
      "startup_urls": [
         "file://$KIOSK_HOME/splashv/splash.png",
         "http://$SCORE_SERVER/kiosk/report_results.html"
      ]
   },
   "bookmark_bar": {
      "show_on_all_tabs": false
   },
   "homepage": "file://$KIOSK_HOME/splashv/splash.png",
   "homepage_is_newtabpage": false
}
EOF
    
    print_success "Chromium configured with startup URLs"
    echo "   Tab 1: Splash screen"
    echo "   Tab 2: http://$SCORE_SERVER/kiosk/report_results.html"
    echo ""
}

################################################################################
# Configure Auto-Login to Wayfire
################################################################################

configure_autologin() {
    print_header "Configuring Auto-Login"
    
    print_step "Setting up console auto-login..."
    
    # Create systemd override for auto-login
    mkdir -p /etc/systemd/system/getty@tty1.service.d
    
    cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $KIOSK_USER --noclear %I \$TERM
EOF
    
    print_step "Setting default boot to console..."
    systemctl set-default multi-user.target &>/dev/null || true
    
    print_step "Creating auto-start script..."
    KIOSK_HOME="/home/$KIOSK_USER"
    
    cat > "$KIOSK_HOME/.bash_profile" <<EOF
# Auto-start Wayfire on login to tty1
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec wayfire
fi
EOF
    
    print_success "Auto-login configured for $KIOSK_USER"
    echo ""
}

################################################################################
# Fix Ownership
################################################################################

fix_ownership() {
    print_header "Setting Permissions"
    
    print_step "Fixing file ownership..."
    chown -R "$KIOSK_USER:$KIOSK_USER" "/home/$KIOSK_USER"
    
    print_success "Permissions set"
    echo ""
}

################################################################################
# Reload System Services
################################################################################

reload_services() {
    print_header "Reloading System Services"
    
    print_step "Reloading systemd..."
    systemctl daemon-reload
    
    print_success "Services reloaded"
    echo ""
}

################################################################################
# Installation Complete
################################################################################

installation_complete() {
    print_header "Installation Complete!"
    
    cat <<EOF
${GREEN}╔═══════════════════════════════════════════════════════════════╗
║                  Kiosk Setup Successful!                      ║
╚═══════════════════════════════════════════════════════════════╝${NC}

${BLUE}Configuration Summary:${NC}
  • Hostname:       $EXPECTED_HOSTNAME
  • User:           $KIOSK_USER
  • Splash Screen:  /home/$KIOSK_USER/splashv/splash.png
  • Results URL:    http://$SCORE_SERVER/kiosk/report_results.html
  • Display:        Rotated $DISPLAY_ROTATION degrees (portrait)

${YELLOW}Important Reminders:${NC}
  1. Make sure AeroJudge Score server is running at $SCORE_SERVER
  2. Publish results to the 'kiosk' folder in Score software
  3. The kiosk will automatically refresh and scroll through results

${GREEN}What Happens Next:${NC}
  • After reboot, system will auto-login as $KIOSK_USER
  • Wayfire will start automatically
  • Chromium will launch in kiosk mode with two tabs
  • Display will rotate between splash screen and results every 30 seconds

${BLUE}Troubleshooting:${NC}
  • If results don't show: verify Score server is at $SCORE_SERVER
  • If display is wrong orientation: check HDMI cable orientation
  • To stop kiosk: SSH in and run 'killall chromium-browser'

EOF

    echo ""
    print_step "Rebooting in 5 seconds..."
    echo ""
    for i in 5 4 3 2 1; do
        echo -n "$i... "
        sleep 1
    done
    echo ""
    echo ""
    reboot
}

################################################################################
# Main Installation Process
################################################################################

main() {
    clear
    cat <<EOF
${BLUE}╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║           Score Results Kiosk - Simple Installer              ║
║                      Version 1.0.0                            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝${NC}

This installer will configure your Raspberry Pi as a kiosk display
for AeroJudge competition results.

${YELLOW}Prerequisites (from Pi Imager):${NC}
  ✓ Raspberry Pi OS Bookworm (Legacy, 32-bit)
  ✓ Hostname: $EXPECTED_HOSTNAME
  ✓ User: $KIOSK_USER with password
  ✓ WiFi: AeroJudgeNET configured
  ✓ SSH: Enabled

${GREEN}Starting installation in 3 seconds... (Ctrl+C to cancel)${NC}
EOF
    sleep 3
    
    check_root
    preflight_checks
    install_packages
    copy_files
    configure_wayfire
    hide_cursor
    configure_chromium
    configure_autologin
    fix_ownership
    reload_services
    installation_complete
}

# Run main installation
main "$@"

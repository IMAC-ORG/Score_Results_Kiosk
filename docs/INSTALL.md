# Installation Guide

This guide walks you through installing the kiosk software on your pre-configured Raspberry Pi.

---

## Prerequisites

Before starting this installation, you must have:

1. ✅ Completed the **[Pi Imager Setup](PI_IMAGER_SETUP.md)** 
2. ✅ Raspberry Pi booted and connected to AeroJudgeNET WiFi
3. ✅ SSH access to the Pi (or keyboard/monitor connected)
4. ✅ AeroJudge Score server available at 192.168.8.100

---

## Installation Methods

You can install using either SSH (recommended) or directly on the Pi.

### Method 1: SSH Installation (Recommended)

**From your computer:**

1. Download or clone this repository to your computer

2. Open Terminal (Mac/Linux) or Command Prompt (Windows)

3. SSH into your Raspberry Pi:
   ```bash
   ssh resultskiosk@aerojudge.local
   # Password: ScoreKiosk#2025
   ```

4. Transfer the repository to the Pi using one of these methods:

   **Option A: Using git (if available on Pi):**
   ```bash
   git clone https://github.com/yourusername/score_results_kiosk.git
   cd score_results_kiosk
   ```

   **Option B: Using scp from your computer:**
   ```bash
   # On your computer, from the repository directory:
   scp -r score_results_kiosk resultskiosk@aerojudge.local:~/
   
   # Then SSH in and navigate:
   ssh resultskiosk@aerojudge.local
   cd score_results_kiosk
   ```

   **Option C: Download directly on Pi:**
   ```bash
   # Download the repository zip
   wget https://github.com/yourusername/score_results_kiosk/archive/main.zip
   unzip main.zip
   cd score_results_kiosk-main
   ```

5. Run the installer:
   ```bash
   sudo ./install.sh
   ```

6. The installer will run automatically:
   - 3 second countdown before starting
   - All steps execute without prompts
   - Automatic reboot after 5 second countdown

7. After reboot, the kiosk will start automatically

---

### Method 2: Direct Installation (Keyboard & Monitor)

**On the Raspberry Pi:**

1. Open Terminal from the desktop

2. Download the repository:
   ```bash
   git clone https://github.com/yourusername/score_results_kiosk.git
   cd score_results_kiosk
   ```

3. Run the installer:
   ```bash
   sudo ./install.sh
   ```

4. The installer will run automatically with no prompts
   - Installation completes in 1-2 minutes
   - System will reboot automatically after 5 second countdown

5. After reboot, the kiosk will start automatically

---

## What the Installer Does

The `install.sh` script performs these steps automatically:

### 1. Pre-Flight Checks
- Verifies OS is Raspberry Pi OS Bookworm (Legacy, 32-bit)
- Confirms user `resultskiosk` exists
- Checks hostname is `aerojudge`
- Verifies network connectivity

### 2. Install Packages
- Updates package lists
- Installs `wtype` (for keyboard simulation)
- Installs `chromium-browser` or `chromium`

### 3. Copy Files
- Installs `switchtab.sh` to `/home/resultskiosk/`
- Copies splash screen to `/home/resultskiosk/splashv/`
- Sets proper permissions

### 4. Configure Wayfire
- Creates `/home/resultskiosk/.config/wayfire.ini`
- Sets display rotation to 270° (portrait mode)
- Configures auto-start for switchtab.sh
- Disables screensaver and power management

### 5. Hide Mouse Cursor
- Renames cursor file to hide pointer on screen

### 6. Configure Chromium
- Sets up two startup tabs:
  - Tab 1: Local splash screen
  - Tab 2: Score results at http://192.168.8.100/kiosk/report_results.html
- Disables browser prompts and toolbars

### 7. Configure Auto-Login
- Sets up automatic console login as `resultskiosk`
- Configures Wayfire to start automatically on login
- Sets boot target to console mode

### 8. Finalize
- Fixes file ownership and permissions
- Reloads systemd services
- Prompts for reboot

---

## Installation Output

The installer runs completely automatically with no user input required.

It provides color-coded feedback:

- 🔵 **Blue Headers**: Section titles
- ✅ **Green Checkmarks**: Successful steps
- ⚠️ **Yellow Warnings**: Non-critical issues
- ❌ **Red X's**: Errors (installation will stop)

### Example Output:

```
═══════════════════════════════════════════════════════
  Pre-Flight Checks
═══════════════════════════════════════════════════════

▶ Checking OS version...
   OS: Raspberry Pi OS (Legacy, 32-bit)
✔ SUCCESS: OS version check passed

▶ Checking for user 'resultskiosk'...
✔ SUCCESS: User 'resultskiosk' found

▶ Checking hostname...
✔ SUCCESS: Hostname is correct: aerojudge

▶ Checking network connectivity...
✔ SUCCESS: Network connection OK
```

---

## After Installation

### First Boot After Reboot

1. The Pi will boot to console
2. Auto-login as `resultskiosk` will occur
3. Wayfire window manager will start
4. Chromium will launch in kiosk mode
5. Display will show splash screen first
6. After 30 seconds, it will switch to results

### Expected Behavior

- **Tab Rotation**: Switches between splash and results every 30 seconds
- **Auto-Refresh**: Results page refreshes automatically
- **Auto-Scroll**: Results page scrolls down automatically
- **Seamless Loop**: Continues indefinitely

---

## Verification

### Check if Kiosk is Running

**From SSH:**
```bash
ssh resultskiosk@aerojudge.local

# Check if Chromium is running:
ps aux | grep chromium

# Check if switchtab script is running:
ps aux | grep switchtab
```

### Check Wayfire Configuration

```bash
cat ~/.config/wayfire.ini
```

Should show `switchtab=bash /home/resultskiosk/switchtab.sh` in the autostart section.

### Check Chromium Configuration

```bash
cat ~/.config/chromium/Default/Preferences | grep startup_urls
```

Should show both the splash screen and results URLs.

---

## Troubleshooting

### Installation Fails: "User 'resultskiosk' does not exist"

**Problem**: Pi was not configured properly in Pi Imager

**Solution**: 
1. Re-flash SD card using Pi Imager
2. Follow [PI_IMAGER_SETUP.md](PI_IMAGER_SETUP.md) carefully
3. Make sure username is exactly `resultskiosk`

---

### Installation Fails: "Wrong OS version"

**Problem**: Not using Raspberry Pi OS Bookworm Legacy 32-bit

**Solution**:
1. Re-flash SD card
2. Select "Raspberry Pi OS (Legacy, 32-bit)" in Pi Imager
3. Do NOT use 64-bit or newer versions

---

### Kiosk Doesn't Show Results

**Problem**: Score server not accessible or not publishing to kiosk folder

**Check**:
1. Is Score server running?
2. Can you access `http://192.168.8.100/kiosk/report_results.html` from a browser?
3. Have you published results to the `kiosk` folder in Score?

**Solution**:
- In Score software, go to Results Report Options
- Check box to publish to additional location
- Set path to: `reports\kiosk`
- Publish results

---

### Display is Rotated Wrong

**Problem**: HDMI cable orientation or rotation setting

**Solutions**:
1. Try rotating the physical display
2. Edit rotation in Wayfire config:
   ```bash
   nano ~/.config/wayfire.ini
   ```
3. Change `transform=270` to:
   - `0` = normal
   - `90` = rotate right
   - `180` = upside down
   - `270` = rotate left (portrait)
4. Reboot

---

### Kiosk Stopped Working

**Quick Fix**:
```bash
# SSH into the Pi
ssh resultskiosk@aerojudge.local

# Restart the kiosk
sudo reboot
```

**If That Doesn't Work**:
```bash
# Kill Chromium
killall chromium-browser

# Restart Wayfire
wayfire &
```

---

### Want to Stop the Kiosk Temporarily

**From SSH**:
```bash
# Stop Chromium
killall chromium-browser

# Stop switchtab script
killall switchtab.sh
```

**To Start Again**:
```bash
sudo reboot
```

---

### Reset to Clean State

**Remove Kiosk Configuration**:
```bash
# Restore cursor
sudo mv /usr/share/icons/PiXflat/cursors/left_ptr.bak /usr/share/icons/PiXflat/cursors/left_ptr

# Remove configurations
rm -rf ~/.config/wayfire.ini
rm -rf ~/.config/chromium
rm ~/switchtab.sh

# Disable auto-login
sudo rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo systemctl daemon-reload

# Reboot
sudo reboot
```

---

## Customization

### Change Score Server IP

Edit the Chromium preferences:
```bash
nano ~/.config/chromium/Default/Preferences
```

Find and update the URL:
```json
"http://192.168.8.100/kiosk/report_results.html"
```

### Change Rotation Timing

Edit the switchtab script:
```bash
nano ~/switchtab.sh
```

Find the `sleep` commands and adjust values (in seconds):
- `sleep 30` = 30 seconds on results page
- `sleep 3` = 3 seconds on splash screen

### Use Different Splash Image

Replace the splash image:
```bash
# Via SCP from your computer:
scp your_image.png resultskiosk@aerojudge.local:~/splashv/splash.png

# Or on the Pi:
cp /path/to/your_image.png ~/splashv/splash.png
```

---

## Uninstall

To completely remove the kiosk setup:

```bash
# Run the reset commands from "Reset to Clean State" section above
# Then optionally re-flash the SD card with a fresh OS
```

---

## Support

For issues or questions:
- Check the [README.md](../README.md)
- Review the [CHANGELOG.md](../CHANGELOG.md)
- File an issue on GitHub

---

## Next Steps

Once installation is complete and verified:
1. Position your display at the event venue
2. Ensure Score server is running and publishing to kiosk folder
3. Power on the kiosk Pi - it will auto-start
4. Results will display automatically as they're published

# AeroJudge Score Results Kiosk

A turnkey Raspberry Pi kiosk system for displaying live AeroJudge competition results at events. Automatically rotates between a splash screen and live results from your local Score server no internet connection required.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%204-red.svg)
![OS](https://img.shields.io/badge/OS-Bookworm%2032--bit-green.svg)

---

## What It Does

This project transforms a Raspberry Pi into a dedicated results display that:
- Connects to your local AeroJudge Score server over WiFi
- Displays competition results in portrait mode on any HDMI display
- Automatically rotates between a branded splash screen and live results
- Auto-refreshes and scrolls through results as they're published
- Requires zero maintenance once set up

Perfect for displaying results at aerobatic competitions without needing internet connectivity or constant manual updates.

---

## Quick Start

### Two Simple Steps

#### Step 1: Configure Your Pi (5 minutes)
Use Raspberry Pi Imager to flash and pre-configure your SD card:
- Flash: Raspberry Pi OS (Legacy, 32-bit)
- Set hostname: `aerojudge`
- Set username: `resultskiosk` with password: `ScoreKiosk#2025`
- Configure WiFi: `AeroJudgeNET` with password: `2Pr1v@TE`
- Enable SSH

**[ Detailed Pi Imager Setup Guide ](docs/PI_IMAGER_SETUP.md)**

#### Step 2: Install Kiosk Software (2 minutes)
Boot your Pi, SSH in, and run the installer:

```bash
ssh resultskiosk@aerojudge.local
git clone https://github.com/IMAC-ORG/score_results_kiosk.git
cd score_results_kiosk
chmod +x install.sh
./install.sh
```

The installer runs automatically with no prompts. After automatic reboot, your kiosk is live!

**[ Detailed Installation Guide ](docs/INSTALL.md)**

---

## Features

### Automated Operation
- Automatic startup on boot
- Auto-login and launch
- Self-refreshing results display
- Continuous rotation between splash and results
- Zero manual intervention required

### Display Features
- Portrait mode (270 rotation)
- Custom IMAC splash screen
- Live results from Score server
- 30-second rotation cycle
- Automatic page scrolling

### Network Setup
- Local WiFi only (AeroJudgeNET)
- No internet required
- Reads from Score server at 192.168.8.100
- No web publishing needed

### Technical
- Raspberry Pi 4 optimized
- Raspberry Pi OS Bookworm (32-bit Legacy)
- Wayfire window manager
- Chromium browser in kiosk mode
- Keyboard automation via wtype

---

## Requirements

### Hardware
- Raspberry Pi 4 (2GB or more recommended)
- 8GB+ microSD card
- HDMI display (any size)
- Power supply for Pi
- WiFi network (AeroJudge system)

### Software (Installed Automatically)
- Raspberry Pi OS Bookworm (Legacy, 32-bit)
- Chromium browser
- Wayfire window manager
- wtype keyboard automation tool

### Score Server
- AeroJudge Score software running at 192.168.8.100
- Results published to `reports\kiosk` folder
- Score web server feature enabled

---

## Documentation

- **[Pi Imager Setup Guide](docs/PI_IMAGER_SETUP.md)** - Step-by-step SD card configuration
- **[Installation Guide](docs/INSTALL.md)** - Software installation and troubleshooting

---

## How It Works

### System Architecture

```
 
 AeroJudge Score Server (192.168.8.100) 
 Publishing to: /reports/kiosk/ 
 WiFi: AeroJudgeNET
 
 Raspberry Pi 4 Kiosk 
 Auto-login as resultskiosk 
 Wayfire window manager 
 Chromium with 2 tabs: 
 - Tab 1: Splash screen 
 - Tab 2: Results URL 
 switchtab.sh script: 
 - Cycles tabs every 30 seconds 
 - Refreshes and scrolls results 
 
 HDMI Output - Display in Portrait Mode 
 Showing: Splash Results (repeating) 
 
```

### Tab Rotation Cycle

1. **Splash Screen** (3 seconds)
 - Displays IMAC logo and branding

2. **Results Display** (30 seconds)
 - Switches to results tab
 - Jumps to top of page
 - Force refreshes (Ctrl+F5)
 - Shows results for 30 seconds

3. **Results Scroll** (30 seconds)
 - Scrolls down one page
 - Shows more results for 30 seconds

4. **Return to Splash** (repeat)
 - Cycles back to splash screen
 - Loop continues indefinitely

---

## Troubleshooting

### Kiosk Not Starting
1. Check if Pi is booting (power LED)
2. Check HDMI cable connection
3. Wait 2-3 minutes for first boot
4. SSH in and check logs

### Results Not Showing
1. Verify Score server is running
2. Check Score is publishing to `kiosk` folder
3. Test URL in browser: http://192.168.8.100/kiosk/report_results.html
4. Verify WiFi connection

### Display Rotated Wrong
1. Check physical display orientation
2. Edit Wayfire config rotation setting
3. Reboot after changes

### Need to Stop Kiosk
```bash
ssh resultskiosk@aerojudge.local
killall chromium-browser
```

## Project Structure

```
score_results_kiosk/
 README.md # This file
 LICENSE # MIT License
 CHANGELOG.md # Version history
 install.sh # Automated installer
 bin/
 switchtab.sh # Tab rotation script
 assets/
 splash/
 pisplash_v.png # Vertical splash (default)
 pisplash_h.png # Horizontal splash
 docs/
 PI_IMAGER_SETUP.md # Pi Imager configuration guide
 INSTALL.md # Installation guide
```

---

## Technical Details

### Display Configuration
- **Resolution**: 1920x1080 @ 60Hz
- **Orientation**: Portrait (270 rotation)
- **Output**: HDMI-A-1 or HDMI-A-2

### Browser Configuration
- **Browser**: Chromium (kiosk mode)
- **Tabs**: 2 (splash + results)
- **Features Disabled**: Toolbars, bookmarks, prompts
- **Startup**: Automatic with predefined URLs

### User Configuration
- **Username**: resultskiosk
- **Auto-login**: Enabled on tty1
- **Shell**: bash with Wayfire auto-start
- **Groups**: video, input, sudo

---

## Support

### Getting Help
- Review the [Installation Guide](docs/INSTALL.md)
- Search existing GitHub issues
- Create a new issue with details

### Reporting Issues
When reporting problems, please include:
- Raspberry Pi model
- OS version (from `cat /etc/os-release`)
- Error messages or symptoms
- Steps to reproduce

---

## Credits

**Created by:** David Garceau 
**For:** AeroJudge Score System integration

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Version

**Current Version:** 1.0.0 
**Release Date:** November 2025 
**Status:** Production Ready

---

**Ready to get started? Follow the [Quick Start](#quick-start) guide above!** 

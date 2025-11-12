# Raspberry Pi Imager Setup Guide

This guide walks you through configuring your Raspberry Pi SD card using Raspberry Pi Imager. Following these exact settings ensures the kiosk installer will work correctly.

---

## Prerequisites

- Raspberry Pi 4 (2GB or more recommended)
- 8GB+ microSD card
- Computer with SD card reader
- Raspberry Pi Imager installed ([Download here](https://www.raspberrypi.com/software/))

---

## Step-by-Step Configuration

### Step 1: Launch Raspberry Pi Imager

1. Open **Raspberry Pi Imager** on your computer
2. You should see the main screen with three buttons:
   - Raspberry Pi Device
   - Operating System
   - Storage

[SCREENSHOT PLACEHOLDER: Main Pi Imager window]

---

### Step 2: Select Raspberry Pi Device

1. Click **"Raspberry Pi Device"**
2. Select **"RASPBERRY PI 4"** from the list
3. Click to confirm

[SCREENSHOT PLACEHOLDER: Device selection showing Pi 4 selected]

---

### Step 3: Select Operating System

1. Click **"Operating System"**
2. Select **"Raspberry Pi OS (Legacy, 32-bit)"**
   - This is also labeled as "Raspberry Pi OS (Legacy) - A port of Debian Bookworm with security updates..."
   - **CRITICAL:** Must be the **32-bit Legacy version** (Bookworm)
   - **DO NOT** use Raspberry Pi OS (64-bit)
   - **DO NOT** use Raspberry Pi OS (other)

[SCREENSHOT PLACEHOLDER: OS selection showing "Raspberry Pi OS (Legacy, 32-bit)" highlighted]

**Important:** The 32-bit Legacy version uses Wayfire window manager which is required for this kiosk setup.

---

### Step 4: Select Storage

1. Click **"Storage"**
2. Insert your microSD card if you haven't already
3. Select your SD card from the list
4. **WARNING:** This will erase all data on the selected storage device

[SCREENSHOT PLACEHOLDER: Storage selection showing SD card]

---

### Step 5: Open OS Customization Settings

1. Click **"NEXT"**
2. A dialog will appear asking "Would you like to apply OS customization settings?"
3. Click **"EDIT SETTINGS"**

[SCREENSHOT PLACEHOLDER: Dialog asking about OS customization]

---

### Step 6: Configure General Settings

You should now see the "OS Customisation" window with multiple tabs.

#### General Tab Settings:

**Hostname:**
- ☑ **Check** "Set hostname"
- Enter: `aerojudge`

**Username and Password:**
- ☑ **Check** "Set username and password"
- Username: `resultskiosk`
- Password: `ScoreKiosk#2025`

**Wireless LAN:**
- ☑ **Check** "Configure wireless LAN"
- SSID: `AeroJudgeNET`
- Password: `2Pr1v@TE`
- Wireless LAN country: `US` (or your country code)

**Locale Settings:**
- ☑ **Check** "Set locale settings"
- Time zone: `America/New_York` (or your timezone)
- Keyboard layout: `us` (or your layout)

[SCREENSHOT PLACEHOLDER: General tab filled out with all settings above]

---

### Step 7: Configure Services Settings

Click the **"SERVICES"** tab at the top.

**SSH:**
- ☑ **Check** "Enable SSH"
- Select: **"Use password authentication"**

This allows you to connect remotely to install the kiosk software.

[SCREENSHOT PLACEHOLDER: Services tab with SSH enabled]

---

### Step 8: Options Tab (Optional)

Click the **"OPTIONS"** tab at the top.

**Recommended Settings:**
- ☑ Check "Eject media when finished"
- ☑ Check "Enable telemetry" (optional, your choice)

Leave other settings at default.

[SCREENSHOT PLACEHOLDER: Options tab]

---

### Step 9: Save and Write

1. Click **"SAVE"** to save your customization settings
2. Click **"YES"** to apply OS customisation settings
3. Confirm you want to erase the SD card by clicking **"YES"**
4. Wait for the image to write (this takes 5-10 minutes)
5. Wait for verification to complete

[SCREENSHOT PLACEHOLDER: Writing progress screen]

---

### Step 10: First Boot

1. Remove the SD card from your computer
2. Insert it into your Raspberry Pi 4
3. Connect HDMI cable to your display
4. Connect power to the Pi
5. Wait for first boot (this takes 2-3 minutes as it applies settings)

**The Pi will:**
- Boot to desktop
- Connect to AeroJudgeNET WiFi automatically
- Be ready for SSH connection as user `resultskiosk`

---

## Verification

After the Pi boots, verify your settings:

### On the Raspberry Pi screen:
- You should see the desktop
- The hostname should show as `aerojudge` 

### From your computer (Optional):
SSH into the Pi to verify configuration:

```bash
ssh resultskiosk@aerojudge.local
# Password: ScoreKiosk#2025
```

If SSH connects successfully, your Pi is ready for kiosk installation!

---

## Configuration Summary

Here's what you configured:

| Setting | Value |
|---------|-------|
| **OS Version** | Raspberry Pi OS (Legacy, 32-bit) Bookworm |
| **Hostname** | aerojudge |
| **Username** | resultskiosk |
| **Password** | ScoreKiosk#2025 |
| **WiFi SSID** | AeroJudgeNET |
| **WiFi Password** | 2Pr1v@TE |
| **SSH** | Enabled with password |

---

## Troubleshooting

**Can't find "Raspberry Pi OS (Legacy, 32-bit)"?**
- Make sure you have the latest version of Raspberry Pi Imager
- Look for the version that says "Bookworm" and "32-bit"
- It may be under "Raspberry Pi OS (other)" → "Raspberry Pi OS (Legacy, 32-bit)"

**Pi won't connect to WiFi?**
- Double-check SSID and password are exact (case-sensitive)
- Make sure your AeroJudge WiFi network is active
- Try connecting manually from the Pi desktop first

**Can't SSH to the Pi?**
- Wait a full 3 minutes after first boot
- Try `ssh resultskiosk@192.168.8.XXX` if .local doesn't work
- Check your router to find the Pi's IP address
- Make sure you're on the same network as the Pi

---

## Next Steps

Once your Pi is configured and booted, proceed to the **Installation Guide** to install the kiosk software.

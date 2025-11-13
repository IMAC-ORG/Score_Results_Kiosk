#!/bin/bash

# Find Chromium browser process ID
chromium_pid=$(pgrep chromium | head -1)

# Check if Chromium is running
while [[ -z $chromium_pid ]]; do
  echo "Chromium browser is not running yet."
  sleep 10
  chromium_pid=$(pgrep chromium | head -1)
done

echo "Chromium browser process ID: $chromium_pid"

export XDG_RUNTIME_DIR=/run/user/1000

# Initial pause to avoid loop timing errors
sleep 30

# Loop to send keyboard events
while true; do

# Switch to Local Server Results
    # Send Ctrl+Tab using `wtype` command
    wtype -M ctrl -P Tab
    # Send Ctrl+Tab using `wtype` command
    wtype -m ctrl -p Tab

  #Refresh to beginning of results Page
    # Home using `wtype` command
    wtype -P Home
    # Home using `wtype` command
    wtype -p Home

 #refresh Page
    # Send Ctrl+F5 using `wtype` command
    wtype -M ctrl -P F5
    # Send Ctrl+F5 using `wtype` command
    wtype -m ctrl -p F5

  sleep 30

  # Scroll Page Down
    # Send PgDN using `wtype` command
    wtype -P Next
    # Send PgDN using `wtype` command
    wtype -p Next

  sleep 30

# Switch to Splash
  # Send Ctrl+Tab using `wtype` command
  wtype -M ctrl -P Tab
  # Send Ctrl+Tab using `wtype` command
  wtype -m ctrl -p Tab

  sleep 3

done

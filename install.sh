#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Copy the main script to /usr/local/bin
cp refind.sh /usr/local/bin/refind

# Make it executable
chmod +x /usr/local/bin/refind

echo "refind installed successfully in /usr/local/bin"

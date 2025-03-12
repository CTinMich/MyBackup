#!/bin/bash

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo ./install.sh)"
    exit 1
fi

echo "Updating package lists..."
sudo apt update

echo "Installing required packages..."
sudo apt install -y git rsync tar docker.io ssh cron

echo "Installation complete!"

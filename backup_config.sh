#!/bin/bash

# Backup locations for OS files
OS_BACKUP_PATHS=(
    "/home/pi"
    "/etc"
    "/var/lib/docker"
    "/var/lib/snapd"
)
OS_BACKUP_DEST_IP="10.0.0.52"
OS_BACKUP_DEST_PATH="/home/pi/usbhdd-02/Backups/"
BACKUP_DIR="/home/pi/usbhdd-02/Backups"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
OS_BACKUP_FILE="$BACKUP_DIR/os_backup_$TIMESTAMP.tar.gz"

# Docker containers and destinations
declare -A DOCKER_APPS=(
    ["Plex"]="10.0.0.52:/home/pi/docker/plex"
    ["Jellyfin"]="10.0.0.51:/home/pi/docker/jellyfin"
    ["Audiobookshelf"]="10.0.0.51:/home/pi/docker/audiobookshelf"
    ["Calibre"]="10.0.0.51:/home/pi/docker/calibre"
)

# Storage paths
declare -A STORAGE_DIRS=(
    ["10.0.0.52"]="/home/pi/usbhdd-01/4T_01:/home/pi/usbhdd-01/"
    ["10.0.0.52"]="/home/pi/usbhdd-02/Backups:/home/pi/usbhdd-04/"
)


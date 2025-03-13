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

# Exclude specific folders from OS backup
OS_BACKUP_EXCLUDES=(
    "/home/pi/usbhdd-01"
    "/home/pi/usbhdd-02"
    "/home/pi/usbhdd-03"
)

# Docker containers and destinations
DOCKER_APPS=(
    "10.0.0.52:/home/pi/docker/Plex:Plex"
    "10.0.0.52:/home/pi/docker/Jellyfin:Jellyfin"
    "10.0.0.52:/home/pi/docker/Audiobookshelf:Audiobookshelf"
    "10.0.0.52:/home/pi/docker/Calibre:Calibre"
)

# Storage paths
STORAGE_DIRS=(
    "10.0.0.52:/home/pi/usbhdd-01/4T_01:/home/pi/usbhdd-01/"
    "10.0.0.52:/home/pi/usbhdd-01/4T_02:/home/pi/usbhdd-01/"
    "10.0.0.52:/home/pi/usbhdd-01/4T_03:/home/pi/usbhdd-02/"
    "10.0.0.52:/home/pi/usbhdd-01/4T_04:/home/pi/usbhdd-02/"
    "10.0.0.52:/home/pi/usbhdd-01/4T_05:/home/pi/usbhdd-02/"
    "10.0.0.52:/home/pi/usbhdd-01/4T_06:/home/pi/usbhdd-02/"
    "10.0.0.52:/home/pi/usbhdd-02/Backups:/home/pi/usbhdd-04/"
    "10.0.0.52:/home/pi/usbhdd-02/Temp:/home/pi/usbhdd-04/"
)

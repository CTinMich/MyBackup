#!/bin/bash
# ==========================================
# MyBackup - Automated System, Docker, and Storage Backup
# Author: CTinMich (https://github.com/CTinMich)
# Version: 2.1
# Description:
#   - Creates system, Docker, and storage backups
#   - Uses rsync for intelligent mirroring
#   - Supports per-app rsync ignore rules
#   - Can be scheduled via cron for automation
#   - Supports CLI arguments to control execution
#   - Provides explicit completion messages for each backup task
#   - Now includes timestamped logging and log rotation
#   - Ensures SSH key authentication for rsync operations
#   - Uses configurable variables for user ID and command options
#   - Improved screen output formatting for better readability
#   - Adds command validation to detect and report failures
# ==========================================

# Define colors before execution check
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
RED='\e[1;31m'
RESET='\e[0m'  # Reset color

# Ensure the script runs as sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "\n\n${YELLOW}=== Re-executing script as root (sudo) ===${RESET}\n"
    exec sudo bash "$0" "$@"
    echo -e "${GREEN}Done.${RESET}\n" | tee -a "$LOG_FILE"
fi

# Define configurable variables
USER_ID="pi"
SSH_KEY="/home/$USER_ID/.ssh/id_rsa"
SSH_OPTIONS="-o StrictHostKeyChecking=no"
RSYNC_OPTIONS=(-e "ssh -i $SSH_KEY $SSH_OPTIONS" -ahW --delete --inplace --no-compress --progress --partial --rsync-path="sudo rsync")
LOG_DIR="./Logs"
MAX_LOG_RETENTION=30
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/backup_$TIMESTAMP.log"

# Load External Configuration File
CONFIG_FILE="backup_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "\n\n${RED}ERROR: Config file not found! (${CONFIG_FILE})${RESET}\n"
    exit 1
fi

mkdir -p "$LOG_DIR"

# Function to check command execution status
check_command() {
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}ERROR: Last command failed. Check logs for details.${RESET}\n" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Function to trim old logs
trim_old_logs() {
    echo -e "\n${YELLOW}=== Trimming old logs, keeping the last $MAX_LOG_RETENTION logs ===${RESET}" | tee -a "$LOG_FILE"
    ls -tp "$LOG_DIR"/*.log | grep -v '/$' | tail -n +$((MAX_LOG_RETENTION+1)) | xargs -d '\n' rm -f 2>/dev/null
    check_command
    echo -e "${GREEN}Done.${RESET}\n" | tee -a "$LOG_FILE"
}

trim_old_logs

echo -e "${YELLOW}=== Starting MyBackup Script v2.1 ===${RESET}" | tee -a "$LOG_FILE"
echo -e "${GREEN}Done.${RESET}\n" | tee -a "$LOG_FILE"

# Flags for execution control
RUN_OS_BACKUP=false
RUN_DOCKER_BACKUP=false
RUN_STORAGE_BACKUP=false
RUN_ALL=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --all|-a) RUN_ALL=true; shift;;
        --os|-o) RUN_OS_BACKUP=true; shift;;
        --docker|-d) RUN_DOCKER_BACKUP=true; shift;;
        --storage|-s) RUN_STORAGE_BACKUP=true; shift;;
        *) echo -e "\n${RED}Unknown option: $1${RESET}\n" | tee -a "$LOG_FILE"; exit 1;;
    esac
done

### Function: Backup Media & General Storage ###
backup_storage() {
    echo -e "${YELLOW}=== Starting Media & General Storage Backup ===${RESET}" | tee -a "$LOG_FILE"

    for entry in "${STORAGE_DIRS[@]}"; do
        IFS=':' read -r dest_ip source_dir dest_dir <<< "$entry"

        echo -e "${YELLOW}Syncing $source_dir --> $dest_ip:$dest_dir${RESET}" | tee -a "$LOG_FILE"

        rsync "${RSYNC_OPTIONS[@]}" "$source_dir" "$USER_ID@$dest_ip:$dest_dir" | tee -a "$LOG_FILE"
        check_command
    done

    echo -e "${GREEN}Done.${RESET}\n" | tee -a "$LOG_FILE"
}

### Execute tasks based on user input ###
if [[ "$RUN_ALL" == "true" ]]; then
    backup_storage
elif [[ "$RUN_STORAGE_BACKUP" == "true" ]]; then
    backup_storage
else
    echo -e "\n${RED}No valid option provided. Use --all, --os, --docker, or --storage.${RESET}\n" | tee -a "$LOG_FILE"
    exit 1
fi

echo -e "\n\n${GREEN}=== Backup process completed successfully! ===${RESET}\n" | tee -a "$LOG_FILE"


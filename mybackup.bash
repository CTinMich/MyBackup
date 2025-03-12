#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "\n\n\e[1;33m=== Re-executing script as root (sudo) ===\e[0m\n\n"
    exec sudo bash "$0" "$@"
fi

# Define colors for better visibility
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
RED='\e[1;31m'
RESET='\e[0m'  # Reset color

# Load External Configuration File
CONFIG_FILE="/path/to/backup_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "\n\n${RED}ERROR: Config file not found! (${CONFIG_FILE})${RESET}\n\n"
    exit 1
fi

echo -e "\n\n${YELLOW}=== Starting system maintenance and backup process ===${RESET}\n\n"

### Function: Perform system cleanup ###
system_cleanup() {
    echo -e "\n\n${YELLOW}=== System Cleanup: Updating and Cleaning Package Manager ===${RESET}\n\n"
    apt-get update && apt-get dist-upgrade -y
    apt autoremove -y
    snap refresh
    apt autoclean -y && apt clean -y

    echo -e "\n\n${YELLOW}=== System Cleanup: Removing Logs and Temporary Files ===${RESET}\n\n"
    journalctl --vacuum-time=7d
    rm -rf /tmp/* /var/tmp/*
    rm -rf ~/.cache/*
}

### Function: Perform Docker cleanup ###
docker_cleanup() {
    echo -e "\n\n${YELLOW}=== Docker Cleanup: Removing Unused Resources ===${RESET}\n\n"
    docker image prune -af
    docker volume prune -f
    docker network prune -f
}

### Function: Backup OS Important Files ###
backup_os_files() {
    echo -e "\n\n${YELLOW}=== Creating OS Backup Archive (as root) ===${RESET}\n\n"

    mkdir -p "$BACKUP_DIR"
    chown pi:pi "$BACKUP_DIR"

    tar -czvf "$OS_BACKUP_FILE" --preserve-permissions --numeric-owner "${OS_BACKUP_PATHS[@]}"

    echo -e "\n\n${GREEN}OS backup created: $OS_BACKUP_FILE${RESET}\n\n"

    echo -e "\n\n${GREEN}Syncing OS backup to $OS_BACKUP_DEST_IP...${RESET}\n\n"
    rsync -avhW --progress --delete --inplace --info=progress2 --no-compress "$OS_BACKUP_FILE" "$OS_BACKUP_DEST_IP:$OS_BACKUP_DEST_PATH"
}

### Function: Sync Docker Applications with Intelligent Restart ###
sync_docker_apps() {
    echo -e "\n\n${YELLOW}=== Starting Intelligent Docker App Sync ===${RESET}\n\n"

    for app_name in "${!DOCKER_APPS[@]}"; do
        IFS=':' read -r dest_host dest_folder <<< "${DOCKER_APPS[$app_name]}"
        
        IGNORE_FILE="/path/to/rsync_ignore_rules/${app_name}_ignore.txt"
        RSYNC_OPTIONS=""

        if [[ -f "$IGNORE_FILE" ]]; then
            RSYNC_OPTIONS="--exclude-from=$IGNORE_FILE"
        fi

        echo -e "\n\n${GREEN}Checking $app_name on $dest_host...${RESET}\n\n"

        container_exists=$(ssh pi@$dest_host "docker ps -a --format '{{.Names}}' | grep -w $app_name || echo 'not_found'")

        if [[ "$container_exists" == "not_found" ]]; then
            echo -e "\n\n${RED}Container $app_name does not exist on $dest_host. Skipping sync.${RESET}\n\n"
            continue
        fi

        container_running=$(ssh pi@$dest_host "docker inspect -f '{{.State.Running}}' $app_name 2>/dev/null" || echo "false")

        if [[ "$container_running" == "true" ]]; then
            echo -e "\n\n${YELLOW}Stopping running container: $app_name on $dest_host...${RESET}\n\n"
            ssh pi@$dest_host "docker stop $app_name"
            was_running="true"
        else
            was_running="false"
        fi

        echo -e "\n\n${GREEN}Syncing $app_name from /home/pi/docker/${app_name,,} to $dest_host:$dest_folder${RESET}\n\n"
        rsync -avAX --delete --numeric-ids $RSYNC_OPTIONS "/home/pi/docker/${app_name,,}" "pi@$dest_host:$dest_folder/"

        if [[ "$was_running" == "true" ]]; then
            echo -e "\n\n${GREEN}Restarting container: $app_name on $dest_host...${RESET}\n\n"
            ssh pi@$dest_host "docker start $app_name"
        fi
    done
}

### Function: Backup Media & General Storage ###
backup_storage() {
    echo -e "\n\n${YELLOW}=== Starting Media & General Storage Backup ===${RESET}\n\n"

    for dest_ip in "${!STORAGE_DIRS[@]}"; do
        IFS=':' read -r source_dir dest_dir <<< "${STORAGE_DIRS[$dest_ip]}"

        echo -e "\n\n${GREEN}Syncing $source_dir --> $dest_ip:$dest_dir${RESET}\n\n"
        rsync -avhW --progress --delete --inplace --info=progress2 --no-compress "$source_dir" "$dest_ip:$dest_dir"
    done
}

### Run all tasks ###
system_cleanup
docker_cleanup
backup_os_files
sync_docker_apps
backup_storage

echo -e "\n\n${GREEN}=== Cleanup and backup process completed successfully! 🎉 ===${RESET}\n\n"


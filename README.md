# MyBackup
### Automated Backup & Docker Sync Script for Raspberry Pi
[![GitHub license](https://img.shields.io/github/license/CTinMich/MyBackup)](https://github.com/CTinMich/MyBackup/blob/main/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/CTinMich/MyBackup)](https://github.com/CTinMich/MyBackup)

## 📌 Features
- 📂 **Backs up system files** (`/home/pi`, `/etc`, `Docker configs`)
- 🚀 **Syncs Docker containers** between multiple hosts
- 🔄 **Stops & Restarts containers** before syncing
- 🛑 **Supports ignore rules** (e.g., Plex `Preferences.xml`)
- 🕒 **Automate via Cron** for scheduled backups

---

## 📖 Installation
Clone the repository:
```bash
git clone https://github.com/CTinMich/MyBackup.git
cd MyBackup
chmod +x mybackup.bash
```
Install required dependencies:
```bash
sudo ./install.sh
```

---

## 🛠️ Usage
Run the script manually:
```bash
./mybackup.bash
```
Schedule it in **cron** for automated backups:
```bash
crontab -e
```
Add the following line (runs every **Sunday at 2 AM**):
```bash
0 2 * * 0 /home/pi/MyBackup/mybackup.bash >> /var/log/mybackup.log 2>&1
```

---

## ⚙️ Configuration
Modify **`backup_config.sh`** to adjust backup locations and settings.

Example **`backup_config.sh`**:
```bash
#!/bin/bash

# OS Backup Locations
OS_BACKUP_PATHS=(
    "/home/pi"
    "/etc"
    "/var/lib/docker"
    "/var/lib/snapd"
)
OS_BACKUP_DEST_IP="10.0.0.52"
OS_BACKUP_DEST_PATH="/home/pi/usbhdd-02/Backups/"

# Docker Containers & Destinations
declare -A DOCKER_APPS=(
    ["Plex"]="10.0.0.52:/home/pi/docker/plex"
    ["Jellyfin"]="10.0.0.51:/home/pi/docker/jellyfin"
    ["Audiobookshelf"]="10.0.0.51:/home/pi/docker/audiobookshelf"
    ["Calibre"]="10.0.0.51:/home/pi/docker/calibre"
)

# Storage Backup Paths
declare -A STORAGE_DIRS=(
    ["10.0.0.52"]="/home/pi/usbhdd-01/4T_01:/home/pi/usbhdd-01/"
    ["10.0.0.52"]="/home/pi/usbhdd-02/Backups:/home/pi/usbhdd-04/"
)
```
💡 **If you modify `backup_config.sh`, no need to update `mybackup.bash`!**

---

## 🚀 Rsync Ignore Rules
By default, all files sync **except** those explicitly excluded.

Example **`rsync_ignore_rules/Plex_ignore.txt`**:
```
Preferences.xml
```
💡 **This ensures Plex maintains a unique server identity while syncing everything else.**

---

## 📜 License
This project is licensed under the **MIT License** - See the [LICENSE](LICENSE) file for details.


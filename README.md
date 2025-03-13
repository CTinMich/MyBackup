# MyBackup
### Automated Backup & Docker Sync Script for My Raspberry Pi and Linux MiniPC
[![GitHub license](https://img.shields.io/github/license/CTinMich/MyBackup)](https://github.com/CTinMich/MyBackup/blob/main/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/CTinMich/MyBackup)](https://github.com/CTinMich/MyBackup/blob/main/)

## 📌 Features
- 📂 **Backs up system files** (`/home/pi`, `/etc`, `Docker configs`)
- 🚀 **Syncs Docker containers** between multiple hosts
- 🔄 **Stops & Restarts containers** before syncing
- 🛑 **Supports ignore rules** (e.g., Plex `Preferences.xml`)
- ⚡ **Uses SSH key authentication** for secure connections
- 🏗 **Preserves permissions, owners, and groups** on synced files
- 🔧 **Handles permission issues** by using `sudo rsync` on the remote host
- 🕒 **Automate via Cron** for scheduled backups

## 📖 Installation
Clone the repository:
```bash
git clone https://github.com/CTinMich/MyBackup.git
cd MyBackup
chmod +x mybackup.bash
```

## 🛠 Usage
Run the script with one of the following options:
```bash
./mybackup.bash --all       # Run all backup routines
./mybackup.bash --os        # Backup OS configuration files
./mybackup.bash --docker    # Cleanup & sync Docker containers
./mybackup.bash --storage   # Backup general storage files
```

## 🔑 SSH Setup (Recommended)
Ensure passwordless SSH authentication between hosts:
```bash
ssh-keygen -t ed25519
ssh-copy-id -i ~/.ssh/id_ed25519.pub pi@REMOTE_HOST
```

## 🚀 Features in v2.2
- **Optimized `rsync` options** for better performance
- **Fixed file permission issues** using `sudo rsync` on the remote host
- **Added command validation** to detect failures early
- **Improved CLI options** for easier backup control
- **Enhanced logging** with timestamped files and auto-trimming

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact
Developed by [CTinMich](https://github.com/CTinMich).  
Contributions and suggestions are welcome! 🚀


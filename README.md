# 🕹️ Atari 7800+ Firmware Upgrade for Linux

This is an idea to havea Safe, fully-automated firmware upgrade tool for Atari 7800+ on Linux.
It should automatically extracts firmware from the official Windows updater .exe, verify checksum, and flash your Atari 7800+ safely using rkdeveloptool.


## ⚡ Features

- ✅ Automatic firmware extraction using binwalk
- ✅ Auto-detects the largest .img — no manual searching
- ✅ SHA256 checksum verification to prevent corrupted flashes
- ✅ Safe flashing workflow with Mask ROM detection and user confirmation
- ✅ Full Linux support — no Windows required

## 📦 Requirements

- Linux machine (tested on Ubuntu/Debian)
- rkdeveloptool installed
- binwalk installed (sudo apt install binwalk)
- sha256sum (standard on most Linux)
- Official Atari 7800+ firmware .exe
- USB cable to connect Atari 7800+ in Mask ROM mode

## 🚀 Installation

- Clone this repo and make the script executable:

git clone https://github.com/masseo1/atari7800-linux-upgrade.git
cd atari7800-linux-upgrade
chmod +x safe_flash_atari7800_auto.sh


Place the official updater .exe in the folder.

## 🛡️ Usage
sudo ./safe_flash_atari7800_auto.sh


## What it does:

Automatically extracts Atari_Firmware.img from the .exe

Verifies the SHA256 checksum

Detects your Atari 7800+ in Mask ROM mode

Prompts you for confirmation before flashing

Safely flashes the firmware

Reboots the console

## ⚠️ Warning: Flashing firmware always carries risk. Ensure your Atari is connected correctly and don’t interrupt the process.

### 🔍 Optional Dry-Run Mode

- You can also preview firmware extraction and checksum without flashing:

` DRY_RUN=1 sudo ./safe_flash_atari7800_auto.sh`


This prints firmware details and verifies integrity without touching the console.

## 🛠️ Contributing

Contributions welcome! Suggestions include:

Supporting future updater .exe versions

Improved checksum verification

Adding a GUI frontend for Linux

## 📜 License

MIT License — free to use, modify, and share.
Give credit where credit is due, but flash at your own risk.

## 💬 Disclaimer

This tool is not official Atari software. Flashing firmware always carries risk of bricking your device. Use responsibly and at your own risk.

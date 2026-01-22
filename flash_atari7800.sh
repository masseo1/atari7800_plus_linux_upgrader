#!/bin/bash
# flash_atari7800.sh
# Fully automatic Atari 7800+ firmware upgrade on Linux
# 1) Automatically extracts firmware from .exe using binwalk
# 2) Automatically selects the correct .img
# 3) Verifies SHA256
# 4) Flashes safely via rkdeveloptool

set -euo pipefail

# --- Config ---
FIRMWARE_EXE="${FIRMWARE_EXE:-Atari7800_Firmware_Updater_2.0.1.4.1.exe}"
FIRMWARE_IMG="${FIRMWARE_IMG:-Atari_Firmware.img}"
# Replace this with the official Atari SHA256 checksum
OFFICIAL_SHA256="${OFFICIAL_SHA256:-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef}"
DRY_RUN="${DRY_RUN:-0}"

# --- Helper functions ---
function error_exit {
    echo "[ERROR] $1" >&2
    exit 1
}

function info {
    echo "[INFO] $1"
}

function warn {
    echo "[WARN] $1" >&2
}

function check_prereqs {
    info "Checking prerequisites..."
    command -v rkdeveloptool >/dev/null 2>&1 || error_exit "rkdeveloptool not installed. Install with: sudo apt install rkdeveloptool"
    command -v binwalk >/dev/null 2>&1 || error_exit "binwalk not installed. Install with: sudo apt install binwalk"
    command -v sha256sum >/dev/null 2>&1 || error_exit "sha256sum not found."
    info "All prerequisites satisfied."
}

function extract_firmware {
    if [ -f "$FIRMWARE_IMG" ]; then
        info "Firmware image already exists: $FIRMWARE_IMG"
        return
    fi

    [ ! -f "$FIRMWARE_EXE" ] && error_exit "$FIRMWARE_EXE not found in current folder. Download from Atari's official site."

    info "Extracting firmware from $FIRMWARE_EXE using binwalk..."
    TMP_DIR=$(mktemp -d)
    trap "rm -rf '$TMP_DIR'" EXIT

    binwalk -e -C "$TMP_DIR" "$FIRMWARE_EXE" >/dev/null || error_exit "Binwalk extraction failed"

    IMG_FOUND=$(find "$TMP_DIR" -type f -name "*.img" -exec ls -s {} + | sort -n -r | head -n1 | awk '{print $2}')
    [ -z "$IMG_FOUND" ] && error_exit "Failed to locate firmware .img in extracted files"

    cp "$IMG_FOUND" "$FIRMWARE_IMG"
    info "Firmware image ready: $FIRMWARE_IMG ($(du -h "$FIRMWARE_IMG" | cut -f1))"
}

function verify_checksum {
    info "Verifying SHA256 checksum..."
    SHA256SUM=$(sha256sum "$FIRMWARE_IMG" | awk '{print $1}')
    info "Calculated: $SHA256SUM"
    info "Expected:   $OFFICIAL_SHA256"
    
    if [[ "$OFFICIAL_SHA256" == "0123456789abcdef"* ]]; then
        warn "Using placeholder checksum. Update OFFICIAL_SHA256 with the real value for production use."
    elif [[ "$SHA256SUM" != "$OFFICIAL_SHA256" ]]; then
        error_exit "SHA256 mismatch! Firmware may be corrupted. Aborting."
    else
        info "Checksum verified OK."
    fi
}

function detect_device {
    info "Detecting Atari 7800+ in Mask ROM mode..."
    DEVICES=$(rkdeveloptool ld 2>/dev/null || true)
    if [[ "$DEVICES" != *"Maskrom"* ]]; then
        error_exit "No device detected in Mask ROM mode. Ensure console is connected and in update mode."
    fi
    info "Device detected: $DEVICES"
}

function confirm_flash {
    echo ""
    echo "============================================="
    echo "  ⚠️  FIRMWARE FLASH CONFIRMATION"
    echo "============================================="
    echo "  File: $FIRMWARE_IMG"
    echo "  Size: $(du -h "$FIRMWARE_IMG" | cut -f1)"
    echo "============================================="
    echo ""
    read -p "Type 'YES' to flash firmware: " CONFIRM
    [[ "$CONFIRM" != "YES" ]] && error_exit "Flash cancelled by user."
}

function flash_firmware {
    info "Flashing firmware to Atari 7800+..."
    rkdeveloptool uf "$FIRMWARE_IMG" || error_exit "Flashing failed! Do not disconnect the device."
    info "Flash completed successfully."
}

function reboot_device {
    info "Rebooting device..."
    rkdeveloptool rd || warn "Auto-reboot failed. Please power-cycle your Atari 7800+ manually."
}

function show_help {
    echo "Atari 7800+ Linux Firmware Upgrader"
    echo ""
    echo "Usage: sudo ./flash_atari7800.sh [OPTIONS]"
    echo ""
    echo "Environment Variables:"
    echo "  FIRMWARE_EXE     Path to firmware .exe (default: Atari7800_Firmware_Updater_2.0.1.4.1.exe)"
    echo "  FIRMWARE_IMG     Output firmware image name (default: Atari_Firmware.img)"
    echo "  OFFICIAL_SHA256  Expected SHA256 checksum"
    echo "  DRY_RUN=1        Extract and verify only, skip flashing"
    echo ""
    echo "Examples:"
    echo "  sudo ./flash_atari7800.sh"
    echo "  DRY_RUN=1 ./flash_atari7800.sh"
    echo "  FIRMWARE_EXE=custom.exe sudo ./flash_atari7800.sh"
    exit 0
}

# --- Main ---
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && show_help

info "=== Atari 7800+ Firmware Upgrader ==="
check_prereqs
extract_firmware
verify_checksum

if [[ "$DRY_RUN" == "1" ]]; then
    info "Dry-run mode: skipping device detection and flash."
    info "Firmware ready for flashing: $FIRMWARE_IMG"
    exit 0
fi

detect_device
confirm_flash
flash_firmware
reboot_device

echo ""
info "🎮 Firmware upgrade complete! Your Atari 7800+ should now boot with the new firmware."


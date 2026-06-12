#!/bin/bash

################################################################################
# ADB Setup Utility Script
# Configures ADB for Termux and Linux environments
################################################################################

setup_adb_termux() {
    echo "[INFO] Setting up ADB for Termux..."
    
    if ! command -v adb &> /dev/null; then
        echo "[INFO] Installing android-tools..."
        pkg update -y
        pkg install android-tools -y
    fi
    
    echo "[INFO] Setting up Termux storage..."
    termux-setup-storage
    
    echo "[✓] Termux ADB setup complete"
}

setup_adb_linux() {
    echo "[INFO] Setting up ADB for Linux..."
    
    if ! command -v adb &> /dev/null; then
        echo "[INFO] Installing android-tools via package manager..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install adb fastboot -y
        elif command -v yum &> /dev/null; then
            sudo yum install adb fastboot -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -S android-tools -y
        fi
    fi
    
    echo "[✓] Linux ADB setup complete"
}

start_adb_daemon() {
    echo "[INFO] Starting ADB daemon..."
    adb start-server
    echo "[✓] ADB daemon started"
}

kill_adb_daemon() {
    echo "[INFO] Stopping ADB daemon..."
    adb kill-server
    echo "[✓] ADB daemon stopped"
}

test_adb_connection() {
    echo "[INFO] Testing ADB connection..."
    
    if adb devices | grep -q "device$"; then
        echo "[✓] ADB device connected successfully"
        adb devices
    else
        echo "[✗] No ADB devices found"
        echo "[INFO] Steps to enable USB Debugging:"
        echo "  1. Go to Settings > About phone"
        echo "  2. Tap Build Number 7 times"
        echo "  3. Go to Developer Options"
        echo "  4. Enable USB Debugging"
        return 1
    fi
}

main() {
    echo "[INFO] ADB Setup Utility"
    echo ""
    
    # Detect environment
    if [ -d "$PREFIX" ] && [ -f "$PREFIX/etc/termux-release" ]; then
        setup_adb_termux
    else
        setup_adb_linux
    fi
    
    start_adb_daemon
    sleep 2
    test_adb_connection
}

main "$@"

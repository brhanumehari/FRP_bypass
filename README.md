# 🔐 FRP Bypass Toolkit — Android 10–16

A comprehensive, modular bash script for **authorized** penetration testing of Factory Reset Protection (FRP) on Android devices. Covers Android 10 through Android 16 with version-specific bypass techniques.

> **⚠ IMPORTANT — This tool is for AUTHORIZED security testing only.**  
> Unauthorized use may violate computer fraud laws. You must own the device or have explicit written permission before running this tool.

## 📖 Description

The **FRP Bypass Toolkit** is a modular, production-grade bash script designed for authorized security professionals conducting Android device penetration testing. It supports Android versions 10 through 16 with version-specific bypass techniques.

📎 **Repository:** https://github.com/brhanumehari/FRP_bypass

## 🧩 Features

| Layer | Technique |
|-------|-----------|
| **Android 10–11** | Account setup activity injection, `settings secure` manipulation, hidden test activities, WebView/browser exploitation |
| **Android 12–13** | TalkBack accessibility sequences, fragment-based activity injection, setup wizard killing, SUW device_provisioned override |
| **Android 14–16** | Recovery-mode ADB enablement, Samsung Odin/DM FRP partition reset, Fastboot `erase frp/config`, managed provisioning abuse |
| **All versions** | Retry logic, timeouts, safety prompts, color-coded output, full audit logging, interactive ADB shell |

## 📋 Prerequisites by Platform

| Platform | Required Tools | Installation Command |
|----------|----------------|----------------------|
| **Linux (Debian/Ubuntu/Kali)** | `adb`, `fastboot`, `git` | `sudo apt update && sudo apt install adb fastboot git -y` |
| **Termux (Android)** | `git`, `android-tools` | `pkg update && pkg install git android-tools -y && termux-setup-storage` |
| **Windows (Git Bash)** | Git Bash, Platform Tools | Download from [git-scm.com](https://git-scm.com/download/win) and [Platform Tools](https://developer.android.com/studio/releases/platform-tools) |
| **Windows (WSL)** | WSL, `adb`, `fastboot`, `git` | `wsl --install` then `sudo apt install adb fastboot git -y` |
| **Windows (CMD + PowerShell)** | Git for Windows, Platform Tools | Download from [git-scm.com](https://git-scm.com/download/win) and [Platform Tools](https://developer.android.com/studio/releases/platform-tools) |

### Verify Installation
```bash
adb version
fastboot --version
```

## 🚀 Quick Start

### Linux / macOS
```bash
# 1. Clone the repository
git clone https://github.com/brhanumehari/FRP_bypass.git
cd FRP_bypass

# 2. Make the script executable
chmod +x bash/frp-remover.sh

# 3. Connect your Android device via USB (USB Debugging enabled)

# 4. Run auto-detect and bypass
bash bash/frp-remover.sh
```

### Windows (CMD)

#### Option A: Using Git Bash (Recommended)
```bash
# 1. Open Git Bash (installed with Git for Windows)
# 2. Clone the repository
git clone https://github.com/brhanumehari/FRP_bypass.git
cd FRP_bypass

# 3. Make the script executable
chmod +x bash/frp-remover.sh

# 4. Download and extract Platform Tools from:
#    https://developer.android.com/studio/releases/platform-tools
#    Add the platform-tools folder to your PATH

# 5. Run the script
bash bash/frp-remover.sh
```

#### Option B: Using Windows Subsystem for Linux (WSL)
```cmd
REM 1. Open CMD as Administrator
REM 2. Install WSL
wsl --install

REM 3. Open Ubuntu/WSL terminal
REM 4. Update packages
sudo apt update && sudo apt upgrade -y

REM 5. Install prerequisites
sudo apt install adb fastboot git -y

REM 6. Clone the repository
git clone https://github.com/brhanumehari/FRP_bypass.git
cd FRP_bypass

REM 7. Make script executable
chmod +x bash/frp-remover.sh

REM 8. Run
bash bash/frp-remover.sh
```

#### Option C: Using CMD with PowerShell (Bash not available)
```cmd
REM 1. Download Platform Tools from:
REM    https://developer.android.com/studio/releases/platform-tools

REM 2. Extract to C:\platform-tools

REM 3. Add to PATH (CMD as Administrator)
setx PATH "%PATH%;C:\platform-tools" /M

REM 4. Download Git for Windows from:
REM    https://git-scm.com/download/win

REM 5. Clone the repo using Git Bash or download ZIP:
REM    https://github.com/brhanumehari/FRP_bypass/archive/refs/heads/main.zip

REM 6. Extract the ZIP to C:\FRP_bypass

REM 7. Open Git Bash and run:
cd /c/FRP_bypass
chmod +x bash/frp-remover.sh
bash bash/frp-remover.sh
```

### Termux (Android)
```bash
# 1. Update Termux packages
pkg update && pkg upgrade -y

# 2. Install git and android-tools
pkg install git android-tools -y

# 3. Give Termux storage access
termux-setup-storage

# 4. Clone your repository
git clone https://github.com/brhanumehari/FRP_bypass.git

# 5. Navigate into the folder
cd FRP_bypass

# 6. Make the script executable
chmod +x bash/frp-remover.sh

# 7. Run it
bash bash/frp-remover.sh
```

## 🔧 Usage

```
USAGE:
  bash bash/frp-remover.sh [OPTIONS]

OPTIONS:
  -a, --auto         Auto-detect device and run bypass (default)
  -v, --verbose      Enable verbose/debug output
  -l, --list         List connected devices
  -d, --diagnose     Run device diagnostics only
  -s, --shell        Drop into interactive ADB shell
  -m, --manual       Manual Android version selection
  -r, --recovery     Reboot and attempt recovery mode bypass
  -f, --force        Skip safety prompts
  -h, --help         Show this help message

EXAMPLES:
  bash bash/frp-remover.sh                 # Auto-detect and attempt bypass
  bash bash/frp-remover.sh -v              # Auto-detect with verbose logging
  bash bash/frp-remover.sh -d              # Device diagnostics only
  bash bash/frp-remover.sh -m              # Manual version selection
  bash bash/frp-remover.sh -r -f          # Recovery mode bypass, skip safety
```

## 🧪 Compatible Devices

| Manufacturer | Models |
|-------------|--------|
| **Samsung** | Galaxy S10–S24, Note10–Note20, A series, Tab series |
| **Google** | Pixel 4–9, Pixel Fold, Pixel Tablet |
| **OnePlus** | 8–12 series, Nord series |
| **Xiaomi** | Mi 9–14, Poco F/X series, Redmi Note series |
| **Motorola** | G series (G30–G100), E series, Edge series |
| **LG** | G7–G9, V50–V70 (discontinued) |
| **Others** | Most Android 10–16 devices with USB Debugging enabled |

## 🛠 How It Works

### Detection Flow
1. Scans for ADB, Fastboot, and Recovery-mode devices
2. Extracts `ro.build.version.release` and `ro.build.version.sdk`
3. Selects the appropriate bypass module(s)

### Version Mapping

| Android Version | SDK Level | Bypass Module |
|----------------|-----------|---------------|
| 10 | 29 | Basic ADB + Settings |
| 11 | 30 | Basic ADB + Settings |
| 12 | 31–32 | TalkBack + Fragment + SUW |
| 13 | 33 | TalkBack + Fragment + SUW |
| 14 | 34 | Recovery + Fastboot + Advanced |
| 15 | 35 | Recovery + Fastboot + Advanced |
| 16 | 36 | Recovery + Fastboot + Advanced |

## 📄 Logging

All actions are timestamped and saved to:
```
logs/frp_remover_YYYYMMDD_HHMMSS.log
```

The log captures every command, result, timeout, and error for post-assessment review.

## ⚠ Safety Warnings

| Risk | Description |
|------|-------------|
| **Samsung Knox** | Running FRP bypass tools may trip the Knox e-fuse (hardware-level, irreversible) |
| **Fastboot erase** | `fastboot erase frp\|config\|persist` can cause data loss or boot loops |
| **OEM unlock** | Unlocking the bootloader wipes all user data |
| **Recovery ops** | Recovery-mode partition writes carry inherent risk |

The script prompts for confirmation before any destructive operation unless `-f` is passed.

## ✅ Authorization Statement

> I have permission and am authorized to perform this penetration test.  
> This tool is used exclusively on devices I own or have explicit written authorization to test.

## 🧑‍💻 Author

**Created by brhanumehari**

- Repository: https://github.com/brhanumehari/FRP_bypass
- Security Research & Penetration Testing Tools

## 📜 License

This project is provided for **authorized security testing and educational purposes only**.  
You may not use this software for illegal activities. The author assumes no liability for misuse.

## 🙏 Acknowledgments

- Android Security Research Community
- Google Project Zero
- XDA Developers Forum members for documented bypass techniques
- All responsible disclosure researchers

## ⭐ Support

If this tool helped your assessment, please star the repository and cite it in your security reports.

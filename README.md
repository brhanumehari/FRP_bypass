Here's the updated `README.md` with Windows CMD installation instructions added:

```markdown
# 🔐 FRP Bypass Toolkit — Android 10–16

A comprehensive, modular bash script for **authorized** penetration testing of Factory Reset Protection (FRP) on Android devices. Covers Android 10 through Android 16 with version-specific bypass techniques, retry logic, detailed logging, and safety checks.

> **⚠ IMPORTANT — This tool is for AUTHORIZED security testing only.**  
> Unauthorized use may violate computer fraud laws. You must own the device or have explicit written permission before running this tool.

## 📖 Description

The **FRP Bypass Toolkit** is a modular, production-grade bash script designed for authorized security professionals conducting Android device penetration testing. It supports Android versions 10 through 16 with version-specific exploits: for Android 10-11 it uses Google Account setup activity injection, settings secure table manipulation, and hidden test activities; for Android 12-13 it leverages TalkBack accessibility service automation, fragment-based activity manager injection, and setup wizard process killing with device provisioned overrides; for Android 14-16 it implements advanced recovery-mode ADB enablement, Samsung Download/Odin mode FRP partition reset commands, and Fastboot erase operations against frp/config/persist partitions. The script automatically detects device state (ADB, Fastboot, or Recovery mode), extracts build properties to identify the exact Android version and manufacturer, and selects the optimal bypass strategy. Safety is paramount — the tool includes Samsung Knox trip warnings, destructive operation confirmations, and graceful interrupt handling. Additional features include configurable retry logic with per-command timeouts, comprehensive timestamped audit logging, color-coded terminal progress indicators, an interactive ADB shell drop-in mode, and a diagnostics module that reports bootloader state, provisioning status, and installed FRP-related packages. Created by ENG-251885 for the security research community. Intended for authorized testing only — unauthorized use may violate applicable laws.

📎 **Repository:** https://github.com/brhanumehari/FRP_bypass

## 🧩 Features

| Layer | Technique |
|-------|-----------|
| **Android 10–11** | Account setup activity injection, `settings secure` manipulation, hidden test activities, WebView/browser exploitation |
| **Android 12–13** | TalkBack accessibility sequences, fragment-based activity injection, setup wizard killing, SUW device_provisioned override |
| **Android 14–16** | Recovery-mode ADB enablement, Samsung Odin/DM FRP partition reset, Fastboot `erase frp/config`, managed provisioning abuse |
| **All versions** | Retry logic, timeouts, safety prompts, color-coded output, full audit logging, interactive ADB shell |

## 📋 Prerequisites

### Linux (Debian/Ubuntu/Kali)
| **Tool** |** Install** |
|------|---------|
| *`adb`* | `*sudo apt install adb`* |
| `*fastboot`* | `sudo apt install fastboot`* |

### Termux (Android)
| Tool | Install |
|------|---------|
| `git` | `pkg install git` |
| `android-tools` | `pkg install android-tools` |

### Windows (CMD/PowerShell)
| Tool | Download |
|------|----------|
| `adb` & `fastboot` | [Platform Tools](https://developer.android.com/studio/releases/platform-tools) |
| `Git Bash` or `WSL` | [Git for Windows](https://git-scm.com/download/win) or `wsl --install` |

### Verify installation
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
chmod +x frp_bypass.sh

# 3. Connect your Android device via USB (USB Debugging enabled)

# 4. Run auto-detect and bypass
./frp_bypass.sh
```

### Windows (CMD)

#### Option A: Using Git Bash (Recommended)
```bash
# 1. Open Git Bash (installed with Git for Windows)
# 2. Clone the repository
git clone https://github.com/brhanumehari/FRP_bypass.git
cd FRP_bypass

# 3. Make the script executable
chmod +x frp_bypass.sh

# 4. Download and extract Platform Tools from:
#    https://developer.android.com/studio/releases/platform-tools
#    Add the platform-tools folder to your PATH

# 5. Run the script
./frp_bypass.sh
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
chmod +x frp_bypass.sh

REM 8. Run
./frp_bypass.sh
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
chmod +x frp_bypass.sh
./frp_bypass.sh
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
chmod +x frp_bypass.sh

# 7. Run it
./frp_bypass.sh
```

## 🔧 Usage

```
USAGE:
  ./frp_bypass.sh [OPTIONS]

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
  ./frp_bypass.sh                      # Auto-detect and attempt bypass
  ./frp_bypass.sh -v                   # Auto-detect with verbose logging
  ./frp_bypass.sh -d                   # Device diagnostics only
  ./frp_bypass.sh -m                   # Manual version selection
  ./frp_bypass.sh -r -f               # Recovery mode bypass, skip safety
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
frp_bypass_YYYYMMDD_HHMMSS.log
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

**Created by ENG-251885***

- Repository:https://github.com/brhanumehari/FRP_bypass
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
```

## Key Additions for Windows:

1. **📋 Prerequisites section** now includes Windows tools (Platform Tools, Git Bash, WSL)
2. **🚀 Quick Start** now has three Windows methods:
   - **Option A**: Git Bash (most compatible with bash scripts)
   - **Option B**: WSL (full Linux environment on Windows)
   - **Option C**: CMD + PowerShell (for users without Git Bash)
3. **Termux** section added separately for Android phone users
4. **Repository URL** updated to `https://github.com/brhanumehari/FRP_bypass`

The Windows CMD method uses Git Bash (which comes with Git for Windows) to run the bash script, since CMD natively cannot execute `.sh` files. WSL is the most robust option for Windows users.

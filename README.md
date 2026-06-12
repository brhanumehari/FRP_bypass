Here's the updated `README.md` with your repository URL inserted:

```markdown
# 🔐 FRP Bypass Toolkit — Android 10–16

A comprehensive, modular bash script for **authorized** penetration testing of Factory Reset Protection (FRP) on Android devices. Covers Android 10 through Android 16 with version-specific bypass techniques, retry logic, detailed logging, and safety checks.

> **⚠ IMPORTANT — This tool is for AUTHORIZED security testing only.**  
> Unauthorized use may violate computer fraud laws. You must own the device or have explicit written permission before running this tool.

## 📖 Description

The **FRP Bypass Toolkit** is a modular, production-grade bash script designed for authorized security professionals conducting Android device penetration testing. It supports Android versions 10 through 16 with version-specific exploits: for Android 10-11 it uses Google Account setup activity injection, settings secure table manipulation, and hidden test activities; for Android 12-13 it leverages TalkBack accessibility service automation, fragment-based activity manager injection, and setup wizard process killing with device provisioned overrides; for Android 14-16 it implements advanced recovery-mode ADB enablement, Samsung Download/Odin mode FRP partition reset commands, and Fastboot erase operations against frp/config/persist partitions. The script automatically detects device state (ADB, Fastboot, or Recovery mode), extracts build properties to identify the exact Android version and manufacturer, and selects the optimal bypass strategy. Safety is paramount — the tool includes Samsung Knox trip warnings, destructive operation confirmations, and graceful interrupt handling. Additional features include configurable retry logic with per-command timeouts, comprehensive timestamped audit logging, color-coded terminal progress indicators, an interactive ADB shell drop-in mode, and a diagnostics module that reports bootloader state, provisioning status, and installed FRP-related packages. Created by ENG-251885 for the security research community. Intended for authorized testing only — unauthorized use may violate applicable laws.

📎 **Repository:** [https://github.com/brhanumehari/FRP_bypass](https://github.com/brhanumehari/FRP_bypass)

## 🧩 Features

| Layer | Technique |
|-------|-----------|
| **Android 10–11** | Account setup activity injection, `settings secure` manipulation, hidden test activities, WebView/browser exploitation |
| **Android 12–13** | TalkBack accessibility sequences, fragment-based activity injection, setup wizard killing, SUW device_provisioned override |
| **Android 14–16** | Recovery-mode ADB enablement, Samsung Odin/DM FRP partition reset, Fastboot `erase frp/config`, managed provisioning abuse |
| **All versions** | Retry logic, timeouts, safety prompts, color-coded output, full audit logging, interactive ADB shell |

## 📋 Prerequisites

| Tool | Install (Debian/Ubuntu/Kali) |
|------|------------------------------|
| `adb` | `sudo apt install adb` |
| `fastboot` | `sudo apt install fastboot` |
| `grep`, `awk`, `sed`, `cut`, `tr` | (usually pre-installed) |

### Verify installation
```bash
adb version
fastboot --version
```

## 🚀 Quick Start

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

**Created by ENG-251885**

- GitHub: [@ENG-251885](https://github.com/ENG-251885)
- Repository: [https://github.com/brhanumehari/FRP_bypass](https://github.com/brhanumehari/FRP_bypass)
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

The updates include:
1. **Repository link** added under the Description section
2. **Clone URL** updated to `https://github.com/brhanumehari/FRP_bypass.git` in Quick Start
3. **Authorization Statement** section added confirming you have permission
4. **Author section** updated with both profile and repository links

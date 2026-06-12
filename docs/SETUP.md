# Setup Guide - FRP Remover

## Prerequisites

### System Requirements
- **Computer**: Linux, macOS, or Windows with WSL/Git Bash
- **Android Device**: Android 10-16
- **USB Cable**: For device connection
- **Administrator/Root**: May be required for some operations

### Software Requirements

#### Linux/macOS
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install adb fastboot git build-essential -y

# macOS
brew install android-platform-tools git
```

#### Termux (Android)
```bash
pkg update && pkg upgrade -y
pkg install git android-tools python3 -y
termux-setup-storage
```

#### Windows (Git Bash)
1. Download and install [Git for Windows](https://git-scm.com/download/win)
2. Download [Android Platform Tools](https://developer.android.com/studio/releases/platform-tools)
3. Add Platform Tools to system PATH

## Installation Steps

### 1. Clone Repository
```bash
git clone https://github.com/brhanumehari/FRP_bypass.git
cd FRP_bypass
```

### 2. Run Installer
```bash
chmod +x bash/install.sh
./bash/install.sh
```

### 3. Setup ADB
```bash
chmod +x bash/utils/adb-setup.sh
./bash/utils/adb-setup.sh
```

### 4. Verify Installation
```bash
adb version
adb devices
```

## Device Preparation

### Enable USB Debugging (Android Device)
1. Go to **Settings > About phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go back to **Settings > Developer Options**
4. Enable **USB Debugging**
5. Connect device via USB cable
6. Approve the authorization dialog

### Verify Connection
```bash
adb devices
```

You should see your device with "device" status.

## Build Rust Components (Optional)

### Install Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### Build Binary
```bash
cd rust
cargo build --release
cd ..
```

The binary will be available at: `rust/target/release/frp-remover`

## Troubleshooting

### ADB Not Found
```bash
# Install android-tools
sudo apt install android-tools

# Or for macOS
brew install android-platform-tools
```

### Device Not Recognized
1. Check USB cable connection
2. Enable USB Debugging on device
3. Try: `adb kill-server && adb start-server`
4. Reconnect device

### Permission Denied
- Run with `sudo` if needed
- On Termux, ensure storage permissions are granted: `termux-setup-storage`

## Next Steps

1. Review [USAGE.md](USAGE.md) for operating instructions
2. Check [SUPPORTED_DEVICES.md](SUPPORTED_DEVICES.md) for device compatibility
3. Consult [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for issues

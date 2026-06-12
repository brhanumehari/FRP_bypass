# 🔐 FRP Remover for Android 10-16 (Termux & Linux)

A comprehensive Factory Reset Protection (FRP) removal toolkit for Android 10 through Android 16 using Bash scripting and Rust, optimized for Termux environment.

## 📋 Features

- **Multi-Device Support**: Samsung, Google (Pixel), MIUI, OnePlus, Motorola, and generic FRP removal
- **Android Versions**: Full support for Android 10, 11, 12, 13, 14, 15, and 16
- **Dual Implementation**: Bash scripts for rapid deployment + Rust tools for performance
- **Termux Optimized**: Works seamlessly in Termux environment
- **Safe & Reversible**: Non-destructive FRP bypass techniques
- **Automated Detection**: Device and Android version auto-detection
- **Logging & Debug**: Comprehensive logging for troubleshooting

## 📁 Project Structure

```
FRP_remover/
├── README.md                 # Main documentation
├── LICENSE                   # MIT License with legal disclaimer
├── .gitignore               # Git ignore configuration
├── docs/                    # Detailed guides
│   ��── SETUP.md            # Installation guide
│   ├── USAGE.md            # Usage instructions
│   ├── SUPPORTED_DEVICES.md # Device compatibility
│   └── TROUBLESHOOTING.md  # Troubleshooting guide
├── bash/                   # Bash scripts
│   ├── install.sh         # Main installer
│   ├── frp-remover.sh     # Main FRP removal script
│   ├── utils/             # Utility functions
│   │   ├── device-detect.sh
│   │   ├── adb-setup.sh
│   │   ├── samsung-bypass.sh
│   │   ├── google-bypass.sh
│   │   ├── miui-bypass.sh
│   │   ├── oneplus-bypass.sh
│   │   └── logger.sh
│   └── config/            # Configuration files
│       └── devices.conf
├── rust/                  # Rust implementation
│   ├── Cargo.toml        # Project manifest
│   ├── Cargo.lock
│   ├── src/
│   │   ├── main.rs
│   │   ├── lib.rs
│   │   ├── device.rs
│   │   ├── frp_bypass.rs
│   │   ├── adb.rs
│   │   └── commands.rs
│   └── build.sh          # Build script for Termux
├── tools/               # Pre-built binaries
│   └── .gitkeep
├── logs/                # Logs directory
└── .gitignore          # Git ignore file
```

## 🚀 Quick Start

### Prerequisites
- Termux installed on Android device OR Linux computer
- USB cable for connection
- Computer with ADB (Android Debug Bridge) installed
- Root access to target Android device (recommended)

### Installation

1. **Clone Repository**
```bash
git clone https://github.com/brhanumehari/FRP_remover.git
cd FRP_remover
```

2. **Run Installer**
```bash
chmod +x bash/install.sh
bash bash/install.sh
```

3. **Setup ADB Connection**
```bash
bash bash/utils/adb-setup.sh
```

4. **Run FRP Remover**
```bash
bash bash/frp-remover.sh
```

## 🛠️ Implementation Details

### Bash Scripts
- **frp-remover.sh**: Main orchestrator with device detection
- **device-detect.sh**: Detects Android version and manufacturer
- **adb-setup.sh**: Configures ADB for your environment
- **samsung-bypass.sh**: Samsung Knox FRP bypass
- **google-bypass.sh**: Google Account FRP removal
- **miui-bypass.sh**: MIUI/Xiaomi FRP bypass
- **oneplus-bypass.sh**: OnePlus FRP bypass
- **logger.sh**: Color-coded logging utilities

### Rust Implementation
- Performance-optimized version for complex operations
- ADB command execution wrapper
- Device communication handler
- Database manipulation tools
- CLI with multiple commands

## 📱 Supported Android Versions

- ✅ Android 10 (API 29)
- ✅ Android 11 (API 30)
- ✅ Android 12 (API 31)
- ✅ Android 13 (API 32)
- ✅ Android 14 (API 33)
- ✅ Android 15 (API 34)
- ✅ Android 16 (API 35)

## 📱 Supported Devices

- Samsung Galaxy S/A/J/M/Note series
- Google Pixel series
- Xiaomi (MIUI) devices
- OnePlus devices
- Motorola devices
- Generic Android devices

## 📖 Documentation

For detailed guides, see:
- [Setup Instructions](docs/SETUP.md)
- [Usage Guide](docs/USAGE.md)
- [Supported Devices](docs/SUPPORTED_DEVICES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## ⚠️ Legal Notice

This tool is provided for:
- Educational purposes
- Recovery of personal devices
- Legitimate device maintenance

**Do NOT use this tool for unauthorized access to devices you don't own.** Users are responsible for ensuring they have proper authorization before using this tool.

## 🔒 Safety

- All operations are logged
- Database backups are created before modifications
- Non-destructive bypass techniques used
- Can be reversed with factory settings reset

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

See [LICENSE](LICENSE) file for details - MIT License with legal disclaimer included.

## ❓ Support

For issues and questions:
- Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Open an issue on GitHub
- Review documentation in `/docs`

## 🙏 Acknowledgments

Built with consideration for security, performance, and user experience.

---

**Repository**: https://github.com/brhanumehari/FRP_remover  
**Version**: 1.0.0 | **Last Updated**: 2026-06-12 | **Author**: brhanumehari

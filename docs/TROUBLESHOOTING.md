# Troubleshooting Guide - FRP Remover

## Common Issues

### ADB Connection Issues

#### Problem: "ADB not found" or "Command not found"
**Solution:**
```bash
# Install Android tools
# Ubuntu/Debian
sudo apt install android-tools-adb android-tools-fastboot -y

# macOS
brew install android-platform-tools

# Termux
pkg install android-tools -y

# Verify installation
adb version
```

#### Problem: Device not appearing in "adb devices"
**Solutions:**
1. **Check USB Connection:**
   - Try different USB cable
   - Try different USB port
   - Connect to different computer

2. **Enable USB Debugging:**
   - Settings > About Phone
   - Tap Build Number 7 times
   - Settings > Developer Options
   - Enable USB Debugging
   - Approve dialog on device

3. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

4. **Install ADB Drivers (Windows):**
   - Download drivers from manufacturer
   - Install Google USB Driver
   - Restart computer

#### Problem: "Device offline" status
**Solution:**
```bash
# Restart device
adb reboot

# Or manually
1. Disconnect USB
2. Wait 10 seconds
3. Reconnect USB
4. Check again: adb devices
```

### Bypass Execution Issues

#### Problem: "Permission denied" errors
**Solution:**
```bash
# Run with elevated privileges
sudo bash bash/frp-remover.sh

# Or on Termux (should not require sudo)
bash bash/frp-remover.sh
```

#### Problem: "Command timed out"
**Solution:**
1. Ensure device is responsive
2. Increase timeout in script
3. Try again with verbose mode: `-v`
4. Check if device is in recovery mode

#### Problem: Bypass completes but FRP still active
**Solution:**
1. Try alternative method with `-m` flag
2. Run diagnostics: `bash bash/frp-remover.sh -d`
3. Check device logs:
   ```bash
   adb logcat | grep -i frp
   adb logcat | grep -i setup
   ```

### Device-Specific Issues

#### Samsung Device Not Bypassing
**Check:**
- Knox security status
- Bootloader lock status: `adb shell getprop ro.oem_unlock_supported`
- SELinux mode: `adb getp selinux.status`

**Try:**
```bash
# Disable Knox
adb shell settings put global knox_preferenceinfo ""

# Or run Samsung-specific bypass
bash bash/utils/samsung-bypass.sh
```

#### Google Pixel Account Bypass Fails
**Try:**
```bash
# Clear Google Services
adb shell pm clear com.google.android.gms
adb shell pm clear com.google.android.gsf

# Or run Pixel-specific bypass
bash bash/utils/google-bypass.sh
```

#### Xiaomi/MIUI Device Issues
**Try:**
```bash
# Clear Mi Account
bash bash/utils/miui-bypass.sh

# Also try disabling Find Device
adb shell pm disable-user --user 0 com.xiaomi.finddevice
```

#### OnePlus Device Not Responding
**Try:**
```bash
# Run OnePlus-specific bypass
bash bash/utils/oneplus-bypass.sh

# Clear OnePlus setup wizard
adb shell pm clear com.oneplus.setup
```

### Logging & Diagnostics

#### View Logs
```bash
# Most recent log
tail -f logs/frp_remover_*.log

# All logs
ls -lah logs/

# Search for errors
grep ERROR logs/frp_remover_*.log
```

#### Run Diagnostics
```bash
# Bash
bash bash/frp-remover.sh -d

# Rust
./rust/target/release/frp-remover diagnose
```

#### Enable Verbose Output
```bash
# Bash
bash bash/frp-remover.sh -v

# Rust
./rust/target/release/frp-remover remove -v
```

#### Get Device Info
```bash
# All properties
adb shell getprop

# Specific info
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk

# FRP status
adb shell settings get global device_provisioned
adb shell settings get secure user_setup_complete
```

### Network & Build Issues

#### Problem: "Cannot connect to build" (Rust)
**Solution:**
```bash
# Check Rust installation
rustc --version

# Update Rust
rustup update

# Try building again
cd rust && cargo clean && cargo build --release && cd ..
```

#### Problem: Network timeout during build
**Solution:**
```bash
# Increase timeout
cd rust
cargo build --release -- -Z timing-info

# Or use offline build
cargo build --release --offline
```

### Permission & Access Issues

#### Problem: "Root access required"
**Solution:**
1. Try without root first - most bypasses don't need it
2. If needed, enable Developer Mode:
   ```bash
   adb shell su -c "command here"
   ```
3. Or use device's built-in root:
   ```bash
   adb shell
   su
   # commands here
   ```

#### Problem: SELinux blocking operations
**Solution:**
```bash
# Check SELinux status
adb shell getenforce

# Set to permissive (if rooted)
adb shell su -c "setenforce 0"

# Or modify policies
adb shell su -c "restorecon -R /data/system"
```

### Termux-Specific Issues

#### Problem: "termux-setup-storage" fails
**Solution:**
1. Grant storage permissions in system settings
2. Try again
3. Or manually set path:
   ```bash
   export HOME=/data/data/com.termux/files/home
   cd $HOME
   ```

#### Problem: Cannot access /sdcard
**Solution:**
```bash
# Ensure storage is mounted
mount | grep sdcard

# Or try via Termux
ls ~/storage/

# Set up symlink
ln -s ~/storage/downloads $HOME/downloads
```

#### Problem: Rust cannot find dependencies in Termux
**Solution:**
```bash
# Update packages
pkg update && pkg upgrade -y

# Install build tools
pkg install build-essential clang -y

# Try building again
cd rust && cargo build --release && cd ..
```

## Recovery Steps

### If Bypass Goes Wrong

#### Device Stuck in Setup Loop
1. Force restart: Hold power button 10+ seconds
2. Boot into recovery: Power + Volume Down
3. Factory reset: Wipe cache/data
4. Start fresh

#### ADB Stops Working
1. Disconnect USB
2. Restart device completely
3. Restart computer if needed
4. Reconnect and verify

#### Lost Access to Device
1. If bootloader is unlocked: Flash stock ROM
2. If bootloader is locked: Factory reset required
3. Contact manufacturer for recovery options

## Getting Help

### Before Opening Issue:
1. ✅ Update tool: `git pull`
2. ✅ Run with verbose: `-v` flag
3. ✅ Save logs: `cat logs/frp_remover_*.log > issue.log`
4. ✅ Get device info: `adb shell getprop > device.txt`

### Provide When Opening Issue:
- Device manufacturer and model
- Android version
- Exact error message
- Full log file
- What you already tried

### Useful Resources:
- [Android Developers - ADB](https://developer.android.com/studio/command-line/adb)
- [XDA Forums](https://forum.xda-developers.com/)
- [Reddit r/androiddev](https://www.reddit.com/r/androiddev/)
- [GitHub Issues](https://github.com/brhanumehari/FRP_bypass/issues)

## Performance Tips

### Speed Up Bypass:
- Use wired connection (USB cable)
- Disable background apps on device
- Keep device on WiFi if needed
- Use latest Android tools

### Reduce Issues:
- Ensure device is fully charged
- Keep device cool
- Don't disconnect during operation
- Monitor logs for warnings

## Prevention

### Future FRP Prevention:
1. Note account credentials
2. Enable "Find My Mobile" (Samsung)
3. Set up recovery email
4. Keep documentation of setup
5. Store credentials securely

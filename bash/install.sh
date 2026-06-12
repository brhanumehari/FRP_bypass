#!/bin/bash

################################################################################
# FRP Remover Installer Script for Termux & Linux
# Supports: Android 10-16, Multiple Device Manufacturers
# Author: brhanumehari
# Version: 1.0.0
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Header
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     FRP Remover Installer for Android 10-16 (Termux)      ║"
    echo "║                        Version 1.0.0                       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check if running on Termux
check_termux() {
    if [ -d "$PREFIX" ] && [ -f "$PREFIX/etc/termux-release" ]; then
        log_success "Running on Termux"
        return 0
    else
        log_warning "Not running on Termux - continuing with Linux setup"
        return 1
    fi
}

# Check and install prerequisites
install_prerequisites() {
    log_info "Checking and installing prerequisites..."

    local missing_packages=()

    # Check for required commands
    if ! command -v git &> /dev/null; then
        missing_packages+=("git")
    fi

    if ! command -v adb &> /dev/null; then
        missing_packages+=("android-tools")
    fi

    if ! command -v python3 &> /dev/null; then
        missing_packages+=("python3")
    fi

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log_success "All prerequisites already installed"
        return 0
    fi

    log_warning "Missing packages: ${missing_packages[*]}"

    # Detect package manager
    if command -v pkg &> /dev/null; then
        # Termux
        log_info "Installing via pkg (Termux)..."
        pkg update -y
        pkg upgrade -y
        for package in "${missing_packages[@]}"; do
            log_info "Installing $package..."
            pkg install "$package" -y
        done
    elif command -v apt &> /dev/null; then
        # Debian/Ubuntu
        log_info "Installing via apt..."
        sudo apt update
        sudo apt upgrade -y
        for package in "${missing_packages[@]}"; do
            log_info "Installing $package..."
            sudo apt install "$package" -y
        done
    elif command -v yum &> /dev/null; then
        # RedHat/CentOS
        log_info "Installing via yum..."
        sudo yum update -y
        for package in "${missing_packages[@]}"; do
            log_info "Installing $package..."
            sudo yum install "$package" -y
        done
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        log_info "Installing via pacman..."
        sudo pacman -Syu --noconfirm
        for package in "${missing_packages[@]}"; do
            log_info "Installing $package..."
            sudo pacman -S "$package" --noconfirm
        done
    else
        log_error "Unsupported package manager"
        return 1
    fi

    log_success "Prerequisites installed"
}

# Setup ADB
setup_adb() {
    log_info "Setting up ADB..."

    if check_termux; then
        log_info "Setting up Termux storage..."
        termux-setup-storage 2>/dev/null || true
    fi

    log_info "Checking ADB connection..."
    if ! command -v adb &> /dev/null; then
        log_error "ADB not found after installation"
        return 1
    fi

    log_success "ADB setup complete"
}

# Create directory structure
setup_directories() {
    log_info "Creating directory structure..."

    local dirs=(
        "bash/utils"
        "bash/config"
        "rust/src"
        "tools"
        "logs"
        "docs"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_info "Created: $dir"
    done

    log_success "Directory structure created"
}

# Build Rust tools
build_rust_tools() {
    log_info "Building Rust tools..."

    if ! command -v rustc &> /dev/null; then
        log_warning "Rust not installed. Skipping Rust build."
        log_info "To install Rust, visit: https://rustup.rs/"
        return 0
    fi

    if [ -f "rust/Cargo.toml" ]; then
        cd rust
        log_info "Building Rust project..."
        cargo build --release 2>&1 | tee build.log

        if [ -f "target/release/frp-remover" ]; then
            cp target/release/frp-remover ../tools/
            log_success "Rust binary built: tools/frp-remover"
        fi

        cd ..
    else
        log_warning "Cargo.toml not found, skipping Rust build"
    fi
}

# Set permissions
set_permissions() {
    log_info "Setting script permissions..."

    find bash -type f -name "*.sh" -exec chmod +x {} \;
    chmod +x tools/* 2>/dev/null || true

    log_success "Permissions set"
}

# Print installation summary
print_summary() {
    echo -e "\n${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete! ✓                       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "1. Connect your Android device via USB"
    echo "2. Enable USB Debugging on the device"
    echo "3. Run: ${YELLOW}bash bash/frp-remover.sh${NC}"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "  - Setup: ${YELLOW}docs/SETUP.md${NC}"
    echo "  - Usage: ${YELLOW}docs/USAGE.md${NC}"
    echo "  - Supported Devices: ${YELLOW}docs/SUPPORTED_DEVICES.md${NC}"
    echo "  - Troubleshooting: ${YELLOW}docs/TROUBLESHOOTING.md${NC}"
    echo ""
}

# Main installation flow
main() {
    print_header

    # Check environment
    check_termux
    is_termux=$?

    # Install prerequisites
    install_prerequisites || exit 1

    # Setup ADB
    setup_adb || exit 1

    # Create directories
    setup_directories

    # Build Rust tools (optional)
    build_rust_tools

    # Set permissions
    set_permissions

    # Print summary
    print_summary
}

# Run main function
main "$@"

#!/bin/bash

################################################################################
# Device Detection Script
# Detects Android version, manufacturer, and device model
################################################################################

detect_android_version() {
    local device_serial="$1"
    adb -s "$device_serial" shell getprop ro.build.version.release
}

detect_sdk_level() {
    local device_serial="$1"
    adb -s "$device_serial" shell getprop ro.build.version.sdk
}

detect_manufacturer() {
    local device_serial="$1"
    adb -s "$device_serial" shell getprop ro.product.manufacturer
}

detect_model() {
    local device_serial="$1"
    adb -s "$device_serial" shell getprop ro.product.model
}

detect_device_name() {
    local device_serial="$1"
    adb -s "$device_serial" shell getprop ro.device.name
}

get_all_device_info() {
    local device_serial="$1"
    
    echo "Device: $device_serial"
    echo "Manufacturer: $(detect_manufacturer "$device_serial")"
    echo "Model: $(detect_model "$device_serial")"
    echo "Device Name: $(detect_device_name "$device_serial")"
    echo "Android Version: $(detect_android_version "$device_serial")"
    echo "SDK Level: $(detect_sdk_level "$device_serial")"
}

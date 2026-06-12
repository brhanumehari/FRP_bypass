// Device detection module
// Detects Android version, manufacturer, and device properties

use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};
use std::process::Command;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeviceInfo {
    pub serial: String,
    pub manufacturer: String,
    pub model: String,
    pub device_name: String,
    pub android_version: String,
    pub sdk_level: u8,
}

impl DeviceInfo {
    pub fn detect(serial: &str) -> Result<Self> {
        let manufacturer = execute_adb_command(serial, "getprop ro.product.manufacturer")?;
        let model = execute_adb_command(serial, "getprop ro.product.model")?;
        let device_name = execute_adb_command(serial, "getprop ro.device.name")?;
        let android_version = execute_adb_command(serial, "getprop ro.build.version.release")?;
        let sdk_level_str = execute_adb_command(serial, "getprop ro.build.version.sdk")?;
        let sdk_level = sdk_level_str.trim().parse::<u8>()?;

        Ok(DeviceInfo {
            serial: serial.to_string(),
            manufacturer: manufacturer.trim().to_string(),
            model: model.trim().to_string(),
            device_name: device_name.trim().to_string(),
            android_version: android_version.trim().to_string(),
            sdk_level,
        })
    }

    pub fn get_bypass_method(&self) -> &str {
        match self.sdk_level {
            29..=30 => "adb_settings",
            31..=32 => "talkback_fragment",
            33 => "talkback_fragment",
            34..=36 => "recovery_fastboot",
            _ => "generic_adb",
        }
    }

    pub fn get_manufacturer_type(&self) -> ManufacturerType {
        match self.manufacturer.to_lowercase().as_str() {
            "samsung" => ManufacturerType::Samsung,
            "google" => ManufacturerType::Google,
            "xiaomi" => ManufacturerType::Xiaomi,
            "oneplus" => ManufacturerType::OnePlus,
            "motorola" => ManufacturerType::Motorola,
            _ => ManufacturerType::Generic,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ManufacturerType {
    Samsung,
    Google,
    Xiaomi,
    OnePlus,
    Motorola,
    Generic,
}

fn execute_adb_command(serial: &str, command: &str) -> Result<String> {
    let output = Command::new("adb")
        .args(&["-s", serial, "shell", command])
        .output()
        .map_err(|e| anyhow!("Failed to execute adb command: {}", e))?;

    if !output.status.success() {
        return Err(anyhow!(
            "ADB command failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    Ok(String::from_utf8(output.stdout)?)
}

pub fn list_devices() -> Result<Vec<String>> {
    let output = Command::new("adb")
        .arg("devices")
        .output()
        .map_err(|e| anyhow!("Failed to list devices: {}", e))?;

    if !output.status.success() {
        return Err(anyhow!("Failed to list ADB devices"));
    }

    let stdout = String::from_utf8(output.stdout)?;
    let devices: Vec<String> = stdout
        .lines()
        .skip(1)
        .filter(|line| line.contains("device") && !line.contains("offline"))
        .map(|line| line.split_whitespace().next().unwrap_or("").to_string())
        .filter(|s| !s.is_empty())
        .collect();

    Ok(devices)
}

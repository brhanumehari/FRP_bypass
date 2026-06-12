// Commands module
// Implements CLI commands for the FRP remover

use anyhow::Result;
use colored::*;
use crate::device::{DeviceInfo, list_devices};
use crate::frp_bypass::FrpBypass;
use crate::adb::AdbClient;
use std::process::Command;

pub async fn detect(device: Option<String>) -> Result<()> {
    let serial = get_device_serial(device).await?;
    
    println!("{}", "Detecting device...".cyan());
    let device_info = DeviceInfo::detect(&serial)?;
    
    println!("\n{}", "Device Information:".bold().green());
    println!("  Serial:       {}", device_info.serial);
    println!("  Manufacturer: {}", device_info.manufacturer);
    println!("  Model:        {}", device_info.model);
    println!("  Android:      {}", device_info.android_version);
    println!("  SDK Level:    {}", device_info.sdk_level);
    println!("  Bypass Method: {}", device_info.get_bypass_method());
    
    Ok(())
}

pub async fn remove(
    device: Option<String>,
    _force: bool,
    _manufacturer: Option<String>,
    _version: Option<u8>,
) -> Result<()> {
    let serial = get_device_serial(device).await?;
    
    println!("{}", "Detecting device...".cyan());
    let device_info = DeviceInfo::detect(&serial)?;
    
    println!("\n{}", "Device Information:".bold().green());
    println!("  Serial:       {}", device_info.serial);
    println!("  Manufacturer: {}", device_info.manufacturer);
    println!("  Model:        {}", device_info.model);
    println!("  Android:      {}", device_info.android_version);
    println!("  Bypass Method: {}", device_info.get_bypass_method());
    
    println!("\n{}", "Starting FRP removal...".yellow());
    
    let client = AdbClient::new()?;
    let bypass = FrpBypass::new(client, device_info);
    bypass.execute().await?;
    
    println!("\n{}", "FRP removal completed successfully!".bold().green());
    Ok(())
}

pub async fn list() -> Result<()> {
    println!("{}", "Connected Devices:".bold().cyan());
    
    let devices = list_devices()?;
    
    if devices.is_empty() {
        println!("{}", "No devices found".yellow());
        return Ok(());
    }
    
    for (i, device) in devices.iter().enumerate() {
        println!("  [{}] {}", i + 1, device);
    }
    
    Ok(())
}

pub async fn shell(device: Option<String>) -> Result<()> {
    let serial = get_device_serial(device).await?;
    
    println!("{}", "Entering interactive shell (type 'exit' to quit)".cyan());
    println!("{}", "Device: ".bold() + &serial);
    
    Command::new("adb")
        .args(&["-s", &serial, "shell"])
        .status()?;
    
    Ok(())
}

pub async fn diagnose(device: Option<String>) -> Result<()> {
    let serial = get_device_serial(device).await?;
    
    println!("{}", "Running diagnostics...".cyan());
    
    let device_info = DeviceInfo::detect(&serial)?;
    
    println!("\n{}", "Device Information:".bold().green());
    println!("  Serial:       {}", device_info.serial);
    println!("  Manufacturer: {}", device_info.manufacturer);
    println!("  Model:        {}", device_info.model);
    println!("  Android:      {}", device_info.android_version);
    println!("  SDK Level:    {}", device_info.sdk_level);
    
    println!("\n{}", "FRP Status:".bold().green());
    // Additional diagnostic checks would go here
    println!("  Status: Pending verification");
    
    Ok(())
}

async fn get_device_serial(device: Option<String>) -> Result<String> {
    match device {
        Some(serial) => Ok(serial),
        None => {
            let devices = list_devices()?;
            match devices.len() {
                0 => Err(anyhow::anyhow!("No devices connected")),
                1 => Ok(devices[0].clone()),
                _ => {
                    println!("{}", "Multiple devices found:".yellow());
                    for (i, dev) in devices.iter().enumerate() {
                        println!("  [{}] {}", i + 1, dev);
                    }
                    Err(anyhow::anyhow!(
                        "Please specify device with -d/--device option"
                    ))
                }
            }
        }
    }
}

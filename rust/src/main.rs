// Main entry point for FRP Remover Rust CLI
// Provides fast, compiled-binary support for FRP removal

use clap::{Parser, Subcommand};
use colored::*;
use std::process;
use tracing::{error, info};

mod device;
mod frp_bypass;
mod adb;
mod commands;

#[derive(Parser)]
#[command(
    name = "FRP Remover",
    about = "Factory Reset Protection remover for Android 10-16",
    version = "1.0.0"
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Enable verbose/debug output
    #[arg(short, long, global = true)]
    verbose: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Detect connected device information
    Detect {
        /// Device serial number
        #[arg(short, long)]
        device: Option<String>,
    },

    /// Remove FRP from device
    Remove {
        /// Device serial number
        #[arg(short, long)]
        device: Option<String>,

        /// Force bypass without confirmation
        #[arg(short, long)]
        force: bool,

        /// Specific manufacturer (samsung, google, xiaomi, oneplus, motorola)
        #[arg(short, long)]
        manufacturer: Option<String>,

        /// Android version (10-16)
        #[arg(short, long)]
        version: Option<u8>,
    },

    /// List connected ADB devices
    List,

    /// Open interactive ADB shell
    Shell {
        /// Device serial number
        #[arg(short, long)]
        device: Option<String>,
    },

    /// Run device diagnostics
    Diagnose {
        /// Device serial number
        #[arg(short, long)]
        device: Option<String>,
    },
}

#[tokio::main]
async fn main() {
    let args = Cli::parse();

    // Initialize logging
    if args.verbose {
        std::env::set_var("RUST_LOG", "debug");
    } else {
        std::env::set_var("RUST_LOG", "info");
    }

    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    // Print banner
    print_banner();

    // Execute command
    let result = match args.command {
        Commands::Detect { device } => commands::detect(device).await,
        Commands::Remove {
            device,
            force,
            manufacturer,
            version,
        } => {
            commands::remove(device, force, manufacturer, version).await
        }
        Commands::List => commands::list().await,
        Commands::Shell { device } => commands::shell(device).await,
        Commands::Diagnose { device } => commands::diagnose(device).await,
    };

    if let Err(e) = result {
        error!("{}", e);
        eprintln!("{}", format!("Error: {}", e).red());
        process::exit(1);
    }
}

fn print_banner() {
    let banner = r#"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          🔓 FRP REMOVER - Android 10-16 (Rust)              ║
║                                                               ║
║  Factory Reset Protection Removal Tool                        ║
║  Version: 1.0.0                                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
"#;
    println!("{}", banner.cyan());
}

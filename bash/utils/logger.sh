#!/bin/bash

################################################################################
# Logging Utility Script
# Provides comprehensive logging functions
################################################################################

# Log levels
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/tmp/frp_remover.log}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialize log file
init_log() {
    local log_file="$1"
    echo "=== FRP Remover Log ===" > "$log_file"
    echo "Started: $(date)" >> "$log_file"
    echo "" >> "$log_file"
}

# Format log message
format_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message"
}

# Log to file
log_to_file() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Log INFO level
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} $message"
    log_to_file "INFO" "$message"
}

# Log SUCCESS level
log_success() {
    local message="$1"
    echo -e "${GREEN}[✓]${NC} $message"
    log_to_file "SUCCESS" "$message"
}

# Log WARNING level
log_warning() {
    local message="$1"
    echo -e "${YELLOW}[⚠]${NC} $message"
    log_to_file "WARNING" "$message"
}

# Log ERROR level
log_error() {
    local message="$1"
    echo -e "${RED}[✗]${NC} $message"
    log_to_file "ERROR" "$message"
}

# Log DEBUG level
log_debug() {
    local message="$1"
    if [ "$VERBOSE" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $message"
    fi
    log_to_file "DEBUG" "$message"
}

# Log command execution
log_command() {
    local command="$1"
    log_debug "Executing: $command"
}

# Log command result
log_result() {
    local command="$1"
    local exit_code="$2"
    
    if [ "$exit_code" -eq 0 ]; then
        log_success "Command succeeded: $command"
    else
        log_error "Command failed with exit code $exit_code: $command"
    fi
}

# Finalize log
finalize_log() {
    if [ -n "$LOG_FILE" ]; then
        echo "" >> "$LOG_FILE"
        echo "Completed: $(date)" >> "$LOG_FILE"
    fi
    log_info "Log saved to: $LOG_FILE"
}

# Export functions
export -f log_info log_success log_warning log_error log_debug

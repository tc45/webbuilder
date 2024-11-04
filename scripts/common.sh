#!/bin/bash

# Get base directory from setup_new_django.sh location
BASE_DIR="$(pwd)"  # Where setup_new_django.sh is located
SCRIPT_DIR="${BASE_DIR}/scripts"  # Scripts directory under BASE_DIR
INSTALL_PATH="/opt/cursor/projects/${PROJECT_NAME,,}"  # Target installation directory
LOG_FILE="${BASE_DIR}/install.log"  # Log file in scripts directory

# Function to log messages with better formatting
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}] $1"
    
    # Ensure LOG_FILE exists and is writable
    if [ ! -f "$LOG_FILE" ]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        touch "$LOG_FILE"
        chmod 666 "$LOG_FILE"
    fi
    
    # Write to log file
    echo "$message" >> "$LOG_FILE"
    
    # Also display to console if not in a subshell
    if [ -t 1 ]; then
        echo "$message"
    fi
}

# Function to check and activate virtual environment
check_venv() {
    if [ ! -f "${INSTALL_PATH}/venv/bin/activate" ]; then
        log_message "ERROR: Virtual environment not found"
        exit 1
    fi
    source "${INSTALL_PATH}/venv/bin/activate"
}

# Function to verify required variables
verify_required_vars() {
    local required_vars=("PROJECT_NAME" "DOMAIN_NAME" "INSTALL_PATH" "ADMIN_USER" "ADMIN_PASSWORD" "DB_TYPE")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_message "ERROR: Required variable $var is not set"
            exit 1
        fi
    done
}

# Function to check script order
check_script_order() {
    local current_script="$1"
    
    # Skip check for setup_new_django.sh and 00_init.sh
    if [[ "$current_script" == "setup_new_django.sh" ]] || [[ "$current_script" == "00_init.sh" ]]; then
        return 0
    fi
    
    local expected_order=(
        "01_initial_setup.sh"
        "02_django_setup.sh"
        "03_settings_setup.sh"
        "04_templates_setup.sh"
        "05_database_setup.sh"
        "06_nginx_setup.sh"
        "07_gunicorn_setup.sh"
        "08_git_setup.sh"
        "09_next_steps.sh"
    )
    
    for script in "${expected_order[@]}"; do
        if [[ "$current_script" == *"$script" ]]; then
            return 0
        fi
    done
    
    log_message "WARNING: Script $current_script may be running out of order"
    return 1
}

# Add function to run initialization
run_init() {
    log_message "Running initialization script..."
    if [ -f "${SCRIPT_DIR}/00_init.sh" ]; then
        bash "${SCRIPT_DIR}/00_init.sh"
        return $?
    else
        log_message "ERROR: Initialization script not found"
        return 1
    fi
}

# Export functions so they're available to child scripts
export -f log_message
export -f check_venv
export -f verify_required_vars
export -f check_script_order
export -f run_init

# Initialize log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
    chmod 664 "$LOG_FILE"
fi

# Verify script execution order
current_script=$(basename "$0")
check_script_order "$current_script"
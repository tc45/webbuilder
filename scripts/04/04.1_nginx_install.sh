#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Nginx installation..."

# Check if Nginx is already installed
if command -v nginx >/dev/null 2>&1; then
    log_message "Nginx is already installed"
else
    # Install Nginx
    log_message "Installing Nginx..."
    sudo apt-get update >> "$LOG_FILE" 2>&1
    sudo apt-get install -y nginx >> "$LOG_FILE" 2>&1 || {
        handle_error 1 "Failed to install Nginx" "${BASH_SOURCE[0]}"
        exit 1
    }
fi

# Verify Nginx installation
nginx -v >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Nginx installation verification failed" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Nginx installation completed" 
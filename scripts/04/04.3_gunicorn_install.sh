#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Gunicorn installation..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Install Gunicorn if not already installed
if ! pip show gunicorn > /dev/null 2>&1; then
    log_message "Installing Gunicorn..."
    pip install gunicorn >> "$LOG_FILE" 2>&1 || {
        handle_error 1 "Failed to install Gunicorn" "${BASH_SOURCE[0]}"
        exit 1
    }
fi

# Verify Gunicorn installation
gunicorn --version >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Gunicorn installation verification failed" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Gunicorn installation completed" 
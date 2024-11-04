#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting pip setup..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Update pip
log_message "Updating pip..."
python -m pip install --upgrade pip >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to upgrade pip" "${BASH_SOURCE[0]}"
    exit 1
}

# Install basic packages
log_message "Installing basic Python packages..."
python -m pip install wheel setuptools >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to install basic packages" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Pip setup completed" 
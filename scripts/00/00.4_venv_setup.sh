#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting virtual environment setup..."

# Create virtual environment if it doesn't exist
if [ ! -d "${INSTALL_PATH}/venv" ]; then
    log_message "Creating virtual environment..."
    python${PYTHON_VERSION} -m venv "${INSTALL_PATH}/venv"
    
    # Ensure venv is owned by correct user
    sudo chown -R $USER:$USER "${INSTALL_PATH}/venv"
fi

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Update pip
log_message "Updating pip..."
python -m pip install --upgrade pip >> "$LOG_FILE" 2>&1

# Install wheel and setuptools
log_message "Installing wheel and setuptools..."
python -m pip install wheel setuptools >> "$LOG_FILE" 2>&1

log_message "Virtual environment setup completed" 
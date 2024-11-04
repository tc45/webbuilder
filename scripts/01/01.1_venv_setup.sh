#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting virtual environment setup..."

# Verify prerequisites
verify_prerequisites "python${PYTHON_VERSION}" || exit 1

# Create virtual environment if it doesn't exist
if [ ! -d "${INSTALL_PATH}/venv" ]; then
    log_message "Creating virtual environment..."
    python${PYTHON_VERSION} -m venv "${INSTALL_PATH}/venv" || {
        handle_error 1 "Failed to create virtual environment" "${BASH_SOURCE[0]}"
        exit 1
    }
fi

# Set proper permissions
set_standard_permissions "${INSTALL_PATH}/venv" "$USER" "$USER" "755"

log_message "Virtual environment setup completed" 
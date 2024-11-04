#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting permissions setup..."

# Set proper permissions for installation directory
sudo chown -R $USER:$USER "$INSTALL_PATH"
sudo chmod -R 755 "$INSTALL_PATH"

# Set specific permissions for key directories
sudo chmod 775 "${INSTALL_PATH}/src"
sudo chmod 775 "${INSTALL_PATH}/logs"

# Ensure log file is writable
sudo chmod 664 "$LOG_FILE"

log_message "Permissions setup completed" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting final permissions setup..."

# Set proper ownership for project files
log_message "Setting project file ownership..."
sudo chown -R $USER:$USER "$INSTALL_PATH"

# Set proper permissions for directories
log_message "Setting directory permissions..."
sudo find "$INSTALL_PATH" -type d -exec chmod 755 {} \;

# Set proper permissions for files
log_message "Setting file permissions..."
sudo find "$INSTALL_PATH" -type f -exec chmod 644 {} \;

# Set executable permissions for scripts
log_message "Setting script permissions..."
sudo chmod -R 755 "${INSTALL_PATH}/scripts"

# Set special permissions for sensitive files
log_message "Setting sensitive file permissions..."
sudo chmod 600 "${INSTALL_PATH}/.env"

# Set web server permissions
log_message "Setting web server permissions..."
sudo chown -R www-data:www-data "${INSTALL_PATH}/src/media"
sudo chown -R www-data:www-data "${INSTALL_PATH}/src/static"
sudo chmod -R 775 "${INSTALL_PATH}/src/media"
sudo chmod -R 775 "${INSTALL_PATH}/src/static"

# Set log directory permissions
log_message "Setting log permissions..."
sudo chown -R www-data:www-data "${INSTALL_PATH}/logs"
sudo chmod -R 775 "${INSTALL_PATH}/logs"

log_message "Final permissions setup completed" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting cleanup..."

# Remove temporary files
log_message "Removing temporary files..."
find "${INSTALL_PATH}" -type f -name "*.pyc" -delete
find "${INSTALL_PATH}" -type d -name "__pycache__" -exec rm -rf {} +
find "${INSTALL_PATH}" -type f -name ".DS_Store" -delete
find "${INSTALL_PATH}" -type f -name "*.swp" -delete

# Clean pip cache
log_message "Cleaning pip cache..."
source "${INSTALL_PATH}/venv/bin/activate"
pip cache purge >> "$LOG_FILE" 2>&1

# Remove installation artifacts
log_message "Removing installation artifacts..."
rm -f "${INSTALL_PATH}/src/create_superuser.py"
rm -f "${INSTALL_PATH}/src/*.bak"
rm -f "${INSTALL_PATH}/src/*.tmp"

# Compress logs
log_message "Compressing old logs..."
find "${INSTALL_PATH}/logs" -type f -name "*.log" -mtime +7 -exec gzip {} \;

log_message "Cleanup completed" 
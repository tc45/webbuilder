#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Creating Django project..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Change to source directory
cd "${INSTALL_PATH}/src"

# Create Django project
django-admin startproject ${PROJECT_NAME,,} . >> "$LOG_FILE" 2>&1 || {
    log_message "ERROR: Failed to create Django project"
    exit 1
}

log_message "Django project created successfully" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Creating Django apps..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Change to source directory
cd "${INSTALL_PATH}/src"

# Create the apps
for app in home accounts devices chat projects; do
    log_message "Creating $app app..."
    python manage.py startapp $app >> "$LOG_FILE" 2>&1 || {
        log_message "ERROR: Failed to create $app app"
        exit 1
    }
    mkdir -p ${app}/templates/${app}
done

log_message "Django apps created successfully" 
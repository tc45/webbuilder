#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting database migrations..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Change to project directory
cd "${INSTALL_PATH}/src"

# Make migrations
log_message "Creating migrations..."
python manage.py makemigrations >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to create migrations" "${BASH_SOURCE[0]}"
    exit 1
}

# Apply migrations
log_message "Applying migrations..."
python manage.py migrate >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to apply migrations" "${BASH_SOURCE[0]}"
    exit 1
}

# Verify migrations
log_message "Verifying migrations..."
python manage.py showmigrations >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to verify migrations" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Database migrations completed" 
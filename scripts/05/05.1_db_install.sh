#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting database installation..."

# Install database based on DB_TYPE
if [ "$DB_TYPE" = "postgres" ]; then
    log_message "Installing PostgreSQL..."
    
    # Install PostgreSQL
    sudo apt-get update >> "$LOG_FILE" 2>&1
    sudo apt-get install -y postgresql postgresql-contrib >> "$LOG_FILE" 2>&1 || {
        handle_error 1 "Failed to install PostgreSQL" "${BASH_SOURCE[0]}"
        exit 1
    }
    
    # Verify PostgreSQL installation
    if ! command -v psql &> /dev/null; then
        handle_error 1 "PostgreSQL installation verification failed" "${BASH_SOURCE[0]}"
        exit 1
    }
    
    # Start PostgreSQL service
    sudo systemctl start postgresql >> "$LOG_FILE" 2>&1
    sudo systemctl enable postgresql >> "$LOG_FILE" 2>&1
else
    log_message "Using SQLite, no installation needed"
fi

log_message "Database installation completed" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting database creation..."

if [ "$DB_TYPE" = "postgres" ]; then
    log_message "Creating PostgreSQL database..."
    
    # Create database and user
    sudo -u postgres psql << EOF >> "$LOG_FILE" 2>&1
CREATE DATABASE ${PROJECT_NAME,,};
CREATE USER ${PROJECT_NAME,,}user WITH PASSWORD '${ADMIN_PASSWORD}';
ALTER ROLE ${PROJECT_NAME,,}user SET client_encoding TO 'utf8';
ALTER ROLE ${PROJECT_NAME,,}user SET default_transaction_isolation TO 'read committed';
ALTER ROLE ${PROJECT_NAME,,}user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE ${PROJECT_NAME,,} TO ${PROJECT_NAME,,}user;
EOF
    
    if [ $? -ne 0 ]; then
        handle_error 1 "Failed to create PostgreSQL database" "${BASH_SOURCE[0]}"
        exit 1
    fi
else
    log_message "Creating SQLite database..."
    
    # Create SQLite database directory
    mkdir -p "${INSTALL_PATH}/src"
    touch "${INSTALL_PATH}/src/db.sqlite3"
    chmod 664 "${INSTALL_PATH}/src/db.sqlite3"
    sudo chown www-data:www-data "${INSTALL_PATH}/src/db.sqlite3"
fi

log_message "Database creation completed" 
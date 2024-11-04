#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting permissions setup functions..."

# Function to set standard directory permissions
set_standard_permissions() {
    local dir="$1"
    local owner="$2"
    local group="$3"
    local perms="$4"
    
    log_message "Setting permissions for $dir"
    sudo chown -R "$owner:$group" "$dir"
    sudo chmod -R "$perms" "$dir"
}

# Function to set web directory permissions
set_web_permissions() {
    local dir="$1"
    log_message "Setting web permissions for $dir"
    sudo chown -R www-data:www-data "$dir"
    sudo chmod -R 775 "$dir"
}

# Function to set secure file permissions
set_secure_file_permissions() {
    local file="$1"
    log_message "Setting secure permissions for $file"
    sudo chmod 600 "$file"
}

# Export functions
export -f set_standard_permissions
export -f set_web_permissions
export -f set_secure_file_permissions

log_message "Permission functions setup completed" 
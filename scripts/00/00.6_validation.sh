#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting validation functions setup..."

# Function to validate path exists
validate_path() {
    local path="$1"
    if [ ! -e "$path" ]; then
        log_message "ERROR: Path does not exist: $path"
        return 1
    fi
    return 0
}

# Function to validate directory is writable
validate_writable() {
    local dir="$1"
    if [ ! -w "$dir" ]; then
        log_message "ERROR: Directory not writable: $dir"
        return 1
    fi
    return 0
}

# Function to validate Python version
validate_python_version() {
    local required_version="$1"
    local current_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    
    if [[ "$current_version" < "$required_version" ]]; then
        log_message "ERROR: Python version $required_version or higher required"
        return 1
    fi
    return 0
}

# Export functions
export -f validate_path
export -f validate_writable
export -f validate_python_version

log_message "Validation functions setup completed" 
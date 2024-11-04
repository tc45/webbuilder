#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting error handling functions setup..."

# Function to handle errors
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local script_name="$3"
    
    log_message "ERROR in $script_name: $error_message (Code: $error_code)"
    
    case $error_code in
        1) log_message "General error occurred" ;;
        2) log_message "Missing dependency" ;;
        3) log_message "Permission denied" ;;
        4) log_message "File not found" ;;
        *) log_message "Unknown error occurred" ;;
    esac
    
    return $error_code
}

# Function to cleanup on error
cleanup_on_error() {
    local script_name="$1"
    log_message "Performing cleanup for failed script: $script_name"
    
    # Add cleanup tasks here
    # Example: remove temporary files
    rm -f /tmp/progress_*.txt
}

# Function to verify script prerequisites
verify_prerequisites() {
    local script_name="$1"
    log_message "Verifying prerequisites for: $script_name"
    
    # Check for required commands
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            handle_error 2 "Required command not found: $cmd" "$script_name"
            return 1
        fi
    done
    
    return 0
}

# Export functions
export -f handle_error
export -f cleanup_on_error
export -f verify_prerequisites

log_message "Error handling functions setup completed" 
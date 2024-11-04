#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting initial setup sequence..."

# Run initial setup scripts in order
for script in "${SCRIPT_DIR}"/01.[1-3]_*.sh; do
    if [ -f "$script" ]; then
        log_message "Running $(basename "$script")..."
        start_progress "$(basename "$script")"
        
        bash "$script" || {
            local exit_code=$?
            handle_error $exit_code "Failed to run $(basename "$script")" "${BASH_SOURCE[0]}"
            cleanup_on_error "${BASH_SOURCE[0]}"
            exit $exit_code
        }
        
        end_progress "$(basename "$script")"
    fi
done

log_message "Initial setup sequence completed"
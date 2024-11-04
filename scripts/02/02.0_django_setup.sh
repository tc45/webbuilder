#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Django setup sequence..."

# Run Django setup scripts in order
for script in "${SCRIPT_DIR}"/02.[1-3]_*.sh; do
    if [ -f "$script" ]; then
        log_message "Running $(basename "$script")..."
        bash "$script" || {
            log_message "ERROR: Failed to run $(basename "$script")"
            exit 1
        }
    fi
done

log_message "Django setup sequence completed" 
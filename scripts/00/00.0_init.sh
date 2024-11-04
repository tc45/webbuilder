#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting initialization sequence..."

# Run initialization scripts in order
for script in "${SCRIPT_DIR}"/00.[1-4]_*.sh; do
    if [ -f "$script" ]; then
        log_message "Running $(basename "$script")..."
        source "$script" || {
            log_message "ERROR: Failed to run $(basename "$script")"
            exit 1
        }
    fi
done

log_message "Initialization sequence completed"
log_message "Project: $PROJECT_NAME"
log_message "Domain: $DOMAIN_NAME"
log_message "Install Path: $INSTALL_PATH" 
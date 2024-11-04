#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")/scripts"
source "${SCRIPT_DIR}/common.sh"

# Verify required variables
verify_required_vars


# Create installation directory if it doesn't exist
# if [ ! -d "$INSTALL_PATH" ]; then
#     log_message "Installation directory exists at ${INSTALL_PATH}..."
#     sudo mkdir -p "$INSTALL_PATH"
#     sudo chown -R $USER:$USER "$INSTALL_PATH"
# fi

# Create virtual environment if it doesn't exist
if [ ! -d "${INSTALL_PATH}/venv" ]; then
    log_message "Creating virtual environment..."
    python${PYTHON_VERSION} -m venv "${INSTALL_PATH}/venv"
fi

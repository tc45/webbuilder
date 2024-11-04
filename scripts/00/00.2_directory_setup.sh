#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting directory structure setup..."

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_PATH" ]; then
    log_message "Creating installation directory at ${INSTALL_PATH}..."
    sudo mkdir -p "$INSTALL_PATH"
fi

# Create project structure
log_message "Creating project directory structure..."
mkdir -p "${INSTALL_PATH}"/{src,logs}
mkdir -p "${INSTALL_PATH}/src"/{static,media,templates}
mkdir -p "${INSTALL_PATH}/src/static"/{css,js,img}
mkdir -p "${INSTALL_PATH}/src/templates"/{base,home,accounts,devices,chat,projects}

log_message "Directory structure setup completed" 
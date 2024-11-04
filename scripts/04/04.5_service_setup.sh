#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting service setup..."

# Create systemd service file
log_message "Creating systemd service file..."
sudo tee "/etc/systemd/system/${PROJECT_NAME,,}.service" > /dev/null << EOF
[Unit]
Description=${PROJECT_NAME} Django Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=${INSTALL_PATH}/src
Environment="PATH=${INSTALL_PATH}/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="DJANGO_SETTINGS_MODULE=${PROJECT_NAME,,}.settings.production"
ExecStart=${INSTALL_PATH}/venv/bin/gunicorn \
    --config ${INSTALL_PATH}/src/gunicorn/gunicorn.conf.py \
    ${PROJECT_NAME,,}.wsgi:application
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
log_message "Reloading systemd daemon..."
sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to reload systemd daemon" "${BASH_SOURCE[0]}"
    exit 1
}

# Enable service
log_message "Enabling service..."
sudo systemctl enable "${PROJECT_NAME,,}" >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to enable service" "${BASH_SOURCE[0]}"
    exit 1
}

# Start service
log_message "Starting service..."
sudo systemctl start "${PROJECT_NAME,,}" >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to start service" "${BASH_SOURCE[0]}"
    exit 1
}

# Check service status
log_message "Checking service status..."
sudo systemctl status "${PROJECT_NAME,,}" >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Service status check failed" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Service setup completed" 
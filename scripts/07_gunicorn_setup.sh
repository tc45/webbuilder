#!/bin/bash

log_message "Starting Gunicorn Setup..."

# Create Gunicorn systemd service file
log_message "Creating Gunicorn systemd service file..."
sudo tee /etc/systemd/system/${PROJECT_NAME,,}.service > /dev/null << EOF
[Unit]
Description=$PROJECT_NAME Django Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=$INSTALL_PATH/src
Environment="PATH=$INSTALL_PATH/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="DJANGO_SETTINGS_MODULE=${PROJECT_NAME,,}.settings.development"
ExecStart=$INSTALL_PATH/venv/bin/gunicorn ${PROJECT_NAME,,}.wsgi:application --bind 0.0.0.0:${DJANGO_PORT:-8000} --workers 3
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
log_message "Reloading systemd daemon..."
sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1

log_message "Enabling Gunicorn service..."
sudo systemctl enable ${PROJECT_NAME,,} >> "$LOG_FILE" 2>&1

log_message "Starting Gunicorn service..."
sudo systemctl start ${PROJECT_NAME,,} >> "$LOG_FILE" 2>&1

log_message "Checking Gunicorn service status..."
sudo systemctl status ${PROJECT_NAME,,} >> "$LOG_FILE" 2>&1

# After starting Gunicorn service
if ! sudo systemctl is-active --quiet ${PROJECT_NAME,,}; then
    log_message "ERROR: Failed to start Gunicorn service"
    log_message "$(sudo systemctl status ${PROJECT_NAME,,})"
    exit 1
fi

log_message "Gunicorn Setup completed successfully"
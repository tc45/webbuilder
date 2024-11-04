#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Nginx configuration..."

# Create Nginx configuration
log_message "Creating Nginx configuration..."
sudo tee "/etc/nginx/sites-available/${PROJECT_NAME,,}" > /dev/null << EOF
upstream ${PROJECT_NAME,,}_app {
    server 127.0.0.1:8001;
}

server {
    listen 80;
    server_name $DOMAIN_NAME;
    client_max_body_size 100M;

    # Logging configuration
    access_log /var/log/nginx/${PROJECT_NAME,,}_access.log;
    error_log /var/log/nginx/${PROJECT_NAME,,}_error.log;

    location /static/ {
        alias ${INSTALL_PATH}/src/static/;
    }

    location /media/ {
        alias ${INSTALL_PATH}/src/media/;
    }

    location / {
        proxy_pass http://${PROJECT_NAME,,}_app;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Create symbolic link
log_message "Creating symbolic link..."
sudo ln -sf "/etc/nginx/sites-available/${PROJECT_NAME,,}" "/etc/nginx/sites-enabled/${PROJECT_NAME,,}"

# Test Nginx configuration
log_message "Testing Nginx configuration..."
sudo nginx -t >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Nginx configuration test failed" "${BASH_SOURCE[0]}"
    exit 1
}

# Restart Nginx
log_message "Restarting Nginx..."
sudo systemctl restart nginx >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to restart Nginx" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Nginx configuration completed" 
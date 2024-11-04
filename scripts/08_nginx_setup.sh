#!/bin/bash

# Nginx Setup Script
# This script configures Nginx as a reverse proxy for the Django application
# It creates the necessary server blocks and sets up static/media file serving

# Log start of script
log_message "Starting Nginx Setup..."

# Enable immediate exit on any error
set -e

# Function to report progress back to the installation status display
# Progress is reported as percentage complete (0-100)
update_progress() {
    echo "PROGRESS:$1" >&2
    log_message "Progress: $1%"
}

# Debug output to help track the issue
log_message "DEBUG: Current environment:"
log_message "PROJECT_NAME=${PROJECT_NAME}"
log_message "DOMAIN_NAME=${DOMAIN_NAME}"
log_message "INSTALL_PATH=${INSTALL_PATH}"


log_message "DEBUG: Checking for existing configurations..."

# Verify all required environment variables are set
# PROJECT_NAME - Used for config file naming and upstream definition
# DOMAIN_NAME - The domain name that Nginx will listen for
# INSTALL_PATH - Base path where static/media files are located
if [ -z "$PROJECT_NAME" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$INSTALL_PATH" ]; then
    log_message "ERROR: Required variables not set"
    echo "ERROR: Required variables not set" >&2
    exit 1
fi

update_progress 20

# Remove any existing Nginx configurations for this project
# This ensures we start with a clean slate and avoid conflicts
log_message "Removing any existing Nginx configurations..."
if [ -f "/etc/nginx/sites-enabled/${PROJECT_NAME,,}" ]; then
    log_message "DEBUG: Removing existing enabled site"
    sudo rm -f "/etc/nginx/sites-enabled/${PROJECT_NAME,,}"
fi

if [ -f "/etc/nginx/sites-available/${PROJECT_NAME,,}" ]; then
    log_message "DEBUG: Removing existing available site"
    sudo rm -f "/etc/nginx/sites-available/${PROJECT_NAME,,}"
fi


log_message "DEBUG: Creating new Nginx configuration..."

update_progress 40

# Create new Nginx configuration
# This sets up:
# - Upstream server definition for Gunicorn
# - Server block listening on port 80
# - Static and media file locations
# - Proxy settings for Django application
NGINX_CONF="/etc/nginx/sites-available/${PROJECT_NAME,,}"
log_message "Creating new Nginx configuration at ${NGINX_CONF}"

if ! sudo tee "$NGINX_CONF" > /dev/null << EOF
upstream ${PROJECT_NAME,,}_app {
    server 127.0.0.1:${DJANGO_PORT:-8000};
}

server {
    listen 80;
    server_name $DOMAIN_NAME;
    client_max_body_size 100M;

    # Logging configuration
    access_log /var/log/nginx/${PROJECT_NAME,,}_access.log;
    error_log /var/log/nginx/${PROJECT_NAME,,}_error.log;

    location /static/ {
        alias $INSTALL_PATH/src/static/;
    }

    location /media/ {
        alias $INSTALL_PATH/src/media/;
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
then
    log_message "ERROR: Failed to create Nginx configuration file"
    exit 1
fi

# Verify configuration file was created
if [ ! -f "$NGINX_CONF" ]; then
    log_message "ERROR: Failed to create Nginx configuration file"
    exit 1
fi

log_message "DEBUG: Configuration file contents:"
log_message "$(cat $NGINX_CONF)"

update_progress 60

# Create symbolic link and verify
log_message "Creating symbolic link for Nginx configuration..."
NGINX_ENABLED="/etc/nginx/sites-enabled/${PROJECT_NAME,,}"
log_message "DEBUG: Linking ${NGINX_CONF} to ${NGINX_ENABLED}"

# Check for and clean up invalid configurations
log_message "DEBUG: Checking for invalid configurations in sites-enabled..."
if [ -d "/etc/nginx/sites-enabled" ]; then
    # Remove any directory that might have been accidentally created
    if [ -d "/etc/nginx/sites-enabled/sites-available" ]; then
        log_message "DEBUG: Removing invalid sites-available directory from sites-enabled"
        sudo rm -rf "/etc/nginx/sites-enabled/sites-available"
    fi
    
    # Check for broken symlinks
    for link in /etc/nginx/sites-enabled/*; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
            log_message "DEBUG: Removing broken symlink: $link"
            sudo rm -f "$link"
        fi
    done
fi

# Create our new symlink
log_message "DEBUG: Creating new symlink for ${PROJECT_NAME,,}"
sudo ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

# Verify symbolic link
if [ ! -L "$NGINX_ENABLED" ]; then
    log_message "ERROR: Failed to create symbolic link"
    exit 1
fi

if [ ! "$(readlink -f "$NGINX_ENABLED")" = "$NGINX_CONF" ]; then
    log_message "ERROR: Symbolic link points to wrong location"
    log_message "DEBUG: Expected: $NGINX_CONF"
    log_message "DEBUG: Actual: $(readlink -f "$NGINX_ENABLED")"
    exit 1
fi

update_progress 80

# Test configuration
log_message "DEBUG: Testing Nginx configuration..."

# Capture Nginx test output with full error details
NGINX_TEST_OUTPUT=$(sudo nginx -t 2>&1)
NGINX_TEST_RESULT=$?

# Log the complete test output
log_message "Nginx Configuration Test Results"
log_message "════════════════════════════════"
log_message "$NGINX_TEST_OUTPUT"
log_message "════════════════════════════════"

if [ $NGINX_TEST_RESULT -ne 0 ]; then
    log_message "ERROR: Nginx configuration test failed with exit code $NGINX_TEST_RESULT"
    log_message "DEBUG: Current Nginx configuration:"
    log_message "$(cat $NGINX_CONF)"
    log_message "DEBUG: Current Nginx sites-enabled directory contents:"
    log_message "$(ls -la /etc/nginx/sites-enabled/)"
    # Output the error to both log and stderr
    echo "$NGINX_TEST_OUTPUT" >&2
    log_message "$NGINX_TEST_OUTPUT"
    exit 1
fi

# Restart Nginx
log_message "DEBUG: Restarting Nginx..."
NGINX_RESTART_OUTPUT=$(sudo systemctl restart nginx 2>&1)
NGINX_RESTART_RESULT=$?

if [ $NGINX_RESTART_RESULT -ne 0 ]; then
    log_message "ERROR: Failed to restart Nginx with exit code $NGINX_RESTART_RESULT"
    log_message "DEBUG: Restart command output:"
    log_message "$NGINX_RESTART_OUTPUT"
    log_message "DEBUG: Nginx status:"
    log_message "$(sudo systemctl status nginx)"
    log_message "DEBUG: Nginx error log after restart attempt:"
    log_message "$(sudo tail -n 50 /var/log/nginx/error.log)"
    exit 1
fi

# Verify Nginx is running
if ! sudo systemctl is-active --quiet nginx; then
    log_message "ERROR: Nginx is not running after restart"
    log_message "DEBUG: Nginx status:"
    log_message "$(sudo systemctl status nginx)"
    exit 1
fi

update_progress 100
log_message "Nginx Setup completed successfully"
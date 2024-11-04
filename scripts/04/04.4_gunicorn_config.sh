#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Gunicorn configuration..."

# Create Gunicorn configuration directory
sudo mkdir -p "${INSTALL_PATH}/src/gunicorn"

# Create Gunicorn configuration file
log_message "Creating Gunicorn configuration..."
cat > "${INSTALL_PATH}/src/gunicorn/gunicorn.conf.py" << EOF
# Gunicorn configuration file
import multiprocessing

# Server socket
bind = "0.0.0.0:8001"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
worker_connections = 1000
timeout = 30
keepalive = 2

# Logging
accesslog = '${INSTALL_PATH}/logs/gunicorn_access.log'
errorlog = '${INSTALL_PATH}/logs/gunicorn_error.log'
loglevel = 'info'

# Process naming
proc_name = '${PROJECT_NAME,,}'

# Server mechanics
daemon = False
pidfile = '${INSTALL_PATH}/gunicorn.pid'
user = 'www-data'
group = 'www-data'

# SSL
keyfile = None
certfile = None

# Server hooks
def on_starting(server):
    server.log.info("Starting Gunicorn server for ${PROJECT_NAME}")

def on_reload(server):
    server.log.info("Reloading Gunicorn server for ${PROJECT_NAME}")

def on_exit(server):
    server.log.info("Stopping Gunicorn server for ${PROJECT_NAME}")
EOF

log_message "Gunicorn configuration completed" 
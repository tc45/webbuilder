#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting environment setup..."

# Verify and export required variables
verify_required_vars

# Generate a secure SECRET_KEY
log_message "Generating Django secret key..."
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' 2>/dev/null || echo "django-insecure-temporary-key")

# Create .env file
log_message "Creating .env file..."
cat > "${INSTALL_PATH}/.env" << EOF
SECRET_KEY='${SECRET_KEY}'
DEBUG=$DEBUG_MODE
ALLOWED_HOSTS=$DOMAIN_NAME,localhost,127.0.0.1
PROJECT_NAME=$PROJECT_NAME
DB_TYPE=$DB_TYPE
ADMIN_USER=$ADMIN_USER
DOMAIN_NAME=$DOMAIN_NAME
EOF

log_message "Environment setup completed" 
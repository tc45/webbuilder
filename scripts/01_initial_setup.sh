#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Initial Setup..."

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate"

# Update pip first
log_message "Updating pip..."
python -m pip install --upgrade pip >> "$LOG_FILE" 2>&1

# Install wheel and setuptools first
log_message "Installing wheel and setuptools..."
python -m pip install wheel setuptools >> "$LOG_FILE" 2>&1

# Create and install requirements
log_message "Creating requirements.txt..."
cat > "${INSTALL_PATH}/requirements.txt" << 'EOF'
Django==5.0.2
python-dotenv==1.0.0
python-decouple==3.8
gunicorn==21.2.0
psycopg2-binary==2.9.9
django-allauth==0.61.0
django-encrypted-model-fields==0.6.5
ansible==9.1.0
ansible-runner==2.3.4
openai==1.12.0
netmiko==4.3.0
pytest==8.0.0
pytest-django==4.7.0
black==24.1.1
flake8==7.0.0
coverage==7.4.1
django-crispy-forms==2.1
crispy-bootstrap5==2023.10
EOF

# Install requirements
log_message "Installing Python requirements..."
python -m pip install -r "${INSTALL_PATH}/requirements.txt" >> "$LOG_FILE" 2>&1

# Add after pip install requirements
if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to install requirements"
    exit 1
fi

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
EOF
log_message "Initial Setup completed successfully"
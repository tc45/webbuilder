#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting requirements installation..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Create requirements.txt
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
python -m pip install -r "${INSTALL_PATH}/requirements.txt" >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to install requirements" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Requirements installation completed" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting superuser creation..."

# Activate virtual environment
source "${INSTALL_PATH}/venv/bin/activate"

# Change to project directory
cd "${INSTALL_PATH}/src"

# Create superuser script
cat > create_superuser.py << EOF
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME,,}.settings.development')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

try:
    if not User.objects.filter(username='${ADMIN_USER}').exists():
        User.objects.create_superuser(
            username='${ADMIN_USER}',
            email='${ADMIN_USER}@${DOMAIN_NAME}',
            password='${ADMIN_PASSWORD}'
        )
        print('Superuser created successfully')
    else:
        print('Superuser already exists')
except Exception as e:
    print(f'Error creating superuser: {e}')
    exit(1)
EOF

# Execute superuser creation script
log_message "Creating superuser..."
python create_superuser.py >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to create superuser" "${BASH_SOURCE[0]}"
    exit 1
}

# Clean up
rm create_superuser.py

log_message "Superuser creation completed" 
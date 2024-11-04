#!/bin/bash

log_message "Starting Database Setup..."

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate" >> "$LOG_FILE" 2>&1 || {
    log_message "ERROR: Failed to activate virtual environment"
    exit 1
}

# Set the Django settings module
export DJANGO_SETTINGS_MODULE="${PROJECT_NAME,,}.settings.development"
log_message "Using settings module: $DJANGO_SETTINGS_MODULE"

# After creating all settings files, test the configuration
# Change to the source directory
log_message "Testing Django configuration..."
cd "${INSTALL_PATH}/src" >> "$LOG_FILE" 2>&1 || {
    log_message "ERROR: Failed to change to source directory"
    exit 1
}

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate" >> "$LOG_FILE" 2>&1 || {
    log_message "ERROR: Failed to activate virtual environment"
    exit 1
}

# Test Django configuration
cd "${INSTALL_PATH}/src" >> "$LOG_FILE" 2>&1 || {
    log_message "ERROR: Failed to change to project directory - ${INSTALL_PATH}/src"
    exit 1
}

# Test Django configuration
log_message "Testing Django configuration..."
if ! python manage.py check >> "$LOG_FILE" 2>&1; then
    log_message "ERROR: Django configuration check failed"
    exit 1
fi

# Run migrations
log_message "Running migrations..."
python manage.py migrate --verbosity 2 >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to apply migrations. Check the log file for details:"

    exit 1
fi

# Make migrations
log_message "Making migrations..."
python manage.py makemigrations --verbosity 2 >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to make migrations"
    exit 1
fi

# Run collectstatic
log_message "Running collectstatic..."
cd "${INSTALL_PATH}/src"
python manage.py collectstatic --noinput >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to collect static files"
    exit 1
fi


# Create superuser
log_message "Creating Django superuser..."
SUPERUSER_SCRIPT="${INSTALL_PATH}/src/create_superuser.py"

cat > "$SUPERUSER_SCRIPT" << EOF
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME,,}.settings.development')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

ADMIN_USERNAME = '$ADMIN_USER'
ADMIN_EMAIL = '$ADMIN_USER@${DOMAIN_NAME}'
ADMIN_PASSWORD = '$ADMIN_PASSWORD'

try:
    if not User.objects.filter(username=ADMIN_USERNAME).exists():
        User.objects.create_superuser(
            username=ADMIN_USERNAME,
            email=ADMIN_EMAIL,
            password=ADMIN_PASSWORD
        )
        print(f'Superuser created successfully: {ADMIN_USERNAME}')
    else:
        print('Superuser already exists')
except Exception as e:
    print(f'Error creating superuser: {str(e)}')
    exit(1)
EOF

# Execute the superuser creation script with output capture
python "$SUPERUSER_SCRIPT" >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to create superuser"
    rm "$SUPERUSER_SCRIPT"
    exit 1
fi

# Clean up
rm "$SUPERUSER_SCRIPT"

# Final test of Django admin interface
log_message "Testing Django admin interface..."
(
    python manage.py runserver 8002 >> "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    sleep 5
    
    if curl -s http://localhost:8002/admin/ > /dev/null; then
        log_message "Django admin interface test successful"
        kill $SERVER_PID
    else
        log_message "ERROR: Django admin interface test failed"
        kill $SERVER_PID
        exit 1
    fi
)

log_message "Database Setup completed successfully"
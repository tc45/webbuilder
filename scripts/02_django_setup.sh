#!/bin/bash

log_message "Starting Django Setup..."

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate"

# Create src directory
log_message "Creating src directory..."
mkdir -p "${INSTALL_PATH}/src"
cd "${INSTALL_PATH}/src"

# Create Django project
log_message "Creating Django project..."
django-admin startproject ${PROJECT_NAME,,} . >> "$LOG_FILE" 2>&1


# Create the apps
log_message "Creating Django apps..."
for app in home accounts devices chat projects; do
    log_message "Creating $app app..."
    # First create the app
    python "${INSTALL_PATH}/src/manage.py" startapp $app >> "$LOG_FILE" 2>&1
    mkdir -p "${INSTALL_PATH}/src/${app}/templates/${app}"
done



# # Create home app views and URLs
# log_message "Setting up home app..."
# cat > home/views.py << 'EOF'
# from django.shortcuts import render

# def index(request):
#     return render(request, 'home/index.html')
# EOF

# cat > home/urls.py << 'EOF'
# from django.urls import path
# from . import views

# app_name = 'home'

# urlpatterns = [
#     path('', views.index, name='index'),
# ]
# EOF

# Generate a secure SECRET_KEY
log_message "Generating Django secret key..."
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())' 2>/dev/null || echo "django-insecure-temporary-key")


# Create .env file
log_message "Creating .env file..."
cat > "${INSTALL_PATH}/src/.env" << EOF
SECRET_KEY='${SECRET_KEY}'
DEBUG=$DEBUG_MODE
ALLOWED_HOSTS=$DOMAIN_NAME,localhost,127.0.0.1
PROJECT_NAME=$PROJECT_NAME
EOF

# Create remaining project structure
log_message "Creating remaining project directory structure..."
mkdir -p "${INSTALL_PATH}"/{logs,scripts}
mkdir -p "${INSTALL_PATH}/src"/{static,media,templates}

log_message "Initialization complete"
log_message "Project: $PROJECT_NAME"
log_message "Domain: $DOMAIN_NAME"
log_message "Install Path: $INSTALL_PATH" 

log_message "Django Setup completed successfully"
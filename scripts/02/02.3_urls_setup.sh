#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Setting up URL configurations..."

# Create URLs for each app
for app in home accounts devices chat projects; do
    log_message "Creating URLs for $app..."
    cat > "${INSTALL_PATH}/src/${app}/urls.py" << EOF
from django.urls import path
from . import views

app_name = '${app}'

urlpatterns = [
]
EOF
done

# Create main URLs file
log_message "Creating main URLs configuration..."
cat > "${INSTALL_PATH}/src/${PROJECT_NAME,,}/urls.py" << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('home.urls')),
    path('accounts/', include('allauth.urls')),
    path('devices/', include('devices.urls')),
    path('chat/', include('chat.urls')),
    path('projects/', include('projects.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
EOF

log_message "URL configurations completed" 
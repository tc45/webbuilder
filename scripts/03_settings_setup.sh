#!/bin/bash

log_message "Starting Settings Setup..."

# Create settings directory structure
log_message "Creating settings directory structure..."
cd "${INSTALL_PATH}/src/${PROJECT_NAME,,}"
mkdir -p settings
touch settings/__init__.py

log_message "Creating base settings..."
cat > settings/base.py << EOF
import os
from pathlib import Path
from decouple import config

BASE_DIR = Path(__file__).resolve().parent.parent.parent

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

SECRET_KEY = config('SECRET_KEY', default='your-secret-key-here')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'crispy_forms',
    'crispy_bootstrap5',
    'allauth',
    'allauth.account',
    
    # Local apps
    'home',
    'accounts',
    'devices',
    'chat',
    'projects',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'allauth.account.middleware.AccountMiddleware',
]

ROOT_URLCONF = '${PROJECT_NAME,,}.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = '${PROJECT_NAME,,}.wsgi.application'

# Database configuration
EOF

# Add database configuration based on DB_TYPE
if [ "$DB_TYPE" = "postgres" ]; then
    cat >> settings/base.py << EOF
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '${PROJECT_NAME,,}',
        'USER': '${PROJECT_NAME,,}user',
        'PASSWORD': '$ADMIN_PASSWORD',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
EOF
else
    cat >> settings/base.py << EOF
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
EOF
fi

# Continue with rest of base settings
cat >> settings/base.py << EOF

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files configuration
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static_root')
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, 'static'),
]

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Crispy Forms
CRISPY_ALLOWED_TEMPLATE_PACKS = "bootstrap5"
CRISPY_TEMPLATE_PACK = "bootstrap5"

# Authentication
LOGIN_URL = 'account_login'
LOGIN_REDIRECT_URL = 'home:index'
LOGOUT_REDIRECT_URL = 'home:index'

# AllAuth Configuration
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
]

ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_EMAIL_VERIFICATION = 'mandatory'
ACCOUNT_LOGIN_ATTEMPTS_LIMIT = 5
ACCOUNT_LOGIN_ATTEMPTS_TIMEOUT = 300
EOF

log_message "Creating development settings..."
cat > settings/development.py << EOF
from .base import *

DEBUG = $DEBUG_MODE
ALLOWED_HOSTS = ['$DOMAIN_NAME', '0.0.0.0','localhost', '127.0.0.1']

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
EOF

log_message "Creating production settings..."
cat > settings/production.py << EOF
from .base import *

DEBUG = False
ALLOWED_HOSTS = ['$DOMAIN_NAME']

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
EOF

log_message "Updating settings/__init__.py..."
cat > settings/__init__.py << EOF
from .development import *
EOF

# Update main settings.py to import modular settings
log_message "Updating main settings.py..."
cat > "${INSTALL_PATH}/src/${PROJECT_NAME,,}/settings.py" << EOF
"""
Django settings for ${PROJECT_NAME} project.
Import all settings from the modular settings files.
"""

from .settings.base import *

try:
    from .settings.development import *
except ImportError:
    pass
EOF

log_message "Settings Setup completed successfully"
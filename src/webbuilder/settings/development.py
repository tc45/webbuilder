from .base import *

DEBUG = True
ALLOWED_HOSTS = ['webbuilder.ddns.net', '0.0.0.0','localhost', '127.0.0.1']

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

#!/bin/bash

log_message "Starting Templates Setup..."

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate"

# Navigate to templates directory
log_message "Setting up templates directory..."
cd "${INSTALL_PATH}/src"

# Create base template
log_message "Creating base template..."
cat > templates/base.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}${PROJECT_NAME}{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{% url 'home:index' %}">${PROJECT_NAME}</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    {% if user.is_authenticated %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'devices:list' %}">Devices</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'projects:list' %}">Projects</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'chat:list' %}">Chat</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'account_logout' %}">Logout</a>
                        </li>
                    {% else %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'account_login' %}">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'account_signup' %}">Sign Up</a>
                        </li>
                    {% endif %}
                </ul>
            </div>
        </div>
    </nav>

    <main class="container mt-4">
        {% if messages %}
            {% for message in messages %}
                <div class="alert alert-{{ message.tags }} alert-dismissible fade show">
                    {{ message }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            {% endfor %}
        {% endif %}
        
        {% block content %}{% endblock %}
    </main>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    {% block extra_js %}{% endblock %}
</body>
</html>
EOF

# Create home template
log_message "Creating home template..."
cat > ${INSTALL_PATH}/src/home/templates/home/index.html << EOF
{% extends 'base.html' %}

{% block title %}${PROJECT_NAME} - Home{% endblock %}

{% block content %}
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8 text-center">
            <h1 class="display-4 mb-4">Welcome to ${PROJECT_NAME}</h1>
            <p class="lead">Your intelligent network management solution</p>
            
            {% if not user.is_authenticated %}
            <div class="mt-5">
                <a href="{% url 'account_login' %}" class="btn btn-primary btn-lg mx-2">Login</a>
                <a href="{% url 'account_signup' %}" class="btn btn-outline-primary btn-lg mx-2">Sign Up</a>
            </div>
            {% endif %}
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create URLs and templates for each app
log_message "Setting up URL configurations and templates..."
for app in home accounts devices chat projects; do
    log_message "Creating URLs and templates for $app..."
    
    # Create urls.py
    cat > "${INSTALL_PATH}/src/${app}/urls.py" << EOF
from django.urls import path
from . import views

app_name = '${app}'

urlpatterns = [
    path('', views.index, name='index'),
]
EOF
    
    log_message "Creating views for $app..."
    # Create views.py
    cat > "${INSTALL_PATH}/src/${app}/views.py" << EOF
from django.shortcuts import render

def index(request):
    return render(request, '${app}/index.html')
EOF

    log_message "Creating default template for $app..."
    # Create index.html template
    cat > "${INSTALL_PATH}/src/${PROJECT_NAME,,}/${app}/templates/${app}/index.html" << EOF
{% extends 'base.html' %}

{% block content %}
<h1>${PROJECT_NAME} - ${app^}</h1>
<p>Welcome to the ${app} section.</p>
{% endblock %}
EOF
done

# Create main URLs file
log_message "Creating main URLs configuration..."
cat > ${PROJECT_NAME,,}/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('home.urls')),
    path('accounts/', include('accounts.urls')),
    path('devices/', include('devices.urls')),
    path('chat/', include('chat.urls')),
    path('projects/', include('projects.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
EOF



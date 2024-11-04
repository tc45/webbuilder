#!/bin/bash

log_message "Starting Templates Setup..."

# Activate virtual environment
log_message "Activating virtual environment..."
source "${INSTALL_PATH}/venv/bin/activate"

# Navigate to templates directory
log_message "Setting up templates directory..."
cd "${INSTALL_PATH}/src"

# Create templates directory structure
log_message "Creating templates directory structure..."
mkdir -p "${INSTALL_PATH}/src/templates/partials"

# Create header template
log_message "Creating header template..."
cat > "${INSTALL_PATH}/src/templates/partials/header.html" << EOF
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="{% url 'home:index' %}">
            <i class="fas fa-network-wired me-2"></i>${PROJECT_NAME}
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link {% if request.resolver_match.url_name == 'index' %}active{% endif %}" 
                       href="{% url 'home:index' %}">
                        <i class="fas fa-home me-2"></i>Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {% if 'devices' in request.path %}active{% endif %}" 
                       href="{% url 'devices:index' %}">
                        <i class="fas fa-server me-2"></i>Devices
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {% if 'projects' in request.path %}active{% endif %}" 
                       href="{% url 'projects:index' %}">
                        <i class="fas fa-project-diagram me-2"></i>Projects
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {% if 'chat' in request.path %}active{% endif %}" 
                       href="{% url 'chat:index' %}">
                        <i class="fas fa-comments me-2"></i>Chat
                    </a>
                </li>
            </ul>
            <ul class="navbar-nav ms-auto">
                {% if user.is_authenticated %}
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle me-2"></i>{{ user.username }}
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="{% url 'accounts:profile' %}">
                                <i class="fas fa-cog me-2"></i>Settings
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="{% url 'account_logout' %}">
                                <i class="fas fa-sign-out-alt me-2"></i>Logout
                            </a></li>
                        </ul>
                    </li>
                {% else %}
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'account_login' %}">
                            <i class="fas fa-sign-in-alt me-2"></i>Login
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'account_signup' %}">
                            <i class="fas fa-user-plus me-2"></i>Sign Up
                        </a>
                    </li>
                {% endif %}
            </ul>
        </div>
    </div>
</nav>
EOF

# Create footer template
log_message "Creating footer template..."
cat > "${INSTALL_PATH}/src/templates/partials/footer.html" << EOF
<footer class="footer mt-auto py-3 bg-dark text-white">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-md-4">
                <small>
                    <i class="fas fa-network-wired me-2"></i>
                    Intelligent Network Management
                </small>
            </div>
            <div class="col-md-4 text-center">
                <small>
                    <a href="#" class="text-white text-decoration-none me-2">About</a>
                    <a href="#" class="text-white text-decoration-none me-2">Terms</a>
                    <a href="#" class="text-white text-decoration-none">Privacy</a>
                </small>
            </div>
            <div class="col-md-4 text-end">
                <small>&copy; 2024 ${PROJECT_NAME}</small>
            </div>
        </div>
    </div>
</footer>
EOF

# Create base template
log_message "Creating base template..."
cat > "${INSTALL_PATH}/src/templates/base.html" << EOF
<!DOCTYPE html>
<html lang="en" class="h-100">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}${PROJECT_NAME}{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    {% block extra_css %}{% endblock %}
</head>
<body class="d-flex flex-column h-100">
    {% include 'partials/header.html' %}

    <main class="flex-shrink-0">
        <div class="container mt-4">
            {% if messages %}
                {% for message in messages %}
                    <div class="alert alert-{{ message.tags }} alert-dismissible fade show">
                        {{ message }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                {% endfor %}
            {% endif %}
            
            {% block content %}{% endblock %}
        </div>
    </main>

    {% include 'partials/footer.html' %}
    
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
<div class="px-4 py-5 my-5 text-center">
    <h1 class="display-4 fw-bold text-body-emphasis">Welcome to ${PROJECT_NAME}</h1>
    <div class="col-lg-6 mx-auto">
        <p class="lead mb-4">Streamline your network management with our intelligent solution. Monitor devices, manage projects, and collaborate in real-time.</p>
        <div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
            {% if not user.is_authenticated %}
                <a href="{% url 'account_signup' %}" class="btn btn-primary btn-lg px-4 gap-3">Get Started</a>
                <a href="{% url 'account_login' %}" class="btn btn-outline-secondary btn-lg px-4">Login</a>
            {% else %}
                <a href="{% url 'devices:index' %}" class="btn btn-primary btn-lg px-4 gap-3">View Devices</a>
                <a href="{% url 'projects:index' %}" class="btn btn-outline-secondary btn-lg px-4">Manage Projects</a>
            {% endif %}
        </div>
    </div>
</div>

<div class="container px-4 py-5">
    <div class="row g-4 py-5 row-cols-1 row-cols-lg-3">
        <div class="col d-flex align-items-start">
            <div class="icon-square text-body-emphasis bg-body-secondary d-inline-flex align-items-center justify-content-center fs-4 flex-shrink-0 me-3">
                <i class="fas fa-server"></i>
            </div>
            <div>
                <h3 class="fs-2 text-body-emphasis">Device Management</h3>
                <p>Monitor and manage all your network devices from a single dashboard.</p>
            </div>
        </div>
        <div class="col d-flex align-items-start">
            <div class="icon-square text-body-emphasis bg-body-secondary d-inline-flex align-items-center justify-content-center fs-4 flex-shrink-0 me-3">
                <i class="fas fa-project-diagram"></i>
            </div>
            <div>
                <h3 class="fs-2 text-body-emphasis">Project Tracking</h3>
                <p>Keep your network projects organized and on schedule.</p>
            </div>
        </div>
        <div class="col d-flex align-items-start">
            <div class="icon-square text-body-emphasis bg-body-secondary d-inline-flex align-items-center justify-content-center fs-4 flex-shrink-0 me-3">
                <i class="fas fa-comments"></i>
            </div>
            <div>
                <h3 class="fs-2 text-body-emphasis">Team Chat</h3>
                <p>Collaborate with your team in real-time through our integrated chat system.</p>
            </div>
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



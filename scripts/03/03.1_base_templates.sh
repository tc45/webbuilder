#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Setting up base templates..."

# Create base template
log_message "Creating base template..."
cat > "${INSTALL_PATH}/src/templates/base/base.html" << EOF
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

log_message "Base templates setup completed" 
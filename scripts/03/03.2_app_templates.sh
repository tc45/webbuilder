#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Setting up app templates..."

# Create app-specific templates
for app in home accounts devices chat projects; do
    log_message "Creating templates for $app..."
    
    # Create index template for each app
    cat > "${INSTALL_PATH}/src/templates/${app}/index.html" << EOF
{% extends 'base/base.html' %}

{% block title %}${PROJECT_NAME} - ${app^}{% endblock %}

{% block content %}
<div class="container">
    <h1>${app^}</h1>
    <div class="row">
        <div class="col-md-12">
            <!-- ${app^} specific content will go here -->
        </div>
    </div>
</div>
{% endblock %}
EOF
done

# Create additional account templates
log_message "Creating account-specific templates..."
for template in login register profile password_reset; do
    cat > "${INSTALL_PATH}/src/templates/accounts/${template}.html" << EOF
{% extends 'base/base.html' %}
{% load crispy_forms_tags %}

{% block title %}${PROJECT_NAME} - ${template^}{% endblock %}

{% block content %}
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body">
                    <h2 class="card-title">${template^}</h2>
                    {% if form %}
                        <form method="post">
                            {% csrf_token %}
                            {{ form|crispy }}
                            <button type="submit" class="btn btn-primary">Submit</button>
                        </form>
                    {% endif %}
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF
done

log_message "App templates setup completed" 
#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Setting up static files..."

# Create basic CSS file
log_message "Creating base CSS..."
cat > "${INSTALL_PATH}/src/static/css/style.css" << EOF
/* Base styles */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
}

/* Custom navbar styling */
.navbar {
    box-shadow: 0 2px 4px rgba(0,0,0,.1);
}

/* Card styling */
.card {
    box-shadow: 0 2px 4px rgba(0,0,0,.1);
    border-radius: 8px;
    border: none;
}

/* Form styling */
.form-control:focus {
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25);
}
EOF

# Create basic JavaScript file
log_message "Creating base JavaScript..."
cat > "${INSTALL_PATH}/src/static/js/main.js" << EOF
// Add custom JavaScript here
document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    });

    // Initialize popovers
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl)
    });
});
EOF

# Create placeholder images directory
log_message "Creating placeholder images..."
mkdir -p "${INSTALL_PATH}/src/static/img/placeholders"

# Set proper permissions
log_message "Setting static file permissions..."
sudo chown -R www-data:www-data "${INSTALL_PATH}/src/static"
sudo chmod -R 755 "${INSTALL_PATH}/src/static"

log_message "Static files setup completed" 
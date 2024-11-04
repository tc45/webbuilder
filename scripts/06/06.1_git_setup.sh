#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting Git setup..."

cd "$INSTALL_PATH"

# Create .gitignore
log_message "Creating .gitignore..."
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
media/

# Virtual Environment
venv/
ENV/

# Environment variables
.env

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

# Initialize git repository
log_message "Initializing Git repository..."
git init >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to initialize Git repository" "${BASH_SOURCE[0]}"
    exit 1
}

# Configure Git
git config --local user.name "$ADMIN_USER" >> "$LOG_FILE" 2>&1
git config --local user.email "$ADMIN_USER@$DOMAIN_NAME" >> "$LOG_FILE" 2>&1

# Initial commit
log_message "Creating initial commit..."
git add . >> "$LOG_FILE" 2>&1
git commit -m "Initial commit: Project setup" >> "$LOG_FILE" 2>&1 || {
    handle_error 1 "Failed to create initial commit" "${BASH_SOURCE[0]}"
    exit 1
}

log_message "Git setup completed" 
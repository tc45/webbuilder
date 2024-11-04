#!/bin/bash

cd $INSTALL_PATH

# Source common functions
source $INSTALL_PATH/scripts/common.sh

# Activate virtual environment
check_venv

# Create .gitignore
log_message "Creating .gitignore file..."
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
log_message "Initializing git repository..."
if ! git init; then
    log_message "WARNING: Failed to initialize git repository"
    exit 0  # Continue with installation despite git failure
fi

# Configure git safe directory
if ! git config --global --add safe.directory $INSTALL_PATH; then
    log_message "WARNING: Failed to configure git safe directory"
    exit 0
fi

# Set main branch
if ! git branch -M main; then
    log_message "WARNING: Failed to set main branch"
    exit 0
fi

# Make initial commit
log_message "Making initial commit..."
if ! git add .; then
    log_message "WARNING: Failed to stage files"
    exit 0
fi

if ! git commit -m "Initial commit: ${PROJECT_NAME} setup"; then
    log_message "WARNING: Failed to make initial commit"
    exit 0
fi

# Set up GitHub repository (if gh CLI is installed)
if command -v gh &> /dev/null; then
    log_message "GitHub CLI found, attempting to create repository..."
    
    # Check GitHub authentication
    if ! gh auth status &> /dev/null; then
        log_message "GitHub authentication required"
        if ! gh auth login; then
            log_message "WARNING: GitHub authentication failed"
            exit 0
        fi
    fi
    
    # Create GitHub repository
    if ! gh repo create "${PROJECT_NAME,,}" --public --source=. --remote=origin --push; then
        log_message "WARNING: Failed to create GitHub repository"
        log_message "You can manually create and push to a GitHub repository later"
        exit 0
    fi
    
    log_message "GitHub repository created successfully"
else
    log_message "GitHub CLI not installed. Please manually create and push to repository."
fi

log_message "Git setup completed (with or without warnings)"
exit 0


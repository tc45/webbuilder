#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Generating next steps information..."

# Create next steps documentation
cat > "${INSTALL_PATH}/NEXT_STEPS.md" << EOF
# Next Steps for ${PROJECT_NAME}

## 1. Access Your Site
- Public URL: http://${DOMAIN_NAME}
- Admin URL: http://${DOMAIN_NAME}/admin
- Default admin credentials:
  - Username: ${ADMIN_USER}
  - Password: ${ADMIN_PASSWORD}

## 2. Security Steps
- [ ] Change the admin password immediately
- [ ] Update SECRET_KEY in .env file
- [ ] Review DEBUG setting in production
- [ ] Set up SSL/HTTPS (recommended)

## 3. Development Workflow
- Make changes in your local environment
- Test thoroughly
- Commit changes: \`git add . && git commit -m "Your message"\`
- Push to repository: \`git push origin main\`

## 4. Useful Commands
- Restart services:
  \`\`\`bash
  sudo systemctl restart ${PROJECT_NAME,,}
  sudo systemctl restart nginx
  \`\`\`
- View logs:
  \`\`\`bash
  sudo journalctl -u ${PROJECT_NAME,,}
  sudo tail -f ${INSTALL_PATH}/logs/django.log
  \`\`\`

## 5. Backup
- Database backup:
  \`\`\`bash
  python manage.py dumpdata > backup.json
  \`\`\`
- Media files backup:
  \`\`\`bash
  tar -czf media_backup.tar.gz ${INSTALL_PATH}/src/media
  \`\`\`

## 6. Monitoring
- Check service status:
  \`\`\`bash
  sudo systemctl status ${PROJECT_NAME,,}
  sudo systemctl status nginx
  \`\`\`

## 7. Regular Maintenance
- [ ] Update dependencies regularly
- [ ] Monitor logs for errors
- [ ] Backup database regularly
- [ ] Keep Django and packages updated
- [ ] Review security settings

For more detailed documentation, refer to the project's README.md
EOF

# Display next steps
cat "${INSTALL_PATH}/NEXT_STEPS.md"

log_message "Next steps documentation generated" 
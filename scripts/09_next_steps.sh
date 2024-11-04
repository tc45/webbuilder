#!/bin/bash

# Display next steps information
cat << EOF
╔════════════════════════════════════════════════════════════════════════════╗
║                           NEXT STEPS FOR ${PROJECT_NAME}                         ║
╚════════════════════════════════════════════════════════════════════════════╝

1. ACCESS YOUR SITE
   • Public URL: http://${DOMAIN_NAME}
   • Admin URL: http://${DOMAIN_NAME}/admin
   • Default admin credentials:
     Username: ${ADMIN_USER}
     Password: ${ADMIN_PASSWORD}

2. SECURITY STEPS
   • Change the admin password immediately
   • Update SECRET_KEY in .env file
   • Review DEBUG setting in production
   • Set up SSL/HTTPS (recommended)

3. CREATING NEW PAGES
   • Create a new app:
     cd ${INSTALL_PATH}/src
     python manage.py startapp your_app_name
   
   • Add to INSTALLED_APPS in settings.py:
     'your_app_name.apps.YourAppNameConfig'

   • Create views in your_app_name/views.py:
     from django.shortcuts import render
     
     def your_view(request):
         return render(request, 'your_app_name/template.html')

   • Create templates in your_app_name/templates/your_app_name/
   • Add URLs in your_app_name/urls.py and update main urls.py

4. DEVELOPMENT WORKFLOW
   • Make changes in your local environment
   • Test thoroughly
   • Commit changes: git add . && git commit -m "Your message"
   • Push to GitHub: git push origin main
   • Deploy: Pull changes on server and restart services

5. USEFUL COMMANDS
   • Restart services:
     sudo systemctl restart ${PROJECT_NAME,,}
     sudo systemctl restart nginx
   
   • View logs:
     sudo journalctl -u ${PROJECT_NAME,,}
     sudo tail -f ${INSTALL_PATH}/logs/django.log

6. BACKUP
   • Regular database backups:
     python manage.py dumpdata > backup.json
   
   • Save media files:
     tar -czf media_backup.tar.gz ${INSTALL_PATH}/src/media

7. MONITORING
   • Check service status:
     sudo systemctl status ${PROJECT_NAME,,}
     sudo systemctl status nginx
   
   • Monitor server resources:
     htop
     df -h

8. GETTING HELP
   • Django documentation: https://docs.djangoproject.com/
   • Project repository: https://github.com/tc45/${PROJECT_NAME,,}
   • Report issues: https://github.com/tc45/${PROJECT_NAME,,}/issues

Remember to regularly:
• Update dependencies
• Monitor logs for errors
• Backup your database
• Keep Django and all packages updated
• Review security settings

For more detailed documentation, check the project's README.md
╔════════════════════════════════════════════════════════════════════════════╗
║                              END OF GUIDE                                  ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

# Keep the message displayed until user presses a key
read -n 1 -s -r -p "Press any key to continue..."
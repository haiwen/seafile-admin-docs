# Customize Email Notifications

**Note:** Subject line may vary between different releases, this is based on Release 2.0.1. Restart Seahub so that your changes take effect.

## User reset his/her password

**Subject**

seahub/seahub/auth/forms.py line:103

**Body**

seahub/seahub/templates/registration/password_reset_email.html

Note: You can copy password_reset_email.html to `seahub-data/custom/templates/registration/password_reset_email.html` and modify the new one. In this way, the customization will be maintained after upgrade. 

## System admin add new member

**Subject**

seahub/seahub/views/sysadmin.py line:424

**Body**

seahub/seahub/templates/sysadmin/user_add_email.html

Note: You can copy user_add_email.html to `seahub-data/custom/templates/sysadmin/user_add_email.html` and modify the new one. In this way, the customization will be maintained after upgrade. 

## System admin reset user password

**Subject**

seahub/seahub/views/sysadmin.py line:368

**Body**

seahub/seahub/templates/sysadmin/user_reset_email.html

Note: You can copy user_reset_email.html to `seahub-data/custom/templates/sysadmin/user_reset_email.html` and modify the new one. In this way, the customization will be maintained after upgrade. 

## User send file/folder share link

**Subject**

seahub/seahub/share/views.py line:668

**Body**

seahub/seahub/templates/shared_link_email.html

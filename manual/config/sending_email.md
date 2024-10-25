# Sending Email Notifications on Seahub

## Types of Email Sending in Seafile

There are currently five types of emails sent in Seafile:

* User resets his/her password
* System admin adds new member
* System admin resets user password
* User sends file/folder share and upload link
* Reminder of unread notifications

The first four types of email are sent immediately. The last type is sent by a background task running periodically.

## Options of Email Sending

Please add the following lines to `seahub_settings.py` to enable email sending.

```python
EMAIL_USE_TLS = True
EMAIL_HOST = 'smtp.example.com'        # smpt server
EMAIL_HOST_USER = 'username@example.com'    # username and domain
EMAIL_HOST_PASSWORD = 'password'    # password
EMAIL_PORT = 587
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
SERVER_EMAIL = EMAIL_HOST_USER

```


**Note**: If your email service still does not work, you can checkout the log file `logs/seahub.log` to see what may cause the problem. For a complete email notification list, please refer to [email notification list](customize_email_notifications.md).

**Note2**: If you want to use the email service without authentication leaf `EMAIL_HOST_USER` and `EMAIL_HOST_PASSWORD` **blank** (`''`). (But notice that the emails then will be sent without a `From:` address.)

**Note3**: About using SSL connection (using port 465)

Port 587 is being used to establish a connection using STARTTLS and port 465 is being used to establish an SSL connection.  Starting from Django 1.8, it supports both.
If you want to use SSL on port 465, set `EMAIL_USE_SSL = True` instead of `EMAIL_USE_TLS`.


## Change `reply to` of email

You can change the reply to field of email by add the following settings to seahub_settings.py. This only affects email sending for file share link.

```python
# Set reply-to header to user's email or not, defaults to ``False``. For details,
# please refer to http://www.w3.org/Protocols/rfc822/
ADD_REPLY_TO_HEADER = True

```

## Config background email sending task

The background task will run periodically to check whether an user have new unread notifications. If there are any, it will send a reminder email to that user. The background email sending task is controlled by `seafevents.conf`.

```
[SEAHUB EMAIL]

## must be "true" to enable user email notifications when there are new unread notifications
enabled = true

## interval of sending seahub email. Can be s(seconds), m(minutes), h(hours), d(days)
interval = 30m

```

## Customize email messages

The simplest way to customize the email messages is setting the `SITE_NAME` variable in `seahub_settings.py`. If it is not enough for your case, you can customize the email templates.

**Note:** Subject line may vary between different releases, this is based on Release 5.0.0. Restart Seahub so that your changes take effect.

### The email base template

[seahub/seahub/templates/email_base.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/email_base.html)

Note: You can copy email_base.html to `seahub-data/custom/templates/email_base.html` and modify the new one. In this way, the customization will be maintained after upgrade.

### User resets his/her password

**Subject**

seahub/seahub/auth/forms.py line:127

```python
        send_html_email(_("Reset Password on %s") % site_name,
                  email_template_name, c, None, [user.username])

```

**Body**

[seahub/seahub/templates/registration/password_reset_email.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/registration/password_reset_email.html)

Note: You can copy password_reset_email.html to `seahub-data/custom/templates/registration/password_reset_email.html` and modify the new one. In this way, the customization will be maintained after upgrade.

### System admin adds new member

**Subject**

seahub/seahub/views/sysadmin.py line:424

```
send_html_email(_(u'Password has been reset on %s') % SITE_NAME,
            'sysadmin/user_reset_email.html', c, None, [email])

```

**Body**

[seahub/seahub/templates/sysadmin/user_add_email.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/sysadmin/user_add_email.html)

Note: You can copy user_add_email.html to `seahub-data/custom/templates/sysadmin/user_add_email.html` and modify the new one. In this way, the customization will be maintained after upgrade.

### System admin resets user password

**Subject**

seahub/seahub/views/sysadmin.py line:1224

```python
send_html_email(_(u'Password has been reset on %s') % SITE_NAME,
            'sysadmin/user_reset_email.html', c, None, [email])

```

**Body**

[seahub/seahub/templates/sysadmin/user_reset_email.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/sysadmin/user_reset_email.html)

Note: You can copy user_reset_email.html to `seahub-data/custom/templates/sysadmin/user_reset_email.html` and modify the new one. In this way, the customization will be maintained after upgrade.

### User sends file/folder share link

**Subject**

seahub/seahub/share/views.py line:913

```python
try:
    if file_shared_type == 'f':
        c['file_shared_type'] = _(u"file")
        send_html_email(_(u'A file is shared to you on %s') % SITE_NAME,
                        'shared_link_email.html',
                        c, from_email, [to_email],
                        reply_to=reply_to
                        )
    else:
        c['file_shared_type'] = _(u"directory")
        send_html_email(_(u'A directory is shared to you on %s') % SITE_NAME,
                        'shared_link_email.html',
                        c, from_email, [to_email],
                        reply_to=reply_to)

```

**Body**

[seahub/seahub/templates/shared_link_email.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/shared_link_email.html)

[seahub/seahub/templates/shared_upload_link_email.html](https://github.com/haiwen/seahub/blob/master/seahub/templates/shared_upload_link_email.html)

Note: You can copy shared_link_email.html to `seahub-data/custom/templates/shared_link_email.html` and modify the new one. In this way, the customization will be maintained after upgrade.

### Reminder of unread notifications

**Subject**

```python
send_html_email(_('New notice on %s') % settings.SITE_NAME,
                                'notifications/notice_email.html', c,
                                None, [to_user])

```

**Body**

[seahub/seahub/notifications/templates/notifications/notice_email.html](https://github.com/haiwen/seahub/blob/master/seahub/notifications/templates/notifications/notice_email.html)

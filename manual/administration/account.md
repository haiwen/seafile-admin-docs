# Account Management

#### User Management

When you setup seahub website, you should have setup a admin account. After you logged in a admin, you may add/delete users and file libraries.

#### How to change a user's ID

Since version 11.0, if you need to change a user's external ID, you can manually modify database table `social_auth_usersocialauth` to map the new external ID to internal ID.


#### Resetting User Password

Administrator can reset password for a user in "System Admin" page.

In a private server, the default settings doesn't support users to reset their password by email. If you want to enable this, you have first to [set up notification email](../config/sending_email.md).

#### Forgot Admin Account?

If you do not know the email address of an existing system administrator, run `./reset-admin.sh` from the `seafile-server-latest` directory to create a new system administrator. The script does not unlock existing accounts, change their passwords, or delete their data.

#### Forgot Admin Password?

If you know the email address of an existing local system administrator, run `./reset-admin-password.sh` from the `seafile-server-latest` directory. Enter the administrator's email address, then enter the new password twice. The password is not displayed as you type.

The script does not create an account or reactivate an inactive account. It cannot reset an LDAP password.

!!! tip
    For Docker deployments, enter the Seafile container and change to `/opt/seafile/seafile-server-latest` before running either script.


#### User Quota Notice

Under the seafile-server-latest directory, run `./seahub.sh python-env python seahub/manage.py check_user_quota` , when the user quota exceeds 90%, an email will be sent. If you want to enable this, you have first to [set up notification email](../config/sending_email.md).

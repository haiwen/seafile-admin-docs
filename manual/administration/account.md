# Account Management

#### User Management

When you setup seahub website, you should have setup a admin account. After you logged in a admin, you may add/delete users and file libraries.

#### How to change a user's ID

Since version 11.0, if you need to change a user's external ID, you can manually modify database table `social_auth_usersocialauth` to map the new external ID to internal ID.

For version below 11.0, if you really want to change a user's ID, you should create a new user then use this admin API to migrate the data from old user to the new user: https://download.seafile.com/published/web-api/v2.1-admin/accounts.md#user-content-Migrate%20Account.



#### Resetting User Password

Administrator can reset password for a user in "System Admin" page.

In a private server, the default settings doesn't support users to reset their password by email. If you want to enable this, you have first to [set up notification email](../config/sending_email.md).

#### Forgot Admin Account or Password?

You may run `reset-admin.sh` script under seafile-server directory. This script would help you reset the admin account and password.
Your data will not be deleted from the admin account, this only unlocks and changes the password for the admin account.

#### User Quota Notice

Under the seafile-server-latest directory, run `./seahub.sh python-env python seahub/manage.py check_user_quota` , when the user quota exceeds 90%, an email will be sent. If you want to enable this, you have first to [set up notification email](../config/sending_email.md).

# Two-Factor Authentication

Starting from version 6.0, we added Two-Factor Authentication to enhance account security.

There are two ways to enable this feature:

* System admin can tick the check-box at the "Password" section of the system settings page, or

* just add `ENABLE_TWO_FACTOR_AUTH = True` to `seahub_settings.py` and restart service.

After that, there will be a "Two-Factor Authentication" section in the user profile page.

Users can use the Google Authenticator app on their smart-phone to scan the QR code.




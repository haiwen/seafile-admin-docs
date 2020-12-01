# Two-Factor Authentication

Starting from version 6.0, we added Two-Factor Authentication to enhance account security.

There are two ways to enable this feature:

* System admin can tick the check-box at the "Password" section of the system settings page, or

* just add `ENABLE_TWO_FACTOR_AUTH = True` to `seahub_settings.py` and restart service.

After that, there will be a "Two-Factor Authentication" section in the user profile page.

Users can use the Google Authenticator app on their smart-phone to scan the QR code.


## Twilio intergration

We also support text message methods by using the Twilio service.

First you need to install the Twilio python library by

```
sudo pip install twilio==5.7.0
```

After that, append the following lines to `seahub_settings.py`, 

```
TWO_FACTOR_SMS_GATEWAY = 'seahub.two_factor.gateways.twilio.gateway.Twilio'
TWILIO_ACCOUNT_SID = '<your-account-sid>'
TWILIO_AUTH_TOKEN = '<your-auth-token>'
TWILIO_CALLER_ID = '<your-caller-id>'
EXTRA_MIDDLEWARE_CLASSES = (
    'seahub.two_factor.gateways.twilio.middleware.ThreadLocals',
)
```

**Note**: if you have already defined `EXTRA_MIDDLEWARE_CLASSES`, please replace `EXTRA_MIDDLEWARE_CLASSES = (` with `EXTRA_MIDDLEWARE_CLASSES += (`


After restarting, there will be a "text message" method when users enable Two-Factor Authentication for their account.

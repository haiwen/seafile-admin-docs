Multi-tenancy feature is designed for hosting providers that what to host several customers in a single Seafile instance. You can create multi-organizations. Organizations is separated from each other. Users can't share libraries between organizations.

## Seafile Config ##

#### seafile.conf

```
[general]
multi_tenancy = true
```

#### seahub_settings.py

```
CLOUD_MODE = True
MULTI_TENANCY = True

ORG_MEMBER_QUOTA_ENABLED = True

ORG_ENABLE_ADMIN_CUSTOM_NAME = True  # Default is True, meaning organization name can be customized
ORG_ENABLE_ADMIN_CUSTOM_LOGO = False  # Default is False, if set to True, organization logo can be customized

ENABLE_MULTI_ADFS = True  # Default is False, if set to True, support per organization custom ADFS/SAML2 login
SAML_ATTRIBUTE_MAPPING = {
    'mail': 'contact_email',
    'displayName': 'display_name',
}
```

## Usage

An organization can be created via system admin in “admin panel->organization->Add organization”.

Every organization has an URL prefix. This field is *for future usage*. When a user create an organization, an URL like org1 will be automatically assigned.

After creating an organization, the first user will become the admin of that organization. The organization admin can add other users. Note, the system admin can't add users.

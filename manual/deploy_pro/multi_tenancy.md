Multi-tenancy feature is designed for hosting providers that what to host several customers in a single Seafile instance. You can create multi-organizations. Organizations is separated from each other. Users can't share libraries between organizations.

## Seafile Config ##

#### seafile.conf

```
[general]
multi_tenancy = true
```

#### seahub_settings.py

```python
CLOUD_MODE = True
MULTI_TENANCY = True

ORG_MEMBER_QUOTA_ENABLED = True

ORG_ENABLE_ADMIN_CUSTOM_NAME = True  # Default is True, meaning organization name can be customized
ORG_ENABLE_ADMIN_CUSTOM_LOGO = False  # Default is False, if set to True, organization logo can be customized

ENABLE_MULTI_ADFS = True  # Default is False, if set to True, support per organization custom ADFS/SAML2 login
LOGIN_REDIRECT_URL = '/saml2/complete/'
SAML_ATTRIBUTE_MAPPING = {
    'name': ('display_name', ),
    'mail': ('contact_email', ),
    ...
}
```

## Usage

An organization can be created via system admin in “admin panel->organization->Add organization”.

Every organization has an URL prefix. This field is *for future usage*. When a user create an organization, an URL like org1 will be automatically assigned.

After creating an organization, the first user will become the admin of that organization. The organization admin can add other users. Note, the system admin can't add users.

## Multi-tenancy ADFS/SAML single sign-on login

### Preparation for ADFS/SAML

**The _system admin_ has to complete the following works.**

**Fisrt**, install xmlsec1 package:

```
$ apt update
$ apt install xmlsec1
```

**Second**, prepare SP(Seafile) certificate directory and generate SP certificates:

Create sp certs dir

```
$ mkdir -p /opt/seafile/seahub-data/certs
```

Generate the SP certs using the following command:

```
$ cd /opt/seafile/seahub-data/certs
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sp.key -out sp.crt
```

__Note__: The `days` option indicates the validity period of the generated certificate. The unit is day. The system admin needs to update the certificate regularly.

**Finally**, add the following configuration to seahub_settings.py and then restart Seafile:

```python
ENABLE_MULTI_ADFS = True
LOGIN_REDIRECT_URL = '/saml2/complete/'
SAML_ATTRIBUTE_MAPPING = {
    'name': ('display_name', ),
    'mail': ('contact_email', ),
    ...
}
```

__Note__: If the xmlsec1 binary is **not situated in** `/usr/bin/xmlsec1`, you need to add the following configuration in seahub_settings.py:

```python
SAML_XMLSEC_BINARY_PATH = '/path/to/xmlsec1'
```

View where the xmlsec1 binary is situated:

```
$ which xmlsec1
```

__Note__: If certificates are **not placed in** `/opt/seafile/seahub-data/certs`, you need to add the following configuration in seahub_settings.py:

```python
SAML_CERTS_DIR = '/path/to/certs'
```

### Deploy and configure ADFS/SAML single sign-on

**The _organization admin_ has to complete the following works.**

#### Deploy and configure Microsoft Azure SAML single sign-on app

If you use Microsoft Azure SAML app to achieve single sign-on, please follow the steps below:

**Firat**, add SAML application and assign users, refer to: [add an Azure AD SAML application](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/add-application-portal), [create and assign users](https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/add-application-portal-assign-users)

**Second**, setup your SAML login URL in the Seafile organization admin interface. The format of the login URL is: https://example.com/org/custom/{custom-part}/, e.g.:

![](../images/auto-upload/8c1988cd-1f66-47c9-ac61-650e8245efcf.png)

**Then**, setup the _Identifier_, _Reply URL_, and _Sign on URL_ of the SAML app based on your login URL, refer to: [enable single sign on for saml application](https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/add-application-portal-setup-sso). The format of the _Identifier_, _Reply URL_, and _Sign on URL_ are: https://example.com/org/custom/{custom-part}/metadata/, https://example.com/org/custom/{custom-part}/acs/, https://example.com/org/custom/{custom-part}/, e.g.:

![](../images/auto-upload/498c6ae2-9213-4452-9238-676d179c375c.png)

__Note__: The {custom-part} of the URL should be 6 to 20 characters, and can only contain alphanumeric characters and hyphens.

**Next**, copy the metadata URL of the SAML app:

![](../images/auto-upload/6702c7c7-a205-4b18-91d2-48dd1a1b7b03.png)

and paste it into the organization admin interface, e.g:

![](../images/auto-upload/d2252310-0c30-4d88-a553-5711820a65df.png)

**Next**, download the SAML app's certificate and rename to idp.crt:

![](../images/auto-upload/3aa0b19d-46ac-426e-adcc-b3869b0a95a1.png)

and upload the idp.crt in the organization admin interface:

![](../images/auto-upload/5b3ff455-de3f-4585-93d2-8ecc1c7cc0ea.png)

**Next**, [edit saml attributes & claims](https://learn.microsoft.com/en-us/azure/active-directory/develop/saml-claims-customization). Keep the default attributes & claims of SAML app unchanged, the _uid_ attribute must be added, the _mail_ and _name_ attributes are optional, e.g.:

![](../images/auto-upload/abee9c69-f03d-4735-9231-92bd923b9ceb.png)

**Finally**, open the browser and enter your custom login URL into the browser, e.g.:

![](../images/auto-upload/fc85a75e-fde8-43e0-bd88-541adae6c54c.png)

Click the Enter key will jump to the SAML app login page, e.g.:

![](../images/auto-upload/21dc07ae-89a7-4281-be18-566a64bca922.png)

#### Deploy and configure ADFS

If you use Microsoft ADFS to achieve single sign-on, please follow the steps below:

<!-- TODO -->

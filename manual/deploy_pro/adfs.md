# AD Federation Service or SAML 2.0 Integration

This documentation describes how to integrate to ADFS with SAML 2.0 protocol. The procedure can also be used to integrate with other SAML 2.0 compliant service with minimal change.

## Requirements

To use ADFS to log in to your Seafile, you need the following components:

1. A Winodws Server with [ADFS](https://technet.microsoft.com/en-us/library/hh831502.aspx) installed. For configuring and installing ADFS you can see [this article](https://msdn.microsoft.com/en-us/library/gg188612.aspx).
2. A valid SSL certificate for ADFS server, and here we use **adfs-server.adfs.com** as the domain name example.
3. A valid SSL certificate for Seafile server, and here we use **demo.seafile.com** as the domain name example.

## Prepare Certs File

1、x.509 certs for SP (Service Provider)

You can generate them by:

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sp.key -out sp.crt

```

These x.509 certs are used to sign and encrypt elements like NameID and Metadata for SAML. 

**Note: Do not use some special characters when generating a certificate**

2、Then copy these two files to `<seafile-install-path>/seahub-data/certs`. (if the certs folder not exists, create it.)

1. x.509 cert from IdP (Identity Provider)
2. Log into the ADFS server and open the ADFS management.
3. Double click **Service** and choose **Certificates**.
4. Export the **Token-Signing** certificate:
   1. Right-click the certificate and select **View Certificate**.
   2. Select the **Details** tab.
   3. Click **Copy to File** (select **DER encoded binary X.509**).
5. Convert this certificate to PEM format, rename it to **idp.crt**
6. Then copy it to `<seafile-install-path>/seahub-data/certs`. 

## Prepare IdP Metadata File

1. Open <https://adfs-server.adfs.com/federationmetadata/2007-06/federationmetadata.xml>
2. Save this xml file, rename it to **idp_federation_metadata.xml**
3. Copy it to `<seafile-install-path>/seahub-data/certs`.

## Install Requirements on Seafile Server

* For Ubuntu 16.04

```
sudo apt install libxmlsec1 xmlsec1
```

* For Seafile 7.1.x

```
sudo pip install cryptography djangosaml2==0.18.1
```

* For Seafile 8.0.x

```
sudo pip install cryptography djangosaml2>=0.19.0
```


## Config Seafile

Add the following lines to **seahub_settings.py**

```
from os import path
import saml2
import saml2.saml

CERTS_DIR = '<seafile-install-path>/seahub-data/certs'
SP_SERVICE_URL = 'https://demo.seafile.com'
XMLSEC_BINARY = '/usr/bin/xmlsec1'
ATTRIBUTE_MAP_DIR = '<seafile-install-path>/seafile-server-latest/seahub-extra/seahub_extra/adfs_auth/attribute-maps'
SAML_ATTRIBUTE_MAPPING = {
    'DisplayName': ('display_name', ),
    'ContactEmail': ('contact_email', ),
    'Department': ('department', ),
    'Telephone': ('telephone', ),
}

ENABLE_ADFS_LOGIN = True
EXTRA_AUTHENTICATION_BACKENDS = (
    'seahub_extra.adfs_auth.backends.Saml2Backend',
)
SAML_USE_NAME_ID_AS_USERNAME = True
LOGIN_REDIRECT_URL = '/saml2/complete/'
SAML_CONFIG = {
    # full path to the xmlsec1 binary programm
    'xmlsec_binary': XMLSEC_BINARY,
	
	'allow_unknown_attributes': True,

    # your entity id, usually your subdomain plus the url to the metadata view
    'entityid': SP_SERVICE_URL + '/saml2/metadata/',

    # directory with attribute mapping
    'attribute_map_dir': ATTRIBUTE_MAP_DIR,

    # this block states what services we provide
    'service': {
        # we are just a lonely SP
        'sp' : {
            "allow_unsolicited": True,
            'name': 'Federated Seafile Service',
            'name_id_format': saml2.saml.NAMEID_FORMAT_EMAILADDRESS,
            'endpoints': {
                # url and binding to the assetion consumer service view
                # do not change the binding or service name
                'assertion_consumer_service': [
                    (SP_SERVICE_URL + '/saml2/acs/',
                     saml2.BINDING_HTTP_POST),
                ],
                # url and binding to the single logout service view
                # do not change the binding or service name
                'single_logout_service': [
                    (SP_SERVICE_URL + '/saml2/ls/',
                     saml2.BINDING_HTTP_REDIRECT),
                    (SP_SERVICE_URL + '/saml2/ls/post',
                     saml2.BINDING_HTTP_POST),
                ],
            },

            # attributes that this project need to identify a user
            'required_attributes': ["uid"],

            # attributes that may be useful to have but not required
            'optional_attributes': ['eduPersonAffiliation', ],

            # in this section the list of IdPs we talk to are defined
            'idp': {
                # we do not need a WAYF service since there is
                # only an IdP defined here. This IdP should be
                # present in our metadata

                # the keys of this dictionary are entity ids
                'https://adfs-server.adfs.com/federationmetadata/2007-06/federationmetadata.xml': {
                    'single_sign_on_service': {
                        saml2.BINDING_HTTP_REDIRECT: 'https://adfs-server.adfs.com/adfs/ls/idpinitiatedsignon.aspx',
                    },
                  'single_logout_service': {
                      saml2.BINDING_HTTP_REDIRECT: 'https://adfs-server.adfs.com/adfs/ls/?wa=wsignout1.0',
                  },
                },
            },
        },
    },

    # where the remote metadata is stored
    'metadata': {
        'local': [path.join(CERTS_DIR, 'idp_federation_metadata.xml')],
    },

    # set to 1 to output debugging information
    'debug': 1,

    # Signing
    'key_file': '', 
    'cert_file': path.join(CERTS_DIR, 'idp.crt'),  # from IdP

    # Encryption
    'encryption_keypairs': [{
        'key_file': path.join(CERTS_DIR, 'sp.key'),  # private part
        'cert_file': path.join(CERTS_DIR, 'sp.crt'),  # public part
    }],
	
    'valid_for': 24,  # how long is our metadata valid
}

```

**Note: Users running the Seafile program should have permission to read all files under **`seahub-data/certs`**.**

## **Role Map for ADFS**

Since Pro 7.0.9, you are able to set user role with ADFS as with [Shibboleth](https://download.seafile.com/published/seafile-manual/deploy/shibboleth_config.md#user-content-Affiliation%20and%20user%20role). Details about user role, please refer to [role permissions](https://download.seafile.com/published/seafile-manual/deploy_pro/roles_permissions.md).

To enable this, add the following configuration information to `seahub_settings.py` to define the role mapping:

```
SHIBBOLETH_AFFILIATION_ROLE_MAP = {
    'role@lian-adfs.local': 'can_generate_upload_link_false',
    'role1@lian-adfs.local': 'guest',
    'patterns': (
        ('*@lian-adfs.local', 'guest1'),
        ('*@*.local', 'guest2'),
        ('*', 'guest3'),
    ),
}

```

## Config ADFS Server

1. Add **Relying Party Trust**

 Relying Party Trust is the connection between Seafile and ADFS.

1. Log into the ADFS server and open the ADFS management.
2. Double click **Trust Relationships**, then right click **Relying Party Trusts**, select **Add Relying Party Trust…**.
3. Select **Import data about the relying party published online or one a local network**, input `https://demo.seafile.com/saml2/metadata/` in the **Federation metadata address**.
4. Then **Next** until **Finish**.
5. Add **Relying Party Claim Rules**

 Relying Party Claim Rules is used for attribute communication between Seafile and users in Windows Domain. 

 **Important**: Users in Windows domain must have the **E-mail** value setted.

1. Right-click on the relying party trust and select **Edit Claim Rules...**
2. On the Issuance Transform Rules tab select **Add Rules...**
3. Select **Send LDAP Attribute as Claims** as the claim rule template to use. 
4. Give the claim a name such as LDAP Attributes. 
5. Set the Attribute Store to **Active Directory**, the LDAP Attribute to **E-Mail-Addresses**, and the Outgoing Claim Type to **E-mail Address**. 
6. Select **Finish**. 
7. Click **Add Rule...** again.
8. Select **Transform an Incoming Claim**. 
9. Give it a name such as **Email to Name ID**.
10. Incoming claim type should be **E-mail Address** (it must match the Outgoing Claim Type in rule #1).
11. The Outgoing claim type is **Name ID** (this is requested in Seafile settings policy `'name_id_format': saml2.saml.NAMEID_FORMAT_EMAILADDRESS`).
12. the Outgoing name ID format is **Email**.
13. **Pass through all claim values** and click **Finish**. 

## Test

After re-starting the services, you may open a web browser and type in `https://demo.seafile.com`, there should be a `ADFS` button in login dialog, click that button will redirect you to the ADFS server (adfs-server.adfs.com), if username and password are correct, you will be redirect back to Seafile home page.

For descktop client, simply click "Shibboleth Login" in "Add a new account" window, type in `https://demo.seafile.com`, click OK button will open a new window display ADFS server login page, if username and password are correct, the window will be closed and show Seafile libraries panel.

* <https://support.zendesk.com/hc/en-us/articles/203663886-Setting-up-single-sign-on-using-Active-Directory-with-ADFS-and-SAML-Plus-and-Enterprise->
* <http://wiki.servicenow.com/?title=Configuring_ADFS_2.0_to_Communicate_with_SAML_2.0#gsc.tab=0>
* <https://github.com/rohe/pysaml2/blob/master/src/saml2/saml.py>



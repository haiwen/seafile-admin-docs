

> This document is for Seafile Server version 6.3 or above, if the server version is lower than 6.3, please refer to [this document](https://manual.seafile.com/deploy/shibboleth_config.html).

## Overview

[Shibboleth](https://shibboleth.net/) is a widely used single sign on (SSO) protocol. Seafile supports authentication via Shibboleth. It allows users from another organization to log in to Seafile without registering an account on the service provider.

In this documentation, we assume the reader is familiar with Shibboleth installation and configuration. For introduction to Shibboleth concepts, please refer to <https://wiki.shibboleth.net/confluence/display/SHIB2/UnderstandingShibboleth> .

Shibboleth Service Provider (SP) should be installed on the same server as the Seafile server. The official SP from <https://shibboleth.net/> is implemented as an Apache module. The module handles all Shibboleth authentication details. Seafile server receives authentication information (username) from HTTP request. The username then can be used as login name for the user.

Seahub provides a special URL to handle Shibboleth login. The URL is `https://your-seafile-domain/sso`. Only this URL needs to be configured under Shibboleth protection. All other URLs don't go through the Shibboleth module. The overall workflow for a user to login with Shibboleth is as follows:

1. In the Seafile login page, there is a separate "Single Sign-On" login button. When the user clicks the button, she/he will be redirected to `https://your-seafile-domain/sso`.
2. Since that URL is controlled by Shibboleth, the user will be redirected to IdP for login. After the user logs in, she/he will be redirected back to `https://your-seafile-domain/sso`.
3. This time the Shibboleth module passes the request to Seahub. Seahub reads the user information from the request(`HTTP_REMOTE_USER` header)  and brings the user to her/his home page.
4. All later access to Seahub will not pass through the Shibboleth module. Since Seahub keeps session information internally, the user doesn't need to login again until the session expires.

Since Shibboleth support requires Apache, if you want to use Nginx, you need two servers, one for non-Shibboleth access, another configured with Apache to allow Shibboleth login. In a cluster environment, you can configure your load balancer to direct traffic to different server according to URL. Only the URL `https://your-seafile-domain/sso` needs to be directed to Apache.

The configuration includes 3 steps:

1. Install and configure Shibboleth Service Provider;
2. Configure Apache;
3. Configure Seahub.

## Install and Configure Shibboleth Service Provider

We use CentOS 7 as example.

#### Configure Apache

You should create a new virtual host configuration for Shibboleth. And then restart Apache.

```
<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerName your-seafile-domain
        DocumentRoot /var/www
        Alias /media /opt/seafile/seafile-server-latest/seahub/media

        ErrorLog ${APACHE_LOG_DIR}/seahub.error.log
        CustomLog ${APACHE_LOG_DIR}/seahub.access.log combined

        SSLEngine on
        SSLCertificateFile  /path/to/ssl-cert.pem
        SSLCertificateKeyFile /path/to/ssl-key.pem

        <Location /Shibboleth.sso>
            SetHandler shib
            AuthType shibboleth
            ShibRequestSetting requireSession 1
            Require valid-user
        </Location>

        <Location /sso>
            SetHandler shib
            AuthType shibboleth
            ShibUseHeaders On
            ShibRequestSetting requireSession 1
            Require valid-user
        </Location>

        RewriteEngine On
        <Location /media>
            Require all granted
        </Location>

        # seafile fileserver
        ProxyPass /seafhttp http://127.0.0.1:8082
        ProxyPassReverse /seafhttp http://127.0.0.1:8082
        RewriteRule ^/seafhttp - [QSA,L]

        # seahub
        SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
        ProxyPass / http://127.0.0.1:8000/
        ProxyPassReverse / http://127.0.0.1:8000/

        # for http
        # RequestHeader set REMOTE_USER %{REMOTE_USER}e
        # for https
        RequestHeader set REMOTE_USER %{REMOTE_USER}s
    </VirtualHost>
</IfModule>

```

#### Install and Configure Shibboleth

Installation and configuration of Shibboleth is out of the scope of this documentation. Here are a few references:

* For RedHat, CentOS-7 and SUSE: <https://wiki.shibboleth.net/confluence/display/SP3/LinuxInstall>

#### Configure Shibboleth(SP)

##### shibboleth2.xml

Open `/etc/shibboleth/shibboleth2.xml` and change some property. After you have done all the followings, don't forget to restart Shibboleth(SP)

###### `ApplicationDefaults` element

Change `entityID` and [`REMOTE_USER`](https://wiki.shibboleth.net/confluence/display/SP3/ApplicationDefaults) property:

```
<!-- The ApplicationDefaults element is where most of Shibboleth's SAML bits are defined. -->
<ApplicationDefaults entityID="https://your-seafile-domain/sso"
    REMOTE_USER="mail"
    cipherSuites="DEFAULT:!EXP:!LOW:!aNULL:!eNULL:!DES:!IDEA:!SEED:!RC4:!3DES:!kRSA:!SSLv2:!SSLv3:!TLSv1:!TLSv1.1">

```

Seahub extracts the username from the `REMOTE_USER` environment variable. So you should modify your SP's shibboleth2.xml config file, so that Shibboleth translates your desired attribute into `REMOTE_USER` environment variable.

In Seafile, only one of the following two attributes can be used for username: `eppn`, and `mail`. `eppn` stands for "Edu Person Principal Name". It is usually the UserPrincipalName attribute in Active Directory. It's not necessarily a valid email address. `mail` is the user's email address. You should set `REMOTE_USER` to either one of these attributes.

###### `SSO` element

Change `entityID` property:

```
<!--
Configures SSO for a default IdP. To properly allow for >1 IdP, remove
entityID property and adjust discoveryURL to point to discovery service.
You can also override entityID on /Login query string, or in RequestMap/htaccess.
-->
<SSO entityID="https://your-IdP-domain">
     <!--discoveryProtocol="SAMLDS" discoveryURL="https://wayf.ukfederation.org.uk/DS"-->
  SAML2
</SSO>

```

###### `MetadataProvider` element

Change `url` and `backingFilePath` property:

```
<!-- Example of remotely supplied batch of signed metadata. -->
<MetadataProvider type="XML" validate="true"
            url="http://your-IdP-metadata-url"
      backingFilePath="your-IdP-metadata.xml" maxRefreshDelay="7200">
    <MetadataFilter type="RequireValidUntil" maxValidityInterval="2419200"/>
    <MetadataFilter type="Signature" certificate="fedsigner.pem" verifyBackup="false"/>

```

##### attribute-map.xml

Open `/etc/shibboleth/attribute-map.xml` and change some property. After you have done all the followings, don't forget to restart Shibboleth(SP)

###### `Attribute` element

Uncomment attribute elements for getting more user info:

```
<!-- Older LDAP-defined attributes (SAML 2.0 names followed by SAML 1 names)... -->
<Attribute name="urn:oid:2.16.840.1.113730.3.1.241" id="displayName"/>
<Attribute name="urn:oid:0.9.2342.19200300.100.1.3" id="mail"/>

<Attribute name="urn:mace:dir:attribute-def:displayName" id="displayName"/>
<Attribute name="urn:mace:dir:attribute-def:mail" id="mail"/>

```

#### Upload Shibboleth(SP)'s metadata

After restarting Apache, you should be able to get the Service Provider metadata by accessing <https://your-seafile-domain/Shibboleth.sso/Metadata>. This metadata should be uploaded to the Identity Provider (IdP) server.

## Configure Seahub

Add the following configuration to seahub_settings.py.

```
ENABLE_SHIB_LOGIN = True
SHIBBOLETH_USER_HEADER = 'HTTP_REMOTE_USER'
# basic user attributes
SHIBBOLETH_ATTRIBUTE_MAP = {
    "HTTP_DISPLAYNAME": (False, "display_name"),
    "HTTP_MAIL": (False, "contact_email"),
}
EXTRA_MIDDLEWARE_CLASSES = (
    'shibboleth.middleware.ShibbolethRemoteUserMiddleware',
)
EXTRA_AUTHENTICATION_BACKENDS = (
    'shibboleth.backends.ShibbolethRemoteUserBackend',
)

```

Seahub can process additional user attributes from Shibboleth. These attributes are saved into Seahub's database, as user's properties. They're all not mandatory. The internal user properties Seahub now supports are:

* givenname
* surname
* contact_email: used for sending notification email to user if username is not a valid email address (like eppn).
* institution: used to identify user's institution

You can specify the mapping between Shibboleth attributes and Seahub's user properties in seahub_settings.py:

```
SHIBBOLETH_ATTRIBUTE_MAP  = {
    "HTTP_EPPN": (False, "username"),
    "HTTP_GIVENNAME": (False, "givenname"),
    "HTTP_SN": (False, "surname"),
    "HTTP_MAIL": (False, "contact_email"),
    "HTTP_ORGANIZATION": (False, "institution"),
}

```

In the above config, the hash key is Shibboleth attribute name, the second element in the hash value is Seahub's property name. You can adjust the Shibboleth attribute name for your own needs. **_Note that you may have to change attribute-map.xml in your Shibboleth SP, so that the desired attributes are passed to Seahub. And you have to make sure the IdP sends these attributes to the SP._**

We also added an option `SHIB_ACTIVATE_AFTER_CREATION` (defaults to `True`) which control the user status after shibboleth connection. If this option set to `False`, user will be inactive after connection, and system admins will be notified by email to activate that account.

#### Affiliation and user role

Shibboleth has a field called affiliation. It is a list like: `employee@uni-mainz.de;member@uni-mainz.de;faculty@uni-mainz.de;staff@uni-mainz.de.`

We are able to set user role from Shibboleth. Details about user role, please refer to <https://download.seafile.com/published/seafile-manual/deploy_pro/roles_permissions.md>


To enable this, modify `SHIBBOLETH_ATTRIBUTE_MAP` above and add `Shibboleth-affiliation` field, you may need to change `Shibboleth-affiliation` according to your Shibboleth SP attributes.

```
SHIBBOLETH_ATTRIBUTE_MAP  = {
    "HTTP_EPPN": (False, "username"),
    "HTTP_GIVENNAME": (False, "givenname"),
    "HTTP_SN": (False, "surname"),
    "HTTP_MAIL": (False, "contact_email"),
    "HTTP_ORGANIZATION": (False, "institution"),
    "HTTP_Shibboleth-affiliation": (False, "affiliation"),
}

```

Then add new config to define affiliation role map,

```
SHIBBOLETH_AFFILIATION_ROLE_MAP = {
    'employee@uni-mainz.de': 'staff',
    'member@uni-mainz.de': 'staff',
    'student@uni-mainz.de': 'student',
    'employee@hu-berlin.de': 'guest',
    'patterns': (
        ('*@hu-berlin.de', 'guest1'),
        ('*@*.de', 'guest2'),
        ('*', 'guest'),
    ),
}

```

After Shibboleth login, Seafile should calcualte user's role from affiliation and SHIBBOLETH_AFFILIATION_ROLE_MAP.

## Verify

After restarting Apache and Seahub service (`./seahub.sh restart`), you can then test the shibboleth login workflow.

## Debug

If you encountered problems when login, follow these steps to get debug info (for Seafile pro 6.3.13).

#### Add this setting to `seahub_settings.py`

```
DEBUG = True

```

#### Change Seafile's code

Open `seafile-server-latest/seahub/thirdpart/shibboleth/middleware.py`

Insert the following code in line 59

```
    assert False

```

Insert the following code in line 65

```
if not username:
    assert False

```

The complete code after these changes is as follows:

```
#Locate the remote user header.
# import pprint; pprint.pprint(request.META)
try:
    username = request.META[SHIB_USER_HEADER]
except KeyError:
    assert False
    # If specified header doesn't exist then return (leaving
    # request.user set to AnonymousUser by the
    # AuthenticationMiddleware).
    return

if not username:
    assert False

p_id = ccnet_api.get_primary_id(username)
if p_id is not None:
    username = p_id

```

Then restart Seafile and relogin, you will see debug info in web page.

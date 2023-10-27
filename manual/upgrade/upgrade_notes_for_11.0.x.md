# Upgrade notes for 11.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

### Change of user identity

Previous Seafile versions directly used a user's email address or SSO identity as their internal user ID.

Seafile 11.0 introduces virtual user IDs - random, internal identifiers like "adc023e7232240fcbb83b273e1d73d36@auth.local". For new users, a virtual ID will be generated instead of directly using their email. A mapping between the email and virtual ID will be stored in the "profile_profile" database table. For SSO users,the mapping between SSO ID and virtual ID is stored in the "social_auth_usersocialauth" table.

Overall this brings more flexibility to handle user accounts and identity changes. Existing users will use the same old ID.


### Reimplementation of LDAP Integration

Previous Seafile versions handled LDAP authentication in the ccnet-server component. In Seafile 11.0, LDAP is reimplemented within the Seahub Python codebase.

LDAP configuration has been moved from ccnet.conf to seahub_settings.py. The ccnet_db.LDAPImported table is no longer used - LDAP users are now stored in ccnet_db.EmailUsers along with other users.

Benefits of this new implementation:

* Improved compatibility across different systems. Python code is more portable than the previous C implementation.
* Consistent handling of users whether they login via LDAP or other methods like email/password.

The upgrade script will merge ccnet_db.LDAPImported table to ccnet_db.EmailUsers table. The setting files need to be changed manually.

### OAuth authentication and other SSO methods

If you use OAuth authentication, the configuration need to be changed a bit.

If you use SAML, you don't need to change configuration files.


### Deprecating SQLite Database Support

Seafile 11.0 deprecates using SQLite as the database. There are several reasons driving this change:

* Focus on collaborative features - SQLite's limitations make advanced concurrency and locking difficult, which collaborative editing requires. Different Seafile components need simultaneous database access.
* Docker deployments - Our official Docker images do not support SQLite. MySQL is the preferred option.
* Migration difficulties - Migrating SQLite databases to MySQL via SQL translation is unreliable.

To migrate from SQLite database to MySQL database, you can follow the document [Migrate from SQLite to MySQL](../deploy/migrate_from_sqlite_to_mysql.md)


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 11.0



## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

For Ubuntu 20.04/22.04

```sh
sudo apt-get update
sudo apt-get install -y python3-dev ldap-utils libldap2-dev

sudo pip3 install future==0.18.* mysqlclient==2.1.* pillow==10.0.* sqlalchemy==2.0.18 captcha==0.4 django_simple_captcha==0.5.* djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.4.3
```


## Upgrade to 11.0.x

### 1) Stop Seafile-10.0.x server.

### 2) Start from Seafile 11.0.x, run the script:

```sh
upgrade/upgrade_10.0_11.0.sh
```

### 3）Modify configurations and migrate LDAP records

#### Change configurations for LDAP

The configuration items of LDAP login and LDAP sync tasks are migrated from ccnet.conf to seahub_settings.py. The name of the configuration item is based on the 10.0 version, and the characters 'LDAP\_' or 'MULTI_LDAP_1' are added. Examples are as follows:

```python
# Basic configuration items for LDAP login
ENABLE_LDAP = True
LDAP_SERVER_URL = 'ldap://192.168.0.125'     # The URL of LDAP server
LDAP_BASE_DN = 'ou=test,dc=seafile,dc=ren'   # The root node of users who can 
                                             # log in to Seafile in the LDAP server
LDAP_ADMIN_DN = 'administrator@seafile.ren'  # DN of the administrator used 
                                             # to query the LDAP server for information
LDAP_ADMIN_PASSWORD = 'Hello@123'            # Password of LDAP_ADMIN_DN
LDAP_PROVIDER = 'ldap'                       # Identify the source of the user, used in 
                                             # the table social_auth_usersocialauth, defaults to 'ldap'
LDAP_LOGIN_ATTR = 'userPrincipalName'        # User's attribute used to log in to Seafile, 
                                             # can be mail or userPrincipalName, cannot be changed
LDAP_FILTER = 'memberOf=CN=testgroup,OU=test,DC=seafile,DC=ren'  # Additional filter conditions,
                                                                 # users who meet the filter conditions can log in, otherwise they cannot log in
# For update user info when login
LDAP_USER_FIRST_NAME_ATTR = 'givenName'  # For update user's first name
LDAP_USER_LAST_NAME_ATTR = 'sn'          # For update user's last name
LDAP_USER_NAME_REVERSE = False           # Whether to reverse the user's first and last name
IMPORT_NEW_USER = True                   # Whether to import new users when sync user
ACTIVATE_USER_WHEN_IMPORT = True         # Whether to activate the user when importing new user
ENABLE_EXTRA_USER_INFO_SYNC = True       # Whether to enable sync of additional user information,
                                         # including user's full name, department, and Windows login name, etc.
```

The following configuration items are only for Pro Edition:
```python
# Configuration items for LDAP sync tasks.
LDAP_SYNC_INTERVAL = 60                  # LDAP sync task period, in minutes

# LDAP user sync configuration items.
ENABLE_LDAP_USER_SYNC = True             # Whether to enable user sync
LDAP_USER_OBJECT_CLASS = 'person'        # This is the name of the class used to search for user objects. 
                                         # In Active Directory, it's usually "person". The default value is "person".
LDAP_DEPT_ATTR = ''                      # LDAP user's department info
LDAP_UID_ATTR = ''                       # LDAP user's login_id attribute
LDAP_CONTACT_EMAIL_ATTR = ''             # LDAP user's contact_email attribute
LDAP_USER_ROLE_ATTR = ''                 # LDAP user's role attribute
LDAP_AUTO_REACTIVATE_USERS = True        # Whether to auto activate deactivated user
LDAP_USE_PAGED_RESULT = False            # Whether to use pagination extension
DEACTIVE_USER_IF_NOTFOUND = False        # Set to "true" if you want to deactivate a user 
                                         # when he/she was deleted in AD server.

# LDAP group sync configuration items.
ENABLE_LDAP_GROUP_SYNC = True            # Whether to enable group sync
LDAP_GROUP_FILTER = ''                   # Group sync filter
LDAP_SYNC_DEPARTMENT_FROM_OU = True      # Whether to enable sync departments from OU.
LDAP_GROUP_OBJECT_CLASS = 'group'        # This is the name of the class used to search for group objects.
LDAP_GROUP_MEMBER_ATTR = 'member'        # The attribute field to use when loading the group's members. 
                                         # For most directory servers, the attributes is "member" 
                                         # which is the default value.For "posixGroup", it should be set to "memberUid".
LDAP_USER_ATTR_IN_MEMBERUID = 'uid'      # The user attribute set in 'memberUid' option, 
                                         # which is used in "posixGroup".The default value is "uid".
LDAP_GROUP_UUID_ATTR = 'objectGUID'      # Used to uniquely identify groups in LDAP
LDAP_USE_GROUP_MEMBER_RANGE_QUERY = False   # When a group contains too many members, 
                                            # AD will only return part of them. Set this option to TRUE
                                            # to make LDAP sync work with large groups.
LDAP_SYNC_GROUP_AS_DEPARTMENT = False    # Whether to sync groups as top-level departments in Seafile
LDAP_DEPT_NAME_ATTR = ''                 # Used to get the department name.
LDAP_CREATE_DEPARTMENT_LIBRARY = False   # If you decide to sync the group as a department,
                                         # you can set this option to "true". In this way, when 
                                         # the group is synchronized for the first time, a library
                                         # is automatically created for the department, and the 
                                         # library's name is the department's name.
LDAP_DEPT_REPO_PERM = 'rw'               # Set the permissions of the department repo, default permission is 'rw'.
LDAP_DEFAULT_DEPARTMENT_QUOTA = -2       # You can set a default space quota for each department
                                         # when you synchronize a group for the first time. The 
                                         # quota is set to unlimited if this option is not set.
                                         # Unit is MB.
DEL_GROUP_IF_NOT_FOUND = False           # Set to "true", sync process will delete the group if not found it in LDAP server.
DEL_DEPARTMENT_IF_NOT_FOUND = False      # Set to "true", sync process will deleted the department if not found it in LDAP server.
```

#### Migrate LDAP records

Run the following script to migrate users in `LDAPImported` to `EmailUsers`

```sh
python3 migrate_ldapusers.py
```

#### Change configuration for OAuth:

In the new version, the OAuth login configuration should keep the email attribute unchanged to be compatible with new and old user logins. In version 11.0, a new uid attribute is added to be used as a user's external unique ID. The uid will be stored in social_auth_usersocialauth to map to internal virtual ID. For old users, the original  email is used the internal virtual ID. The example is as follows:

```python
# Version 10.0 or earlier
OAUTH_ATTRIBUTE_MAP = {
    "id": (True, "email"),
    "name": (False, "name"),
    "email": (False, "contact_email"),
}

# Since 11.0 version, added 'uid' attribute.
OAUTH_ATTRIBUTE_MAP = {
    "id": (True, "email"),  # In the new version, the email attribute configuration should be kept unchanged to be compatible with old and new user logins
    "uid": (True, "uid"),   # Seafile use 'uid' as the external unique identifier of the user. Different OAuth systems have different attributes, which may be: 'uid' or 'username', etc.
    "name": (False, "name"),
    "email": (False, "contact_email"),
}

```


### 4) Start Seafile-11.0.x server.

# Configure Seafile Pro Edition to use LDAP

## How does LDAP User Management work in Seafile

When Seafile is integrated with LDAP, users in the system can be divided into two tiers:

- Users within Seafile's internal user database. Some attributes are attached to these users, such as whether it's a system admin user, whether it's activated.

- Users in LDAP server. These are all the intended users of Seafile inside the LDAP server. Seafile doesn't manipulate these users directly. It has to import them into its internal database before setting attributes on them.

When Seafile counts the number of users in the system, it only counts the **activated** users in its internal database.

## Basic LDAP Integration

The only requirement for Seafile to use LDAP for authentication is that there must be a unique identifier for each user in the LDAP server. Seafile can only use email-address-format user identifiers. So there are usually only two options for this unique identifier:

- Email address: this is the most common choice. Most organizations assign unique email address for each member.

- UserPrincipalName: this is a user attribute only available in Active Directory. It's format is `user-login-name@domain-name`, e.g. `john@example.com`. It's not a real email address, but it works fine as the unique identifier.

### Integration Configuration

Add the following options to `seahub_settings.py`. Examples are as follows:

```python
ENABLE_LDAP = True
LDAP_SERVER_URL = 'ldap://192.168.0.1'       # The URL of LDAP server
LDAP_BASE_DN = 'ou=test,dc=seafile,dc=ren'   # The root node of users who can 
                                             # log in to Seafile in the LDAP server
LDAP_ADMIN_DN = 'administrator@example.com'  # DN of the administrator used 
                                             # to query the LDAP server for information.
                                             # For OpenLDAP, it maybe cn=admin,dc=example,dc=com
LDAP_ADMIN_PASSWORD = 'Hello@123'            # Password of LDAP_ADMIN_DN
LDAP_PROVIDER = 'ldap'                       # Identify the source of the user, used in 
                                             # the table social_auth_usersocialauth, defaults to 'ldap'
LDAP_LOGIN_ATTR = 'userPrincipalName'        # User's attribute used to log in to Seafile, 
                                             # can be mail or userPrincipalName, cannot be changed
LDAP_CONTACT_EMAIL_ATTR = ''                 # LDAP user's contact_email attribute
LDAP_USER_ROLE_ATTR = ''                     # LDAP user's role attribute
LDAP_USER_FIRST_NAME_ATTR = 'givenName'      # For sync user's first name
LDAP_USER_LAST_NAME_ATTR = 'sn'              # For sync user's last name
LDAP_USER_NAME_REVERSE = False               # Whether to reverse the user's first and last name
LDAP_FILTER = 'memberOf=CN=testgroup,OU=test,DC=seafile,DC=ren'  # Additional filter conditions,
                                             # users who meet the filter conditions can log in, otherwise they cannot log in

```

Tips for choosing `LDAP_BASE_DN` and `LDAP_ADMIN_DN`:

* To determine the `LDAP_BASE_DN`, you first have to navigate your organization hierachy on the domain controller GUI.

    * If you want to allow all users to use Seafile, you can use `cn=users,dc=yourdomain,dc=com` as `LDAP_BASE_DN` (with proper adjustment for your own needs).

    * If you want to limit users to a certain OU (Organization Unit), you run `dsquery` command on the domain controller to find out the DN for this OU. For example, if the OU is `staffs`, you can run `dsquery ou -name staff`. More information can be found [here](https://technet.microsoft.com/en-us/library/cc770509.aspx).

* AD supports `user@domain.name` format for the `LDAP_ADMIN_DN` option. For example you can use administrator@example.com for `LDAP_ADMIN_DN`. Sometime the domain controller doesn't recognize this format. You can still use `dsquery` command to find out user's DN. For example, if the user name is 'seafileuser', run `dsquery user -name seafileuser`. More information [here](https://technet.microsoft.com/en-us/library/cc725702.aspx).

## Setting Up LDAP User Sync (optional)

In Seafile Pro, except for importing users into internal database when they log in, you can also configure Seafile to periodically sync user information from LDAP server into the internal database.

User's full name, department and contact email address can be synced to internal database. Users can use this information to more easily search for a specific user.
User's Windows or Unix login id can be synced to the internal database. This allows the user to log in with its familiar login id.
When a user is removed from LDAP, the corresponding user in Seafile will be deactivated. Otherwise, he could still sync files with Seafile client or access the web interface.
After synchronization is complete, you can see the user's full name, department and contact email on its profile page.

### Sync configuration items

Add the following options to `seahub_settings.py`. Examples are as follows:

```python
# Basic configuration items
ENABLE_LDAP = True
......

# ldap user sync options.
LDAP_SYNC_INTERVAL = 60                  # LDAP sync task period, in minutes
ENABLE_LDAP_USER_SYNC = True             # Whether to enable user sync
LDAP_USER_OBJECT_CLASS = 'person'        # This is the name of the class used to search for user objects. 
                                         # In Active Directory, it's usually "person". The default value is "person".
LDAP_DEPT_ATTR = ''                      # LDAP user's department info
LDAP_UID_ATTR = ''                       # LDAP user's login_id attribute
LDAP_AUTO_REACTIVATE_USERS = True        # Whether to auto activate deactivated user
LDAP_USE_PAGED_RESULT = False            # Whether to use pagination extension

IMPORT_NEW_USER = True                   # Whether to import new users when sync user
ACTIVATE_USER_WHEN_IMPORT = True         # Whether to activate the user when importing new user
DEACTIVE_USER_IF_NOTFOUND = False        # Set to "true" if you want to deactivate a user 
                                         # when he/she was deleted in AD server.
ENABLE_EXTRA_USER_INFO_SYNC = True       # Whether to enable sync of additional user information,
                                         # including user's full name, department, and Windows login name, etc.
```

### Importing Users without Activating Them

The users imported with the above configuration will be activated by default. For some organizations with large number of users, they may want to import user information (such as user full name) without activating the imported users. Activating all imported users will require licenses for all users in LDAP, which may not be affordable.

Seafile provides a combination of options for such use case. You can modify below option in `seahub_settings.py`:

```python
ACTIVATE_USER_WHEN_IMPORT = False
```

This prevents Seafile from activating imported users. Then, add below option to `seahub_settings.py`:

```python
ACTIVATE_AFTER_FIRST_LOGIN = True
```

This option will automatically activate users when they login to Seafile for the first time.

### Reactivating Users

When you set the `DEACTIVE_USER_IF_NOTFOUND` option, a user will be deactivated when he/she is not found in LDAP server. By default, even after this user reappears in the LDAP server, it won't be reactivated automatically. This is to prevent auto reactivating a user that was manually deactivated by the system admin.

However, sometimes it's desirable to auto reactivate such users. You can modify below option in `seahub_settings.py`:

```python
LDAP_AUTO_REACTIVATE_USERS = True
```

### Manually Trigger Synchronization

To test your LDAP sync configuration, you can run the sync command manually.

To trigger LDAP sync manually:

```
cd seafile-server-lastest
./pro/pro.py ldapsync
```

## Setting Up LDAP Group Sync (optional)

### How It Works

The importing or syncing process maps groups from LDAP directory server to groups in Seafile's internal database. This process is one-way.

* Any changes to groups in the database won't propagate back to LDAP;

* Any changes to groups in the database, except for "setting a member as group admin", will be overwritten in the next LDAP sync operation. If you want to add or delete members, you can only do that on LDAP server.

* The creator of imported groups will be set to the system admin.

There are two modes of operation:

* Periodical: the syncing process will be executed in a fixed interval

* Manual: there is a script you can run to trigger the syncing once

### Configuration

Before enabling LDAP group sync, you should have configured LDAP authentication. See [Basic LDAP Integration](#basic-ldap-integration) for details.

The following are LDAP group sync related options:

```python
# ldap group sync options.
ENABLE_LDAP_GROUP_SYNC = True            # Whether to enable group sync
LDAP_GROUP_OBJECT_CLASS = 'group'        # This is the name of the class used to search for group objects.
LDAP_GROUP_MEMBER_ATTR = 'member'        # The attribute field to use when loading the group's members. 
                                         # For most directory servers, the attributes is "member" 
                                         # which is the default value.For "posixGroup", it should be set to "memberUid".
LDAP_USER_ATTR_IN_MEMBERUID = 'uid'      # The user attribute set in 'memberUid' option, 
                                         # which is used in "posixGroup".The default value is "uid".
LDAP_GROUP_UUID_ATTR = 'objectGUID'      # Used to uniquely identify groups in LDAP
LDAP_GROUP_FILTER = ''                   # An additional filter to use when searching group objects.
                                         # If it's set, the final filter used to run search is "(&(objectClass=GROUP_OBJECT_CLASS)(GROUP_FILTER))";
                                         # otherwise the final filter would be "(objectClass=GROUP_OBJECT_CLASS)".
LDAP_USE_GROUP_MEMBER_RANGE_QUERY = False   # When a group contains too many members, 
                                         # AD will only return part of them. Set this option to TRUE
                                         # to make LDAP sync work with large groups.
DEL_GROUP_IF_NOT_FOUND = False           # Set to "true", sync process will delete the group if not found it in LDAP server.
LDAP_SYNC_GROUP_AS_DEPARTMENT = False    # Whether to sync groups as top-level departments in Seafile.
                                         # Learn more about departments in Seafile [here](https://help.seafile.com/sharing_collaboration/departments/).
LDAP_DEPT_NAME_ATTR = ''                 # Used to get the department name.
```

**Note**:

* The search base for groups is the option `LDAP_BASE_DN`.

* Some LDAP server, such as Active Directory, allows a group to be a member of another group. This is called "group nesting". If we find a nested group B in group A, we should recursively add all the members from group B into group A. And group B should still be imported a separate group. That is, all members of group B are also members in group A.

* In some LDAP server, such as OpenLDAP, it's common practice to use Posix groups to store group membership. To import Posix groups as Seafile groups, set `LDAP_GROUP_OBJECT_CLASS` option to `posixGroup`. A `posixGroup` object in LDAP usually contains a multi-value attribute for the list of member UIDs. The name of this attribute can be set with the `LDAP_GROUP_MEMBER_ATTR` option. It's `MemberUid` by default. The value of the `MemberUid` attribute is an ID that can be used to identify a user, which corresponds to an attribute in the user object. The name of this ID attribute is usually `uid`, but can be set via the `LDAP_USER_ATTR_IN_MEMBERUID` option. Note that `posixGroup` doesn't support nested groups.

### Sync OU as Departments

A department in Seafile is a special group. In addition to what you can do with a group, there are two key new features for departments:

* Department supports hierarchy. A department can have any levels of sub-departments.

* Department can have storage quota.

Seafile supports syncing OU (Organizational Units) from AD/LDAP to departments. The sync process keeps the hierarchical structure of the OUs.

Options for syncing departments from OU:

```python
LDAP_SYNC_DEPARTMENT_FROM_OU = True      # Whether to enable sync departments from OU.
LDAP_DEPT_NAME_ATTR = 'description'      # Used to get the department name.
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
DEL_DEPARTMENT_IF_NOT_FOUND = False      # Set to "true", sync process will deleted the department if not found it in LDAP server.
```

### Periodical and Manual Sync

Periodical sync won't happen immediately after you restart seafile server. It gets scheduled after the first sync interval. For example if you set sync interval to 30 minutes, the first auto sync will happen after 30 minutes you restarts. To sync immediately, you need to manually trigger it.

After the sync is run, you should see log messages like the following in logs/seafevents.log. And you should be able to see the groups in system admin page.

```
[2023-03-30 18:15:05,109] [DEBUG] create group 1, and add dn pair CN=DnsUpdateProxy,CN=Users,DC=Seafile,DC=local<->1 success.
[2023-03-30 18:15:05,145] [DEBUG] create group 2, and add dn pair CN=Domain Computers,CN=Users,DC=Seafile,DC=local<->2 success.
[2023-03-30 18:15:05,154] [DEBUG] create group 3, and add dn pair CN=Domain Users,CN=Users,DC=Seafile,DC=local<->3 success.
[2023-03-30 18:15:05,164] [DEBUG] create group 4, and add dn pair CN=Domain Admins,CN=Users,DC=Seafile,DC=local<->4 success.
[2023-03-30 18:15:05,176] [DEBUG] create group 5, and add dn pair CN=RAS and IAS Servers,CN=Users,DC=Seafile,DC=local<->5 success.
[2023-03-30 18:15:05,186] [DEBUG] create group 6, and add dn pair CN=Enterprise Admins,CN=Users,DC=Seafile,DC=local<->6 success.
[2023-03-30 18:15:05,197] [DEBUG] create group 7, and add dn pair CN=dev,CN=Users,DC=Seafile,DC=local<->7 success.
```

To trigger LDAP sync manually,

```
cd seafile-server-lastest
./pro/pro.py ldapsync
```

## Advanced LDAP Integration Options

### Multiple BASE

Multiple base DN is useful when your company has more than one OUs to use Seafile. You can specify a list of base DN in the `LDAP_BASE_DN` option. The DNs are separated by ";", e.g.

```python
LDAP_BASE_DN = 'ou=developers,dc=example,dc=com;ou=marketing,dc=example,dc=com'
```

### Additional Search Filter

Search filter is very useful when you have a large organization but only a portion of people want to use Seafile. The filter can be given by setting `LDAP_FILTER` option. The value of this option follows standard LDAP search filter syntax (https://msdn.microsoft.com/en-us/library/aa746475(v=vs.85).aspx).

The final filter used for searching for users is `(&($LOGIN_ATTR=*)($LDAP_FILTER))`. `$LOGIN_ATTR` and `$LDAP_FILTER` will be replaced by your option values.

For example, add below option to `seahub_settings.py`:

```python
LDAP_FILTER = 'memberOf=CN=group,CN=developers,DC=example,DC=com'
```

The final search filter would be `(&(mail=*)(memberOf=CN=group,CN=developers,DC=example,DC=com))`

Note that the case of attribute names in the above example is significant. The `memberOf` attribute is only available in Active Directory.

### Limiting Seafile Users to a Group in Active Directory

You can use the `LDAP_FILTER` option to limit user scope to a certain AD group.

1. First, you should find out the DN for the group. Again, we'll use the `dsquery` command on the domain controller. For example, if group name is 'seafilegroup', run `dsquery group -name seafilegroup`.

2. Add below option to `seahub_settings.py`:

```python
LDAP_FILTER = 'memberOf={output of dsquery command}'
```

### Using TLS connection to LDAP server

If your LDAP service supports TLS connections, you can configure `LDAP_SERVER_URL` as the access address of the ldaps protocol to use TLS to connect to the LDAP service, for example:

```python
LDAP_SERVER_URL = 'ldaps://192.168.0.1:636/'
```

### Use paged results extension

LDAP protocol version 3 supports "paged results" (PR) extension. When you have large number of users, this option can greatly improve the performance of listing users. Most directory server nowadays support this extension.

In Seafile Pro Edition, add this option to `seahub_settings.py` to enable PR:

```python
LDAP_USE_PAGED_RESULT = True

```

### Follow referrals

Seafile Pro Edition supports auto following referrals in LDAP search. This is useful for partitioned LDAP or AD servers, where users may be spreaded on multiple directory servers. For more information about referrals, you can refer to [this article](https://technet.microsoft.com/en-us/library/cc978014.aspx).

To configure, add below option to `seahub_settings.py`, e.g.:

```python
LDAP_FOLLOW_REFERRALS = True
```

### Configure Multi-ldap Servers

Seafile Pro Edition supports multi-ldap servers, you can configure two ldap servers to work with seafile. Multi-ldap servers mean that, when get or search ldap user, it will iterate all configured ldap servers until a match is found; When listing all ldap users, it will iterate all ldap servers to get all users; For Ldap sync it will sync all user/group info in all configured ldap servers to seafile.

**Currently, only two LDAP servers are supported.**

If you want to use multi-ldap servers, please replace `LDAP` in the options with `MULTI_LDAP_1`, and then add them to `seahub_settings.py`, for example:

```python
# Basic config options
ENABLE_LDAP = True
......

# Multi ldap config options
ENABLE_MULTI_LDAP_1 = True
MULTI_LDAP_1_SERVER_URL = 'ldap://192.168.0.2'
MULTI_LDAP_1_BASE_DN = 'ou=test,dc=seafile,dc=top'
MULTI_LDAP_1_ADMIN_DN = 'administrator@example.top'
MULTI_LDAP_1_ADMIN_PASSWORD = 'Hello@123'
MULTI_LDAP_1_PROVIDER = 'ldap1'
MULTI_LDAP_1_LOGIN_ATTR = 'userPrincipalName'
......
```

**Note**: There are still some shared config options are used for all LDAP servers, as follows:

```python
# Common basic config options
LDAP_USER_FIRST_NAME_ATTR = 'givenName'      # For sync user's first name
LDAP_USER_LAST_NAME_ATTR = 'sn'              # For sync user's last name
LDAP_USER_NAME_REVERSE = False               # Whether to reverse the user's first and last name

# Common user sync options
LDAP_SYNC_INTERVAL = 60
IMPORT_NEW_USER = True                   # Whether to import new users when sync user
ACTIVATE_USER_WHEN_IMPORT = True         # Whether to activate the user when importing new user
DEACTIVE_USER_IF_NOTFOUND = False        # Set to "true" if you want to deactivate a user 
                                         # when he/she was deleted in AD server.
ENABLE_EXTRA_USER_INFO_SYNC = True       # Whether to enable sync of additional user information,
                                         # including user's full name, department, and Windows login name, etc.

# Common group sync options
DEL_GROUP_IF_NOT_FOUND = False           # Set to "true", sync process will delete the group if not found it in LDAP server.
DEL_DEPARTMENT_IF_NOT_FOUND = False      # Set to "true", sync process will deleted the department if not found it in LDAP server.
```

## Importing Roles from LDAP

Seafile Pro Edition supports syncing roles from LDAP or Active Directory.

To enable this feature, add below option to `seahub_settings.py`, e.g.

```python
LDAP_USER_ROLE_ATTR = 'title'
```

`LDAP_USER_ROLE_ATTR` is the attribute field to configure roles in LDAP. We provide a user-defined function to map the role：Create `custom_functions.py` under conf/ and edit it like:

```python
# -*- coding: utf-8 -*-


def ldap_role_mapping(role):
    if 'staff' in role:
        return 'Staff'
    if 'guest' in role:
        return 'Guest'
    if 'manager' in role:
        return 'Manager'
```

You can rewrite this function (in python) to make your own mapping rules. If the file or function doesn't exist, all roles in `LDAP_USER_ROLE_ATTR` will be synced.

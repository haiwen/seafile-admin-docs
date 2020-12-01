# Importing Groups from LDAP/AD

Since version 4.1.0, the Pro Edition supports importing (syncing) groups from LDAP or Active Directory.

## How It Works

The importing or syncing process maps groups from LDAP directory server to groups in Seafile's internal database. This process is one-way.

* Any changes to groups in the database won't propagate back to LDAP;
* Any changes to groups in the database, except for "setting a member as group admin", will be overwritten in the next LDAP sync operation. If you want to add or delete members, you can only do that on LDAP server.
* The creator of imported groups will be set to the system admin.

There are two modes of operation:

* Periodical: the syncing process will be executed in a fixed interval
* Manual: there is a script you can run to trigger the syncing once

## Prerequisite

You have to install python-ldap library in your system.

For Debian or Ubuntu

```
sudo apt-get install python-ldap

```

For CentOS or RedHat

```
sudo yum install python-ldap

```

## Syncing Groups

### Configuration

Before enabling LDAP group sync, you should have configured LDAP authentication. See [Configure Seafile to use LDAP](using_ldap_pro.md) for details.

The following are LDAP group sync related options. They're in the "\[ldap_sync]" section of [ccnet.conf](../config/ccnet-conf.md).

Below are summary of options for syncing groups:

* **ENABLE_GROUP_SYNC**: set to "true" if you want to enable ldap group syncing
* **GROUP_OBJECT_CLASS**: This is the name of the class used to search for group objects. In Active Directory, it's usually "group"; in OpenLDAP or others, you may use "groupOfNames","groupOfUniqueNames" or "posixGroup", depends on your LDAP server. The default value is "group".
* **SYNC_INTERVAL**: The interval to sync. Unit is minutes. You can set it to 60, which means that data is synchronized from the LDAP/AD server every 60 minutes.
* **GROUP_FILTER**: An additional filter to use when searching group objects. If it's set, the final filter used to run search is "(&(objectClass=GROUP_OBJECT_CLASS)(GROUP_FILTER))"; otherwise the final filter would be "(objectClass=GROUP_OBJECT_CLASS)".
* **GROUP_MEMBER_ATTR**: The attribute field to use when loading the group's members. For most directory servers, the attributes is "member", which is the default value.For "posixGroup", it should be set to "memberUid".
* **USER_ATTR_IN_MEMBERUID**: The user attribute set in 'memberUid' option, which is used in "posixGroup".The default value is "uid".
* **DEL_GROUP_IF_NOT_FOUND**: set to "true", will deleted the groups if not found it in LDAP/AD server; need Seafile-pro-6.3.0 and above version
* **SYNC_GROUP_AS_DEPARTMENT**: In 6.3.8 version, a new option SYNC_GROUP_AS_DEPARTMENT is added. If this option is set to "true", the groups will be synced as top-level departments in Seafile, instead of simple groups. Learn more about departments in Seafile [here](https://help.seafile.com/en/sharing_collaboration/departments.html).
* **CREATE_DEPARTMENT_LIBRARY**: If you decide to sync the group as a department, you can set this option to "true". In this way, when the group is synchronized for the first time, a library is automatically created for the department, and the library's name is the department's name.
* **DEFAULT_DEPARTMENT_QUOTA**: If you decide to sync the group as a department, you can set a default space quota for each department when you synchronize a group for the first time. The quota is set to unlimited if this option is not set. Unit is MB.
* **DEPT_NAME_ATTR**: Get the department name. You can set this configuration item to an AD field that represents the "department" name, such as "description". The name of the department created by Seafile will be the department name set in the AD field instead of the OU name. Requires Seafile-pro-7.0.11 and above.
* **DEPT_REPO_PERM: **Set the permissions of the department repo. The default permission is 'rw'. Set permissions for the department repo created during AD synchronization. Requires Seafile-pro-7.0.11 and above.

The search base for groups is the "BASE_DN" set in "\[ldap]" section of ccnet.conf.

Some LDAP server, such as Active Directory, allows a group to be a member of another group. This is called "group nesting". If we find a nested group B in group A, we should recursively add all the members from group B into group A. And group B should still be imported a separate group. That is, all members of group B are also members in group A.

In some LDAP server, such as OpenLDAP, it's common practice to use Posix groups to store group membership. To import Posix groups as Seafile groups, set GROUP_OBJECT_CLASS option to posixGroup . A posixGroup  object in LDAP usually contains a multi-value attribute for the list of member UIDs. The name of this attribute can be set with the GROUP_MEMBER_ATTR option. It's MemberUid  by default. The value of the MemberUid  attribute is an ID that can be used to identify a user, which corresponds to an attribute in the user object. The name of this ID attribute is usually uid , but can be set via the USER_ATTR_IN_MEMBERUID option. Note that posixGroup  doesn't support nested groups.

### Example Configurations

Here is an example configuration for syncing nested groups in Active Directory:

```
[LDAP]
HOST = ldap://192.168.1.123/
BASE = cn=users,dc=example,dc=com
USER_DN = administrator@example.local
PASSWORD = secret
LOGIN_ATTR = mail

[LDAP_SYNC]
ENABLE_GROUP_SYNC = true
SYNC_INTERVAL = 60

```

For AD, you usually don't need to configure other options except for "ENABLE_GROUP_SYNC". That's because the default values for other options are the usual values for AD. If you have special settings in your LDAP server, just set the corresponding options.

Here is an example configuration for syncing nested groups (but not PosixGroups) in OpenLDAP:

```
[LDAP]
HOST = ldap://192.168.1.123/
BASE = ou=users,dc=example,dc=com
USER_DN = cn=admin,dc=example,dc=com
PASSWORD = secret
LOGIN_ATTR = mail

[LDAP_SYNC]
ENABLE_GROUP_SYNC = true
SYNC_INTERVAL = 60
GROUP_OBJECT_CLASS = groupOfNames

```

## Sync OU as Departments

A department in Seafile is a special group. In addition to what you can do with a group, there are two key new features for departments:

* Department supports hierarchy. A department can have any levels of sub-departments.
* Department can have storage quota.

Seafile supports syncing OU (Organizational Units) from AD/LDAP to departments. The sync process keeps the hierarchical structure of the OUs.

Options for syncing departments from OU:

* **SYNC_DEPARTMENT_FROM_OU**: set to "true" to enable syncing departments from OU.
* **SYNC_INTERVAL**: The interval to sync. Unit is minutes. You can set it to 60, which means that data is synchronized from the LDAP/AD server every 60 minutes.
* **DEL_DEPARTMENT_IF_NOT_FOUND**: If set to "true", sync process will delete a department if the corresponding OU is not found in AD/LDAP server.
* **CREATE_DEPARTMENT_LIBRARY**: set to "true", if you want to automatically create a department library with the OU name.
* **DEFAULT_DEPARTMENT_QUOTA**: default quota for the imported departments in MB. The quota is set to unlimited if this option is not set.
* **DEPT_NAME_ATTR**: Get the department name. You can set this configuration item to an AD field that represents the "department" name, such as "description". The name of the department created by Seafile will be the department name set in the AD field instead of the OU name. Requires Seafile-pro-7.0.11 and above.
* **DEPT_REPO_PERM: **Set the permissions of the department repo. The default permission is 'rw'. Set permissions for the department repo created during AD synchronization. Requires Seafile-pro-7.0.11 and above.

**NOTE**: Before 6.3.8, an old configuration syntax is used for syncing OU as departments. That syntax is no long supported. The old syntax cannot support syncing both groups and OU from AD/LDAP at the same time. However this is necessary for many situations. With the new syntax, you can sync both.

## Periodical and Manual Sync

Periodical sync won't happen immediately after you restart seafile server. It gets scheduled after the first sync interval. For example if you set sync interval to 30 minutes, the first auto sync will happen after 30 minutes you restarts. To sync immediately, you need to manually trigger it.

After the sync is run, you should see log messages like the following in logs/seafevents.log. And you should be able to see the groups in system admin page.

```
[2015-03-30 18:15:05,109] [DEBUG] create group 1, and add dn pair CN=DnsUpdateProxy,CN=Users,DC=Seafile,DC=local<->1 success.
[2015-03-30 18:15:05,145] [DEBUG] create group 2, and add dn pair CN=Domain Computers,CN=Users,DC=Seafile,DC=local<->2 success.
[2015-03-30 18:15:05,154] [DEBUG] create group 3, and add dn pair CN=Domain Users,CN=Users,DC=Seafile,DC=local<->3 success.
[2015-03-30 18:15:05,164] [DEBUG] create group 4, and add dn pair CN=Domain Admins,CN=Users,DC=Seafile,DC=local<->4 success.
[2015-03-30 18:15:05,176] [DEBUG] create group 5, and add dn pair CN=RAS and IAS Servers,CN=Users,DC=Seafile,DC=local<->5 success.
[2015-03-30 18:15:05,186] [DEBUG] create group 6, and add dn pair CN=Enterprise Admins,CN=Users,DC=Seafile,DC=local<->6 success.
[2015-03-30 18:15:05,197] [DEBUG] create group 7, and add dn pair CN=dev,CN=Users,DC=Seafile,DC=local<->7 success.

```

To trigger LDAP sync manually,

```
cd seafile-server-lastest
./pro/pro.py ldapsync

```



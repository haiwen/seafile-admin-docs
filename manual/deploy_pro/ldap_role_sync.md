# Importing Roles from LDAP/AD

Since version 6.1.5, the Pro Edition supports syncing roles from LDAP or Active Directory.

To enable this feature, add config option `ROLE_NAME_ATTR` to ccnet.conf

```
[LDAP_SYNC]
ROLE_NAME_ATTR = title

```

`ROLE_NAME_ATTR` is the attribute field  to configure roles in LDAP .
We provide a user-defined function to map the role：Create `custom_functions.py` under conf/ and edit it like:

```
#coding=utf-8
import sys 
reload(sys)
sys.setdefaultencoding('utf8')

def ldap_role_mapping(role):
    if 'staff' in role:
        return 'Staff'
    if 'guest' in role:
        return 'Guest'
    if 'manager' in role:
        return 'Manager'

```

you can rewrite this function (in python) to make your own mapping rules. If the file or function doesn't exist, all roles in `ROLE_NAME_ATTR` will be synced.

** NOTE: **Make sure that ccnet-server keeps running while doing LDAP role sync.

Note: If you are using 7.1 version or later, and with Python 3, you should remove the following code from \`custom_functions.py\`:

```
import sys 
reload(sys)
sys.setdefaultencoding('utf8')

```



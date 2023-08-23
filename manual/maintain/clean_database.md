# Clean Database

## Seahub

### Session

Since version 5.0, we offered command to clear expired session records in Seahub database.

For version 7.0 and earlier
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env seahub/manage.py clearsessions
```

For version 7.1 and later
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clearsessions
```

### Activity

To clean the activity records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM Event WHERE to_days(now()) - to_days(timestamp) > 90;
```

The corresponding items in UserEvent will deleted automatically by MariaDB when the foreign keys in Event table are deleted.

Since version 7.0, the table Activity is used intead of Event. Correspondingly, you need to empty the Activity table. 

Use the following command:

```
use seahub_db;
DELETE FROM Activity WHERE to_days(now()) - to_days(timestamp) > 90;
```

The corresponding items in UserActivity will deleted automatically by MariaDB when the foreign keys in Activity table are deleted.

### Login

To clean the login records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM sysadmin_extra_userloginlog WHERE to_days(now()) - to_days(login_date) > 90;
```

### File Access

To clean the file access records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM FileAudit WHERE to_days(now()) - to_days(timestamp) > 90;
```

### File Update

To clean the file update records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM FileUpdate WHERE to_days(now()) - to_days(timestamp) > 90;
```

### Permisson

To clean the permisson records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM PermAudit WHERE to_days(now()) - to_days(timestamp) > 90;
```

### File History

To clean the file history records, login in to MySQL/MariaDB and use the following command:

```
use seahub_db;
DELETE FROM FileHistory WHERE to_days(now()) - to_days(timestamp) > 90;
```

### Command clean_db_records

Since version 8.0, you can use the following command to simultaneously clean up Activity, sysadmin_extra_userloginlog, FileAudit, FileUpdate, FileHistory, PermAudit these 6 tables 90 days ago records:

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clean_db_records

```

### Outdated Library Data

Since version 6.2, we offer command to clear outdated library records in Seahub database,
e.g. records that are not deleted after a library is deleted. This is because users can restore a deleted library, so we can't delete these records at library deleting time.

For version 7.0 and earlier
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env seahub/manage.py clear_invalid_repo_data
```

For version 7.1 and later
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clear_invalid_repo_data
```

This command has been improved in version 10.0, including:

1. It will clear the invalid data in small batch, avoiding consume too much database resource in a short time.

2. Dry-run mode: if you just want to see how much invalid data can be deleted without actually deleting any data, you can use the dry-run option, e.g.

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clear_invalid_repo_data --dry-run=true
```


### Library Sync Tokens

There are two tables in Seafile db that are related to library sync tokens.

* RepoUserToken contains the authentication tokens used for library syncing. Note that a separate token is created for every client (including sync client and SeaDrive.)
* RepoTokenPeerInfo contains more information about each client token, such as client name, IP address, last sync time etc.

When you have many sync clients connected to the server, these two tables can have large number of rows. Many of them are no longer actively used. You may clean the tokens that are not used in a recent period, by the following SQL query:

```
delete t,i from RepoUserToken t, RepoTokenPeerInfo i where t.token=i.token and sync_time < xxxx;
```

xxxx is the UNIX timestamp for the time before which tokens will be deleted.

To be safe, you can first check how many tokens will be removed:

```
select * from RepoUserToken t, RepoTokenPeerInfo i where t.token=i.token and sync_time < xxxx;
```

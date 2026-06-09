# Clean Database

## Session

Use the following command to clear expired session records in Seahub database:

```
cd seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clearsessions
```

!!! tip
    Enter into the docker image, then go to `/opt/seafile/seafile-server-latest`

## Use clean_db_records command to clean seahub_db

Use the clean_db_records command to clean up records older than a specified number of days in the following tables of seahub_db: Activity, sysadmin_extra_userloginlog, FileAudit, FileUpdate, FileHistory, PermAudit, FileTrash.

**Default usage (clean up records older than 90 days)**

By default, the command cleans up records older than 90 days. Use the following command:

```
./seahub.sh python-env python3 seahub/manage.py clean_db_records
```

**Customize the number of days with --ndays parameter**

You can specify the number of days using the --ndays parameter. For example, to clean up records older than 50 days:

```
./seahub.sh python-env python3 seahub/manage.py clean_db_records --ndays=50
```

You can also clean these tables manually if you like as following.

### Activity

Use the following command to clear the activity records:

```
use seahub_db;
DELETE FROM Activity WHERE to_days(now()) - to_days(timestamp) > 90;
DELETE FROM UserActivity WHERE to_days(now()) - to_days(timestamp) > 90;
```

### Login

Use the following command to clean the login records:

```
use seahub_db;
DELETE FROM sysadmin_extra_userloginlog WHERE to_days(now()) - to_days(login_date) > 90;
```

### File Access

Use the following command to clean the file access records:

```
use seahub_db;
DELETE FROM FileAudit WHERE to_days(now()) - to_days(timestamp) > 90;
```

### File Update

Use the following command to clean the file update records:

```
use seahub_db;
DELETE FROM FileUpdate WHERE to_days(now()) - to_days(timestamp) > 90;
```

### Permisson

Use the following command to clean the permission change audit records:

```
use seahub_db;
DELETE FROM PermAudit WHERE to_days(now()) - to_days(timestamp) > 90;
```

### File History

Use the following command to clean the file history records:

```
use seahub_db;
DELETE FROM FileHistory WHERE to_days(now()) - to_days(timestamp) > 90;
```



## Clean outdated library data

Since version 6.2, we offer command to clear outdated library records in Seafile database, e.g. records that are not deleted after a library is deleted. This is because users can restore a deleted library, so we can't delete these records at library deleting time.

```
./seahub.sh python-env python3 seahub/manage.py clear_invalid_repo_data
```

This command has been improved in version 10.0, including:

1. It will clear the invalid data in small batch, avoiding consume too much database resource in a short time.

2. Dry-run mode: if you just want to see how much invalid data can be deleted without actually deleting any data, you can use the dry-run option, e.g.

```
./seahub.sh python-env python3 seahub/manage.py clear_invalid_repo_data --dry-run=true
```


## Clean library sync tokens

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

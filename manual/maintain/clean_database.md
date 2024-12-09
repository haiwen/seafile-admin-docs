# Clean Database

## Seahub

### Session

Since version 5.0, we offered command to clear expired session records in Seahub database.

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clearsessions
```

### Clean DB Records

Since version 8.0, we offer command to clear login, activity, file access, file update, file history and permisson records in Seahub database.

For version 8.0, all records older that 90 days will be deleted
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clean_db_records
```

For version 10 and later there is an keep days option, all records that are older that this will be deleted.
```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python3 seahub/manage.py clean_db_records --days 120
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

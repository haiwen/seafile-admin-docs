# Upgrade notes for 11.0 (Draft)

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](../docker/upgrade/upgrade_docker.md)

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

* For Ubuntu 20.04/22.04

```sh

```


## Upgrade to 11.0.x

#### 1) Stop Seafile-10.0.x server.

#### 2) Start from Seafile 11.0.x, run the script:

```sh
upgrade/upgrade_10.0_11.0.sh
```
   
Change configurations for LDAP

Change configuration for OAuth

#### 3) Start Seafile-11.0.x server.

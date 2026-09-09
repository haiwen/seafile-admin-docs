# Upgrade notes

These notes give an overview about changes for each major version.


## Upgrade notes for 14.0

### Important release changes

Seafile version 14.0 has the following configuration changes:

* WebDAV is configured via environment variables in the Seafile server `.env`. 
* Metadata server is configured via environment variables in the Seafile server `.env`. 
* Seafile AI models are configured via `seafile_ai_config.yaml`.
* Face recognition has been removed. 
* Thumbnail server configurations in `seahub_settings.py` have changed. Please refer to [Thumbnail server](../extension/thumbnail-server.md) for details.
* SeaSearch is the default search engine for new Seafile Pro Docker deployments, and authorization configurations of search can also be set in environment variables.
* Local-password policy for externally authenticated users is now controlled by `DISABLE_SSO_USER_LOCAL_PWD_LOGIN` in `seahub_settings.py`.

### Seafile AI configuration changes

Seafile AI configuration has been significantly changed in Seafile 14.0.

1. LLM configuration is moved from the Seafile `.env` file to `$SEAFILE_VOLUME/seafile/conf/seafile_ai_config.yaml`. After `LLM_MODELS` is configured, remove the following legacy model environment variables:

    ```env
    SEAFILE_AI_LLM_TYPE=
    SEAFILE_AI_LLM_URL=
    SEAFILE_AI_LLM_KEY=
    SEAFILE_AI_LLM_MODEL=
    ```

    Configure one or more models in `LLM_MODELS` instead. Set one model as the default and assign model tiers as needed.

2. The following environment variables are added for Seafile AI:

    ```env
    INNER_METADATA_SERVER_URL=
    SEASEARCH_URL=
    SEASEARCH_TOKEN=

    SEAFILE_MYSQL_DB_HOST=
    SEAFILE_MYSQL_DB_PORT=
    SEAFILE_MYSQL_DB_USER=
    SEAFILE_MYSQL_DB_PASSWORD=
    SEAFILE_MYSQL_DB_CCNET_DB_NAME=
    SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=
    SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=

    SEAF_SERVER_STORAGE_TYPE=
    S3_COMMIT_BUCKET=
    S3_FS_BUCKET=
    S3_BLOCK_BUCKET=
    S3_KEY_ID=
    S3_SECRET_KEY=
    S3_USE_V4_SIGNATURE=
    S3_AWS_REGION=
    S3_HOST=
    S3_USE_HTTPS=
    S3_PATH_STYLE_REQUEST=
    S3_SSE_C_KEY=
    ```

3. Face recognition and the face-embedding service have been removed. Remove the following configuration and any `face-embedding.yml` file from your `COMPOSE_FILE` setting:

    ```env
    ENABLE_FACE_RECOGNITION=
    FACE_EMBEDDING_SERVICE_URL=
    FACE_EMBEDDING_SERVICE_KEY=
    FACE_EMBEDDING_VOLUME=
    ```

For configuration details, refer to [Seafile AI extension](../extension/seafile-ai.md).

### Local password configuration changes

The following `seahub_settings.py` options have been removed in Seafile 14.0:

```python
DISABLE_ADFS_USER_PWD_LOGIN = True
ENABLE_CHANGE_PASSWORD = True
ENABLE_SSO_USER_CHANGE_PASSWORD = True
```

Remove these options from `seahub_settings.py`. To prevent users authenticated through external providers from using passwords stored in Seafile, add the following option instead:

```python
DISABLE_SSO_USER_LOCAL_PWD_LOGIN = True # default: False
```

When enabled, this option disables local-password login and local password change/reset operations for users authenticated through SAML/ADFS, OAuth, LDAP, and so on. 

### Search configuration changes

From Seafile 14.0 Pro, the [SeaSearch](https://seasearch-manual.seacloud-labs.ai/) becomes the default-enabled search engine.

SeaSearch and Elasticsearch configurations are moved from seafevents.conf to `.env` file.

`ENABLE_FULL_TEXT_SEARCH` controls document-content indexing for both engines and defaults to `true`. Set it to `false` if you need file-name-only search.

See [Search with SeaSearch](../setup/use_seasearch.md) and [Search with ElasticSearch](../setup/use_elasticsearch.md) for configuration details.


## Upgrade notes for 13.0

### Important release changes

Seafile version 13.0 has following major changes:

* SeaDoc: SeaDoc is now version 2.0, beside support sdoc, it support whiteboard too
* Thumbnail server: A new thumbnail server component is added to improve performance for thumbnail generating and support thumbnail for videos
* Metadata server: A new metadata server component is avaible to manage extended file properties
* Notification server: The web interface now support real-time update when other people add or remove files if notification-server is enabled
* SeaSearch: SeaSearch is now version 1.0 and support full-text search


Configuration changes:

* Database and memcache configurations are added to `.env`, it is recommended to use environment variables to config database and memcache
* Redis is recommended to be used as memcache server
* (Optional) S3 configuration can be done via environment variables and is much simplified
* Elastic search is now have its own yml file
* The Nginx bundled in seafile docker image no longer generates and reads configurations from mapped volume. The Nginx is used for servering static files in Seahub, and map the ports of different components in seafile docker image to a single 80 port.

Breaking changes

* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The old file tags feature can no longer be used, the interface provide an upgrade notice for migrate the data to the new file tags feature


Deploying Seafile with binary package is no longer supported for community edition. We recommend you to migrate your existing Seafile deployment to docker based.


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 13.0


## Upgrade notes for 12.0


Seafile version 12.0 has following major changes:

* A redesigned Web UI
* SeaDoc is now stable, providing online notes and documents feature
* A new wiki module
* A new trash mechanism, that deleted files will be recorded in database for fast listing. In the old version, deleted files are scanned from library history, which is slow.
* Community edition now also support online GC (because SQLite support is dropped)


Configuration changes:

* Notification server is now packaged into its own docker image.
* For binary package based installation, a new `.env` file is needed to contain some configuration items. These configuration items need to be shared by different components in Seafile. We name it `.env` to be consistant with docker based installation.
* The password strength level is now calculated by algorithm. The old USER_PASSWORD_MIN_LENGTH, USER_PASSWORD_STRENGTH_LEVEL is removed. Only USER_STRONG_PASSWORD_REQUIRED is still used.
* ADDITIONAL_APP_BOTTOM_LINKS is removed. Because there is no buttom bar in the navigation side bar now.
* SERVICE_URL and FILE_SERVER_ROOT are removed. SERVICE_URL will be calculated from SEAFILE_SERVER_PROTOCOL and SEAFILE_SERVER_HOSTNAME in `.env` file.
* `ccnet.conf` is removed. Some of its configuration items are moved from `.env` file, others are read from items in `seafile.conf` with same name.
* Two role permissions are added, `can_create_wiki` and `can_publish_wiki` are used to control whether a role can create a Wiki and publish a Wiki. The old role permission `can_publish_repo` is removed.
* REMOTE_USER header is not passed to Seafile by default, you need to change `gunicorn.conf.py` if you need REMOTE_USER header for SSO.

Other changes:

* A new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.


Breaking changes

* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.
* For ElasticSearch based search, full text search of doc/xls/ppt file types are no longer supported. This enable us to remove Java dependency in Seafile side.
* The search dialog now support loading more items when scroll down and the original separate detailed file search page is no longer used
* The right side panel is redesigned and the seldom used file comments feature in the panel is removed

Deploying Seafile with binary package is now deprecated and probably no longer be supported in version 13.0. We recommend you to migrate your existing Seafile deployment to docker based.


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 12.0


## Uggrade notes for 11.0

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

You need to run `migrate_ldapusers.py` script to merge ccnet_db.LDAPImported table to ccnet_db.EmailUsers table. The setting files need to be changed manually. (See more details below)

### OAuth authentication and other SSO methods

If you use OAuth authentication, the configuration need to be changed a bit.

If you use SAML, you don't need to change configuration files. For SAML2, in version 10, the name_id field is returned from SAML server, and is used as the username (the email field in ccnet_dbEmailUser). In version 11, for old users, Seafile will find the old user and create a name_id to name_id mapping in social_auth_usersocialauth. For new users, Seafile will create a new user with random ID and add a name_id to the random ID mapping in social_auth_usersocialauth. In addition, we have added a feature where you can configure to disable login with a username and password for saml users by using the config of `DISABLE_ADFS_USER_PWD_LOGIN = True` in seahub_settings.py.



### Dropped SQLite Database Support

Seafile 11.0 **dropped** using SQLite as the database. It is better to migrate from SQLite database to MySQL database before upgrading to version 11.0.

There are several reasons driving this change:

* Focus on collaborative features - SQLite's limitations make advanced concurrency and locking difficult, which collaborative editing requires. Different Seafile components need simultaneous database access. Especially after adding seafevents component in version 11.0 for the community edition.
* Docker deployments - Our official Docker images do not support SQLite. MySQL is the preferred option.
* Migration difficulties - Migrating SQLite databases to MySQL via SQL translation is unreliable.

To migrate from SQLite database to MySQL database, you can follow the document [Migrate from SQLite to MySQL](../setup_binary/migrate_from_sqlite_to_mysql.md). If you have issues in the migration, just post a thread in our forum. We are glad to help you.


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 11.0

### New SAML prerequisites (MULTI_TENANCY only)

For Ubuntu 20.04/22.04

```sh
sudo apt-get update
sudo apt-get install -y dnsutils
```


### Django CSRF protection issue

Django 4.* has introduced a new check for the origin http header in CSRF verification. It now compares the values of the origin field in HTTP header and the host field in HTTP header. If they are different, an error is triggered.

If you deploy Seafile behind a proxy, or if you use a non-standard port, or if you deploy Seafile in cluster, it is likely the **origin** field in HTTP header received by Django and the **host** field in HTTP header received by Django are different. Because the **host** field in HTTP header is likely to be modified by proxy. This mismatch results in a CSRF error.

You can add CSRF_TRUSTED_ORIGINS to seahub_settings.py to solve the problem:

```
CSRF_TRUSTED_ORIGINS = ["https://<your-domain>"]
```

## Upgrade notes for 10.0


### Enable notification server

The notification server enables desktop syncing and drive clients to get notification of library changes immediately using websocket. There are two benefits:

1. Reduce the time for syncing new changes to local
2. Reduce the load of the server as periodically pulling is removed. There are significant reduction of load when you have 1000+ clients. 

The notification server works with Seafile syncing client 9.0+ and drive client 3.0+.

Please follow the document to [enable notification server](../extension/notification-server.md)

### Memcached section in the seafile.conf (pro edition only)

If you use storage backend or cluster, make sure the memcached section is in the seafile.conf.

Since version 10.0, all memcached options are consolidated to the one below.

Modify the seafile.conf:

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

### SAML SSO change (pro edition only)

The configuration for SAML SSO in Seafile is greatly simplified. Now only three options are needed:

```
ENABLE_ADFS_LOGIN = True
LOGIN_REDIRECT_URL = '/saml2/complete/'
SAML_REMOTE_METADATA_URL = 'https://login.microsoftonline.com/xxx/federationmetadata/2007-06/federationmetadata.xml?appid=xxx'
SAML_ATTRIBUTE_MAPPING = {
    'name': ('display_name', ),
    'mail': ('contact_email', ),
    ...
}
```

Please check the new document on [SAML SSO](../config/saml2_in_10.0.md)

### Rate control in role settings (pro edition only)

Starting from version 10.0, Seafile allows administrators to configure upload and download speed limits for users with different roles through the following two steps:

1. Configuring rate limiting for different roles in `seahub_settings.py`.

```
ENABLED_ROLE_PERMISSIONS = {
    'default': {
	...
        'upload_rate_limit': 2000,  # unit: kb/s
        'download_rate_limit': 4000,
	...
    },
    'guest': {
	...
        'upload_rate_limit': 100,
        'download_rate_limit': 200,
	...
    },
}
```

2. Run the following command in the `seafile-server-latest` directory to make the configuration take effect.

```
./seahub.sh python-env python3 seahub/manage.py set_user_role_upload_download_rate_limit
```

### ElasticSearch change (pro edition only)

Elasticsearch is upgraded to version 8.x, fixed and improved some issues of file search function.

Since elasticsearch 7.x, the default number of shards has changed from 5 to 1, because too many index shards will over-occupy system resources; but when a single shard data is too large, it will also reduce search performance. Starting from version 10.0, Seafile supports customizing the number of shards in the configuration file.

You can use the following command to query the current size of each shard to determine the best number of shards for you:

```
curl 'http{s}://<es IP>:9200/_cat/shards/repofiles?v'
```

The official recommendation is that the size of each shard should be between 10G-50G: <https://www.elastic.co/guide/en/elasticsearch/reference/8.6/size-your-shards.html#shard-size-recommendation>.

Modify the seafevents.conf:

```
[INDEX FILES]
...
shards = 10     # default is 5
...
```

# Upgrade notes for 12.0

- These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

- For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

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


Other changes:

* A new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.


Breaking changes

* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.
* For ElasticSearch based search, full text search of doc/xls/ppt file types are no longer supported. This enable us to remove Java dependency in Seafile side.


Deploying Seafile with binary package is now deprecated and probably no longer be supported in version 13.0. We recommend you to migrate your existing Seafile deployment to docker based.


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 12.0

## New system libraries

=== "Ubuntu 24.04/22.04"

    ```sh
    apt-get install -y default-libmysqlclient-dev build-essential pkg-config libmemcached-dev
    ```

=== "Debian 11"
    ```sh
    apt-get install -y libsasl2-dev
    ```


## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

=== "Ubuntu 24.04 / Debian 12"

    ```sh
    sudo pip3 install future==1.0.* mysqlclient==2.2.* pillow==10.4.* sqlalchemy==2.0.* pillow_heif==0.18.0 \
    gevent==24.2.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* \
    pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 python-ldap==3.4.*
    ```

=== "Ubuntu 22.04 / Debian 11"

    ```sh
    sudo pip3 install future==1.0.* mysqlclient==2.1.* pillow==10.4.* sqlalchemy==2.0.* pillow_heif==0.18.0 \
    gevent==24.2.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* \
    pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.2.0
    ```


## Upgrade to 12.0 (for binary installation)

The following instruction is for binary package based installation. If you use Docker based installation, please see [*Updgrade Docker*](./upgrade_docker.md)

### 1) Clean database tables before upgrade

If you have a large number of `Activity` in MySQL, clear this table first [Clean Database](../../administration/clean_database). Otherwise, the database upgrade will take a long time.

### 2) Install new system libraries and Python libraries

Install new system libraries and Python libraries for your operation system as documented above.


### 3) Stop Seafile-11.0.x server

In the folder of Seafile 11.0.x, run the commands:

```sh
./seahub.sh stop
./seafile.sh stop
```

### 4) Run Seafile 12.0.x upgrade script

In the folder of Seafile 12.0.x, run the upgrade script

```sh
upgrade/upgrade_11.0_12.0.sh
```

### 5) Create the `.env` file in `conf/` directory

conf/.env

```env
TIME_ZONE=UTC
JWT_PRIVATE_KEY=xxx
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=seafile.example.com
SEAFILE_MYSQL_DB_HOST=db # your MySQL host
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=<your MySQL password>
SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db
SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db
SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db
```

!!! tip
    JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, can be generated by
    
    ```sh
    pwgen -s 40 1
    ```

### 6) Start Seafile-12.0.x server

In the folder of Seafile 12.0.x, run the command:

```
./seafile.sh start # starts seaf-server
./seahub.sh start  # starts seahub
```

### 7) (Optional) Upgrade notification server

Since seafile 12.0, we use docker to deploy the notification server. Please follow the document of [notification server](../extension/notification-server.md) to re-deploy notification server.

!!! note Notification server and Seafile binary package

    Notification server is designed to be work with Docker based deployment. To make it work with **Seafile binary package** on the same server, you will need to add Nginx rules for notification server properly.


### 8) (Optional) Upgrade SeaDoc from 0.8 to 1.0

If you have deployed SeaDoc v0.8 with Seafile v11.0, you can upgrade it to 1.0 use the following two steps:

1. Delete sdoc_db.
2. Re-deploy SeaDoc server. In other words, delete the old SeaDoc deployment and re-deploy a new SeaDoc server.

!!! note "SeaDoc and Seafile binary package"

    Deploying SeaDoc and **Seafile binary package** on the same server is no longer officially supported. You will need to add Nginx rules for SeaDoc server properly.


#### 8.1) Delete sdoc_db

From version 1.0, SeaDoc is using seahub_db database to store its operation logs and no longer need an extra database sdoc_db. The database tables in seahub_db are created automatically when you upgrade Seafile server from v11.0 to v12.0. You can simply delete sdoc_db.

#### 8.2) Deploy a new SeaDoc server

Please see the document [Setup SeaDoc](../extension/setup_seadoc.md) to install SeaDoc on a separate machine and integrate with your binary packaged based Seafile server v12.0.


### 9) (Optional) Update `gunicorn.conf.py` file in `conf/` directory

If you deployed single sign on (SSO) by Shibboleth protocol, the following line should be added to the gunicorn config file.

```python

forwarder_headers = 'SCRIPT_NAME,PATH_INFO,REMOTE_USER'
```


## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

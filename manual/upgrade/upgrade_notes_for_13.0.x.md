# Upgrade notes for 13.0

- These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

- For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

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

## New system libraries

=== "Ubuntu 24.04/22.04"

    ```sh
    apt-get install -y python3 python3-dev python3-setuptools python3-pip python3-ldap python3-rados libmysqlclient-dev memcached libmemcached-dev redis-server libhiredis-dev ldap-utils libldap2-dev python3.12-venv default-libmysqlclient-dev build-essential pkg-config
    ```

=== "Debian 12/13"
    ```sh
    apt-get install -y python3 python3-dev python3-setuptools python3-pip python3-ldap python3-rados libmariadb-dev-compat memcached libmemcached-dev redis-server libhiredis-dev ldap-utils libldap2-dev libsasl2-dev pkg-config python3.13-venv
    ```


## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

=== "Ubuntu 24.04 / Debian 12"

    ```sh
    pip3 install --timeout=3600 boto3 oss2 twilio configparser pytz \
    sqlalchemy==2.0.* pymysql==1.1.* jinja2 django-pylibmc pylibmc redis django-redis psd-tools lxml \
    django==5.2.* cffi==1.17.1 future==1.0.* mysqlclient==2.2.* captcha==0.7.* django_simple_captcha==0.6.* \
    pyjwt==2.10.* djangosaml2==1.11.* pysaml2==7.5.* pycryptodome==3.23.* python-ldap==3.4.* pillow==11.3.* pillow-heif==1.0.* cairosvg==2.8.*
    ```

## Upgrade to 13.0 (for binary installation)

The following instruction is for binary package based installation. If you use Docker based installation, please see [*Updgrade Docker*](./upgrade_docker.md)

### 1) Clean database tables before upgrade

If you have a large number of `Activity` in MySQL, clear this table first [Clean Database](../../administration/clean_database). Otherwise, the database upgrade will take a long time.

### 2) Install new system libraries and Python libraries

Install new system libraries and Python libraries for your operation system as documented above.


### 3) Stop Seafile-12.0.x server

In the folder of Seafile 12.0.x, run the commands:

```sh
./seahub.sh stop
./seafile.sh stop
```

### 4) Run Seafile 13.0.x upgrade script

In the folder of Seafile 13.0.x, run the upgrade script

```sh
upgrade/upgrade_12.0_13.0.sh
```

### 5) Modify the `.env` file in `conf/` directory

conf/.env

```env
JWT_PRIVATE_KEY=<Your jwt private key>
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=seafile.example.com
SEAFILE_MYSQL_DB_HOST=<your database host>
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=<your MySQL password>
SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db
SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db
SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db

## Cache
CACHE_PROVIDER=redis # options: redis (recommend), memcached

### Redis
REDIS_HOST='<your redis host>'
REDIS_PORT=6379
REDIS_PASSWORD=

### Memcached
MEMCACHED_HOST='<your memcached host>'
MEMCACHED_PORT=11211
```

!!! tip
    Redis is recommended as the cache server, you need to install the following dependencies.
    
    ```sh
    apt-get install -y redis-server libhiredis-dev
    
    # activate the venv
    source python-venv/bin/activate
    pip3 install redis django-redis

    systemctl enable --now redis-server
    ```

    If you are using memcached as the cache server, you need to install the following dependencies.

    ```sh
    apt-get install memcached libmemcached-dev -y
    
    # activate the venv
    source python-venv/bin/activate
    pip3 install pylibmc django-pylibmc
    
    systemctl enable --now memcached
    ```
    

!!! tip
    JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, can be generated by
    
    ```sh
    pwgen -s 40 1
    ```

### 6) Start Seafile-13.0.x server

In the folder of Seafile 13.0.x, run the command:

```
./seafile.sh start # starts seaf-server
./seahub.sh start  # starts seahub
```

### 7) (Optional) Upgrade notification server

Since seafile 12.0, we use docker to deploy the notification server. Please follow the document of [notification server](../extension/notification-server.md) to re-deploy notification server.

!!! note Notification server and Seafile binary package

    Notification server is designed to be work with Docker based deployment. To make it work with **Seafile binary package** on the same server, you will need to add Nginx rules for notification server properly.

### 8) (Optional) Upgrade SeaDoc from 1.0 to 2.0

Since seafile 12.0, we use docker to deploy the seadoc server. Please see the document [Setup SeaDoc](../extension/setup_seadoc.md) to install SeaDoc on a separate machine and integrate with your binary packaged based Seafile server v13.0.

!!! note "SeaDoc and Seafile binary package"

    Deploying SeaDoc and **Seafile binary package** on the same server is no longer officially supported. You will need to add Nginx rules for SeaDoc server properly.


## FAQ

We have documented common issues encountered by users when upgrading to version 13.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

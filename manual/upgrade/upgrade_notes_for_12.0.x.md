# Upgrade notes for 12.0 (In progress)

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 12.0 has following major changes:

* A redesigned Web UI
* SeaDoc is now stable, providing online notes and documents feature
* A new wiki module (still in beta, disabled by default)
* A new trash mechanism, that deleted files will be recorded in database for fast listing. In the old version, deleted files are scanned from library history, which is slow.

Other changes:

* A new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.

Breaking changes

* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* The password strength level is now calculated by algorithm. The old USER_PASSWORD_MIN_LENGTH, USER_PASSWORD_STRENGTH_LEVEL is removed. Only USER_STRONG_PASSWORD_REQUIRED is still used.
* For binary package based installation, a new `.env` file is needed to contain some configuration items. These configuration items need to be shared by different components in Seafile. We name it `.env` to be consistant with docker based installation.
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.

Deploying SeaDoc and Seafile binary package on the same server is no longer supported. You can:

* Deploy SeaDoc on a new server and integrate it with Seafile.
* Migrate Seafile to a docker based deployment method and then deploy SeaDoc in the same server.

Deploying Seafile with binary package is now deprecated and probably no longer be supported in version 13.0. We recommend you to migrate your existing Seafile deployment to docker based.


### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 12.0

## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

For Ubuntu 22.04/24.04

```sh
sudo pip3 install future==1.0.* mysqlclient==2.2.* pillow==10.4.* sqlalchemy==2.0.* gevent==24.2.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 python-ldap==3.4.* PyMuPDF==1.24.*
```

## Upgrade to 12.0.x

### 1) Stop Seafile-11.0.x server

### 2) Start from Seafile 12.0.x, run the script

```sh
upgrade/upgrade_11.0_12.0.sh
```

### 3) Create the `.env` file in conf/ directory

conf/.env

```env
JWT_PRIVATE_KEY=xxx
```

Note: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`

### 4) Start Seafile-12.0.x server

## Upgrade SeaDoc from 0.8 to 1.0

If you have deployed SeaDoc extension in version 11.0, please use the following steps to upgrade it to version 1.0.

Deploying SeaDoc and Seafile binary package on the same server is no longer supported. You can:

* Deploy SeaDoc on a new server and integrate it with Seafile.
* Migrate Seafile to a docker based deployment method and then deploy SeaDoc in the same server.

If you have deployed SeaDoc extension in version 11.0 on a standalone server, please use the following steps to upgrade it to version 1.0.

### Delete sdoc_db

From version 1.0, SeaDoc is using seahub_db database to store its operation logs and no longer need an extra database sdoc_db. You can simply delete sdoc_db.


### Deploy a new SeaDoc server

In version 1.0, we use env file to configure SeaDoc docker image, instead of modifying the docker-compose.yml file directly.

Download [.env](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/env) and [docker-compose.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/docker-compose.yml), then modify .env file.

The following fields merit particular attention:

* Seafile MySQL host (SEAFILE_MYSQL_DB_HOST)
* Seafile MySQL user (SEAFILE_MYSQL_DB_USER)
* Seafile MySQL password (SEAFILE_MYSQL_DB_PASSWD)
* The volume directory of SeaDoc data (SEADOC_VOLUMES)
* SeaDoc service URL (SDOC_SERVER_HOSTNAME)
* Seafile service URL (SEAHUB_SERVICE_URL)

Start SeaDoc server with the following command

```sh
docker compose up -d
```

## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

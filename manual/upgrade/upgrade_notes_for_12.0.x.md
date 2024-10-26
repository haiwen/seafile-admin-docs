---
status: new
---

# Upgrade notes for 12.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 12.0 has following major changes:

* A redesigned Web UI
* SeaDoc is now stable, providing online notes and documents feature
* A new wiki module (still in beta, disabled by default)
* A new trash mechanism, that deleted files will be recorded in database for fast listing. In the old version, deleted files are scanned from library history, which is slow.
* Community edition now also support online GC (because SQLite support is dropped)

Other changes:

* A new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.

Breaking changes

* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* The password strength level is now calculated by algorithm. The old USER_PASSWORD_MIN_LENGTH, USER_PASSWORD_STRENGTH_LEVEL is removed. Only USER_STRONG_PASSWORD_REQUIRED is still used.
* For binary package based installation, a new `.env` file is needed to contain some configuration items. These configuration items need to be shared by different components in Seafile. We name it `.env` to be consistant with docker based installation.
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.
* For ElasticSearch based search, full text search of doc/xls/ppt file types are no longer supported. This enable us to remove Java dependency in Seafile side.

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
sudo pip3 install future==1.0.* mysqlclient==2.2.* pillow==10.4.* sqlalchemy==2.0.* gevent==24.2.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 python-ldap==3.4.* PyMuPDF==1.24.* numpy==1.26.*
```

## Upgrade to 12.0 (for binary installation)

The following instruction is for binary package based installation. If you use Docker based installation, please see [](./upgrade_docker.md)

### 1) Stop Seafile-11.0.x server

### 2) Start from Seafile 12.0.x, run the script

```sh
upgrade/upgrade_11.0_12.0.sh
```

### 3) Create the `.env` file in conf/ directory

conf/.env

```env
JWT_PRIVATE_KEY=xxx
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=seafile.example.com
```

Note: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`

### 4) Start Seafile-12.0.x server

## Upgrade SeaDoc from 0.8 to 1.0

If you have deployed SeaDoc v0.8 with Seafile v11.0, you can upgrade it to 1.0 use the following two steps:

1. Delete sdoc_db.
2. Re-deploy SeaDoc server. In other words, delete the old SeaDoc deployment and deploy a new SeaDoc server on a separate machine.

Note, deploying SeaDoc and **Seafile binary package** on the same server is no longer supported. If you really want to deploying SeaDoc and Seafile server on the same machine, you should deploy Seafile server with Docker.

### Delete sdoc_db

From version 1.0, SeaDoc is using seahub_db database to store its operation logs and no longer need an extra database sdoc_db. The database tables in seahub_db are created automatically when you upgrade Seafile server from v11.0 to v12.0. You can simply delete sdoc_db.

### Deploy a new SeaDoc server

Please see the document [Setup SeaDoc](../extension/setup_seadoc.md) to install SeaDoc on a separate machine and integrate with your binary packaged based Seafile server v12.0.


## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

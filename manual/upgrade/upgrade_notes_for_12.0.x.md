# Upgrade notes for 12.0 (In progress)

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 12.0 has four major changes:

* A redesigned Web UI
* Easy deployment of SeaDoc
* A new wiki module (still in beta, disabled by default)
* A new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.
* WebDAV no longer support login with LDAP account, the user must generate a WebDAV token at the profile page

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

### 3) Start Seafile-12.0.x server

## Upgrade SeaDoc from 0.8 to 1.0

If you have deployed SeaDoc extension in version 11.0, please use the following steps to upgrade it to version 1.0.

SeaDoc 1.0 is for working with Seafile 12.0.

### Backup SeaDoc files

Stop SeaDoc and backup files

```sh
docker compose down

mv /opt/seadoc-data/ /opt/seadoc-data-bak/
```

### Update the docker compose file

In version 1.0, we use .env file to configure SeaDoc docker image, instead of modifying the docker-compose.yml file directly.

Make sure you have installed Seafile 12.0.

Download [.env](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/env), [docker-compose.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/docker-compose.yml) and [caddy.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/caddy.yml), then modify .env file.

The following fields merit particular attention:

* Seafile MySQL host (SEAFILE_MYSQL_DB_HOST)
* Seafile MySQL user (SEAFILE_MYSQL_DB_USER)
* Seafile MySQL password (SEAFILE_MYSQL_DB_PASSWD)
* The volume directory of SeaDoc data (SEADOC_VOLUMES)
* The volume directory of Caddy data (SEAFILE_CADDY_VOLUMES)
* SeaDoc service URL (SEADOC_SERVER_HOSTNAME)
* Seafile service URL (SEAFILE_SERVER_HOSTNAME)
* jwt (JWT_PRIVATE_KEY, the same in Seafile .env)

Start SeaDoc server with the following command

```sh
docker compose up -d
```

## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

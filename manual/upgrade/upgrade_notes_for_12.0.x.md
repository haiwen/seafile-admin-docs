# Upgrade notes for 12.0 (In progress)

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 12.0 has four major changes:

* a new redesigned Web UI
* easy deployment of SeaDoc
* a new wiki module (still in beta)
* a new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.

### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 11.0

## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

For Ubuntu 20.04/24.04

```sh
sudo pip3 install future==1.0.* mysqlclient==2.2.* pillow==10.4.* sqlalchemy==2.0.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 python-ldap==3.4.*
```

## Upgrade to 12.0.x

### 1) Stop Seafile-11.0.x server

### 2) Start from Seafile 12.0.x, run the script

```sh
upgrade/upgrade_11.0_12.0.sh
```

### 3) Start Seafile-12.0.x server

## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

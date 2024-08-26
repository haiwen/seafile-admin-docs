# Upgrade Seafile Docker

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 10.0 to 11.0, see instructions below.

Please check the **upgrade notes** for any special configuration or changes before/while upgrading.

## Upgrade from 11.0 to 12.0 (In progress)

From Seafile Docker 12.0, we recommend that you use `.env` and `docker-compose.yml` files for configuration. Download [.env](https://manual.seafile.com/docker/docker-compose/ce/12.0/.env) and [docker-compose.yml](https://manual.seafile.com/docker/docker-compose/ce/12.0/docker-compose.yml), then modify .env file.

The following fields merit particular attention:

* The password of MySQL root (SEAFILE_MYSQL_ROOT_PASSWORD)
* The volume directory of MySQL data (SEAFILE_MYSQL_VOLUMES)
* The volume directory of Seafile data (SEAFILE_VOLUMES).

Start with docker compose up.

### Upgrade SeaDoc from 0.8 to 1.0 for Seafile v12.0

If you have deployed SeaDoc extension in version 11.0, please use the following steps to upgrade it to version 1.0.

SeaDoc 1.0 is for working with Seafile 12.0.

#### Change the DB_NAME

From version 1.0, SeaDoc is using seahub_db database to store its operation logs and no longer need an extra database sdoc_db. You need to change the `DB_NAME` to `seahub_db` in the config file manually.

conf/sdoc_server_config.json

```json
"database": "seahub_db"
```

#### Update the docker compose file

In version 1.0, we use env file to configure SeaDoc docker image, instead of modifying the docker-compose.yml file directly.

Use one of the following method to upgrade the docker compose file depends on your current deployment method.

##### For deployment where SeaDoc is on a separate host

Make sure you have installed Seafile 12.0, then backup old SeaDoc docker-compose.yml file.

```sh
mv docker-compose.yml docker-compose.yml.bak
```

Download [.env](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/.env) and [docker-compose.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/docker-compose.yml), then modify .env file.

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

##### For deployment where SeaDoc and Seafile docker are on the same host

Make sure you have installed Seafile Docker 12.0.

Download [seadoc.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/seadoc.yml) to the Seafile path, then modify Seafile .env file.

Note: modify the `COMPOSE_FILE` field, and add all other fields.

```env
COMPOSE_FILE='docker-compose.yml,seadoc.yml'


SEADOC_IMAGE=seafileltd/sdoc-server:1.0-latest
SEADOC_VOLUMES=/opt/seadoc-data

SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWD=PASSWORD

SEAHUB_SERVICE_URL=http://seafile.example.com
```

The following fields merit particular attention:

* Seafile MySQL user (SEAFILE_MYSQL_DB_USER)
* Seafile MySQL password (SEAFILE_MYSQL_DB_PASSWD)
* The volume directory of SeaDoc data (SEADOC_VOLUMES)
* Seafile service URL (SEAHUB_SERVICE_URL)

Start Seafile server and SeaDoc server with the following command

```sh
docker compose up -d
```

## Upgrade from 10.0 to 11.0

Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Taking the [community edition](../docker/deploy_seafile_with_docker.md) as an example, you have to modify

```yml
...
service:
    ...
    seafile:
        image: seafileltd/seafile-mc:10.0-latest
        ...
    ...
```

to

```yml
service:
    ...
    seafile:
        image: seafileltd/seafile-mc:11.0-latest
        ...
    ...
```

 It is also recommended that you upgrade **mariadb** and **memcached** to newer versions as in the v11.0 docker-compose.yml file. Specifically, in version 11.0, we use the following versions:

- MariaDB: 10.11
- Memcached: 1.6.18

What's more, you have to migrate configuration for LDAP and OAuth according to <https://manual.seafile.com/upgrade/upgrade_notes_for_11.0.x>

Start with docker compose up.

## Upgrade from 9.0 to 10.0

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

If you are using pro edition with ElasticSearch, SAML SSO and storage backend features, follow the upgrading manual on how to update the configuration for these features: <https://manual.seafile.com/upgrade/upgrade_notes_for_10.0.x>

If you want to use the new notification server and rate control (pro edition only), please refer to the upgrading manual: <https://manual.seafile.com/upgrade/upgrade_notes_for_10.0.x>

## Upgrade from 8.0 to 9.0

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

### Let's encrypt SSL certificate

Since version 9.0.6, we use Acme V3 (not acme-tiny) to get certificate.

If there is a certificate generated by an old version, you need to back up and move the old certificate directory and the seafile.nginx.conf before starting.

```shell
mv /opt/seafile/shared/ssl /opt/seafile/shared/ssl-bak

mv /opt/seafile/shared/nginx/conf/seafile.nginx.conf /opt/seafile/shared/nginx/conf/seafile.nginx.conf.bak
```

Starting the new container will automatically apply a certificate.

```shell
docker compose down
docker compose up -d
```

Please wait a moment for the certificate to be applied, then you can modify the new seafile.nginx.conf as you want. Execute the following command to make the nginx configuration take effect.

```sh
docker exec seafile nginx -s reload
```

A cron job inside the container will automatically renew the certificate.

## Upgrade from 7.1 to 8.0

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

## Upgrade from 7.0 to 7.1

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

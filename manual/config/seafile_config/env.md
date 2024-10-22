# .env

The `.env` file will be used to specify the components used by the Seafile-docker instance and the environment variables required by each component. The default contents list in below

```shell
COMPOSE_FILE='seafile-server.yml,caddy.yml'
COMPOSE_PATH_SEPARATOR=','


SEAFILE_IMAGE=docker.seadrive.org/seafileltd/seafile-pro-mc:12.0-latest
SEAFILE_DB_IMAGE=mariadb:10.11
SEAFILE_MEMCACHED_IMAGE=memcached:1.6.29
SEAFILE_ELASTICSEARCH_IMAGE=elasticsearch:8.15.0 # pro edition only
SEAFILE_CADDY_IMAGE=lucaslorentz/caddy-docker-proxy:2.9

SEAFILE_VOLUME=/opt/seafile-data
SEAFILE_MYSQL_VOLUME=/opt/seafile-mysql/db
SEAFILE_ELASTICSEARCH_VOLUME=/opt/seafile-elasticsearch/data # pro edition only
SEAFILE_CADDY_VOLUME=/opt/seafile-caddy

SEAFILE_MYSQL_DB_HOST=db
SEAFILE_MYSQL_ROOT_PASSWORD=ROOT_PASSWORD
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD

TIME_ZONE=Etc/UTC

JWT_PRIVATE_KEY=

SEAFILE_SERVER_HOSTNAME=example.seafile.com
SEAFILE_SERVER_PROTOCOL=https

SEAFILE_ADMIN_EMAIL=me@example.com
SEAFILE_ADMIN_PASSWORD=asecret


SEADOC_IMAGE=seafileltd/sdoc-server:1.0-latest
SEADOC_VOLUME=/opt/seadoc-data

ENABLE_SEADOC=false
SEADOC_SERVER_URL=http://example.seafile.com/sdoc-server
```

## Seafile-docker configurations

### Components configurations

- `COMPOSE_FILE`: `.yml` files for components of [Seafile-docker](../setup/overview.md), each `.yml` must be separated by the symbol defined in `COMPOSE_PATH_SEPARATOR`. The core components are involved in `seafile-server.yml` and `caddy.yml` which must be taken in this term.
- `COMPOSE_PATH_SEPARATOR`: The symbol used to separate the `.yml` files in term `COMPOSE_FILE`, default is ','.

### Docker images configurations

- `SEAFILE_IMAGE`: The image of Seafile-server, default is `docker.seadrive.org/seafileltd/seafile-pro-mc:12.0-latest`.
- `SEAFILE_DB_IMAGE`: Database server image, default is `mariadb:10.11`.
- `SEAFILE_MEMCACHED_IMAGE`: Cached server image, default is `memcached:1.6.29`
- `SEAFILE_ELASTICSEARCH_IMAGE`: Only valid in pro edition. The elasticsearch image, default is `elasticsearch:8.15.0`.
- `SEAFILE_CADDY_IMAGE`: Caddy server image, default is `lucaslorentz/caddy-docker-proxy:2.9`.
- `SEADOC_IMAGE`: Only valid after integrating [SeaDoc](../../extension/extra_components/setup_seadoc.md). SeaDoc server image, default is `seafileltd/sdoc-server:1.0-latest`.

### Persistent Volume Configurations

- `SEAFILE_VOLUME`: The volume directory of Seafile data, default is `/opt/seafile-data`.
- `SEAFILE_MYSQL_VOLUME`: The volume directory of MySQL data, default is `/opt/seafile-mysql/db`.
- `SEAFILE_CADDY_VOLUME`: The volume directory of Caddy data used to store certificates obtained from Let's Encrypt's, default is `/opt/seafile-caddy`.
- `SEAFILE_ELASTICSEARCH_VOLUME`: Only valid in pro edition. The volume directory of Elasticsearch data, default is `/opt/seafile-elasticsearch/data`.
- `SEADOC_VOLUME`: Only valid after integrating [SeaDoc](../../extension/extra_components/setup_seadoc.md). The volume directory of [SeaDoc server data](../../extension/extra_components/setup_seadoc.md#seadoc-directory-structure), default is `/opt/seadoc-data`.

## MySQL configurations

- `SEAFILE_MYSQL_DB_HOST`: The host address of Mysql, default is the pre-defined service name `db` in Seafile-docker instance.
- `SEAFILE_MYSQL_ROOT_PASSWORD`: The `root` password of MySQL.
- `SEAFILE_MYSQL_DB_USER`: The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`).
- `SEAFILE_MYSQL_DB_PASSWORD`: The user `seafile` password of MySQL.

## Seafile-server configurations

- `SEAFILE_MYSQL_DB_PASSWORD`: The user `seafile` password of MySQL
- `JWT`: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`
- `SEAFILE_SERVER_HOSTNAME`: Seafile server hostname or domain
- `SEAFILE_SERVER_PROTOCOL`: Seafile server protocol (http or https)
- `TIME_ZONE`: Time zone (default UTC)
- `SEAFILE_ADMIN_EMAIL`: Admin username
- `SEAFILE_ADMIN_PASSWORD`: Admin password

## SeaDoc configurations (only valid after integrating SeaDoc)

- `ENABLE_SEADOC`: Enable the SeaDoc server or not, default is `false`.
- `SEADOC_SERVER_URL`: Only valid in `ENABLE_SEADOC=true`. Url of Seadoc server (e.g., http://example.seafile.com/sdoc-server).

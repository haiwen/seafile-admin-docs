# .env

The [`.env`](../repo/docker/pro/env) file will be used to specify the components used by the Seafile-docker instance and the environment variables required by each component.

## Seafile-docker configurations

### Components configurations

- `COMPOSE_FILE`: `.yml` files for components of [Seafile-docker](../setup/overview.md), each `.yml` must be separated by the symbol defined in `COMPOSE_PATH_SEPARATOR`. The core components are involved in `seafile-server.yml` and `caddy.yml` which must be taken in this term.
- `COMPOSE_PATH_SEPARATOR`: The symbol used to separate the `.yml` files in term `COMPOSE_FILE`, default is ','.

### Docker images configurations

- `SEAFILE_IMAGE`: The image of Seafile-server, default is `seafileltd/seafile-pro-mc:12.0-latest`.
- `SEAFILE_DB_IMAGE`: Database server image, default is `mariadb:10.11`.
- `SEAFILE_MEMCACHED_IMAGE`: Cached server image, default is `memcached:1.6.29`
- `SEAFILE_ELASTICSEARCH_IMAGE`: Only valid in pro edition. The elasticsearch image, default is `elasticsearch:8.15.0`.
- `SEAFILE_CADDY_IMAGE`: Caddy server image, default is `lucaslorentz/caddy-docker-proxy:2.9-alpine`.
- `SEADOC_IMAGE`: Only valid after integrating [SeaDoc](../extension/setup_seadoc.md). SeaDoc server image, default is `seafileltd/sdoc-server:1.0-latest`.
- `NON_ROOT`: Run Seafile container without a root user, default is `false`

### Persistent Volume Configurations

- `SEAFILE_VOLUME`: The volume directory of Seafile data, default is `/opt/seafile-data`.
- `SEAFILE_MYSQL_VOLUME`: The volume directory of MySQL data, default is `/opt/seafile-mysql/db`.
- `SEAFILE_CADDY_VOLUME`: The volume directory of Caddy data used to store certificates obtained from Let's Encrypt's, default is `/opt/seafile-caddy`.
- `SEAFILE_ELASTICSEARCH_VOLUME`: Only valid in pro edition. The volume directory of Elasticsearch data, default is `/opt/seafile-elasticsearch/data`.
- `SEADOC_VOLUME`: Only valid after integrating [SeaDoc](../extension/setup_seadoc.md). The volume directory of [SeaDoc server data](../extension/setup_seadoc.md#seadoc-directory-structure), default is `/opt/seadoc-data`.

## MySQL configurations

- `SEAFILE_MYSQL_DB_HOST`: The host address of Mysql, default is the pre-defined service name `db` in Seafile-docker instance.
- `SEAFILE_MYSQL_DB_PORT`: The port of Mysql, default is `3306`.
- `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`: (Only required on first deployment) The `root` password of MySQL. 
- `SEAFILE_MYSQL_DB_USER`: The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`).
- `SEAFILE_MYSQL_DB_PASSWORD`: The user `seafile` password of MySQL.
- `SEAFILE_MYSQL_DB_SEAFILE_DB_NAME`: The name of Seafile database name, default is `seafile_db`
- `SEAFILE_MYSQL_DB_CCNET_DB_NAME`: The name of ccnet database name, default is `ccnet_db`
- `SEAFILE_MYSQL_DB_SEAHUB_DB_NAME`: The name of seahub database name, default is `seahub_db`

## Cache configurations

- `CACHE_PROVIDER`: The type of cache server used for Seafile. The available options are `redis` and `memcached`. Since Seafile 13, it is recommended to use `redis` as the cache service to support new features, and `memcached` will no longer be integrated into Seafile Docker by default. Default is `redis`

### Redis configurations

This part of configurations is only valid in `CACHE_PROVIDER=redis`:

- `REDIS_HOST`: Redis server host, default is `redis`
- `REDIS_PORT`: Redis server port, default is `6379`
- `REDIS_PASSWORD`: Redis server password. 

### Memcached configurations

This part of configurations is only valid in `CACHE_PROVIDER=memcached`:

- `MEMCACHED_HOST`: Memcached server host, default is `memcached`
- `MEMCACHED_PORT`: Memcached server port, default is `11211`

## Seafile-server configurations

- `JWT_PRIVATE_KEY`: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`
- `SEAFILE_SERVER_HOSTNAME`: Seafile server hostname or domain
- `SEAFILE_SERVER_PROTOCOL`: Seafile server protocol (http or https)
- `TIME_ZONE`: Time zone (default `UTC`)
- `INIT_SEAFILE_ADMIN_EMAIL`: Admin username
- `INIT_SEAFILE_ADMIN_PASSWORD`: Admin password

## SeaDoc configurations (only valid after integrating SeaDoc)

- `ENABLE_SEADOC`: Enable the SeaDoc server or not, default is `false`.
- `SEADOC_SERVER_URL`: Only valid in `ENABLE_SEADOC=true`. Url of Seadoc server (e.g., http://seafile.example.com/sdoc-server).

## S3 storage backend configurations (pro)

- `SEAF_SERVER_STORAGE_TYPE`: What kind of the Seafile data for storage. Available options are `disk` (i.e., local disk), `s3` and `multiple` (see the details of [multiple storage backends](../setup/setup_with_multiple_storage_backends.md))
- `S3_COMMIT_BUCKET`: S3 storage backend fs objects bucket
- `S3_FS_BUCKET`: S3 storage backend block objects bucket
- `S3_BLOCK_BUCKET`: S3 storage backend block objects bucket
- `S3_SS_BUCKET`: S3 storage bucket for SeaSearch data (valid when service enabled)
- `S3_MD_BUCKET`: S3 storage bucket for metadata-sever data (valid when service available)
- `S3_KEY_ID`: S3 storage backend key ID
- `S3_SECRET_KEY`: S3 storage backend secret key
- `S3_USE_V4_SIGNATURE`: Use the v4 protocol of S3 if enabled, default is `true`
- `S3_AWS_REGION`: Region of your buckets (AWS only), default is `us-east-1`.
- `S3_HOST`: Host of your buckets (required when not use AWS).
- `S3_USE_HTTPS`: Use HTTPS connections to S3 if enabled, default is `true`
- `S3_PATH_STYLE_REQUEST`: This option asks Seafile to use URLs like `https://192.168.1.123:8080/bucketname/object` to access objects. In *Amazon S3*, the default URL format is in virtual host style, such as `https://bucketname.s3.amazonaws.com/object`. But this style relies on advanced DNS server setup. So most self-hosted storage systems only implement the path style format. Default `false`.
- `S3_SSE_C_KEY`: A string of 32 characters can be generated by openssl rand -base64 24. It can be any 32-character long random string. It's required to use V4 authentication protocol and https if you enable SSE-C.

!!! success "Easier to configure S3 for Seafile and its components"
    Since Seafile Pro 13.0, in order to facilitate users to deploy Seafile's related extension components and other services in the future, a section will be provided in `.env` to store the **S3 Configurations** for Seafile and some extension components (such as *SeaSearch*, *Metadata server*). You can locate it with the title bar **Storage configurations for S3**.

!!! warning "S3 configurations in `.env` only support single S3 storage backend mode"
    The Seafile server only support configuring S3 in `.env` for **single S3 storage backend mode** (i.e., when `SEAF_SERVER_STORAGE_TYPE=s3`). If you would like to use other storage backend (e.g., [Ceph](./setup_with_ceph.md), [Swift](./setup_with_swift.md)) or other settings that can only be set in `seafile.conf` (like [multiple storage backends](./setup_with_multiple_storage_backends.md)), please set `SEAF_SERVER_STORAGE_TYPE` to `multiple`, and set `MD_STORAGE_TYPE` and `SS_STORAGE_TYPE` according to your configurations.

!!! note "The S3 configurations only valid with at least one `STORAGE_TYPE` has specified to `s3`"
    Now there are three (pro) and one (cluster) ***STORAGE_TYPE*** we provided in `.env`:
        - SEAF_SERVER_STORAGE_TYPE (pro & cluster)
        - MD_STORAGE_TYPE (pro, see the [Metadata server](#metadata-server) section for the details)
        - SS_STORAGE_TYPE (pro, see the [SeaSearch](#seasearch) section for the details)
        
    You have to specify at least one of them as s3 for the above configuration to take effect.

## SeaSearch

For configurations about SeaSearch in `.env`, please refer [here](https://seasearch-manual.seafile.com/config/) for the details.

## Metadata server

For configurations about Metadata server in `.env`, please refer [here](../extension/metadata-server.md#list-of-environment-variables-of-metadata-server) for the details.

## Notification server

- `NOTIFICATION_SERVER_URL`: The [notification server](../extension/notification-server.md) url, leave blank to disable it (default).

## Cluster init configuration 

- `CLUSTER_INIT_MODE`: (only valid in pro edition at deploying first time). Cluster initialization mode, in which the necessary configuration files for the service to run will be generated (but **the service will not be started**). If the configuration file already exists, no operation will be performed. The default value is `true`. When the configuration file is generated, ***be sure to set this item to `false`***.
- `CLUSTER_INIT_ES_HOST`: (only valid in pro edition at deploying first time). Your cluster Elasticsearch server host.
- `CLUSTER_INIT_ES_PORT`: (only valid in pro edition at deploying first time). Your cluster Elasticsearch server port. Default is `9200`.
- `CLUSTER_MODE`: Seafile service node type, i.e., `frontend` (default) or `backend`.

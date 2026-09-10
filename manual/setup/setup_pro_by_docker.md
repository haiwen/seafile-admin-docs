# Installation of Seafile Server Professional Edition with Docker

This manual explains how to deploy and run Seafile Server Professional Edition (Seafile PE) on a Linux server using Docker and Docker Compose. The deployment has been tested for Debian/Ubuntu and CentOS, but Seafile PE should also work on other Linux distributions.

## System requirements

Please refer [here](./system_requirements.md#seafile-pro) for system requirements about Seafile PE. In general, we recommend that you have at least 4G RAM and a 4-core CPU (> 2GHz).

!!! tip "About license"
    Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at [sales@seafile.com](mailto:sales@seafile.com). For futher details, please refer the [license page](../setup_binary/seafile_professional_sdition_software_license_agreement.md) of Seafile PE.

## Setup

The following assumptions and conventions are used in the rest of this document:

- `/opt/seafile` is the directory of Seafile for storing Seafile docker files. If you decide to put Seafile in a different directory, adjust all paths accordingly.
- Seafile uses two [Docker volumes](https://docs.docker.com/storage/volumes/) for persisting data generated in its database and Seafile Docker container. The volumes' [host paths](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes) are /opt/seafile-mysql and /opt/seafile-data, respectively. It is not recommended to change these paths. If you do, account for it when following these instructions.
- All configuration and log files for Seafile and the webserver Nginx are stored in the volume of the Seafile container.

### Installing Docker

Use the [official installation guide for your OS to install Docker](https://docs.docker.com/engine/install/).

### Downloading the Seafile Image

!!! success "Standard deployment"
    Since v12.0, Seafile PE versions are hosted on DockerHub and does not require username and password to download. For ***older Seafile PE*** versions are available private docker repository (back to Seafile 7.0). You can get the username and password on the download page in the [Customer Center](https://customer.seafile.com/downloads).

```bash
docker pull seafileltd/seafile-pro-mc:14.0-latest
```
    
### Downloading and Modifying `.env`

Seafile uses `.env`, `seafile-server.yml`  and `caddy.yml` files for configuration.

```bash
mkdir /opt/seafile
cd /opt/seafile

wget -O .env https://manual.seafile.com/14.0/repo/docker/pro/env
wget https://manual.seafile.com/14.0/repo/docker/pro/seafile-server.yml
wget https://manual.seafile.com/14.0/repo/docker/pro/seasearch.yml
wget https://manual.seafile.com/14.0/repo/docker/seadoc.yml
wget https://manual.seafile.com/14.0/repo/docker/caddy.yml

nano .env
```

Only change the required settings below for a standard deployment. Keep all other values in the template at their defaults unless you need one of the optional configurations described later.

#### Required settings

!!! success "Easier deployment"
    For a standard deployment, updating only the settings in this section is sufficient to deploy Seafile.

| Variable | Description | Value |
| --- | --- | --- |
| `SEAFILE_SERVER_HOSTNAME` | Public hostname or domain of the Seafile server. | Required |
| `JWT_PRIVATE_KEY` | Random string of at least 32 characters. Generate one with `pwgen -s 40 1`. | Required |
| `SEAFILE_MYSQL_DB_PASSWORD` | Password for the Seafile MySQL user. | Required |
| `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` | MySQL `root` password. | Required on first deployment only |
| `INIT_SEAFILE_ADMIN_EMAIL` | Initial Seafile administrator username. | Required on first deployment only |
| `INIT_SEAFILE_ADMIN_PASSWORD` | Initial Seafile administrator password. | Required on first deployment only |
| `SEASEARCH_TOKEN` | Authorization token for the SeaSearch API. Generate from `echo -n 'INIT_SEAFILE_ADMIN_EMAIL:INIT_SEAFILE_ADMIN_PASSWORD' | base64` | Required |

!!! note "Custom SeaSearch user"
    In default, the SeaSearch first user will take:
    - `INIT_SS_ADMIN_USER` = `INIT_SEAFILE_ADMIN_EMAIL`
    - `INIT_SS_ADMIN_PASSWORD` = `INIT_SEAFILE_ADMIN_PASSWORD`

    You can use custom user by modifying the `INIT_SS_ADMIN_USER` and `INIT_SS_ADMIN_PASSWORD`, then set the `SEASEARCH_TOKEN` from:

    ```sh
    echo -n 'INIT_SS_ADMIN_USER:INIT_SS_ADMIN_PASSWORD'
    ```

#### Common optional settings

| Variable | Description | Default |
| --- | --- | --- |
| `BASIC_STORAGE_PATH` | Base directory for Docker persistent data. The derived data, database, Caddy, and SeaSearch paths normally do not need to be changed individually. | `/opt` |
| `SEAFILE_SERVER_PROTOCOL` | Public server protocol: `http` or `https`. | `http` |
| `TIME_ZONE` | Time zone used by the containers. | `Etc/UTC` |

#### Database settings

| Variable | Description | Default Value |
| --- | --- | --- |
| `SEAFILE_MYSQL_DB_HOST` | The host of MySQL. | `db` |
| `SEAFILE_MYSQL_DB_PORT` | The port of MySQL. | `3306` |
| `SEAFILE_MYSQL_DB_USER` | The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`). | `seafile` |

`SEAFILE_MYSQL_DB_PASSWORD` is required and listed above. For database names and other database settings, see [environment variables](../config/env.md#mysql-configurations).

#### Cache service settings

Seafile Docker uses its integrated Redis service by default, so no cache settings need to be changed for a standard deployment.

| Variable | Description | Default Value |
| --- | --- | --- |
| `CACHE_PROVIDER` | The type of cache server used by Seafile. Available options are `redis` and `memcached`. | `redis` |
| `REDIS_HOST` | The host of Redis. | `redis` |
| `REDIS_PORT` | The port of Redis. | `6379` |
| `REDIS_PASSWORD` | The password of Redis. | (none) |

!!! note "Recommended Redis since Seafile 13.0"
    Since Seafile 13.0, many new features depend on Redis as the cache server. Starting with Seafile 14.0, we do not recommend using Memcached as the cache server. If you need to use Memcached, see [environment variables](../config/env.md#cache-configurations) for its configuration.

#### Storage backend settings

!!! success "Easier to configure S3 for Seafile and its components"
    Since Seafile Pro 13.0, in order to facilitate users to deploy Seafile's related extension components and other services in the future, a section will be provided in `.env` to store the **S3 Configurations** for Seafile and some extension components (such as *SeaSearch*, *Metadata server*). You can locate it with the title bar **Storage configurations for S3**.

!!! warning "S3 configurations in `.env` only support single S3 storage backend mode"
    The Seafile server only support configuring S3 in `.env` for **single S3 storage backend mode** (i.e., when `SEAF_SERVER_STORAGE_TYPE=s3`). If you would like to use other storage backend (e.g., [Ceph](./setup_with_ceph.md), [Swift](./setup_with_swift.md)) or other settings that can only be set in `seafile.conf` (like [multiple storage backends](./setup_with_multiple_storage_backends.md)), please set `SEAF_SERVER_STORAGE_TYPE` to `multiple`, and set `MD_STORAGE_TYPE` and `SS_STORAGE_TYPE` according to your configurations.

| Variable | Description | Default Value |
| --- | --- | --- |
| `SEAF_SERVER_STORAGE_TYPE` | Type of storage used for Seafile data. Available options are `disk` (local disk), `s3`, and `multiple`. | `disk` |
| `S3_COMMIT_BUCKET` | S3 storage backend bucket for commit objects. | Required when `SEAF_SERVER_STORAGE_TYPE=s3` |
| `S3_FS_BUCKET` | S3 storage backend bucket for fs objects. | Required when `SEAF_SERVER_STORAGE_TYPE=s3` |
| `S3_BLOCK_BUCKET` | S3 storage backend bucket for block objects. | Required when `SEAF_SERVER_STORAGE_TYPE=s3` |
| `S3_KEY_ID` | S3 storage backend access key ID. | Required when `SEAF_SERVER_STORAGE_TYPE=s3` |
| `S3_SECRET_KEY` | S3 storage backend secret access key. | Required when `SEAF_SERVER_STORAGE_TYPE=s3` |
| `S3_HOST` | Host of the S3-compatible storage service. | Required when using S3 other than AWS |

For all S3 connection options, see [environment variables](../config/env.md#s3-storage-backend-configurations-pro). For multiple storage backends, set `SEAF_SERVER_STORAGE_TYPE=multiple` and follow [multiple storage backends](./setup_with_multiple_storage_backends.md).

#### Search settings

| Variable | Description | Default Value |
| --- | --- | --- |
| `ENABLE_SEARCH` | Enable or disable the search service. | `true` |
| `SEARCH_ENGINE` | Search engine to use. Available options are `seasearch` and `elasticsearch`. | `seasearch` |
| `INIT_SS_ADMIN_USER` | SeaSearch administrator username, used only on first deployment. | Same as `INIT_SEAFILE_ADMIN_EMAIL` |
| `INIT_SS_ADMIN_PASSWORD` | SeaSearch administrator password, used only on first deployment. | Same as `INIT_SEAFILE_ADMIN_PASSWORD` |
| `SEASEARCH_URL` | SeaSearch URL reachable from the Seafile container. | `http://seasearch:4080` |
| `SEASEARCH_TOKEN` | Authorization token for the SeaSearch API. | See [Search with SeaSearch](./use_seasearch.md#enable-seasearch-in-seafile) |

!!! tip "Recommended SeaSearch since Seafile 13.0"
    Starting with Seafile 14.0, we recommend using [SeaSearch](https://seasearch-manual.seacloud-labs.ai/) as the search engine. If you need to use Elasticsearch, set `SEARCH_ENGINE=elasticsearch` and refer to [Search with Elasticsearch](./use_elasticsearch.md) for its configuration.

SeaSearch cache and log settings should retain their defaults. For SeaSearch configuration details, see [Search with SeaSearch](./use_seasearch.md).

#### Optional extension settings

The template includes settings for optional services such as SeaDoc, the [notification server](../extension/notification-server.md), and [metadata server](../extension/metadata-server.md). Leave these disabled unless you are deploying the corresponding service. For a complete list of environment variables, see [environment variables](../config/env.md).

For component storage, use `MD_STORAGE_TYPE` and `S3_MD_BUCKET` for the metadata server, or `SS_STORAGE_TYPE` and `S3_SS_BUCKET` for SeaSearch. These settings use the shared `S3_*` credentials and connection options in the same `.env` file.

### Starting the Docker Containers

Run docker compose in detached mode:

```bash
docker compose up -d
```

!!! warning "ERROR: Named volume "xxx" is used in service "xxx" but no declaration was found in the volumes section"
    You may encounter this problem when your Docker (or docker-compose) version is out of date. You can upgrade or reinstall the Docker service to solve this problem according to the [Docker official documentation](https://docs.docker.com/engine/install/).


!!! note
    You must run the above command in the directory with the `.env`. If `.env` file is elsewhere, please run

    ```sh
    docker compose --env-file /path/to/.env up -d
    ```

!!! success
    After starting the services, you can see the initialization progress by tracing the logs of container `seafile` (i.e., `docker logs seafile -f`)

    ```
    ---------------------------------
    This is your configuration
    ---------------------------------

        server name:            seafile
        server ip/domain:       seafile.example.com

        seafile data dir:       /opt/seafile/seafile-data
        fileserver port:        8082

        database:               create new
        ccnet database:         ccnet_db
        seafile database:       seafile_db
        seahub database:        seahub_db
        database user:          seafile


    Generating seafile configuration ...

    done
    Generating seahub configuration ...

    ----------------------------------------
    Now creating seafevents database tables ...

    ----------------------------------------
    ----------------------------------------
    Now creating ccnet database tables ...

    ----------------------------------------
    ----------------------------------------
    Now creating seafile database tables ...

    ----------------------------------------
    ----------------------------------------
    Now creating seahub database tables ...

    ----------------------------------------

    creating seafile-server-latest symbolic link ...  done

    -----------------------------------------------------------------
    Your seafile server configuration has been finished successfully.
    -----------------------------------------------------------------

    ``` 
    
    And then you can see the following messages which the Seafile server starts successfully:

    ```
    Starting seafile server, please wait ...
    Seafile server started

    Done.

    Starting seahub at port 8000 ...

    ----------------------------------------
    Successfully created seafile admin
    ----------------------------------------

    Seahub is started

    Done.
    ```

    Finially, you can go to `http://seafile.example.com` to use Seafile.

!!! tip "A 502 Bad Gateway error means that the system has not yet completed the initialization"

### Find logs

To view Seafile docker logs, please use the following command

```shell
docker compose logs -f
```

The Seafile logs are under `/shared/logs/seafile` in the docker, or `/opt/seafile-data/logs/seafile` in the server that run the docker.

The system logs are under `/shared/logs/var-log`, or `/opt/seafile-data/logs/var-log` in the server that run the docker.

### Activating the Seafile License

If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container. The volumne's default path in the Compose file is `/opt/seafile-data`. If you have modified the path, save the license file under your custom path.

!!! danger "If the license file has a different name or cannot be read, Seafile server will start with in trailer mode with most THREE users"

Then restart Seafile:

```bash
docker compose down

docker compose up -d
```

## Seafile directory structure

### Path `/opt/seafile-data`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files and upload directory outside. This allows you to rebuild containers easily without losing important information.

* /opt/seafile-data/seafile: This is the directory for seafile server configuration, logs and data.
  * /opt/seafile-data/seafile/logs: This is the directory that would contain the log files of seafile server processes. For example, you can find seaf-server logs in `/opt/seafile-data/seafile/logs/seafile.log`.
* /opt/seafile-data/logs: This is the directory for operating system and Nginx logs.
  * /opt/seafile-data/logs/var-log: This is the directory that would be mounted as `/var/log` inside the container. For example, you can find the nginx logs in `/opt/seafile-data/logs/var-log/nginx/`.

### Reviewing the Deployment

The command `docker container list` should list the containers specified in the `.env`.

The directory layout of the Seafile container's volume should look as follows:

```bash
$ tree /opt/seafile-data -L 2
/opt/seafile-data
├── logs
│   └── var-log
├── nginx
│   └── conf
└── seafile
    ├── ccnet
    ├── conf
    ├── logs
    ├── pro-data
    ├── seafile-data
    └── seahub-data
```

All Seafile config files are stored in `/opt/seafile-data/seafile/conf`. The nginx config file is in `/opt/seafile-data/nginx/conf`.

Any modification of a configuration file requires a restart of Seafile to take effect:

```bash
docker compose restart
```

All Seafile log files are stored in `/opt/seafile-data/seafile/logs` whereas all other log files are in `/opt/seafile-data/logs/var-log`.

## Backup and Recovery

Follow the instructions in [Backup and restore for Seafile Docker](../administration/backup_recovery.md)

## Garbage Collection

When files are deleted, the blocks comprising those files are not immediately removed as there may be other files that reference those blocks (due to the magic of deduplication). To remove them, Seafile requires a ['garbage collection'](../administration/seafile_gc.md) process to be run, which detects which blocks no longer used and purges them.

## FAQ

### Seafile service and container maintenance

Q: If I want enter into the Docker container, which command I can use?

A: You can enter into the docker container using the command:

```bash
docker exec -it seafile /bin/bash
```


Q: I forgot the Seafile admin email address/password, how do I create a new admin account?

A: You can create a new admin account by running

```shell
docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh
```

The Seafile service must be up when running the superuser command.


Q: If, for whatever reason, the installation fails, how do I to start from a clean slate again?

A: Remove the directories /opt/seafile, /opt/seafile-data and /opt/seafile-mysql and start again.


Q: Something goes wrong during the start of the containers. How can I find out more?

A: You can view the docker logs using this command: `docker compose logs -f`.

### About cache

Q: How Seafile use cache?

A: Seafile uses cache to improve performance in many situations. The content includes but is not limited to user session information, avatars, profiles, records from database, etc. From Seafile Docker 13, the ***Redis*** takes the default cache server for supporting the new features (please refer the ***upgradte notes***), which has integrated in Seafile Docker 13 and can be configured directly in environment variables in `.env` (**no additional settings are required by default**)

Q: Is the Redis integrated in Seafile Docker safe? Does it have an access password?

A: Although the Redis integrated by Seafile Docker does not have a password set by default, it can only be accessed through the Docker private network and will not expose the service port externally. Of course, you can also set a password for it if necessary. You can set `REDIS_PASSWORD` in `.env` and remove the following comment markers in `seafile-server.yml` to set the integrated Redis' password:

```yml
services:
    ...
    redis:
    image: ${SEAFILE_REDIS_IMAGE:-redis}
    container_name: seafile-redis
    # remove the following comment markers
    command:
        - /bin/sh
        - -c
        - redis-server --requirepass "$${REDIS_PASSWORD:?Variable is not set or empty}"
    networks:
    - seafile-net
    ...
```

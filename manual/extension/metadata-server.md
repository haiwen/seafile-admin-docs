# Metadata server

Metadata server aims to provide metadata management for your libraries, so as to better understand the relevant information of your libraries.

## Deployment

!!! note "Prerequisites"
    The startup of Metadata server requires using ***Redis*** as the cache server (it should be the default cache server in Seafile 13.0). So you must deploy *Redis* for Seafile, then modify [`seafile.conf`](../config/seafile-conf.md#cache-pro-edition-only), [`seahub_settings.py`](https://docs.djangoproject.com/en/4.2/topics/cache/#redis) and [`seafevents.conf`](../config/seafevents-conf.md) to enable it before deploying metadata server.

### Download docker-compose file

Please download the file by following command:

=== "Deploy in the same machine with Seafile"

    !!! note
        You have to download this file to the directory same as `seafile-server.yml`

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/md-server.yml
    ```

=== "Standalone"

    !!! note
        For standalone deployment (usually used in cluster deployment), the metadata server only supports Seafile using the storage backend such as **S3**. 

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/metadata-server/md-server.yml
    wget -O .env https://manual.seafile.com/13.0/repo/docker/metadata-server/env
    ```

### Modify `.env`

Metadata server read all configurations from environtment and **does not need a dedicated configuration file**, and you don't need to add additional variables to your `.env` (except for standalone deployment) to get the metadata server started, because it will read the exact same configuration as the Seafile server (including `JWT_PRIVATE_KEY` ) and keep the repository metadata locally (default `/opt/seafile-data/seafile/md-data`). But you still need to modify the `COMPOSE_FILE` list in `.env`, and add `md-server.yml` to enable the metadata server:

```
COMPOSE_FILE='...,md-server.yml'
```

The following table is all the related environment variables with metadata-server:

| Variables           | Description                                                                                                                | Required |
| --- | --- | --- |
| `JWT_PRIVATE_KEY`   | The JWT key used to connect with Seafile server | **Required** |
| `MD_MAX_CACHE_SIZE` | The maximum cache size.                                                                                                    | Optional, default `1GB`            |
| `MD_STORAGE_TYPE`   | The type of Seafile backend storage. Options: `file` (local storage), `s3`, `oss`.                                                 | Optional, default `file` and `s3` in deploying metadata server in the same machine with Seafile and standalone respective |
| `REDIS_SERVER`        | Your *Redis* service host.                                                                                                 | Optional, default `redis`          |
| `REDIS_PORT`        | Your *Redis* service port.                                                                                                 | Optional, default `6379`           |
| `REDIS_PASSWORD`    | Your *Redis* access password.                                                                                              | Optional                |

And here is other optional values according to your `MD_STORAGE_TYPE` setting:

- `MD_STORAGE_TYPE=file` (only for deploying the metadata server in the same machine with Seafile)

    | Variables           | Description                                                                                                                | Required |
    | --- | --- | --- |
    | `SEAFILE_VOLUME`           | Directory for Seafile data | Optional, default `/opt/seafile-data`   |


- `MD_STORAGE_TYPE=s3`

    | Variables           | Description                                                                                                                | Required |
        | --- | --- | --- |
    | `MD_S3_HOST`        | Host of s3 backend.                                                                                                        | Optional                |
    | `MD_S3_AWS_REGION`  | Region of *AWS* s3 backend.                                                                                                | Optional                |
    | `MD_S3_USE_HTTPS`   | Use https connecting to S3 backend.                                                                                        | Optional, default `true`          |
    | `MD_S3_BUCKET`      | Name of S3 bucket for storaging metadata.                                                                                 |  **Required** |
    | `MD_S3_PATH_STYLE_REQUEST` | S3 backend use path style request.                                                                                 | Optional, default `false`          |
    | `MD_S3_KEY_ID`      | S3 backend authorization key ID.                                                                                           | **Required** |
    | `MD_S3_KEY`         | S3 backend authorization key secret.                                                                                       |  **Required** |
    | `MD_S3_USE_V4_SIGNATURE` | Use V4 signature to S3 storage backend.                                                                              | Optional, default `true`           |
    | `MD_S3_SSE_C_KEY`   | S3 SSE-C key.                                                                                                              | Optional                |

### Modify `seahub_settings.py`

To enable metadata server in Seafile, please add the following field in your `seahub_settings.py`:

=== "Deploy in the same machine with Seafile"
    ```py
    ENABLE_METADATA_MANAGEMENT = True
    METADATA_SERVER_SECRET_KEY = '<your JWT key> '
    METADATA_SERVER_URL = 'http://seafile-md-server:8084'
    ```
=== "Standalone"
    ```py
    ENABLE_METADATA_MANAGEMENT = True
    METADATA_SERVER_SECRET_KEY = '<your JWT key> '
    METADATA_SERVER_URL = 'http://<your metadata-server host>:8084'
    ```

## Start service

You can use following command to start metadata server (and the Seafile service also have to restart):

```sh
docker compose down
docker compose up -d
```

!!! success
    If the container startups normally, the message you can get from the following logs
    
    - `docker logs -f seafile-md-server`:
        ```log
        [md-server] [2025-01-24 06:23:44] [INFO] Environment variable validity checked
        [md-server] [2025-01-24 06:23:44] [INFO] Database initialization completed
        [md-server] [2025-01-24 06:23:44] [INFO] Configuration file generated
        ```
    - `$SEAFILE_VOLUME/seafile/logs/seafevents.log`
        ```log
        [2025-02-23 06:08:05] [INFO] seafevents.repo_metadata.index_worker:134 refresh_lock refresh_thread Starting refresh locks
        [2025-02-23 06:08:05] [INFO] seafevents.repo_metadata.slow_task_handler:61 worker_handler slow_task_handler_thread_0 starting update metadata work
        [2025-02-23 06:08:05] [INFO] seafevents.repo_metadata.slow_task_handler:61 worker_handler slow_task_handler_thread_1 starting update metadata work
        [2025-02-23 06:08:05] [INFO] seafevents.repo_metadata.slow_task_handler:61 worker_handler slow_task_handler_thread_2 starting update metadata work
        ```

!!! tip "Access denied for MySQL"
    If you have confirmed that your database configuration is correct, this error may also occur when you deploy the Metadata server at the same time as deploying Seafile. You can restart the Metadata server by executing the following command after Seafile is initialized:

    ```sh
    docker compose restart seafile-md-server
    ```

## Directory structure

When you deploy Seafile server and Metadata server to the **same machine**, Metadata server will use the same persistence directory (e.g. /opt/seafile-data) as Seafile server. Metadata server will use the following directories or files:

- `/opt/seafile-data/seafile/md-data`: Metadata server data and cache
- `/opt/seafile-data/seafile/logs/seaf-md-server`: The logs directory of Metadata server, consist of a running log and an access log.

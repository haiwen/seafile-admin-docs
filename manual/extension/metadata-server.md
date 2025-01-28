---
status: new
---

# Metadata server

Metadata server aims to provide metadata management for your libraries, so as to better understand the relevant information of your libraries.

## Deployment

!!! note "Prerequisites"
    The startup of Metadata server **requires the use of *Redis* service**, but Seafile server uses *Memcached* as the cache server by default, so you must [deploy ***Redis*** for Seafile](../config/seafile-conf.md#cache-pro-edition-only) before using Metadata server, or use an external Redis service.

### Download YML file

    Please download YML file **in your `seafile-server.yml` directory** by following command:

    ```sh
    wget https://manual.seafile.com/12.0/repo/docker/md-server.yml
    ```

### Modify `.env` according

Normally, you don't need to set additional variables in `.env` for metadata server, because the default settings and necessary environment variables will be consistent with Seafile server (e.g., `JWT_PRIVATE_KEY`), and the metadata of libraries will be stored locally (default is `/opt/md-data`). By the way, you can also add or modify relevant environment variables in `.env` according to the information in the following table:

!!! success "Faster configuration"
    Metadata-server docker we use an one-time configuration file, which will be generated directly through the environment variable, eliminating the need for you to repeatedly write configuration files (i.e., **no `md-server.conf`**), which will significantly improve your deployment efficiency.


| Variables           | Description                                                                                                                | Required |
| --- | --- | --- |
| `MD_STORAGE_TYPE`   | The type of backend storage. Options: `file` (local storage), `s3`, `oss`.                                                 | Optional, default `file`            |
| `MD_DATA`           | Directory where local data (only valid in `MD_STORAGE_TYPE=file`) and cache are located.                                  | Optional, default `/opt/md-data`   |
| `MD_MAX_CACHE_SIZE` | The maximum cache size.                                                                                                    | Optional, default `1GB`            |
| `MD_S3_HOST`        | Host of s3 backend.                                                                                                        | Optional                |
| `MD_S3_AWS_REGION`  | Region of *AWS* s3 backend.                                                                                                | Optional                |
| `MD_S3_USE_HTTPS`   | Use https connecting to S3 backend.                                                                                        | Optional, default `true`          |
| `MD_S3_BUCKET`      | Name of S3 bucket for storaging metadata.                                                                                 | **Required**                |
| `MD_S3_PATH_STYLE_REQUEST` | S3 backend use path style request.                                                                                 | Optional, default `false`          |
| `MD_S3_KEY_ID`      | S3 backend authorization key ID.                                                                                           | **Required**                |
| `MD_S3_KEY`         | S3 backend authorization key secret.                                                                                       | **Required**                |
| `MD_S3_USE_V4_SIGNATURE` | Use V4 signature to S3 storage backend.                                                                              | Optional, default `true`           |
| `MD_S3_SSE_C_KEY`   | S3 SSE-C key.                                                                                                              | Optional                |
| `MD_OSS_HOST`       | OSS backend host.                                                                                                          | Optional                |
| `MD_OSS_REGION`     | OSS backend region.                                                                                                        | Optional                |
| `MD_OSS_BUCKET`     | Name of OSS bucket for storaging metadata.                                                                               | **Required**                |
| `MD_OSS_KEY_ID`     | OSS backend authorization key ID.                                                                                          | **Required**                |
| `MD_OSS_KEY`        | OSS backend authorization key secret.                                                                                      | **Required**                |
| `REDIS_HOST`        | Your *Redis* service host.                                                                                                 | Optional, default `redis`          |
| `REDIS_PORT`        | Your *Redis* service port.                                                                                                 | Optional, default `6379`           |
| `REDIS_PASSWORD`    | Your *Redis* access password.                                                                                              | Optional                |
    

!!! tip "More descriptions about *Optional* and *Required* in above table"
    - In the table above, although many items are marked as *Required*, some of them are only required when the storage backend specified by `MD_STORAGE_TYPE` is used:
        - `MD_S3_xxx` only valid in `MD_STORAGE_TYPE=s3`
        - `MD_OSS_xxx` only valid in `MD_STORAGE_TYPE=oss`

    - If `MD_STORAGE_TYPE` is `s3` or `oss`, although `MD_xxx_HOST` and `MD_xxx_REGION` are marked as ***Optional***, when you use one of these two storage backends, **you must specify at least one of `MD_xxx_HOST` and `MD_xxx_REGION`, otherwise the service will fail to start**.

## Start service

You can use following command to start metadata server:

```sh
docker compose up -d
```

!!! success
    If the container startups normally, the follow message you can get from `docker logs -f metadata-server`:
    ```log
    [md-server] [2025-01-24 06:23:44] [INFO] Environment variable validity checked
    [md-server] [2025-01-24 06:23:44] [INFO] Database initialization completed
    [md-server] [2025-01-24 06:23:44] [INFO] Configuration file generated
    [md-server] [2025-01-24 06:45:17] [INFO] starting seaf-md-server
    ```

!!! note "About listening port of Metadata server"

    By default, the Metadata server listens on port 8084. You can modify it by specifying `MD_PORT` in .env. At the same time, due to security reasons, this port is not open to the external network. If you need to open this port, you need to modify `md-server.yml` to uncomment the following:
    
    ```yml
    services:
      metadata-server:
        ...
        ports:
          - ${MD_PORT:-8084}:${MD_PORT:-8084}
        ...
    ```

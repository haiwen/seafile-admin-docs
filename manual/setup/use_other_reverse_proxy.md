# Use other reverse proxy

Since Seafile 12.0, all reverse proxy, HTTPS, etc. processing for **single-node deployment based on Docker** is handled by [caddy](./caddy.md). If you need to use other reverse proxy services, you can refer to this document to modify the relevant configuration files.

## Services that require reverse proxy

Before making changes to the configuration files, you **have to** know the services used by Seafile and related components (***Table 1*** therafter).

!!! tip
    The services shown in the table below are **all based on the single-node integrated deployment** in accordance with the Seafile official documentation. 
    
    If these services are **deployed in standalone mode** (such as *seadoc* and *notification-server*), or **deployed in the official documentation** of third-party plugins (such as *onlyoffice* and *collabora*), **you can skip modifying the configuration files of these services** (because Caddy is not used as a reverse proxy for such deployment approaches).

    If you have not integrated the services in the *Table 1*, please choose ***Standalone*** or ***Refer to the official documentation of third-party plugins*** to install them when you need these services


| YML | Service | Suggest exposed port | Service listen port | Require WebSocket |
| --- | --- | --- | --- | --- |
| `seafile-server.yml` | *seafile* | 80 | 80 | No |
| `seadoc.yml` | *seadoc* | 8888 | 80 | Yes |
| `notification-server.yml` | *notification-server* | 8083 | 8083 | Yes |
| `collabora.yml` | *collabora* | 6232 | 9980 | No |
| `onlyoffice.yml` | *onlyoffice* | 6233 | 80 | No |

## Modify YML files

1. Refer to ***Table 1*** for the related service exposed ports. Add section `ports` for corresponding services

    ```yml
    services:
        <the service need to be modified>:
            ...
            ports:
                - "<Suggest exposed port>:<Service listen port>"
    ```

2. Delete all fields related to Caddy reverse proxy (in `label` section)

    !!! tip
        Some `.yml` files (e.g., `collabora.yml`) also have port-exposing information with Caddy in the top of the file, which also needs to be removed.

We take `seafile-server.yml` for example (Pro edition):

```yml
services:
    # ... other services

    seafile:
    image: ${SEAFILE_IMAGE:-seafileltd/seafile-pro-mc:12.0-latest}
    container_name: seafile
    ports:
       - "80:80"
    volumes:
      - ${SEAFILE_VOLUME:-/opt/seafile-data}:/shared
    environment:
      - DB_HOST=${SEAFILE_MYSQL_DB_HOST:-db}
      - DB_PORT=${SEAFILE_MYSQL_DB_PORT:-3306}
      - DB_ROOT_PASSWD=${INIT_SEAFILE_MYSQL_ROOT_PASSWORD:-}
      - DB_PASSWORD=${SEAFILE_MYSQL_DB_PASSWORD:?Variable is not set or empty}
      - SEAFILE_MYSQL_DB_CCNET_DB_NAME=${SEAFILE_MYSQL_DB_CCNET_DB_NAME:-ccnet_db}
      - SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=${SEAFILE_MYSQL_DB_SEAFILE_DB_NAME:-seafile_db}
      - SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=${SEAFILE_MYSQL_DB_SEAHUB_DB_NAME:-seahub_db}
      - TIME_ZONE=${TIME_ZONE:-Etc/UTC}
      - INIT_SEAFILE_ADMIN_EMAIL=${INIT_SEAFILE_ADMIN_EMAIL:-me@example.com}
      - INIT_SEAFILE_ADMIN_PASSWORD=${INIT_SEAFILE_ADMIN_PASSWORD:-asecret}
      - SEAFILE_SERVER_HOSTNAME=${SEAFILE_SERVER_HOSTNAME:?Variable is not set or empty}
      - SEAFILE_SERVER_PROTOCOL=${SEAFILE_SERVER_PROTOCOL:-http}
      - SITE_ROOT=${SITE_ROOT:-/}
      - NON_ROOT=${NON_ROOT:-false}
      - JWT_PRIVATE_KEY=${JWT_PRIVATE_KEY:?Variable is not set or empty}
      - ENABLE_SEADOC=${ENABLE_SEADOC:-false}
      - SEADOC_SERVER_URL=${SEADOC_SERVER_URL:-http://seafile.example.com/sdoc-server}
      - INIT_S3_STORAGE_BACKEND_CONFIG=${INIT_S3_STORAGE_BACKEND_CONFIG:-false}
      - INIT_S3_COMMIT_BUCKET=${INIT_S3_COMMIT_BUCKET:-}
      - INIT_S3_FS_BUCKET=${INIT_S3_FS_BUCKET:-}
      - INIT_S3_BLOCK_BUCKET=${INIT_S3_BLOCK_BUCKET:-}
      - INIT_S3_KEY_ID=${INIT_S3_KEY_ID:-}
      - INIT_S3_SECRET_KEY=${INIT_S3_SECRET_KEY:-}
      - INIT_S3_USE_V4_SIGNATURE=${INIT_S3_USE_V4_SIGNATURE:-true}
      - INIT_S3_AWS_REGION=${INIT_S3_AWS_REGION:-us-east-1}
      - INIT_S3_HOST=${INIT_S3_HOST:-us-east-1}
      - INIT_S3_USE_HTTPS=${INIT_S3_USE_HTTPS:-true}
    # please remove the label section
    depends_on:
      - db
      - memcached
      - elasticsearch
    networks:
      - seafile-net

# ... other options
```

## Add reverse proxy for related services

Modify `nginx.conf` and add reverse proxy for services ***seafile*** and ***seadoc***:

!!! note
    If your proxy server's host is not the same as the host the Seafile deployed to, please **replase `127.0.0.1` to your Seafile server's host**

=== "seafile"
    ```conf
    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_read_timeout 310s;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Connection "";
        proxy_http_version 1.1;

        client_max_body_size 0;
    }
    ```

=== "seadoc"
    ```conf
    location /sdoc-server/ {
        proxy_pass         http://127.0.0.1:8888/;
        proxy_redirect     off;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host  $server_name;

        client_max_body_size 100m;
    }

    location /socket.io {
        proxy_pass http://127.0.0.1:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_redirect off;

        proxy_buffers 8 32k;
        proxy_buffer_size 64k;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
    }
    ```
=== "notification-server"
    ```conf
    location /notification/ping {
        proxy_pass http://127.0.0.1:8083/ping;
        access_log      /var/log/nginx/notification.access.log seafileformat;
        error_log       /var/log/nginx/notification.error.log;
    }
    location /notification {
        proxy_pass http://127.0.0.1:8083/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        access_log      /var/log/nginx/notification.access.log seafileformat;
        error_log       /var/log/nginx/notification.error.log;
    }
    ```
=== "onlyoffice"
    ```conf
    location /onlyofficeds/ {
        proxy_pass http://127.0.0.1:6233/;
        proxy_http_version 1.1;
        client_max_body_size 100M;
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $proxy_connection;
        proxy_set_header X-Forwarded-Host $the_host/onlyofficeds;
        proxy_set_header X-Forwarded-Proto $the_scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    ```

## Modify .env

Remove `caddy.yml` from field `COMPOSE_FILE` in `.env`, e.g.

```sh
COMPOSE_FILE='seafile-server.yml' # remove caddy.yml
```

## Restart services and nginx

```sh
docker compose down
docker compose up -d
nginx restart
```

# Upgrade Seafile Docker

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 10.0 to 11.0, see instructions below.

Please check the **upgrade notes** for any special configuration or changes before/while upgrading.


## Upgrade from 12.0 to 13.0

From Seafile Docker 13.0, the `elasticsearch.yml` has separated from `seafile-server.yml`, and Seafile will support getting cache configuration from environment variables

1. Stop the services:

    ```sh
    docker compose down
    ```

2. Backup the original `seafile-server.yml`

    ```sh
    mv seafile-server.yml seafile-server.yml.bak
    ```

3. Download the new `seafile-server.yml`:

    === "Seafile community edition"
        ```sh
        wget https://manual.seafile.com/13.0/repo/docker/ce/seafile-server.yml
        ```
    === "Seafile Pro edition"
        ```sh
        wget https://manual.seafile.com/13.0/repo/docker/pro/seafile-server.yml
        ```

4. From Seafile Docker 13.0 (**Pro**), the *ElasticSearch* service will be controlled by a separate resource file (i.e., `elasticsearch.yml`). If you are using Seafile Pro and still plan to use *ElasticSearch*, please download the `elasticsearch.yml` and update the `COMPOSE_FILE` list in `.env`:

    - Download the `elasticsearch.yml`:

        ```sh
        wget https://manual.seafile.com/13.0/repo/docker/pro/elasticsearch.yml
        ```
    
    - Modify `.env` to add `elasticsearch.yml` in `COMPOSE_FILE` list:

        ```
        COMPOSE_FILE='...,elasticsearch.yml'
        ```
        
5. Since Seafile 13, Redis will be recommended as the primary cache server for supporting some new features (please refer the ***upgradte notes***, you can also refer to more details about Redis in Seafile Docker [here](../setup/setup_pro_by_docker.md#about-redis)) and can be configured directly from environment variables. So you should modify `.env`, add or modify the following fields:

    ```
    ## Cache
    CACHE_PROVIDER=redis # or memcached

    ### Redis
    REDIS_SERVER=redis
    REDIS_PORT=6379
    REDIS_PASSWORD=

    ### Memcached
    MEMCACHED_SERVER=memcached
    MEMCACHED_PORT=11211
    ```

    Although you can configure the cache directly through environment variables, since Seafile Docker 12 uses Memcached by default, we recommend that you remove or modify the cache configuration in the following files to avoid ambiguity：

    - `seafile.conf`: remove the `[memcached]` section

    - `seahub_settings.py`: remove the key `default` in variable `CACHES`

6. Start with `docker compose up -d`.

## Upgrade from 11.0 to 12.0

Note: If you have a large number of `Activity` in MySQL, clear this table first [Clean Database](../../administration/clean_database). Otherwise, the database upgrade will take a long time.

From Seafile Docker 12.0, we recommend that you use `.env` and `seafile-server.yml` files for configuration.

### Backup the original docker-compose.yml file:

```sh
mv docker-compose.yml docker-compose.yml.bak
```

### Download Seafile 12.0 Docker files

Download `.env`, `seafile-server.yml` and `caddy.yml`, and modify `.env` file according to the old configuration in `docker-compose.yml.bak`

=== "Seafile community edition"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/repo/docker/ce/env
    wget https://manual.seafile.com/12.0/repo/docker/ce/seafile-server.yml
    wget https://manual.seafile.com/12.0/repo/docker/caddy.yml
    ```
    The following fields merit particular attention:

    | Variable                        | Description                                                                                                   | Default Value                   |  
    | ------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------- |  
    | `SEAFILE_VOLUME`                | The volume directory of Seafile data                                                                          | `/opt/seafile-data`             |  
    | `SEAFILE_MYSQL_VOLUME`          | The volume directory of MySQL data                                                                            | `/opt/seafile-mysql/db`         |  
    | `SEAFILE_CADDY_VOLUME`          | The volume directory of Caddy data used to store certificates obtained from Let's Encrypt's                    | `/opt/seafile-caddy`            |  
    | `SEAFILE_MYSQL_DB_USER`         | The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`)                                    | `seafile`  |  
    | `SEAFILE_MYSQL_DB_PASSWORD`     | The user `seafile` password of MySQL                                                                          | (required)  |  
    | `SEAFILE_MYSQL_DB_CCNET_DB_NAME`     | The database name of ccnet | `ccnet_db`  |
    | `SEAFILE_MYSQL_DB_SEAFILE_DB_NAME`     | The database name of seafile | `seafile_db`  |
    | `SEAFILE_MYSQL_DB_SEAHUB_DB_NAME`     | The database name of seahub | `seahub_db`  |
    | `JWT_PRIVATE_KEY`                           | JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters is required for Seafile, which can be generated by using `pwgen -s 40 1` | (required) |  
    | `SEAFILE_SERVER_HOSTNAME`       | Seafile server hostname or domain                                                                  | (required)  |  
    | `SEAFILE_SERVER_PROTOCOL`       | Seafile server protocol (http or https)                                                                       | `http` |  
    | `TIME_ZONE`                     | Time zone                                                                                                     | `UTC`                           |  
=== "Seafile pro edition"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/repo/docker/pro/env
    wget https://manual.seafile.com/12.0/repo/docker/pro/seafile-server.yml
    wget https://manual.seafile.com/12.0/repo/docker/caddy.yml
    ```
    The following fields merit particular attention:

    | Variable                        | Description                                                                                                   | Default Value                   |  
    | ------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------- |  
    | `SEAFILE_VOLUME`                | The volume directory of Seafile data                                                                          | `/opt/seafile-data`             |  
    | `SEAFILE_MYSQL_VOLUME`          | The volume directory of MySQL data                                                                            | `/opt/seafile-mysql/db`         |  
    | `SEAFILE_CADDY_VOLUME`          | The volume directory of Caddy data used to store certificates obtained from Let's Encrypt's                    | `/opt/seafile-caddy`            |  
    | `SEAFILE_ELASTICSEARCH_VOLUME`  | (Only valid for Seafile PE) The volume directory of Elasticsearch data | `/opt/seafile-elasticsearch/data` |   
    | `SEAFILE_MYSQL_DB_USER`         | The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`)                                    | `seafile`  |  
    | `SEAFILE_MYSQL_DB_PASSWORD`     | The user `seafile` password of MySQL                                                                          | (required)  |  
    | `JWT_PRIVATE_KEY`                           | JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters is required for Seafile, which can be generated by using `pwgen -s 40 1` | (required) |  
    | `SEAFILE_SERVER_HOSTNAME`       | Seafile server hostname or domain                                                                  | (required)  |  
    | `SEAFILE_SERVER_PROTOCOL`       | Seafile server protocol (http or https)                                                                       | `http` |  
    | `TIME_ZONE`                     | Time zone                                                                                                     | `UTC`                           |  


!!! note

    - The value of the variables in the above table should be identical to your existing installation. You should check them from the existing configuration files (e.g., `seafile.conf`).
    - For variables **used to initialize configurations** (e.g., `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`, `INIT_SEAFILE_ADMIN_EMAIL`, `INIT_SEAFILE_ADMIN_PASSWORD`), you can remove it in the `.env` file.


SSL is now handled by the [caddy server](../setup/caddy.md). If you have used SSL before, you will also need modify the seafile.nginx.conf. Change server listen 443 to 80.

Backup the original seafile.nginx.conf file:

```sh
cp seafile.nginx.conf seafile.nginx.conf.bak
```

Remove the `server listen 80` section:

```config
#server {
#    listen 80;
#    server_name _ default_server;

    # allow certbot to connect to challenge location via HTTP Port 80
    # otherwise renewal request will fail
#    location /.well-known/acme-challenge/ {
#        alias /var/www/challenges/;
#        try_files $uri =404;
#    }

#    location / {
#        rewrite ^ https://seafile.example.com$request_uri? permanent;
#    }
#}
```

Change `server listen 443` to `80`:

```config
server {
#listen 443 ssl;
listen 80;

#    ssl_certificate      /shared/ssl/pkg.seafile.top.crt;
#    ssl_certificate_key  /shared/ssl/pkg.seafile.top.key;

#    ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;

   ...
```

Start with docker compose up.

### Upgrade notification server


If you has deployed the notification server. The *Notification Server* is now moved to its own Docker image. You need to redeploy it according to [Notification Server document](../extension/notification-server.md)


### Upgrade SeaDoc from 0.8 to 1.0 for Seafile v12.0

If you have deployed SeaDoc v0.8 with Seafile v11.0, you can upgrade it to 1.0 use the following steps:

1. Delete sdoc_db.
2. Remove SeaDoc configs in seafile.nginx.conf file.
3. Re-deploy SeaDoc server. In other words, delete the old SeaDoc deployment and deploy a new SeaDoc server.

#### Delete sdoc_db

From version 1.0, SeaDoc is using seahub_db database to store its operation logs and no longer need an extra database sdoc_db. The database tables in seahub_db are created automatically when you upgrade Seafile server from v11.0 to v12.0. You can simply delete sdoc_db.

#### Remove SeaDoc configs in seafile.nginx.conf file

If you have deployed SeaDoc older version, you should remove `/sdoc-server/`, `/socket.io` configs in seafile.nginx.conf file.

```config
#    location /sdoc-server/ {
#        add_header Access-Control-Allow-Origin *;
#        add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
#        add_header Access-Control-Allow-Headers "deviceType,token, authorization, content-type";
#        if ($request_method = 'OPTIONS') {
#            add_header Access-Control-Allow-Origin *;
#            add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
#            add_header Access-Control-Allow-Headers "deviceType,token, authorization, content-type";
#            return 204;
#        }
#        proxy_pass         http://sdoc-server:7070/;
#        proxy_redirect     off;
#        proxy_set_header   Host              $host;
#        proxy_set_header   X-Real-IP         $remote_addr;
#        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
#        proxy_set_header   X-Forwarded-Host  $server_name;
#        proxy_set_header   X-Forwarded-Proto $scheme;
#        client_max_body_size 100m;
#    }
#    location /socket.io {
#        proxy_pass http://sdoc-server:7070;
#        proxy_http_version 1.1;
#        proxy_set_header Upgrade $http_upgrade;
#        proxy_set_header Connection 'upgrade';
#        proxy_redirect off;
#        proxy_buffers 8 32k;
#        proxy_buffer_size 64k;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header Host $http_host;
#        proxy_set_header X-NginX-Proxy true;
#    }
```

#### Deploy a new SeaDoc server

Please see the document [Setup SeaDoc](../extension/setup_seadoc.md) to install SeaDoc with Seafile.


## Upgrade from 10.0 to 11.0

Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Taking the [community edition](../setup/setup_ce_by_docker.md) as an example, you have to modify

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

What's more, you have to migrate configuration for LDAP and OAuth according to [here](upgrade_notes_for_11.0.x.md)

Start with docker compose up.

## Upgrade from 9.0 to 10.0

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

If you are using pro edition with ElasticSearch, SAML SSO and storage backend features, follow the upgrading manual on how to update the configuration for these [features](upgrade_notes_for_10.0.x.md).

If you want to use the new notification server and rate control (pro edition only), please refer to the [upgrading manual](upgrade_notes_for_10.0.x.md).

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


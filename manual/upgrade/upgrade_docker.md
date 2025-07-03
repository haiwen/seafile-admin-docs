# Upgrade Seafile Docker

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 10.0 to 11.0, see instructions below.

Please check the **upgrade notes** for any special configuration or changes before/while upgrading.


## Upgrade from 12.0 to 13.0

From Seafile Docker 13.0, the `elasticsearch.yml` has separated from `seafile-server.yml`, and Seafile will support getting cache configuration from environment variables

### Step 1) Stop the services:

Before upgrading, please shutdown you Seafile server

```sh
docker compose down
```

### Step 2) Download the newest `.yml` files

#### Step 2.1) Download `seafile-server.yml`

Before downloading the newest `seafile-server.yml`, please backup your original one:

```sh
mv seafile-server.yml seafile-server.yml.bak
```

Then download the new `seafile-server.yml` according to the following commands:

=== "Seafile community edition"
    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/ce/seafile-server.yml
    ```
=== "Seafile Pro edition"
    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/pro/seafile-server.yml
    ```

#### Step 2.2) Download `.yml` file for search engine (Pro edition)

=== "ElasticSearch"

    From Seafile Docker 13.0 (**Pro**), the *ElasticSearch* service will be controlled by a separate resource file (i.e., `elasticsearch.yml`). If you are using Seafile Pro and still plan to use *ElasticSearch*, please download the `elasticsearch.yml`:

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/pro/elasticsearch.yml
    ```

=== "SeaSearch"

    If you are using SeaSearch as the search engine, please download the newest `seasearch.yml` file:

    ```sh
    mv seasearch.yml seasearch.yml.bak
    wget https://manual.seafile.com/13.0/repo/docker/pro/seasearch.yml
    ```

### Step 3) Modify `.env`, update image version and add cache configurations

#### Step 3.1) Update image version to Seafile 13

=== "Seafile CE"

    ```sh
    SEAFILE_IMAGE=seafileltd/seafile-mc:13.0-latest
    SEADOC_IMAGE=seafileltd/sdoc-server:1.0-latest
    NOTIFICATION_SERVER_IMAGE=seafileltd/notification-server:13.0-latest
    ```

=== "Seafile Pro"

    ```sh
    # -- add `elasticsearch.yml` if you are still using ElasticSearch
    # COMPOSE_FILE='...,elasticsearch.yml'

    # -- if you are using SeaSearch, please also update the SeaSearch image
    # SEASEARCH_IMAGE=seafileltd/seasearch:1.0-latest # or seafileltd/seasearch-nomkl:1.0-latest for Apple chips

    SEAFILE_IMAGE=seafileltd/seafile-pro-mc:13.0-latest
    SEADOC_IMAGE=seafileltd/sdoc-server:1.0-latest
    NOTIFICATION_SERVER_IMAGE=seafileltd/notification-server:13.0-latest
    
    ```

#### Step 3.2) Add configurations for cache

From Seafile 13, the configurations of database and cache can be set via environment variables directly (you can define it in the `.env`). What's more, the Redis will be recommended as the primary cache server for supporting some new features (please refer the ***upgradte notes***, you can also refer to more details about Redis in Seafile Docker [here](../setup/setup_pro_by_docker.md#about-redis)).


=== "Redis"

    ```sh
    ## Cache
    CACHE_PROVIDER=redis

    ### Redis
    REDIS_HOST=redis
    REDIS_PORT=6379
    REDIS_PASSWORD=
    ```
=== "Memcached"

    ```sh
    ## Cache
    CACHE_PROVIDER=memcached

    ### Memcached
    MEMCACHED_HOST=memcached
    MEMCACHED_PORT=11211
    ```

#### Step 3.3)  Add configuration for notification server

If you are using notification server in Seafile 12, please specify the notification server url in `.env`:

=== "Deploy in the same host with Seafile"
    ```sh
    ENABLE_NOTIFICATION_SERVER=true
    NOTIFICATION_SERVER_URL=$SEAFILE_SERVER_PROTOCOL://$SEAFILE_SERVER_HOSTNAME/notification
    ```
=== "Standalone deployment"
    ```sh
    ENABLE_NOTIFICATION_SERVER=true
    NOTIFICATION_SERVER_URL=http://<your notification server host>:8083
    INNER_NOTIFICATION_SERVER_URL=$NOTIFICATION_SERVER_URL
    ```

#### Step 3.4) Add configurations for storage backend (Pro)

Seafile 13.0 add a new environment `SEAF_SERVER_STORAGE_TYPE` to determine the storage backend of seaf-server component. You can delete the variable or set it to empty (`SEAF_SERVER_STORAGE_TYPE=`) to use the old way, i.e., determining the storage backend from seafile.conf.

=== "Local disk (default)"

    Set `SEAF_SERVER_STORAGE_TYPE` to `disk` (default value):

    ```sh
    SEAF_SERVER_STORAGE_TYPE=disk
    ```

=== "S3 backend"

    Set `SEAF_SERVER_STORAGE_TYPE` to `s3`, and add your s3 configurations:

    ```sh
    SEAF_SERVER_STORAGE_TYPE=s3

    S3_COMMIT_BUCKET=<your commit bucket name>
    S3_FS_BUCKET=<your fs bucket name>
    S3_BLOCK_BUCKET=<your block bucket name>
    S3_SS_BUCKET=<your seasearch bucket name> # for seasearch
    S3_MD_BUCKET=<your metadata bucket name> # for metadata-server
    S3_KEY_ID=<your-key-id>
    S3_SECRET_KEY=<your-secret-key>
    S3_USE_V4_SIGNATURE=true
    S3_PATH_STYLE_REQUEST=false
    S3_AWS_REGION=us-east-1
    S3_HOST=
    S3_USE_HTTPS=true
    S3_SSE_C_KEY=
    ```

=== "Multiple storage backends"

    Set `SEAF_SERVER_STORAGE_TYPE` to `multiple`. In this case, you don't need to change the storage configuration in `seafile.conf`.

    ```sh
    SEAF_SERVER_STORAGE_TYPE=multiple
    ```

=== "Use the configuration in `seafile.conf`"

    If you would like to use the storage configuration in `seafile.conf`, please remove default value of `SEAF_SERVER_STORAGE_TYPE` in `.env`:

    ```sh
    SEAF_SERVER_STORAGE_TYPE=
    ```

### Step 4) Remove obsolote configurations

Although the configurations in environment (i.e., `.env`) have higher priority than the configurations in config files, we recommend that you remove or modify the cache configuration in the following files to avoid ambiguity:

1. Backup the old configuration files:

    ```sh
    # please replace /opt/seafile-data to your $SEAFILE_VOLUME

    cp /opt/seafile-data/seafile/conf/seafile.conf /opt/seafile-data/seafile/conf/seafile.conf.bak
    cp /opt/seafile-data/seafile/conf/seahub_settings.py /opt/seafile-data/seafile/conf/seahub_settings.py.bak
    ```

2. Clean up redundant configuration items in the configuration files:

    - Open `/opt/seafile-data/seafile/conf/seafile.conf` and remove the entire `[memcached]`, `[database]`, `[commit_object_backend]`, `[fs_object_backend]` and `[block_backend]` if above sections have correctly specified in `.env`.
    - Open `/opt/seafile-data/seafile/conf/seahub_settings.py` and remove the entire blocks for `DATABASES = {...}` and `CAHCES = {...}`

    In the most cases, the `seafile.conf` only include the listen port `8082` of Seafile file server.

### Step 5) Start Seafile

```sh
docker compose up -d
```


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

### Other configuration changes

#### Enable passing of REMOTE_USER

REMOTE_USER header is not passed to Seafile by default, you need to change `gunicorn.conf.py` if you need REMOTE_USER header for SSO.

```python
forwarder_headers = 'SCRIPT_NAME,PATH_INFO,REMOTE_USER'
```

#### Supplement or remove ALLOWED_HOSTS in seahub_settings.py

Since version 12.0, the seaf-server component need to send internal requests to seahub component to check permissions, as reporting ***400 Error*** when downloading files if the `ALLOWED_HOSTS` set incorrect. In this case, you can either **remove** `ALLOWED_HOSTS` in `seahub_settings.py` or **supplement** `127.0.0.1` in `ALLOWED_HOSTS` list:

```py
# seahub_settings.py

ALLOWED_HOSTS = ['...(your domain)', '127.0.0.1']
```

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


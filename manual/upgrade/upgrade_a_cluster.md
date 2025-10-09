---
status: new
---

# Upgrade a Seafile cluster

## Major and minor version upgrade

Seafile adds new features in major and minor versions. It is likely that some database tables need to be modified or the search index need to be updated. In general, upgrading a cluster contains the following steps:

1. Update Seafile image
2. Upgrade the database
3. Update configuration files at each node
4. Update search index in the backend node

In general, to upgrade a cluster, you need:

1. Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Start with docker compose up.
2. Run the upgrade script in container (for example, `/opt/seafile/seafile-server-latest/upgrade/upgrade_x_x_x_x.sh`) in one frontend node
3. Update configuration files at each node according to the documentation for each version
4. Delete old search index in the backend node if needed

## Upgrade a cluster from Seafile 11 to 12

1. Stop the seafile service in all nodes

    ```sh
    docker compose down
    ```

2. Download the docker-compose files for *Seafile 12*

    ```sh
    wget -O .env https://manual.seafile.com/13.0/repo/docker/cluster/env
    wget https://manual.seafile.com/13.0/repo/docker/cluster/seafile-server.yml
    ```

3. Modify `.env`:

    - Generate a JWT key

        ```sh
        pwgen -s 40 1

        # e.g., EkosWcXonPCrpPE9CFsnyQLLPqoPhSJZaqA3JMFw
        ```

    - Fill up the following field according to your configurations using in *Seafile 11*:

        ```sh
        SEAFILE_SERVER_HOSTNAME=<your loadbalance's host>
        SEAFILE_SERVER_PROTOCOL=https # or http
        SEAFILE_MYSQL_DB_HOST=<your mysql host>
        SEAFILE_MYSQL_DB_USER=seafile # if you don't use `seafile` as your Seafile server's account, please correct it
        SEAFILE_MYSQL_DB_PASSWORD=<your mysql password for user `seafile`>
        JWT_PRIVATE_KEY=<your JWT key generated in Sec. 3.1>
        ```

        !!! tip "Remove the variables using in Cluster initialization"
            Since Seafile has been initialized in Seafile 11, the variables related to Seafile cluster initialization can be removed from `.env`:

            - INIT_SEAFILE_MYSQL_ROOT_PASSWORD
            - CLUSTER_INIT_MODE
            - CLUSTER_INIT_MEMCACHED_HOST
            - CLUSTER_INIT_ES_HOST
            - CLUSTER_INIT_ES_PORT
            - INIT_S3_STORAGE_BACKEND_CONFIG
            - INIT_S3_COMMIT_BUCKET
            - INIT_S3_FS_BUCKET
            - INIT_S3_BLOCK_BUCKET
            - INIT_S3_KEY_ID
            - INIT_S3_USE_V4_SIGNATURE
            - INIT_S3_SECRET_KEY
            - INIT_S3_AWS_REGION
            - INIT_S3_HOST
            - INIT_S3_USE_HTTPS

4. Start the Seafile in a node

    !!! note
        According to this upgrade document, a **frontend** service will be started here. If you plan to use this node as a backend node, you need to modify this item in `.env` and set it to `backend`:

        ```sh
        CLUSTER_MODE=backend
        ```

    ```sh
    docker compose up -d
    ```

5. Upgrade Seafile

    ```sh
    docker exec -it seafile bash
    # enter the container `seafile`

    # stop servers
    cd /opt/seafile/seafile-server-latest
    ./seafile.sh stop
    ./seahub.sh stop
    
    # upgrade seafile
    cd upgrade
    ./upgrade_11.0_12.0.sh
    ```

    !!! success
        After upgrading the Seafile, you can see the following messages in your console:

        ```
        Updating seafile/seahub database ...

        [INFO] You are using MySQL
        [INFO] updating seafile database...
        [INFO] updating seahub database...
        [INFO] updating seafevents database...
        Done

        migrating avatars ...

        Done

        updating /opt/seafile/seafile-server-latest symbolic link to /opt/seafile/seafile-pro-server-12.0.6 ...



        -----------------------------------------------------------------
        Upgraded your seafile server successfully.
        -----------------------------------------------------------------
        ```

        Then you can exit the container by `exit`

6. Restart current node

    ```sh
        docker compose down
        docker compose up -d
    ```

    !!! tip 
        - You can use `docker logs -f seafile` to check whether the current node service is running normally

7. Operations for other nodes

    - Download and modify `.env` similar to the first node (for backend node, you should set `CLUSTER_MODE=backend`)

    - Start the Seafile server:
        ```sh
        docker compose up -d
        ```     

## Upgrade a cluster from Seafile 12 to 13

### Step 1) Stop the services

Before upgrading, please shutdown you Seafile server

```sh
docker compose down
```

### Step 2) Download the newest `seafile-server.yml` file

Before downloading the newest `seafile-server.yml`, please backup your original one:

```sh
mv seafile-server.yml seafile-server.yml.bak
```

Then download the new `seafile-server.yml` according to the following commands:

```sh
wget https://manual.seafile.com/13.0/repo/docker/cluster/seafile-server.yml
```

### Step 3) Modify `.env`, update image version and some configurations

#### Step 3.1) Update image version to Seafile 13

 ```sh
 SEAFILE_IMAGE=seafileltd/seafile-pro-mc:13.0-latest
 ```

#### Step 3.2) Add configurations for cache

From Seafile 13, the configurations of cache can be set via environment variables directly (you can define it in the `.env`). What's more, the Redis will be recommended as the primary cache server for supporting some new features (please refer the ***upgradte notes***, you can also refer to more details about Redis in Seafile Docker [here](../setup/setup_pro_by_docker.md#about-redis)).


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

#### Step 3.3) Add configurations for database
```sh
SEAFILE_MYSQL_DB_HOST=db
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD
SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db
SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db
SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db
```

#### Step 3.4) Add configurations for storage backend

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

### Step 4) Remove obsolete configurations

Although the configurations in environment (i.e., `.env`) have higher priority than the configurations in config files, we recommend that you remove or modify the cache configuration in the following files to avoid ambiguity:

1. Backup the old configuration files:

    ```sh
    cp /opt/seafile/shared/seafile/conf/seafile.conf /opt/seafile/shared/seafile/conf/seafile.conf.bak
    cp /opt/seafile/shared/seafile/conf/seahub_settings.py /opt/seafile/shared/seafile/conf/seahub_settings.py.bak
    ```

2. Clean up redundant configuration items in the configuration files:

    - Open `/opt/seafile/shared/seafile/conf/seafile.conf` and remove the entire `[memcached]`, `[database]`, `[commit_object_backend]`, `[fs_object_backend]`, `[notification]` and `[block_backend]` if above sections have correctly specified in `.env`.
    - Open `/opt/seafile/shared/seafile/conf/seahub_settings.py` and remove the entire blocks for `DATABASES = {...}` and `CAHCES = {...}`

    In the most cases, the `seafile.conf` only include the listen port `8082` of Seafile file server.

### Step 5) Start the Seafile in a node

!!! note
    According to this upgrade document, a **frontend** service will be started here. If you plan to use this node as a backend node, you need to modify this item in `.env` and set it to `backend`:

    ```sh
    CLUSTER_MODE=backend
    ```

 ```sh
 docker compose up -d
 ```

### Step 6) Upgrade Seafile

 ```sh
 docker exec -it seafile bash
 # enter the container `seafile`

 # stop servers
 cd /opt/seafile/seafile-server-latest
 ./seafile.sh stop
 ./seahub.sh stop
 
 # upgrade seafile
 cd upgrade
 ./upgrade_12.0_13.0.sh
 ```

!!! success
     After upgrading the Seafile, you can see the following messages in your console:

     ```
     Updating seafile/seahub database ...

     [INFO] You are using MySQL
     [INFO] updating seafile database...
     [INFO] updating seahub database...
     [INFO] updating seafevents database...
     Done

     migrating avatars ...

     Done

     updating /opt/seafile/seafile-server-latest symbolic link to /opt/seafile/seafile-pro-server-13.0.11 ...



     -----------------------------------------------------------------
     Upgraded your seafile server successfully.
     -----------------------------------------------------------------
     ```

     Then you can exit the container by `exit`

### Step 7) Restart current node

```sh
docker compose down
docker compose up -d
```

!!! tip 
     - You can use `docker logs -f seafile` to check whether the current node service is running normally

### Step 8) Operations for other nodes

 - Download the newest seafile-sever.yml file and modify `.env` similar to the first node (for backend node, you should set `CLUSTER_MODE=backend`)

 - Start the Seafile server:
     ```sh
     docker compose up -d
     ```     
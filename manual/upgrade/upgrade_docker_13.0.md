# Upgrade Seafile Docker from 12.0 to 13.0

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 12.0 to 13.0, see instructions below.

Please check the **upgrade notes** for an overview about changes in this major version before upgrading.

---

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

#### Step 2.2) Download `.yml` file for notification server

=== "Deployment with Seafile"
    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/notification-server.yml
    ```
=== "Standalone deployment"
    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/notification-server/notification-server.yml
    ```

#### Step 2.3) Download `.yml` file for search engine (Pro edition)

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

#### Step 2.4) Download `.yml` file for SeaDoc (optional)

If you use SeaDoc extension, the seadoc.yml file need to be updated too: 

```sh
wget https://manual.seafile.com/13.0/repo/docker/seadoc.yml
```

### Step 3) Modify `.env`, update image version and add cache configurations

#### Step 3.1) Update image version to Seafile 13

=== "Seafile CE"

    ```sh
    SEAFILE_IMAGE=seafileltd/seafile-mc:13.0-latest
    SEADOC_IMAGE=seafileltd/sdoc-server:2.0-latest
    NOTIFICATION_SERVER_IMAGE=seafileltd/notification-server:13.0-latest
    ```

=== "Seafile Pro"

    ```sh
    # -- add `elasticsearch.yml` if you are still using ElasticSearch
    # COMPOSE_FILE='...,elasticsearch.yml'

    # -- if you are using SeaSearch, please also update the SeaSearch image
    # SEASEARCH_IMAGE=seafileltd/seasearch:1.0-latest # or seafileltd/seasearch-nomkl:1.0-latest for Apple chips

    SEAFILE_IMAGE=seafileltd/seafile-pro-mc:13.0-latest
    SEADOC_IMAGE=seafileltd/sdoc-server:2.0-latest
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

### Step 4) Remove obsolete configurations

Although the configurations in environment (i.e., `.env`) have higher priority than the configurations in config files, we recommend that you remove or modify the cache configuration in the following files to avoid ambiguity:

1. Backup the old configuration files:

    ```sh
    # please replace /opt/seafile-data to your $SEAFILE_VOLUME

    cp /opt/seafile-data/seafile/conf/seafile.conf /opt/seafile-data/seafile/conf/seafile.conf.bak
    cp /opt/seafile-data/seafile/conf/seahub_settings.py /opt/seafile-data/seafile/conf/seahub_settings.py.bak
    ```

2. Clean up redundant configuration items in the configuration files:

    - Open `/opt/seafile-data/seafile/conf/seafile.conf` and remove the entire `[memcached]`, `[database]`, `[commit_object_backend]`, `[fs_object_backend]`, `[notification]` and `[block_backend]` if above sections have correctly specified in `.env`.
    - Open `/opt/seafile-data/seafile/conf/seahub_settings.py` and remove the entire blocks for `DATABASES = {...}` and `CAHCES = {...}`

    In the most cases, the `seafile.conf` only include the listen port `8082` of Seafile file server.

### Step 5) Start Seafile

```sh
docker compose up -d
```


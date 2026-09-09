# Upgrade Seafile Docker from 13.0 to 14.0

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 13.0 to 14.0, see instructions below.

Please check the **upgrade notes** for an overview about changes in this major version before upgrading.

----

!!! tip "Clean Database"
    The database upgrade may take a long time. You can clean the database before upgrading. Please refer to [Clean Database](../administration/clean_database.md).

## Step 1) Stop the services

Before upgrading, please shutdown your Seafile server:

```sh
docker compose down
```

## Step 2) Download the newest `.yml` files

### Step 2.1) Download `seafile-server.yml`

Before downloading the newest `seafile-server.yml`, please backup your original one:

```sh
mv seafile-server.yml seafile-server.yml.bak
```

Then download the new `seafile-server.yml` according to the following commands:

=== "Seafile community edition"
    ```sh
    wget https://manual.seafile.com/14.0/repo/docker/ce/seafile-server.yml
    ```
=== "Seafile Pro edition"
    ```sh
    wget https://manual.seafile.com/14.0/repo/docker/pro/seafile-server.yml
    ```

### Step 2.2) Download `.yml` file for notification server (optional)

If you are using notification server, please backup the old file and download the 14.0 file:

=== "Deployment with Seafile"
    ```sh
    mv notification-server.yml notification-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/notification-server.yml
    ```
=== "Standalone deployment"
    ```sh
    mv notification-server.yml notification-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/notification-server/notification-server.yml
    ```

### Step 2.3) Download `.yml` file for metadata server (optional)

If you are using Metadata server, please backup the old file and download the 14.0 file:

=== "Deployment with Seafile"
    ```sh
    mv md-server.yml md-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/md-server.yml
    ```
=== "Standalone deployment"
    ```sh
    mv md-server.yml md-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/metadata-server/md-server.yml
    ```

### Step 2.4) Download `.yml` file for thumbnail server (optional)

If you are using Thumbnail server, please backup the old file and download the 14.0 file:

=== "Deployment with Seafile"
    ```sh
    mv thumbnail-server.yml thumbnail-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/thumbnail-server.yml
    ```
=== "Standalone deployment"
    ```sh
    mv thumbnail-server.yml thumbnail-server.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/thumbnail-server/thumbnail-server.yml
    ```

### Step 2.5) Download `.yml` file for Seafile AI (optional)

If you are using Seafile AI, please backup the old file and download the 14.0 file:

=== "Deployment with Seafile"
    ```sh
    mv seafile-ai.yml seafile-ai.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/seafile-ai.yml
    ```
=== "Standalone deployment"
    ```sh
    mv seafile-ai.yml seafile-ai.yml.bak
    wget https://manual.seafile.com/14.0/repo/docker/seafile-ai/seafile-ai.yml
    ```

## Step 3) Modify `.env`

### Step 3.1) Update image versions

=== "Seafile CE"

    ```sh
    SEAFILE_IMAGE=seafileltd/seafile-mc:14.0-latest

    # If you are using notification server
    NOTIFICATION_SERVER_IMAGE=seafileltd/notification-server:14.0-latest

    # If you are using Metadata server
    MD_IMAGE=seafileltd/seafile-md-server:14.0-latest

    # If you are using Thumbnail server
    THUMBNAIL_SERVER_IMAGE=seafileltd/thumbnail-server:14.0-latest

    # If you are using Seafile AI
    SEAFILE_AI_IMAGE=seafileltd/seafile-ai:14.0-latest
    ```

=== "Seafile Pro"

    ```sh
    SEAFILE_IMAGE=seafileltd/seafile-pro-mc:14.0-latest

    # If you are using notification server
    NOTIFICATION_SERVER_IMAGE=seafileltd/notification-server:14.0-latest

    # If you are using Metadata server
    MD_IMAGE=seafileltd/seafile-md-server:14.0-latest

    # If you are using Thumbnail server
    THUMBNAIL_SERVER_IMAGE=seafileltd/thumbnail-server:14.0-latest

    # If you are using Seafile AI
    SEAFILE_AI_IMAGE=seafileltd/seafile-ai:14.0-latest

    # If you have enabled the search function
    ENABLE_SEARCH=true
    # Index document contents for full-text search
    ENABLE_FULL_TEXT_SEARCH=true
    
    ## If you are using SeaSearch
    SEARCH_ENGINE=seasearch
    SEASEARCH_URL=http://seasearch:4080
    SEASEARCH_TOKEN=<Your seasearch token>

    ## If you are using ElasticSearch
    SEARCH_ENGINE=elasticsearch
    ELASTICSEARCH_SCHEME=http
    ELASTICSEARCH_HOST=<Your ES host>
    ELASTICSEARCH_PORT=9200
    ELASTICSEARCH_USER=
    ELASTICSEARCH_PASSWORD=
    ```

### Step 3.2) Add SeaSearch configurations for Seafile AI (optional)

If you are not using Seafile AI, skip this step.

Add the following settings to the `.env` used by Seafile AI:

=== "SeaSearch deployed with Seafile"
    ```env
    SEASEARCH_URL=http://seasearch:4080
    SEASEARCH_TOKEN=<your SeaSearch authorization token>
    ```
=== "Standalone SeaSearch deployment"
    ```env
    SEASEARCH_URL=http://<your SeaSearch server host>:4080
    SEASEARCH_TOKEN=<your SeaSearch authorization token>
    ```

Leave both variables empty if SeaSearch is not used. For details, refer to [Search with SeaSearch](../setup/use_seasearch.md).

### Step 3.3) Update model configurations for Seafile AI (optional)

If you are not using Seafile AI, skip this step.

In Seafile 14.0, Seafile AI models are configured in `seafile_ai_config.yaml` instead of through environment variables. Update the model configuration according to [Seafile AI extension](../extension/seafile-ai.md).

### Step 3.4) Update configurations for WebDAV

If you are not using WebDAV, skip this step.

In Seafile 14.0, the WebDAV enable switch and worker count are configured through environment variables in the Seafile server `.env`. If WebDAV was enabled in `seafdav.conf` before the upgrade, add the following settings to `.env`:

```env
ENABLE_SEAFDAV=true
SEAFDAV_WORKERS=5
```

`SEAFDAV_WORKERS` replaces the old `workers` option in `seafdav.conf`. Keep the other WebDAV settings, such as `port`, `share_name`, `timeout`, `debug`, and `show_repo_id`, in `/opt/seafile-data/seafile/conf/seafdav.conf`.

If the following old options exist in `/opt/seafile-data/seafile/conf/seafdav.conf`, remove them to avoid ambiguity:

```ini
enabled = true
workers = 5
```

### Step 3.5) Update configurations for Metadata server

If you are not using Metadata server, skip this step.

In Seafile 14.0, the following two Metadata server configurations are moved from `seahub_settings.py` to the `.env` file used by the Seafile server. Remove them from `seahub_settings.py` if they exist there, and add them to the Seafile server `.env`. The old `METADATA_SERVER_URL` configuration is renamed to `INNER_METADATA_SERVER_URL`.

=== "Deploy in the same machine with Seafile"
    ```env
    ENABLE_METADATA_MANAGEMENT=True
    INNER_METADATA_SERVER_URL=http://seafile-md-server:8084
    ```
=== "Standalone"
    ```env
    ENABLE_METADATA_MANAGEMENT=True
    INNER_METADATA_SERVER_URL=http://<your metadata-server host>:8084
    ```

    In a cluster deployment, add the same settings to the `.env` of each Seafile server node that needs to use the Metadata server. `INNER_METADATA_SERVER_URL` must be reachable from the Seafile server container.

## Step 4) Modify `seahub_settings.py` for Thumbnail server

If you are not using Thumbnail server, skip this step.

Open `/opt/seafile-data/seafile/conf/seahub_settings.py` and remove the following configuration if it exists. In Seafile 14.0, video thumbnail is enabled by default.

```py
# video thumbnails (disabled by default)
ENABLE_VIDEO_THUMBNAIL = True
```

Then add the following configuration to enable Thumbnail server:

```py
# enable thumbnail-server (disabled by default)
ENABLE_THUMBNAIL_SERVER = True
```

## Step 5) Remove obsolete SeaSearch (or ElasticSearch) configurations

Remove obsolete SeaSearch (or ElasticSearch) configurations in `seafevents.conf`:

1. `enabled` in both `[INDEX FILES]` and `[SEASEARCH]` sections are useless, you can remove it now (which is specified by two options in `.env`: `ENABLE_SEARCH` and `SEARCH_ENGINE`).
2. If you are using SeaSearch and have specified the authorization information (`SEASEARCH_URL` and `SEASEARCH_TOKEN`) in `.env` you can safely remove the `seasearch_url` and `seasearch_token` in `[SEASEARCH]`.
3. If you are using ElasticSearch and have specified the authorization information (`ELASTICSEARCH_SCHEME`, `ELASTICSEARCH_HOST`, `ELASTICSEARCH_PORT`, `ELASTICSEARCH_USER` and `ELASTICSEARCH_PASSWORD`) in `.env` you can safely remove the `scheme`, `es_host`, `es_port`, `username` and `password` in `[INDEX FILES]`.
4. `ENABLE_FULL_TEXT_SEARCH` controls document-content indexing for both search engines and defaults to `true`. If you set it in `.env`, remove `enable_full_text_search` from `[INDEX FILES]` or `[SEASEARCH]` to avoid ambiguity. Set it to `false` to retain file-name-only search.


## Step 6) Switch the cache server to Redis

If you are already using Redis as the cache server, skip this step. Starting with Seafile 14.0, many new features rely on Redis as the cache server. We strongly recommend switching to Redis if you are currently using Memcached.

1. Do not remove or comment out the `redis` service, or the `redis` dependency in the `seafile` service, in the newly downloaded `seafile-server.yml`.

2. Update the cache settings in `.env` as follows:

    ```env
    ## Cache
    CACHE_PROVIDER=redis

    ### Redis
    REDIS_HOST=redis
    REDIS_PORT=6379
    REDIS_PASSWORD=
    ```

!!! tip "External Redis server"
    If you use an external Redis server, replace `REDIS_HOST`, `REDIS_PORT`, and `REDIS_PASSWORD` with that server's connection settings.


## Step 7) Start Seafile

```sh
docker compose up -d
```


# Upgrade Seafile Docker from 13.0 to 14.0

Please check the [upgrade notes](./upgrade_notes.md) for an overview about changes in this major version before upgrading.

----

!!! important "Redeploy Seafile AI"
    Seafile AI has undergone significant changes in Seafile 14.0. If you are using Seafile AI, follow [Seafile AI extension](../extension/seafile-ai.md) to redeploy it. Before redeploying, remove the old settings listed in [Seafile obsolete configurations](./seafile_obsolete_configurations.md#seafile-13-to-14-obsolete-configurations).

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
    ```

### Step 3.2) Update configurations for WebDAV

If you are not using WebDAV, skip this step.

In Seafile 14.0, the WebDAV enable switch and worker count are configured through environment variables in the Seafile server `.env`. If WebDAV was enabled in `seafdav.conf` before the upgrade, add the following settings to `.env`:

```env
ENABLE_SEAFDAV=true
SEAFDAV_WORKERS=5
```

Remove the `enabled` and `workers` options from `/opt/seafile-data/seafile/conf/seafdav.conf` and keep the other settings unchanged.

### Step 3.3) Update configurations for Metadata server

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

## Step 4) Modify `seahub_settings.py`

### Step 4.1) Update configurations for Thumbnail server

If you are not using Thumbnail server, skip to Step 4.2.

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

### Step 4.2) Update local password configurations

The following options have been removed in Seafile 14.0. Remove them from `/opt/seafile-data/seafile/conf/seahub_settings.py` if they exist:

```python
DISABLE_ADFS_USER_PWD_LOGIN = True
ENABLE_CHANGE_PASSWORD = True
ENABLE_SSO_USER_CHANGE_PASSWORD = True
```

To prevent users authenticated through external providers from using passwords stored in Seafile, add the following option to `/opt/seafile-data/seafile/conf/seahub_settings.py`:

```python
DISABLE_SSO_USER_LOCAL_PWD_LOGIN = True # default: False
```

When enabled, this option disables local-password login and local password change/reset operations for users authenticated through SAML/ADFS, OAuth, LDAP, and so on.

### Step 4.3) Update monthly traffic-limit configurations

If `ENABLED_ROLE_PERMISSIONS` in `/opt/seafile-data/seafile/conf/seahub_settings.py` does not contain `monthly_rate_limit` or `monthly_rate_limit_per_user`, skip this step.

In Seafile 14.0, monthly download and upload allowances are configured independently. The legacy settings are no longer read. For each role in `ENABLED_ROLE_PERMISSIONS`, preserve the existing values while making the following replacements:

```python
# Replace this legacy setting:
'monthly_rate_limit': '<existing value>',

# With the download allowance setting:
'monthly_download_traffic_limit': '<existing value>',
```

For organization users, replace the corresponding per-user setting in the same way:

```python
# Replace this legacy setting:
'monthly_rate_limit_per_user': '<existing value>',

# With the download allowance setting:
'monthly_download_traffic_limit_per_user': '<existing value>',
```

To configure independent monthly upload allowances, add the following settings to each applicable role:

```python
'monthly_upload_traffic_limit': '',
'monthly_upload_traffic_limit_per_user': '',
```

The settings without the `_per_user` suffix apply to non-organization users. The `_per_user` settings apply to organization users, and the configured value is multiplied by the organization's member quota. Use quota units such as `500M` or `100G`; an empty value means no monthly allowance.

When a user exceeds an allowance, Seafile reduces the corresponding transfer speed. To override the default throttled rate of `1k` (1 KB/s), add either or both of the following options to `seahub_settings.py`:

```python
DOWNLOAD_LIMIT_WHEN_THROTTLE = '1k'
UPLOAD_LIMIT_WHEN_THROTTLE = '1k'
```

For more information, refer to [Roles and Permissions](../config/roles_permissions.md) and [Traffic limit exceeded throttle rate](../config/seahub_settings_py.md#traffic-limit-exceeded-throttle-rate).

## Step 5) Update search configurations (Pro edition only)

In Seafile 14.0, the search switch, search engine selection, document-content indexing, and search engine connection settings are configured in the Seafile server `.env` file. The new Pro Compose file enables search and uses SeaSearch by default. If you do not use search, add the following setting to `.env` and skip the rest of this step:

```env
ENABLE_SEARCH=false
```

If you use search, add the settings for your search engine to `.env`:

=== "SeaSearch"
    ```env
    ENABLE_SEARCH=true
    SEARCH_ENGINE=seasearch
    ENABLE_FULL_TEXT_SEARCH=true

    SEASEARCH_URL=http://seasearch:4080
    SEASEARCH_TOKEN=<your SeaSearch authorization token>
    ```
=== "ElasticSearch"
    ```env
    ENABLE_SEARCH=true
    SEARCH_ENGINE=elasticsearch
    ENABLE_FULL_TEXT_SEARCH=true

    ELASTICSEARCH_SCHEME=http
    ELASTICSEARCH_HOST=<your Elasticsearch host>
    ELASTICSEARCH_PORT=9200
    ELASTICSEARCH_USER=
    ELASTICSEARCH_PASSWORD=
    ```

`ENABLE_FULL_TEXT_SEARCH` controls document-content indexing for both search engines and defaults to `true`. Set it to `false` to retain file-name-only search. If SeaSearch is deployed on a different machine, replace `SEASEARCH_URL` with the URL that is reachable from the Seafile server container.

After adding these settings to `.env`, remove their old equivalents from `/opt/seafile-data/seafile/conf/seafevents.conf`:

1. Remove `enabled` from the `[INDEX FILES]` and `[SEASEARCH]` sections. Search is now controlled by `ENABLE_SEARCH` and `SEARCH_ENGINE` in `.env`.
2. If you use SeaSearch, remove `seasearch_url` and `seasearch_token` from `[SEASEARCH]`.
3. If you use ElasticSearch, remove `scheme`, `es_host`, `es_port`, `username`, and `password` from `[INDEX FILES]`.
4. Remove `enable_full_text_search` from `[INDEX FILES]` or `[SEASEARCH]`. It is now controlled by `ENABLE_FULL_TEXT_SEARCH` in `.env`.

Keep any other advanced search options in `seafevents.conf`. For more information, refer to [Search with SeaSearch](../setup/use_seasearch.md) or [Search with ElasticSearch](../setup/use_elasticsearch.md).


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

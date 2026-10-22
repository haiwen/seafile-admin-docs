# Upgrade a Seafile cluster from 13.0 to 14.0

Please check the [upgrade notes](./upgrade_notes.md) for an overview about changes in this major version before upgrading.

## Step 1) Stop the services

Before upgrading, stop Seafile on **all** frontend and backend nodes:

```sh
docker compose down
```

If notification server, metadata server, thumbnail server, or Seafile AI run in separate Compose stacks (on the same hosts or other machines), bring those stacks down as well before continuing.

## Step 2) Download the newest `seafile-server.yml`

Before downloading the newest `seafile-server.yml`, backup your original one on each Seafile node:

```sh
mv seafile-server.yml seafile-server.yml.bak
```

Then download the 14.0 **cluster** Compose file:

```sh
wget https://manual.seafile.com/14.0/repo/docker/cluster/seafile-server.yml
```

If you manage notification server, metadata server, or thumbnail server with their own Compose files, refresh those YAML files according to [Upgrade Seafile Docker from 13.0 to 14.0](./upgrade_docker_14.0.md) (Steps 2.2–2.4) or the corresponding [extension](../extension/metadata-server.md) docs. The default cluster `COMPOSE_FILE` only includes `seafile-server.yml`.

## Step 3) Modify `.env`

Apply the following changes on **every** Seafile node so that `.env` stays consistent across the cluster (except `CLUSTER_MODE`, which differs between frontend and backend).

### Step 3.1) Update image version to Seafile 14

```sh
SEAFILE_IMAGE=seafileltd/seafile-pro-mc:14.0-latest
```

If a node also runs notification / metadata / thumbnail containers from its own Compose file, upgrade the corresponding image variables to `14.0-latest` on that host (see [Upgrade Seafile Docker from 13.0 to 14.0](./upgrade_docker_14.0.md#step-31-update-image-versions)).

### Step 3.2) Update configurations for WebDAV

If you are not using WebDAV, skip this step.

In Seafile 14.0, the WebDAV enable switch and worker count are configured through environment variables. If WebDAV was enabled in `seafdav.conf` before the upgrade, add the following settings to `.env` on each Seafile node:

```sh
ENABLE_SEAFDAV=true
SEAFDAV_WORKERS=5
```

Remove the `enabled` and `workers` options from `$SEAFILE_VOLUME/seafile/conf/seafdav.conf` (default path `/opt/seafile/shared/seafile/conf/seafdav.conf`) and keep the other settings unchanged. Because the volume is shared, update that file once.

### Step 3.3) Update configurations for Metadata server

If you are not using Metadata server, skip this step.

In Seafile 14.0, Metadata server configurations move from `seahub_settings.py` to `.env`. Remove `ENABLE_METADATA_MANAGEMENT` and `METADATA_SERVER_URL` from `seahub_settings.py` if they exist there. The old `METADATA_SERVER_URL` is renamed to `INNER_METADATA_SERVER_URL`.

Add the settings to the `.env` of **each** Seafile node that needs Metadata server. `INNER_METADATA_SERVER_URL` must be reachable from the Seafile container:

```sh
ENABLE_METADATA_MANAGEMENT=True
INNER_METADATA_SERVER_URL=http://<your metadata-server host>:8084
```

### Step 3.4) Update search configurations

In Seafile 14.0, the search switch, search engine selection, document-content indexing, and search engine connection settings are configured in `.env`. The 14.0 cluster Compose/env defaults enable search and use SeaSearch. Keep these settings **identical on every Seafile node**; full-text indexing usually runs on the **backend** node.

!!! warning "Do not enable Elasticsearch and SeaSearch together"
    In `seafevents`, do **not** enable Elasticsearch (`[INDEX FILES]`) and SeaSearch (`[SEASEARCH]`) at the same time. Choose **one** search engine: set `SEARCH_ENGINE=seasearch` **or** `SEARCH_ENGINE=elasticsearch` in `.env`, and remove the obsolete enable/connection keys for the unused engine from `seafevents.conf` as described below. Enabling both can cause seafevents to fail at start.

If you do not use search, add the following setting and skip the rest of this step:

```sh
ENABLE_SEARCH=false
```

If you use search, add the settings for your search engine:

=== "SeaSearch"
    ```sh
    ENABLE_SEARCH=true
    SEARCH_ENGINE=seasearch
    ENABLE_FULL_TEXT_SEARCH=true

    SEASEARCH_URL=http://seasearch:4080
    SEASEARCH_TOKEN=<your SeaSearch authorization token>
    ```
=== "ElasticSearch"
    ```sh
    ENABLE_SEARCH=true
    SEARCH_ENGINE=elasticsearch
    ENABLE_FULL_TEXT_SEARCH=true

    ELASTICSEARCH_SCHEME=http
    ELASTICSEARCH_HOST=<your Elasticsearch host>
    ELASTICSEARCH_PORT=9200
    ELASTICSEARCH_USER=
    ELASTICSEARCH_PASSWORD=
    ```

`ENABLE_FULL_TEXT_SEARCH` controls document-content indexing and defaults to `true`. Set it to `false` for file-name-only search. `SEASEARCH_URL` / `ELASTICSEARCH_HOST` must be reachable from **each** Seafile container.

Also remove obsolete init-only variables from `.env` if they are still present (they existed in 13.0 cluster Compose and were removed in 14.0):

```sh
# Remove these if present:
# CLUSTER_INIT_ES_HOST=...
# CLUSTER_INIT_ES_PORT=...
```

After updating `.env`, remove the old equivalents from the shared `$SEAFILE_VOLUME/seafile/conf/seafevents.conf` (once for the cluster):

1. Remove `enabled` from the `[INDEX FILES]` and `[SEASEARCH]` sections.
2. If you use SeaSearch, remove `seasearch_url` and `seasearch_token` from `[SEASEARCH]`.
3. If you use ElasticSearch, remove `scheme`, `es_host`, `es_port`, `username`, and `password` from `[INDEX FILES]`.
4. Remove `enable_full_text_search` from `[INDEX FILES]` or `[SEASEARCH]`.

Keep any other advanced search options in `seafevents.conf`. For more information, refer to [Search with SeaSearch](../setup/use_seasearch.md) or [Search with ElasticSearch](../setup/use_elasticsearch.md). If you change full-text search settings during the upgrade, clear and rebuild the search index afterward as described in those docs and [Upgrade a Seafile cluster](./upgrade_a_cluster.md).

### Step 3.5) Switch the cache server to Redis

If you are already using Redis as the cache server, skip this step. Starting with Seafile 14.0, many new features rely on Redis. We strongly recommend switching to Redis if you are currently using Memcached. All Seafile nodes must share the **same** Redis instance.

1. Do not remove or comment out the `redis` service, or the `redis` dependency in the `seafile` service, in the newly downloaded cluster `seafile-server.yml` (unless you use an external Redis and have adjusted Compose accordingly).

2. Update the cache settings in `.env` on every node:

    ```sh
    ## Cache
    CACHE_PROVIDER=redis

    ### Redis
    REDIS_HOST=redis
    REDIS_PORT=6379
    REDIS_PASSWORD=
    ```

!!! tip "External Redis server"
    If you use an external Redis server, replace `REDIS_HOST`, `REDIS_PORT`, and `REDIS_PASSWORD` with that server's connection settings on every node.

### Step 3.6) Optional checks

- If database or storage backend variables were never migrated to `.env` during the 13.0 upgrade, ensure they are present now (see [Upgrade a Seafile cluster from 12.0 to 13.0](./upgrade_a_cluster_13.0.md), Steps 3.3–3.4).
- The 14.0 cluster Compose file supports `CSRF_TRUSTED_ORIGINS`. Set it in `.env` when your load balancer / public URL requires it; otherwise you can leave it unset.

!!! tip "Non-standard public HTTP port"
    If the load balancer or Caddy publishes Seafile on a host port other than 80/443 (for example `8080:80`), generated upload/download links may omit that port and point at host port 80. Ensure `SERVICE_URL` and `FILE_SERVER_ROOT` include the public port (for example `http://example.com:8080` and `http://example.com:8080/seafhttp`), or also map host port 80 to the same HTTP listener (`80:80` in addition to `8080:80`).

## Step 4) Modify shared config files under `$SEAFILE_VOLUME`

Config files live under `$SEAFILE_VOLUME/seafile/conf/` (default `/opt/seafile/shared/seafile/conf/`). Because the volume is **shared** across nodes, update each file **once** (for example on one node) and confirm the changes are visible cluster-wide.

### Step 4.1) Update configurations for Thumbnail server

If you are not using Thumbnail server, skip to Step 4.2.

Open `seahub_settings.py` and remove the following configuration if it exists. In Seafile 14.0, video thumbnail is enabled by default:

```python
# video thumbnails (disabled by default)
ENABLE_VIDEO_THUMBNAIL = True
```

Then add:

```python
# enable thumbnail-server (disabled by default)
ENABLE_THUMBNAIL_SERVER = True
```

### Step 4.2) Update local password configurations

The following options have been removed in Seafile 14.0. Remove them from `seahub_settings.py` if they exist:

```python
DISABLE_ADFS_USER_PWD_LOGIN = True
ENABLE_CHANGE_PASSWORD = True
ENABLE_SSO_USER_CHANGE_PASSWORD = True
```

To prevent users authenticated through external providers from using passwords stored in Seafile, you may add:

```python
DISABLE_SSO_USER_LOCAL_PWD_LOGIN = True # default: False
```

### Step 4.3) Update monthly traffic-limit configurations

If `ENABLED_ROLE_PERMISSIONS` in `seahub_settings.py` does not contain `monthly_rate_limit` or `monthly_rate_limit_per_user`, skip this step.

In Seafile 14.0, monthly download and upload allowances are configured independently. Replace legacy keys with `monthly_download_traffic_limit` / `monthly_download_traffic_limit_per_user`, and optionally add independent upload limits. Full examples and throttle options are documented in [Upgrade Seafile Docker from 13.0 to 14.0](./upgrade_docker_14.0.md#step-43-update-monthly-traffic-limit-configurations). Also see [Roles and Permissions](../config/roles_permissions.md).

### Step 4.4) Seafile AI and obsolete cleanup

!!! important "Redeploy Seafile AI"
    Seafile AI has undergone significant changes in Seafile 14.0. If you are using Seafile AI, follow [Seafile AI extension](../extension/seafile-ai.md) to redeploy it. Before redeploying, remove the old settings listed in [Seafile obsolete configurations](./seafile_obsolete_configurations.md#seafile-13-to-14-obsolete-configurations). Face recognition has been removed in 14.0; clean up related settings as described in the obsolete configurations page.

    Model settings must live in `$SEAFILE_VOLUME/seafile/conf/seafile_ai_config.yaml` under `global.LLM_MODELS`. For a custom OpenAI-compatible endpoint, use `type: other` (a wrong schema yields "No valid LLM configurations"). Translate API calls need `lang=zh-cn` (not `target_lang`) and an `Authorization: Token <HS256 JWT>` header signed with `JWT_PRIVATE_KEY`. Details are in the [Seafile AI extension](../extension/seafile-ai.md).

Also remove obsolete keys listed in [Seafile obsolete configurations (13 to 14)](./seafile_obsolete_configurations.md#seafile-13-to-14-obsolete-configurations). In particular, delete `ENABLE_FACE_RECOGNITION` and any face-embedding Compose references if still present from 13.0, and move leftover Seafile AI model settings out of `.env` into `seafile_ai_config.yaml`.

## Step 5) Start Seafile on one node

!!! note
    According to this upgrade document, start a **frontend** node first so the database upgrade in the next step runs on a frontend. If this node must remain a backend, set the following in `.env` (database upgrade should still be performed on one frontend):

    ```sh
    CLUSTER_MODE=backend
    ```

```sh
docker compose up -d
```

## Step 6) Upgrade Seafile

Run the upgrade script **once**, inside the Seafile container on the frontend node you just started:

```sh
docker exec -it seafile bash
# enter the container `seafile`

# stop servers
cd /opt/seafile/seafile-server-latest
./seafile.sh stop
./seahub.sh stop

# upgrade seafile
cd upgrade
./upgrade_13.0_14.0.sh
```

!!! tip
    The `14.0` image ships `upgrade/upgrade_13.0_14.0.sh` (verified in `seafile-pro-mc:14.0.x`). Follow the script prompts. When it finishes successfully, exit the container with `exit`. Do **not** run the upgrade script again on other nodes.

    The script may print `WARN` lines about missing database tables you never used (for example `permaudit`, and similarly unused audit/virus/trash-related tables). Those warnings are safe to ignore if the corresponding features were not enabled on your deployment.

## Step 7) Restart current node

```sh
docker compose down
docker compose up -d
```

!!! tip
    - You can use `docker logs -f seafile` to check whether the current node service is running normally.

## Step 8) Operations for other nodes

On each remaining frontend and backend node:

1. Download the same cluster `seafile-server.yml` and align `.env` with the first node (image version, WebDAV, metadata, search, Redis, and other shared settings). For backend nodes, set `CLUSTER_MODE=backend`.
2. Do **not** run `upgrade_13.0_14.0.sh` again.
3. Start Seafile:

    ```sh
    docker compose up -d
    ```

Shared conf under `$SEAFILE_VOLUME` is already updated. Avoid diverging per-node conf copies if any node does not use the shared volume.

After all nodes are up, verify load-balancer health for frontend nodes.

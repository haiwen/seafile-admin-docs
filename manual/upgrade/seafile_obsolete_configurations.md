# Seafile Obsolete Configurations

## Seafile 13 to 14 Obsolete Configurations

Back up `.env` and the files in `conf/`, and migrate values before removing old settings. Download the [latest `.yml` files](./upgrade_docker_14.0.md#step-2-download-the-newest-yml-files) to replace the existing deployment files. For the upgrade procedure, see [Upgrade Seafile Docker from 13.0 to 14.0](./upgrade_docker_14.0.md).

### seafdav.conf

Move these `[WEBDAV]` options to the Seafile server `.env`, then remove them from `seafdav.conf`:

| Old option | Replacement in `.env` |
| --- | --- |
| `enabled` | `ENABLE_SEAFDAV` (default: `false`) |
| `workers` | `SEAFDAV_WORKERS` (default: `5`) |

Keep the other WebDAV options. See [WebDAV extension](../extension/webdav.md).

### seahub_settings.py

Remove or migrate the following settings:

| Old setting | Action |
| --- | --- |
| `DISABLE_ADFS_USER_PWD_LOGIN`, `ENABLE_CHANGE_PASSWORD`, `ENABLE_SSO_USER_CHANGE_PASSWORD` | Remove. Use `DISABLE_SSO_USER_LOCAL_PWD_LOGIN=True` to disable local-password login and change/reset operations for externally authenticated users. |
| `ENABLE_METADATA_MANAGEMENT` | Move to the Seafile server `.env`; set to `True` to enable metadata management. |
| `METADATA_SERVER_URL` | Move to `.env` as `INNER_METADATA_SERVER_URL`. The default for same-host deployment is `http://seafile-md-server:8084`; set a reachable URL for a standalone server. |
| `ENABLE_VIDEO_THUMBNAIL` | Remove. Video thumbnails are enabled by default in 14.0. Set `ENABLE_THUMBNAIL_SERVER=True` to use the optional Thumbnail server. |
| `AI_PRICES` | Move model prices to `global.LLM_MODELS[].price` in `seafile_ai_config.yaml`. |

`DISABLE_SSO_USER_LOCAL_PWD_LOGIN` defaults to `False` and applies only to externally authenticated users. It does not replace the old global password-change switch.

AI prices now use `input_tokens` and `output_tokens` per **1,000,000 tokens**. Multiply old `input_tokens_1k` and `output_tokens_1k` prices by 1,000, checking any custom units. Review `monthly_ai_credit_per_user`: 14.0 uses **100 credits per currency unit**. See [AI usage statistics](../extension/seafile-ai.md#enable-ai-usage-statistics).

#### Monthly traffic limits

Replace these keys in every role in `ENABLED_ROLE_PERMISSIONS`, preserving their values:

| Old role permission | Replacement |
| --- | --- |
| `monthly_rate_limit` | `monthly_download_traffic_limit` |
| `monthly_rate_limit_per_user` | `monthly_download_traffic_limit_per_user` |

Upload allowances use `monthly_upload_traffic_limit` and `monthly_upload_traffic_limit_per_user`. See [Monthly traffic-limit migration](./upgrade_docker_14.0.md#step-43-update-monthly-traffic-limit-configurations).

### seafevents.conf (Pro edition only)

Move these settings to the Seafile server `.env`, then remove the old options:

| Section | Old option | Replacement in `.env` |
| --- | --- | --- |
| `[INDEX FILES]` | `enabled` | `ENABLE_SEARCH` and `SEARCH_ENGINE=elasticsearch` |
| `[SEASEARCH]` | `enabled` | `ENABLE_SEARCH` and `SEARCH_ENGINE=seasearch` |
| Either section | `index_office_pdf`, `enable_full_text_search` | `ENABLE_FULL_TEXT_SEARCH` |
| `[SEASEARCH]` | `seasearch_url` | `SEASEARCH_URL` |
| `[SEASEARCH]` | `seasearch_token` | `SEASEARCH_TOKEN` |
| `[INDEX FILES]` | `scheme` | `ELASTICSEARCH_SCHEME` |
| `[INDEX FILES]` | `es_host` | `ELASTICSEARCH_HOST` |
| `[INDEX FILES]` | `es_port` | `ELASTICSEARCH_PORT` |
| `[INDEX FILES]` | `username` | `ELASTICSEARCH_USER` |
| `[INDEX FILES]` | `password` | `ELASTICSEARCH_PASSWORD` |

In 14.0 Pro, `ENABLE_SEARCH` and `ENABLE_FULL_TEXT_SEARCH` default to `true`, and `SEARCH_ENGINE` defaults to `seasearch`. Set `ENABLE_SEARCH=false` to keep search disabled, or `ENABLE_FULL_TEXT_SEARCH=false` for file-name-only search. Keep `SEARCH_ENGINE=elasticsearch` if using Elasticsearch. Changing full-text indexing requires clearing and rebuilding the index.

Environment variables take precedence over the corresponding file-based full-text and Elasticsearch connection settings. Keep advanced options such as `interval`, `highlight`, `office_file_size_limit`, `cafile`, and custom index names. See [SeaSearch](../setup/use_seasearch.md) or [ElasticSearch](../setup/use_elasticsearch.md).

### .env

#### Seafile AI models

Replace these variables with fields in `global.LLM_MODELS` in `$SEAFILE_VOLUME/seafile/conf/seafile_ai_config.yaml`:

| Old variable | Model field |
| --- | --- |
| `SEAFILE_AI_LLM_TYPE` | `type` |
| `SEAFILE_AI_LLM_URL` | `url` |
| `SEAFILE_AI_LLM_KEY` | `key` |
| `SEAFILE_AI_LLM_MODEL` | `model` |

Keep `ENABLE_SEAFILE_AI` and `SEAFILE_AI_SERVER_URL`. Redeploy using the [14.0 Seafile AI guide](../extension/seafile-ai.md); for standalone deployment, keep the model files on both hosts consistent.

#### Face recognition

Face recognition has been removed. Remove these variables from Seafile, Seafile AI, and face-embedding deployments:

```env
ENABLE_FACE_RECOGNITION=
FACE_EMBEDDING_IMAGE=
FACE_EMBEDDING_SERVICE_URL=
FACE_EMBEDDING_SERVICE_KEY=
FACE_EMBEDDING_VOLUME=
```

Remove `face-embedding.yml` from the `.env` setting `COMPOSE_FILE`. Keep `JWT_PRIVATE_KEY`, which other services still require.

#### Standalone Metadata server

Remove `MD_DATA`; use `SEAFILE_VOLUME` for the host data directory, keeping the existing data path. Rename `S3_KEY` to `S3_SECRET_KEY`, preserving its value. These correct unused entries in the 13.0 `.env` template. See [Metadata server](../extension/metadata-server.md).

#### Standalone Seafile AI

Remove `SEAFILE_SERVER_PROTOCOL` and `SEAFILE_SERVER_HOSTNAME` from the standalone AI `.env`; configure `INNER_SEAHUB_SERVICE_URL` instead. Keep the protocol and hostname variables in the Seafile server `.env` and other deployments that use them.

## Seafile 12 to 13 Obsolete Configurations

### seafevents.conf

You should remove the `[DATABASE]` configuration block.

### seafile.conf
You should remove the `[database]` and `[memcached]` configuration block.

### seahub_settings.py
You should remove the `SERVICE_URL`, `DATABASES = {...}`, `CACHES = {...}`, `COMPRESS_CACHE_BACKEND` and `FILE_SERVER_ROOT` configuration block.

### env
The following configurations are removed or renamed to new ones.

```shell
SEAFILE_MEMCACHED_IMAGE=docker.seafile.top/seafileltd/memcached:1.6.29

INIT_S3_STORAGE_BACKEND_CONFIG=false
INIT_S3_COMMIT_BUCKET=<your-commit-objects>
INIT_S3_FS_BUCKET=<your-fs-objects>
INIT_S3_BLOCK_BUCKET=<your-block-objects>
INIT_S3_KEY_ID=<your-key-id>
INIT_S3_SECRET_KEY=<your-secret-key>
INIT_S3_USE_V4_SIGNATURE=true
INIT_S3_AWS_REGION=us-east-1
INIT_S3_HOST=
INIT_S3_USE_HTTPS=true

NOTIFICATION_SERVER_VOLUME=/opt/notification-data

SS_S3_USE_V4_SIGNATURE=false
SS_S3_ACCESS_ID=<your access id>
SS_S3_ACCESS_SECRET=<your access secret>
SS_S3_ENDPOINT=
SS_S3_BUCKET=<your bucket name>
SS_S3_USE_HTTPS=true
SS_S3_PATH_STYLE_REQUEST=true
SS_S3_AWS_REGION=us-east-1
SS_S3_SSE_C_KEY=<your SSE-C key>
```

## Seafile 11 to 12 Obsolete Configurations

### ccnet.conf
You should remove the entire `ccnet.conf` configuration file.

### seafile.conf

You should remove the `[notification]` configuration block.

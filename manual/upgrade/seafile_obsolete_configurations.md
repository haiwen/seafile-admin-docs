# Seafile Obsolete Configurations

The Seafile configuration files are located in the `/opt/seafile-data/seafile/conf/` directory.

## Seafile 13 to 14 Obsolete Configurations

### seahub_settings.py

Remove the following options. They are replaced by `DISABLE_SSO_USER_LOCAL_PWD_LOGIN`, which controls use of locally stored passwords by externally authenticated users.

```python
DISABLE_ADFS_USER_PWD_LOGIN = True
ENABLE_CHANGE_PASSWORD = True
ENABLE_SSO_USER_CHANGE_PASSWORD = True
```

The following legacy keys in `ENABLED_ROLE_PERMISSIONS` are no longer read. After migrating their existing values to `monthly_download_traffic_limit` and `monthly_download_traffic_limit_per_user`, remove them from every role where they are configured:

```python
'monthly_rate_limit': '',
'monthly_rate_limit_per_user': '',
```

### .env

Seafile AI models are configured in `seafile_ai_config.yaml` in Seafile 14.0. Remove the following legacy model environment variables:

```env
SEAFILE_AI_LLM_TYPE=
SEAFILE_AI_LLM_URL=
SEAFILE_AI_LLM_KEY=
SEAFILE_AI_LLM_MODEL=
```

Face recognition and the face-embedding service have been removed in Seafile 14.0. Remove the following environment variables:

```env
ENABLE_FACE_RECOGNITION=
FACE_EMBEDDING_SERVICE_URL=
FACE_EMBEDDING_SERVICE_KEY=
FACE_EMBEDDING_VOLUME=
```

If `face-embedding.yml` is included in the `COMPOSE_FILE` setting, remove it from that setting.

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

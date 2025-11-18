# Seafile Obsolete Configurations

The Seafile configuration files are located in the `/opt/seafile-data/seafile/conf/` directory.

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

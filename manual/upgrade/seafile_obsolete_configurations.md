# Seafile Obsolete Configurations

The Seafile configuration files are located in the `/opt/seafile-data/seafile/conf/` directory.

## **Seafile 12 to 13 Obsolete Configurations**

### seafevents.conf

You should remove the `[DATABASE]` configuration block.

### seafile.conf
You should remove the `[database]` and `[memcached]` configuration block.

### seahub_settings.py
You should remove the `SERVICE_URL`, `DATABASES = {...}`, `CACHES = {...}`, `COMPRESS_CACHE_BACKEND` and `FILE_SERVER_ROOT` configuration block.

### env
The env file has undergone major changes. It is recommended that you download the latest env file.

#### Removed Configurations

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

#### New Configurations

```shell
BASIC_STORAGE_PATH=/opt
CACHE_PROVIDER=redis # options: redis (recommend), memcached
ENABLE_NOTIFICATION_SERVER=false
ENABLE_SEAFILE_AI=false
MD_FILE_COUNT_LIMIT=100000
MD_IMAGE=docker.seafile.top/seafileltd/seafile-md-server:13.0-latest
MD_STORAGE_TYPE=$SEAF_SERVER_STORAGE_TYPE # disk, s3
MEMCACHED_HOST=memcached
MEMCACHED_PORT=11211
NOTIFICATION_SERVER_URL=
REDIS_HOST=redis
REDIS_PASSWORD=
REDIS_PORT=6379
S3_AWS_REGION=us-east-1
S3_BLOCK_BUCKET=<your block bucket name>
S3_COMMIT_BUCKET=<your commit bucket name>
S3_FS_BUCKET=<your fs bucket name>
S3_HOST=
S3_KEY_ID=<your-key-id>
S3_MD_BUCKET=<your metadata bucket name> # for metadata-server
S3_PATH_STYLE_REQUEST=false
S3_SECRET_KEY=<your-secret-key>
S3_SSE_C_KEY=
S3_SS_BUCKET=<your seasearch bucket name> # for seasearch
S3_USE_HTTPS=true
S3_USE_V4_SIGNATURE=true
SEAFILE_AI_LLM_KEY= # your llm key
SEAFILE_AI_LLM_MODEL=gpt-4o-mini
SEAFILE_AI_LLM_TYPE=openai
SEAFILE_AI_LLM_URL=
SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db
SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db
SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db
SEAFILE_REDIS_IMAGE=redis
SEAF_SERVER_STORAGE_TYPE=disk # disk, s3, multiple
```

## **Seafile 11 to 12 Obsolete Configurations**

### ccnet.conf
You should remove the entire `ccnet.conf` configuration file.

### gunicorn.conf.py

#### New Configurations

```shell
# for forwarder headers
forwarder_headers = 'SCRIPT_NAME,PATH_INFO,REMOTE_USER'
```

### seafile.conf

You should remove the `[notification]` configuration block.

#### New Configurations

```shell
[memcached]
memcached_options = --SERVER=memcached --POOL-MIN=10 --POOL-MAX=100
```

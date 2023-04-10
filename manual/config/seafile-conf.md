# Seafile.conf settings

**Important**: Every entry in this configuration file is **case-sensitive**.

You need to restart seafile and seahub so that your changes take effect.

```
./seahub.sh restart
./seafile.sh restart

```

## Storage Quota Setting

You may set a default quota (e.g. 2GB) for all users. To do this, just add the following lines to `seafile.conf` file

```
[quota]
# default user quota in GB, integer only
default = 2

```

This setting applies to all users. If you want to set quota for a specific user, you may log in to seahub website as administrator, then set it in "System Admin" page.

## Default history length limit

If you don't want to keep all file revision history, you may set a default history length limit for all libraries.

```
[history]
keep_days = days of history to keep

```

## Default trash expiration time

The default time for automatic cleanup of the libraries trash is 30 days.You can modify this time by adding the following configuration：

```
[library_trash]
expire_days = 60

```

## System Trash

Seafile uses a system trash, where deleted libraries will be moved to. In this way, accidentally deleted libraries can be recovered by system admin.

## Seafile fileserver configuration

The configuration of seafile fileserver is in the `[fileserver]` section of the file `seafile.conf`

```
[fileserver]
# bind address for fileserver
# default to 0.0.0.0, if deployed without proxy: no access restriction
# set to 127.0.0.1, if used with local proxy: only access by local
host = 127.0.0.1
# tcp port for fileserver
port = 8082

```

Since Community Edition 6.2 and Pro Edition 6.1.9, you can set the number of worker threads to server http requests. Default value is 10, which is a good value for most use cases.

```
[fileserver]
worker_threads = 15

```

Change upload/download settings.

```
[fileserver]
# Set maximum upload file size to 200M.
# If not configured, there is no file size limit for uploading.
max_upload_size=200

# Set maximum download directory size to 200M.
# Default is 100M.
max_download_dir_size=200

```

After a file is uploaded via the web interface, or the cloud file browser in the client, it needs to be divided into fixed size blocks and stored into storage backend. We call this procedure "indexing". By default, the file server uses 1 thread to sequentially index the file and store the blocks one by one. This is suitable for most cases. But if you're using S3/Ceph/Swift backends, you may have more bandwidth in the storage backend for storing multiple blocks in parallel. We provide an option to define the number of concurrent threads in indexing:

```
[fileserver]
max_indexing_threads = 10

```

When users upload files in the web interface (seahub), file server divides the file into fixed size blocks. Default blocks size for web uploaded files is 8MB. The block size can be set here.

```
[fileserver]
#Set block size to 2MB
fixed_block_size=2

```

When users upload files in the web interface, file server assigns an token to authorize the upload operation. This token is valid for 1 hour by default. When uploading a large file via WAN, the upload time can be longer than 1 hour. You can change the token expire time to a larger value.

```
[fileserver]
#Set uploading time limit to 3600s
web_token_expire_time=3600

```

You can download a folder as a zip archive from seahub, but some zip software
on windows doesn't support UTF-8, in which case you can use the "windows_encoding"
settings to solve it.

```
[zip]
# The file name encoding of the downloaded zip file.
windows_encoding = iso-8859-1

```

The "httptemp" directory contains temporary files created during file upload and zip download. In some cases the temporary files are not cleaned up after the file transfer was interrupted. Starting from 7.1.5 version, file server will regularly scan the "httptemp" directory to remove files created long time ago.

```
[fileserver]
# After how much time a temp file will be removed. The unit is in seconds. Default to 3 days.
http_temp_file_ttl = x
# File scan interval. The unit is in seconds. Default to 1 hour.
http_temp_scan_interval = x

```

New in Seafile Pro 7.1.16 and Pro 8.0.3: You can set the maximum number of files contained in a library that can be synced by the Seafile client. The default is 100000. When you download a repo, Seafile client will request fs id list, and you can control the timeout period of this request through `fs_id_list_request_timeout` configuration, which defaults to 5 minutes. These two options are added to prevent long fs-id-list requests from overloading the server.

Since Pro 8.0.4 version, you can set both options to -1, to allow unlimited size and timeout.

```
[fileserver]
max_sync_file_count = 100000
fs_id_list_request_timeout = 300
```

If you use object storage as storage backend, when a large file is frequently downloaded, the same blocks need to be fetched from the storage backend to Seafile server. This may waste bandwith and cause high load on the internal network. Since Seafile Pro 8.0.5 version, we add block caching to improve the situation. Note that this configuration is only effective for downloading files through web page or API, but not for syncing files.

* To enable this feature, set `use_block_cache` option in the `[fileserver]` group. It's not enabled by default. 
* The `block_cache_size_limit` option is used to limit the size of the cache. Its default value is 10GB. The blocks are cached in `seafile-data/block-cache` directory. When the total size of cached files exceeds the limit, seaf-server will clean up older files until the size reduces to 70% of the limit. The cleanup interval is 5 minutes. You have to have a good estimate on how much space you need for the cache directory. Otherwise on frequent downloads this directory can be quickly filled up.
* The `block_cache_file_types` configuration is used to choose the file types that are cached. `block_cache_file_types` the default value is mp4;mov.

```
[fileserver]
use_block_cache = true
# Set block cache size limit to 100MB
block_cache_size_limit = 100
block_cache_file_types = mp4;mov
```
When a large number of files are uploaded through the web page and API, it will be expensive to calculate block IDs based on the block contents. Since Seafile-pro-9.0.6, you can add the `skip_block_hash` option to use a random string as block ID. Note that this option will prevent fsck from checking block content integrity. You should specify `--shallow` option to fsck to not check content integrity.

```
[fileserver]
skip_block_hash = true
```

If you want to limit the type of files when uploading files, since Seafile Pro 10.0.0 version, you can set `file_ext_white_list` option in the `[fileserver]` group. This option is a list of file types, only the file types in this list are allowed to be uploaded. It's not enabled by default. 

```
[fileserver]
file_ext_white_list = md;mp4;mov
```

Since seafile 10.0.1, when you use go fileserver, you can set `upload_limit` and `download_limit` option in the `[fileserver]` group to limit the speed of file upload and download. It's not enabled by default. 

```
[fileserver]
# The unit is in KB/s.
upload_limit = 100
download_limit = 100
```

## Database configuration

The whole database configuration is stored in the `[database]` section of the configuration file, whether you use SQLite, MySQL or PostgreSQL.

```
[database]
type=mysql
host=127.0.0.1
user=root
password=root
db_name=seafile_db
connection_charset=utf8
max_connections=100

```

When you configure seafile server to use MySQL, the default connection pool size is 100, which should be enough for most use cases.

## File Locking (Pro edition only)

The Seafile Pro server auto expires file locks after some time, to prevent a locked file being locked for too long. The expire time can be tune in seafile.conf file.

```
[file_lock]
default_expire_hours = 6

```

The default is 12 hours.

Since Seafile-pro-9.0.6, you can add cache for getting locked files (reduce server load caused by sycing client).

```
[file_lock]
use_locked_file_cache = true

```

At the same time, you also need to configure the following memcache options for the cache to take effect:

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100

```

## Enable Slow Log

Since Seafile-pro-6.3.10, you can enable seaf-server's RPC slow log to do performance analysis.The slow log is enabled by default.

If you want to configure related options, add the options to seafile.conf:

```
[slow_log]
# default to true
enable_slow_log = true
# the unit of all slow log thresholds is millisecond.
# default to 5000 milliseconds, only RPC queries processed for longer than 5000 milliseconds will be  logged.
rpc_slow_threshold = 5000

```

You can find `seafile_slow_rpc.log` in `logs/slow_logs`. You can also use [log-rotate](../deploy/using_logrotate.md) to rotate the log files. You just need to send `SIGUSR2` to `seaf-server` process. The slow log file will be closed and reopened.

Since 9.0.2 Pro, the signal to trigger log rotation has been changed to `SIGUSR1`. This signal will trigger rotation for all log files opened by seaf-server. You should change your log rotate settings accordingly.

## Enable Access Log

Even though Nginx logs all requests with certain details, such as url, response code, upstream process time, it's sometimes desirable to have more context about the requests, such as the user id for each request. Such information can only be logged from file server itself. Since 9.0.2 Pro, access log feature is added to fileserver.

To enable access log, add below options to seafile.conf:

```
[fileserver]
# default to false. If enabled, fileserver-access.log will be written to log directory.
enable_access_log = true
```

The log format is as following:

```
start time - user id - url - response code - process time
```

You can use `SIGUSR1` to trigger log rotation.

## Profiling Go Fileserver Performance

Since Seafile 9.0.7, you can enable the profile function of go fileserver by adding the following configuration options:

```
# profile_password is required, change it for your need
[fileserver]
enable_profiling = true
profile_password = 8kcUz1I2sLaywQhCRtn2x1

```

This interface can be used through the pprof tool provided by Go language. See https://pkg.go.dev/net/http/pprof for details. Note that you have to first install Go on the client that issues the below commands. The password parameter should match the one you set in the configuration.

```
go tool pprof http://localhost:8082/debug/pprof/heap?password=8kcUz1I2sLaywQhCRtn2x1
go tool pprof http://localhost:8082/debug/pprof/profile?password=8kcUz1I2sLaywQhCRtn2x1
```

## Notification server configuration
Since Seafile 10.0.0, you can enable the notification server by adding the following configuration options:

```
# jwt_private_key are required.You should generate it manually.
[notification]
enabled = true
# the ip of notification server
host = 127.0.0.1
# the port of notification server
port = 8083
# the log level of notification server
log_level = info
# jwt_private_key is used to generate jwt token and authenticate seafile server
jwt_private_key = M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F
```

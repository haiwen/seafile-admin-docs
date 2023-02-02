# Memcached Options for Pro Edition

In Seafile Pro edition, a few advanced features rely on memcached, in addition to the basic memcached usage mentioned in [community edition memcached options](../deploy/add_memcached.md).

* When clustering is enabled, some information is stored in memcached to allow access from multiple nodes. It includes copy/move progress, zip progress.
* Some information is cached in memcached to improve performance, such as library list, small objects from object storage backends, mapping from library ID to storage backends.

For historic reasons, the memcached configurations for different features are scattered in different sections in seafile.conf file. We list these options here for quick reference.

For [clustering](./deploy_in_a_cluster.md), the following options are provided.

```
[cluster]
enabled = true
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

For object storage backends, memcached options can be added in the backend configurations. You can refer to the corresponding documentation for specific backend. For example, when you use S3 backend,

```
[block_backend]
name = s3
# bucket name can only use lowercase characters, numbers, periods and dashes. Period cannot be used in Frankfurt region.
bucket = my-block-objects
key_id = your-key-id
key = your-secret-key
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

When you enable [multiple storage backend](./multiple_storage_backends.md), you can set the below options to cache mappings from library ID to its backend. This option also enables library list cache feature, which reduces database loads for frequently listing accessible library list.

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

Since version 8.0, all memcached options are consolidated to the one below.

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

If the above option is set, it'll override all other memcached options. If it's not set, the old and existing options will be used. So it's backward compatible.

## Cache Options after 10.0

Since Seafile-pro-10.0.0, redis cache is supported and `[memcached]` or `[redis]` option group must be configured in seafile.conf.

You can use redis as the cache by adding the following configuration:

```
[redis]
# the ip of redis server
redis_server = 127.0.0.1
# the port of redis server
redis_port = 6379
# the expire time of redis, the unit is second, default to 24h
redis_expriy = 86400
# the max number of connections to redis server, default to 100
max_connections = 100
```

If you configure `[redis]` and `[memcache]` option group at the same time, then redis will be used as the cache.

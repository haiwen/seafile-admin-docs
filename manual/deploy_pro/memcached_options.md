# Setup Memcached for Pro Edition

In Seafile Pro edition, a few advanced features rely on memcached.

* When clustering is enabled, some information is stored in memcached to allow access from multiple nodes. It includes copy/move progress, zip progress.
* Some information is cached in memcached to improve performance, such as library list, small objects from object storage backends, mapping from library ID to storage backends.

## Install Memcached

First, make sure `libmemcached` library and development headers are installed on your system.

```
# on Debian/Ubuntu 18.04+
apt-get install memcached libmemcached-dev -y
pip3 install --timeout=3600 pylibmc django-pylibmc

systemctl enable --now memcached

```

```
# on CentOS 8
yum install memcached libmemcached -y
pip3 install --timeout=3600 pylibmc django-pylibmc﻿

systemctl enable --now memcached

```

## Modify seahub_settings.py

Add the following configuration to `seahub_settings.py`.

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
}

```

## Modify seafile.conf

Since Seafile-pro-10.0.0, `[memcached]` option group must be configured in seafile.conf. You only need to set this one option to replace all previous memcached related options in seafile.conf.

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

### For version 7.1 or before

The memcached configurations for different features are scattered in different sections in seafile.conf file. We list these options here for quick reference.

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


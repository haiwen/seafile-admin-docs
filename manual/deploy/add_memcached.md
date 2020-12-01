# Add memcached

Seahub caches items (avatars, profiles, etc) on the file system in /tmp/seahub_cache/ by default. You can use memcached instead to improve the performance.

First, make sure `libmemcached` library and development headers are installed on your system.

**For Seafile 7.0.x**

```
# on Debian/Ubuntu 16.04
apt-get install memcached libmemcached-dev -y

﻿systemctl enable --now memcached

```

```
# on CentOS 7
yum install memcached libffi-devel -y

﻿systemctl enable --now memcached

```

**For Seafile 7.1.x**

```
# on Debian/Ubuntu 18.04
apt-get install memcached libmemcached-dev -y
pip3 install --timeout=3600 pylibmc django-pylibmc

﻿systemctl enable --now memcached

```

```
# on CentOS 8
yum install memcached libmemcached -y
pip3 install --timeout=3600 pylibmc django-pylibmc﻿

systemctl enable --now memcached

```

Add the following configuration to `seahub_settings.py`.

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
}

```

If you use a memcached cluster, your configuration depends on your Seafile server version. You can find how to setup memcached cluster [here](../deploy_pro/memcached_mariadb_cluster.md).

## Seafile server before 6.2.11

Please replace the `CACHES` variable with the following. This configuration uses consistent hashing to distribute the keys in memcached. More information can be found on [pylibmc documentation](http://sendapatch.se/projects/pylibmc/behaviors.html) and [django-pylibmc documentation](https://github.com/django-pylibmc/django-pylibmc). Supposed your memcached server addresses are 192.168.1.13\[4-6].

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': ['192.168.1.134:11211', '192.168.1.135:11211', '192.168.1.136:11211',],
        'OPTIONS': {
            'ketama': True,
            'remove_failed': 1,
            'retry_timeout': 3600,
            'dead_timeout': 3600
        }
    },
    'locmem': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    },
}
COMPRESS_CACHE_BACKEND = 'locmem'

```

## Seafile Server 6.2.11 or newer

The configuration is the same as single node memcached server. Just replace the IP address with the floating IP.

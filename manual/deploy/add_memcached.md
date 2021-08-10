# Add memcached

Seahub caches items (avatars, profiles, etc) on the file system in /tmp/seahub_cache/ by default. You can use memcached instead to improve the performance.

First, make sure `libmemcached` library and development headers are installed on your system.

**For Seafile 7.1+**

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

Add the following configuration to `seahub_settings.py`.

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
}

```


**For Seafile 7.0.x**

```
# on Debian/Ubuntu 16.04
apt-get install memcached libmemcached-dev -y

systemctl enable --now memcached

```

```
# on CentOS 7
yum install memcached libffi-devel -y

systemctl enable --now memcached

```


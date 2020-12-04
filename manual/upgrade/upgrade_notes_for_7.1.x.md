# Upgrade notes for 7.1.x

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

From 7.1.0 version, Seafile will depend on the Python 3 and is not compatible with Python 2.

Therefore you cannot upgrade directly from Seafile 6.x.x to 7.1.x.

**If your current version of Seafile is not 7.0.x, you must first download the 7.0.x installation package and **[**upgrade to 7.0.x**](./upgrade_notes_for_7.0.x.md)** before performing the subsequent operations.**

To support both Python 3.6 and 3.7, we no longer bundle python libraries with Seafile package. You need to install most of the libraries by your own as bellow.

### Deploy Python3

Note, you should install Python libraries system wide using root user or sudo mode.

#### Seafile-CE

* For Ubuntu 16.04/18.04 or Debian 10

```sh
apt-get install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
    django-pylibmc django-simple-captcha python3-ldap

```

* For CentOS 7/8

```sh
yum install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
    django-pylibmc django-simple-captcha python3-ldap

```

#### Seafile-Pro

* For Ubuntu 16.04/18.04 or Debian 10

```sh
apt-get install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
    django-pylibmc django-simple-captcha python3-ldap

```

* For CentOS 7/8

```sh
yum install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy \
    django-pylibmc django-simple-captcha python3-ldap

```

### Upgrade to 7.1.x

1. Stop Seafile-7.0.x server.
2. Start from Seafile 7.0.x, run the script:

```sh
upgrade/upgrade_7.0_7.1.sh

```

3. Clear the Seahub cache:

```
rm -rf /tmp/seahub_cache # Clear the Seahub cache files from disk.
# If you are using the Memcached service, you need to restart the service to clear the Seahub cache.
systemctl restart memcached

```

4. Start Seafile-7.1.x server.

### Proxy Seafdav

After Seafile 7.1.x, Seafdav does not support Fastcgi, only Wsgi.

This means that if you are using Seafdav functionality and have deployed Nginx or Apache reverse proxy. You need to change Fastcgi to Wsgi.

#### For Nginx

For Seafdav, the configuration of Nginx is as follows:

```
.....
    location /seafdav {
        proxy_pass         http://127.0.0.1:8080/seafdav;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout  1200s;
        client_max_body_size 0;

        access_log      /var/log/nginx/seafdav.access.log seafileformat;
        error_log       /var/log/nginx/seafdav.error.log;
    }

```

#### For Apache

For Seafdav, the configuration of Apache is as follows:

```
......
    <Location /seafdav>
        ProxyPass "http://127.0.0.1:8080/seafdav"
    </Location>

```

### Builtin office file preview

The implementation of builtin office file preview has been changed. You should update your configuration according to:

<https://download.seafile.com/published/seafile-manual/deploy_pro/office_documents_preview.md#user-content-Version%207.1+>

### If you are using Ceph backend

If you are using Ceph storage backend, you need to install new python library.

On Debian/Ubuntu (Seafile 7.1+):

```
sudo apt-get install python3-rados

```

### Login Page Customization

If you have customized the login page or other html pages, as we have removed some old javascript libraries, your customized pages may not work anymore. Please try to re-customize based on the newest version.

### User name encoding issue with Shibboleth login

> Note, the following patch is included in version pro-7.1.8 and ce-7.1.5 already.

We have two customers reported that after upgrading to version 7.1, users login via Shibboleth single sign on have a wrong name if the name contains a special character. We suspect it is a Shibboleth problem as it does not sending the name in UTF-8 encoding to Seafile. (<https://issues.shibboleth.net/jira/browse/SSPCPP-2>)

The solution is to modify the code in seahub/thirdpart/shibboleth/middleware.py:

```
158         if nickname.strip():  # set nickname when it's not empty
159             p.nickname = nickname

to 

158         if nickname.strip():  # set nickname when it's not empty
159             p.nickname = nickname.encode("iso-8859-1”).decode('utf8')

```

If you have this problem too, please let us know.

## FAQ

### SQL Error during upgrade

The upgrade script will try to create a missing table and remove an used index. The following SQL errors are jus warnings and can be ignored:

```
[INFO] updating seahub database...
/opt/seafile/seafile-server-7.1.1/seahub/thirdpart/pymysql/cursors.py:170: Warning: (1050, "Table 'base_reposecretkey' already exists")
  result = self._query(query)
[WARNING] Failed to execute sql: (1091, "Can't DROP 'drafts_draft_origin_file_uuid_7c003c98_uniq'; check that column/key exists")

```

### Internal server error after upgrade to version 7.1

Please check whether the seahub process is running in your server. If it is running, there should be an error log in seahub.log for internal server error.

If seahub process is not running, you can modify conf/gunicorn.conf, change `daemon = True`  to `daemon = False`  , then run ./seahub.sh again. If there are missing Python dependencies, the error will be reported in the terminal.

The most common issue is that you use an old memcache configuration that depends on python-memcache. The new way is

```
'BACKEND': 'django_pylibmc.memcached.PyLibMCCache'

```

The old way is

```
'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',

```



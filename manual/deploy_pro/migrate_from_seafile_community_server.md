# Migrate from Seafile Community Server

## Restriction

It's quite likely you have deployed the Seafile Community Server and want to switch to the [Professional Server](http://seafile.com/en/product/private_server/), or vice versa. But there are some restrictions:

* You can only switch between Community Server and Professional Server of the same minor version.

That means, if you are using Community Server version 9.0, and want to switch to the Professional Server 10.0, you must first upgrade to Community Server version 10.0, and then follow the guides below to switch to the Professional Server 10.0. (The last tiny version number in 10.0.x is not important.)

## Preparation

### Install poppler-utils

The package poppler-utils is required for full text search of pdf files.

On Ubuntu/Debian:

```
sudo apt-get install poppler-utils

```


## Do the migration

We assume you already have deployed Seafile Community Server 10.0.0 under `/opt/seafile/seafile-server-10.0.0`. 

### Get the license

If the license you received is not named as seafile-license.txt, rename it to seafile-license.txt. Then put the license file under the top level diretory. In our example, it is `/opt/seafile/`.

### Download & uncompress Seafile Professional Server

You should uncompress the tarball to the top level directory of your installation, in our example it is `/opt/seafile`.

```
tar xf seafile-pro-server_10.0.0_x86-64_Ubuntu.tar.gz

```

Now you have:

```
seafile
├── seafile-license.txt
├── seafile-pro-server-10.0.0/
├── seafile-server-10.0.0/
├── ccnet/
├── seafile-data/
├── seahub-data/
└── conf/
└── logs/

```

---

You should notice the difference between the names of the Community Server and Professional Server. Take the 10.0.0 64bit version as an example:

* Seafile Community Server tarball is `seafile-server_10.0.0_x86-64_Ubuntu.tar.gz`; After uncompressing, the folder is `seafile-server-10.0.0`
* Seafile Professional Server tarball is `seafile-pro-server_10.0.0_x86-64_Ubuntu.tar.gz`; After uncompressing, the folder is `seafile-pro-server-10.0.0`
    

### Do the migration

* Stop Seafile Community Server if it's running


```
cd seafile/seafile-server-10.0.0
./seafile.sh stop
./seahub.sh stop

```

* Run the migration script 


```
cd seafile/seafile-pro-server-10.0.0/
./pro/pro.py setup --migrate

```

The migration script is going to do the following for you:

* ensure your have all the prerequisites met
* create necessary extra configurations
* update the avatar directory
* create extra database tables

Now you have:

```
seafile
├── seafile-license.txt
├── seafile-pro-server-10.0.0/
├── seafile-server-10.0.0/
├── ccnet/
├── seafile-data/
├── seahub-data/
├── seahub.db
├── seahub_settings.py
└── pro-data/

```

### Add Memory Cache Configuration

Using memory cache is mandatory in Pro Edition. You may use Memcached or Reids as cache server.

#### Use Memcached

Use the following commands to install memcached and corresponding libraies on your system:

```
# on Debian/Ubuntu 18.04+
apt-get install memcached libmemcached-dev -y
pip3 install --timeout=3600 pylibmc django-pylibmc

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

#### Use Redis

Redis is supported since version 11.0.

First, Install Redis with package installers in your OS.

Then refer to [Django's documentation about using Redis cache](https://docs.djangoproject.com/en/4.2/topics/cache/#redis) to add Redis configurations to `seahub_settings.py`.

### Start Seafile Professional Server

```
cd seafile/seafile-pro-server-10.0.0
./seafile.sh start
./seahub.sh start

```

## Switch Back to Community Server

Stop Seafile Professional Server if it's running


```
cd seafile/seafile-pro-server-10.0.0/
./seafile.sh stop
./seahub.sh stop

```

Run the minor-upgrade script to fix symbolic links


```
cd seafile/seafile-server-10.0.0/
./upgrade/minor-upgrade.sh

```

Start Seafile Community Server


```
cd haiwen/seafile-server-10.0.0/
./seafile.sh start
./seahub.sh start

```

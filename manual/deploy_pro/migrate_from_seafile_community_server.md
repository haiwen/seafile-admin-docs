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

On CentOS/Red Hat:

```
sudo yum install poppler-utils

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
cd haiwen/seafile-server-10.0.0
./seafile.sh stop
./seahub.sh stop

```

* Run the migration script 


```
cd haiwen/seafile-pro-server-10.0.0/
./pro/pro.py setup --migrate

```

The migration script is going to do the following for you:

* ensure your have all the prerequisites met
* create necessary extra configurations
* update the avatar directory
* create extra database tables

Now you have:

```
haiwen
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

### Start Seafile Professional Server

```
cd haiwen/seafile-pro-server-10.0.0
./seafile.sh start
./seahub.sh start

```

## Switch Back to Community Server

* Stop Seafile Professional Server if it's running


```
cd haiwen/seafile-pro-server-10.0.0/
./seafile.sh stop
./seahub.sh stop

```

* Update the avatar directory link just like in [Maintenance Upgrade](../upgrade/upgrade.md#maintenance-version-upgrade-eg-from-622-to-623)


```
cd haiwen/seafile-server-10.0.0/
./upgrade/minor-upgrade.sh

```

* Start Seafile Community Server


```
cd haiwen/seafile-server-10.0.0/
./seafile.sh start
./seahub.sh start

```

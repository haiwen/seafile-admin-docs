# Migrate from File System Backend to Ceph

Ceph is a scalable distributed storage system. Seafile can use Ceph's RADOS object storage layer for storage backend.

By default, a typical Seafile server deployment uses file system as storage backend (e.g. Ext4). Later you may want to switch to more scalable storage solution like Ceph. This documentation shows you how to migrate your existing date from file system to Ceph and connect to Ceph. If you're deploying a fresh install with Ceph backend, please refer to [setup with Ceph](setup_with_ceph.md).

## Copy ceph conf file and client keyring

Seafile acts as a client to Ceph/RADOS, so it needs to access ceph cluster's conf file and keyring. You have to copy these files from a ceph admin node's /etc/ceph directory to the seafile machine.

```
seafile-machine# sudo scp user@ceph-admin-node:/etc/ceph/ /etc
```

## Install and enable memcached

For best performance, Seafile requires install memcached and enable memcache for objects. 

We recommend to allocate 128MB memory for memcached. Edit /etc/memcached.conf

```
# Start with a cap of 64 megs of memory. It's reasonable, and the daemon default
# Note that the daemon will grow to this size, but does not start out holding this much
# memory
# -m 64
-m 128
```

## Install Python Ceph Library

File search and WebDAV functions rely on Python Ceph library installed in the system.

On Debian/Ubuntu:

```
sudo apt-get install python-ceph
```

On RedHat/CentOS:

```
sudo yum install python-rados
```

## Create Pools for Seafile in Ceph

It's recommended to create separate pools for commit, fs, and block objects.

```
ceph-admin-node# rados mkpool seafile-blocks
ceph-admin-node# rados mkpool seafile-commits
ceph-admin-node# rados mkpool seafile-fs
```

## Migrate Existing Data to Ceph

The migration process involves 3 steps:

1. Create a Seafile config folder for Ceph
2. Run the migration script
3. Update seafile.conf

### Create a Seafile Config Folder for Ceph

In the Seafile installation folder (e.g. `haiwen`), 

```
cd haiwen
mkdir ceph-conf
cp conf/seafile.conf ceph-conf
```

Edit `ceph-conf/seafile.conf`, add the following lines:

```
[block_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
pool = seafile-blocks
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100

[commit_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
pool = seafile-commits
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100

[fs_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
pool = seafile-fs
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100
```

Now there are two seafile.conf files, one under `conf` folder and the other under `ceph-conf` folder.

### Run Migration Script

From Pro edition 6.0.0 on, the migration scripts are included in the package. For older versions, you have to download the two scripts into `seafile-server-latest` folder:

- https://github.com/haiwen/seafile-server/blob/master/scripts/seafobj_migrate.py
- https://github.com/haiwen/seafile-server/blob/master/scripts/migrate-to-ceph.sh

You can run the migration script when your Seafile server is still running.

```
cd haiwen/seafile-server-latest
./migrate-to-ceph.sh ../ceph-conf
```

If there is any error in the migration process, the script will stop. After you check and fix the errors, you can run the script again. The script is designed to be idempotent to multiple runs. It only copies non-existing objects to Ceph. The script won't delete any objects from the file system backend.

***After the initial migration completes successfully, you need to shutdown the Seafile server and run the script again to migrate the data that's added when you run the initial migration.*** Since the script won't migrate objects that have been migrated, this phase should finish in a short time.

### Update seafile.conf

After migration is done. You need to update `conf/seafile.conf` to make Seafile server use Ceph as backend in the future.

```
cp -R conf conf-backup
cp ceph-conf/seafile.conf conf/seafile.conf
```

After restart, Seafile server will use Ceph as backend.

### Using memcached cluster

In a cluster environment, you may want to use a memcached cluster. In the above configuration, you have to specify all the memcached server node addresses in seafile.conf

```
memcached_options = --SERVER=192.168.1.134 --SERVER=192.168.1.135 --SERVER=192.168.1.136 --POOL-MIN=10 --POOL-MAX=100 --RETRY-TIMEOUT=3600
```

Notice that there is a `--RETRY-TIMEOUT=3600` option in the above config. This option is important for dealing with memcached server failures. After a memcached server in the cluster fails, Seafile server will stop trying to use it for "RETRY-TIMEOUT" (in seconds). You should set this timeout to relatively long time, to prevent Seafile from retrying the failed server frequently, which may lead to frequent request errors for the clients.

## Notes for Ubuntu 16.04

Since version 5.1.0 version, we upgraded the bundled Ceph rados library to 0.94.6. On Ubuntu 16.04, this causes some incompatibility. To work around this issue, you have to install librados 0.94.6 in the Ubuntu system (from Ceph's official repositories) and let Seafile use the library from system. To do this, you have to remove a few bundled libraries:

```
cd seafile-server-latest/seafile/lib
rm librados.so.2 libstdc++.so.6 libnspr4.so
```

## Use arbitary Ceph user

The above configuration will use the default (client.admin) user to connect to Ceph.
You may want to use some other Ceph user to connect. This is supported in Seafile.
To specify the Ceph user, you have to add a `ceph_client_id` option to seafile.conf, as the following:

```
[block_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
# Sepcify Ceph user for Seafile here
ceph_client_id = seafile
pool = seafile-blocks
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100

[commit_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
# Sepcify Ceph user for Seafile here
ceph_client_id = seafile
pool = seafile-commits
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100

[fs_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
# Sepcify Ceph user for Seafile here
ceph_client_id = seafile
pool = seafile-fs
memcached_options = --SERVER=localhost --POOL-MIN=10 --POOL-MAX=100
```

You can create a ceph user for seafile on your ceph cluster like this:

```
ceph auth add client.seafile \
  mds 'allow' \
  mon 'allow r' \
  osd 'allow rwx pool=seafile-blocks, allow rwx pool=seafile-commits, allow rwx pool=seafile-fs'
```

You also have to add this user's keyring path to /etc/ceph/ceph.conf:

```
[client.seafile]
keyring = <path to user's keyring file>
```

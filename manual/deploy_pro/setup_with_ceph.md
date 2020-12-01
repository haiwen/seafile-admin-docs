# Setup With Ceph

**Note**: Since Seafile Server 5.0.0, all config files are moved to the central **conf** folder. [Read More](../deploy/new_directory_layout_5_0_0.md).

Ceph is a scalable distributed storage system. It's recommended to use Ceph's S3 Gateway (RGW) to integarte with Seafile. Seafile can also use Ceph's RADOS object storage layer for storage backend. But using RADOS requires to link with librados library, which may introduce library incompatibility issues during deployment. Furthermore the S3 Gateway provides easier to manage HTTP based interface. If you want to integrate with S3 gateway, please refer to "Use S3-compatible Object Storage" section in [this documentation](./setup_with_amazon_s3.md). The documentation below is for integrating with RADOS.

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

On Debian/Ubuntu (Seafile 7.1+):

```
sudo apt-get install python3-rados

```

On Debian/Ubuntu (Seafile 7.0 or below):

```
sudo apt-get install python-ceph

```

On RedHat/CentOS (Seafile 7.0 or below):

```
sudo yum install python-rados

```

## Edit seafile configuration

Edit `seafile.conf`, add the following lines:

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

It's recommended to create separate pools for commit, fs, and block objects.

```
ceph-admin-node# rados mkpool seafile-blocks
ceph-admin-node# rados mkpool seafile-commits
ceph-admin-node# rados mkpool seafile-fs

```

### Using memcached cluster

In a cluster environment, you may want to use a memcached cluster. In the above configuration, you have to specify all the memcached server node addresses in seafile.conf

```
memcached_options = --SERVER=192.168.1.134 --SERVER=192.168.1.135 --SERVER=192.168.1.136 --POOL-MIN=10 --POOL-MAX=100 --RETRY-TIMEOUT=3600

```

Notice that there is a `--RETRY-TIMEOUT=3600` option in the above config. This option is important for dealing with memcached server failures. After a memcached server in the cluster fails, Seafile server will stop trying to use it for "RETRY-TIMEOUT" (in seconds). You should set this timeout to relatively long time, to prevent Seafile from retrying the failed server frequently, which may lead to frequent request errors for the clients.

## Notes for Ubuntu 16.04 and 18.04

Since version 5.1.0 version, we upgraded the bundled Ceph rados library to 0.94.6. On Ubuntu 16.04, this causes some incompatibility. To work around this issue, you have to install librados 0.94.6 in the Ubuntu system (from Ceph's official repositories) and let Seafile use the library from system.

As of version 7.1.0, the librados we packaged into the bundle is older than the one provided in system repositories. This leads to incompatibility with the python-rados package on **Ubuntu 18.04**. So it's also needed to remove the bundle librados libraries.

To do this, you have to remove a few bundled libraries:

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



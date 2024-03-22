# Setup With Ceph

Ceph is a scalable distributed storage system. It's recommended to use Ceph's S3 Gateway (RGW) to integarte with Seafile. Seafile can also use Ceph's RADOS object storage layer for storage backend. But using RADOS requires to link with librados library, which may introduce library incompatibility issues during deployment. Furthermore the S3 Gateway provides easier to manage HTTP based interface. If you want to integrate with S3 gateway, please refer to "Use S3-compatible Object Storage" section in [this documentation](./setup_with_amazon_s3.md). The documentation below is for integrating with RADOS.

## Copy ceph conf file and client keyring

Seafile acts as a client to Ceph/RADOS, so it needs to access ceph cluster's conf file and keyring. You have to copy these files from a ceph admin node's /etc/ceph directory to the seafile machine.

```
seafile-machine# sudo scp user@ceph-admin-node:/etc/ceph/ /etc

```

## Install and enable memcached

For best performance, Seafile requires install memcached or redis and enable cache for objects. 

We recommend to allocate at least 128MB memory for object cache.

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

[commit_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
pool = seafile-commits

[fs_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
pool = seafile-fs
```

You also need to add [memory cache configurations](/manual/config/seafile-conf/#cache-pro-edition-only).

It's required to create separate pools for commit, fs, and block objects.

```
ceph-admin-node# rados mkpool seafile-blocks
ceph-admin-node# rados mkpool seafile-commits
ceph-admin-node# rados mkpool seafile-fs

```

## Troubleshooting librados incompatibility issues

Since 8.0 version, Seafile bundles librados from Ceph 16. On some systems you may find Seafile fail to connect to your Ceph cluster. In such case, you can usually solve it by removing the bundled librados libraries and use the one installed in the OS.

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

[commit_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
# Sepcify Ceph user for Seafile here
ceph_client_id = seafile
pool = seafile-commits

[fs_object_backend]
name = ceph
ceph_config = /etc/ceph/ceph.conf
# Sepcify Ceph user for Seafile here
ceph_client_id = seafile
pool = seafile-fs

# Memcached or Reids configs
......

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



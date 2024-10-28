# Setup With OpenStack Swift

This backend uses the native Swift API. Previously users can only use the S3-compatibility layer of Swift. That way is obsolete now. <!--The old documentation is still available [here](setup_with_openstackswift.md).-->

Since version 6.3, OpenStack Swift v3.0 API is supported.

## Prepare

To setup Seafile Professional Server with Swift:

* Setup the basic Seafile Professional Server following the guide on [Download and setup Seafile Professional Server](../setup_binary/installation_by_binary.md)
* Install and configure memcached or Redis. For best performance, Seafile requires enable memory cache for objects. We recommend to at least allocate 128MB memory for memcached.

## Modify Seafile.conf

Edit `seafile.conf`, add the following lines:

```
[block_backend]
name = swift
tenant = yourTenant
user_name = user
password = secret
container = seafile-blocks
auth_host = 192.168.56.31:5000
auth_ver = v3.0
region = yourRegion

[commit_object_backend]
name = swift
tenant = yourTenant
user_name = user
password = secret
container = seafile-commits
auth_host = 192.168.56.31:5000
auth_ver = v3.0
region = yourRegion

[fs_object_backend]
name = swift
tenant = yourTenant
user_name = user
password = secret
container = seafile-fs
auth_host = 192.168.56.31:5000
auth_ver = v3.0
region = yourRegion

```

You also need to add [memory cache configurations](../config/seafile-conf.md#cache-pro-edition-only).

The above config is just an example. You should replace the options according to your own environment.

Seafile supports Swift with Keystone as authentication mechanism. The `auth_host` option is the address and port of Keystone service.The `region` option is used to select publicURL,if you don't configure it, use the first publicURL in returning authenticated information.

Seafile also supports Tempauth and Swauth since professional edition 6.2.1. The `auth_ver` option should be set to `v1.0`, `tenant` and `region` are no longer needed.

It's required to create separate containers for commit, fs, and block objects.

### Use HTTPS connections to Swift

Since Pro 5.0.4, you can use HTTPS connections to Swift. Add the following options to seafile.conf:

```
[commit_object_backend]
name = swift
......
use_https = true

[fs_object_backend]
name = swift
......
use_https = true

[block_backend]
name = swift
......
use_https = true

```

!!! note "Note"

    Because the server package is built on CentOS 6, if you're using Debian/Ubuntu, you have to copy the system CA bundle to CentOS's CA bundle path. Otherwise Seafile can't find the CA bundle so that the SSL connection will fail.

    ```
    sudo mkdir -p /etc/pki/tls/certs
    sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt
    sudo ln -s /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/cert.pem

    ```

## Run and Test

Now you can start Seafile by `./seafile.sh start` and `./seahub.sh start` and visit the website.

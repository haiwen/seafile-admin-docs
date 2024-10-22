# Setup With Alibaba OSS

## Prepare

To setup Seafile Professional Server with Alibaba OSS:

* Setup the basic Seafile Professional Server following the guide on [Download and setup Seafile Professional Server](../../../setup_binary/pro/installation.md)
* Install the python `oss2` library: `sudo pip install oss2==2.3.0`.For more installation help, please refer to [this document](https://www.alibabacloud.com/help/en/object-storage-service/latest/python-preface).
* Install and configure memcached or Redis. For best performance, Seafile requires enable memory cache for objects. We recommend to allocate at least 128MB memory for Memcached or Redis.

## Modify Seafile.conf

Edit `seafile.conf`, add the following lines:
```
[commit_object_backend]
name = oss
bucket = <your-seafile-commits-bucket>
key_id = <your-key-id>
key = <your-key>
region = beijing

[fs_object_backend]
name = oss
bucket = <your-seafile-fs-bucket>
key_id = <your-key-id>
key = <your-key>
region = beijing

[block_backend]
name = oss
bucket = <your-seafile-blocks-bucket>
key_id = <your-key-id>
key = <your-key>
region = beijing
```

You also need to add [memory cache configurations](../../../config/seafile_config/seafile-conf.md#cache-pro-edition-only).

It's required to create separate buckets for commit, fs, and block objects. For performance and to save network traffic costs, you should create buckets within the region where the seafile server is running.

The key_id and key are required to authenticate you to OSS. You can find the key_id and key in the "security credentials" section on your OSS management page.

The region is the region where the bucket you created is located, such as beijing, hangzhou, shenzhen, etc.

### Use OSS in VPC

Before version 6.0.9, Seafile only supports using OSS services in the classic network environment. The OSS service address in the VPC (Virtual Private Network) environment is different from the classic network, so you need to specify the OSS access address in the configuration environment. After version 6.0.9, it supports the configuration of OSS access addresses, thus adding the support for VPC OSS services.

Use the following configuration:

```
[commit_object_backend]
name = oss
bucket = <your-seafile-commits-bucket>
key_id = <your-key-id>
key = <your-key>
endpoint = vpc100-oss-cn-beijing.aliyuncs.com

[fs_object_backend]
name = oss
bucket = <your-seafile-fs-bucket>
key_id = <your-key-id>
key = <your-key>
endpoint = vpc100-oss-cn-beijing.aliyuncs.com

[block_backend]
name = oss
bucket = <your-seafile-blocks-bucket>
key_id = <your-key-id>
key = <your-key>
endpoint = vpc100-oss-cn-beijing.aliyuncs.com

```

Compared with the configuration under the classic network, the above configuration uses the `endpoint` option to replace the `region` option. The corresponding `endpoint` address can be found at <https://www.alibabacloud.com/help/en/object-storage-service/latest/regions-and-endpoints>.

`endpoint` is a general option, you can also set it to the OSS access address under the classic network, and it will work as well.

You also need to add [memory cache configurations](../../../config/seafile_config/seafile-conf.md#cache-pro-edition-only).

### Use HTTPS connections to OSS

To use HTTPS connections to OSS, add the following options to seafile.conf:

```
[commit_object_backend]
name = oss
......
use_https = true

[fs_object_backend]
name = oss
......
use_https = true

[block_backend]
name = oss
......
use_https = true
```

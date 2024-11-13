---
status: new
---


# Setup With S3 Storage

!!! tip "New feature from 12.0 pro edition"
    If your will deploy Seafile server in Docker, you can modify the following fields in `.env` **before starting the services**:

    ```sh
    INIT_S3_STORAGE_BACKEND_CONFIG=true
    INIT_S3_COMMIT_BUCKET=<your-commit-objects>
    INIT_S3_FS_BUCKET=<your-fs-objects>
    INIT_S3_BLOCK_BUCKET=<your-block-objects>
    INIT_S3_KEY_ID=<your-key-id>
    INIT_S3_SECRET_KEY=<your-secret-key>
    ```

    The above modifications will generate the same configuration file as [AWS S3](#aws-s3) and will take effect when the service is started for the first time.

## Prepare

To setup Seafile Professional Server with Amazon S3:

- Setup the basic Seafile Professional Server following the guide on [setup Seafile Professional Server](./setup_pro_by_docker.md)
- Install the python `boto` library. It's needed to access S3 service.
=== "Seafile 10.0 or earlier"

    ```
    sudo pip install boto
    ```
=== "Seafile 11.0"
    ```
    sudo pip install boto3
    ```
- Install and configure memcached or Redis. For best performance, Seafile requires enable memory cache for objects. We recommend to at least allocate 128MB memory for memcached or Redis.

The configuration options differ for different S3 storage. We'll describe the configurations in separate sections.

!!! note "You also need to add [memory cache configurations](../config/seafile-conf.md#cache-pro-edition-only)"

## AWS S3
AWS S3 is the original S3 storage provider.

Edit `seafile.conf`, add the following lines:

```
[commit_object_backend]
name = s3
bucket = my-commit-objects
key_id = your-key-id
key = your-secret-key
use_v4_signature = true
aws_region = eu-central-1
use_https = true

[fs_object_backend]
name = s3
bucket = my-fs-objects
key_id = your-key-id
key = your-secret-key
use_v4_signature = true
aws_region = eu-central-1
use_https = true

[block_backend]
name = s3
bucket = my-block-objects
key_id = your-key-id
key = your-secret-key
use_v4_signature = true
aws_region = eu-central-1
use_https = true
```

We'll explain the configurations below:

| Variable | Description |  
| --- | --- |  
| `bucket` | It's required to create separate buckets for commit, fs, and block objects. When creating your buckets on S3, please first read [S3 bucket naming rules][1]. Note especially not to use **UPPERCASE** letters in bucket names (don't use camel style names, such as MyCommitObjects). |  
| `key_id` | The `key_id` is required to authenticate you to S3. You can find the `key_id` in the "security credentials" section on your AWS account page. |  
| `key` | The `key` is required to authenticate you to S3. You can find the `key` in the "security credentials" section on your AWS account page. |  
| `use_v4_signature` | There are two versions of authentication protocols that can be used with S3 storage: Version 2 (older, may still be supported by some regions) and Version 4 (current, used by most regions). If you don't set this option, Seafile will use the v2 protocol. It's suggested to use the v4 protocol. |  
| `aws_region` | If you use the v4 protocol, set this option to the region you chose when you create the buckets. If it's not set and you're using the v4 protocol, Seafile will use `us-east-1` as the default. This option will be ignored if you use the v2 protocol. |
| `use_https` | Use https to connect to S3. It's recommended to use https. |

[1]: <https://docs.aws.amazon.com/AmazonS3/latest/userguide/BucketRestrictions.html#bucketnamingrules> (Replace this placeholder with the actual link to the S3 bucket naming rules documentation if necessary)


### Use server-side encryption with customer-provided keys (SSE-C)

Since Pro 11.0, you can use SSE-C to S3. Add the following options to seafile.conf:

```
[commit_object_backend]
name = s3
......
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P

[fs_object_backend]
name = s3
......
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P

[block_backend]
name = s3
......
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P
```

`sse_c_key` is a string of 32 characters.

You can generate `sse_c_key` with the following command：

```
openssl rand -base64 24
```

It's required to use V4 authentication protocol and https if you enable SSE-C.

!!! note "If you have existing data in your S3 storage bucket, turning on the above configuration will make your data inaccessible. That's because Seafile server doesn't support encrypted and non-encrypted objects mixed in the same bucket. You have to create a new bucket, and migrate your data to it by following [storage backend migration documentation](./migrate_backends_data.md#migrating-to-sse-c-encrypted-s3-storage)."

## Other Public Hosted S3 Storage

There are other S3-compatible cloud storage providers in the market, such as Blackblaze and Wasabi. Configuration for those providers are just a bit different from AWS. We don't assure the following configuration works for all providers. If you have problems please contact our support

```
[commit_object_backend]
name = s3
bucket = my-commit-objects
host = <access endpoint for storage provider>
key_id = your-key-id
key = your-secret-key
# v2 authentication protocol will be used if not set
use_v4_signature = true
# required for v4 protocol. ignored for v2 protocol.
aws_region = <region name for storage provider>
use_https = true

[fs_object_backend]
name = s3
bucket = my-fs-objects
host = <access endpoint for storage provider>
key_id = your-key-id
key = your-secret-key
use_v4_signature = true
aws_region = <region name for storage provider>
use_https = true

[block_backend]
name = s3
bucket = my-block-objects
host = <access endpoint for storage provider>
key_id = your-key-id
key = your-secret-key
use_v4_signature = true
aws_region = <region name for storage provider>
use_https = true
```

| variable       | description                                                                                                                                                                                                                       |  
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| `host`         | The endpoint by which you access the storage service. Usually it starts with the region name. It's required to provide the host address, otherwise Seafile will use AWS's address.                                                   |  
| `bucket`       | It's required to create separate buckets for commit, fs, and block objects.                                                                                                                                                       |  
| `key_id`       | The key_id is required to authenticate you to S3 storage.                                                                                                                                                                         |  
| `key`          | The key is required to authenticate you to S3 storage. (Note: `key_id` and `key` are typically used together for authentication.)                                                                                                 |  
| `use_v4_signature` | There are two versions of authentication protocols that can be used with S3 storage. Version 2 is the older one, which may still be supported by some cloud providers; version 4 is the current one used by Amazon S3 and is supported by most providers. If you don't set this option, Seafile will use v2 protocol. It's suggested to use v4 protocol. |  
| `aws_region`   | If you use v4 protocol, set this option to the region you chose when you create the buckets. If it's not set and you're using v4 protocol, Seafile will use `us-east-1` as the default. This option will be ignored if you use v2 protocol. |
| `use_https` | Use https to connect to S3. It's recommended to use https. |


## Self-hosted S3 Storage

Many self-hosted object storage systems are now compatible with the S3 API, such as OpenStack Swift, Ceph's RADOS Gateway and Minio. You can use these S3-compatible storage systems as backend for Seafile. Here is an example config:

```
[commit_object_backend]
name = s3
bucket = my-commit-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true
use_v4_signature = true
use_https = true

[fs_object_backend]
name = s3
bucket = my-fs-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true
use_v4_signature = true
use_https = true

[block_backend]
name = s3
bucket = my-block-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true
use_v4_signature = true
use_https = true
```

| variable           | description                                                                                                                                                                                             |  
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| `host`             | It is the address and port of the S3-compatible service. You cannot prepend "http" or "https" to the `host` option. By default it'll use http connections. If you want to use https connection, please set `use_https = true` option. |  
| `bucket`           | It's required to create separate buckets for commit, fs, and block objects.                                                                                                                            |  
| `key_id`           | The key_id is required to authenticate you to S3 storage.                                                                                                                                              |  
| `key`              | The key is required to authenticate you to S3 storage. (Note: `key_id` and `key` are typically used together for authentication.)                                                                       |  
| `path_style_request` | This option asks Seafile to use URLs like `https://192.168.1.123:8080/bucketname/object` to access objects. In Amazon S3, the default URL format is in virtual host style, such as `https://bucketname.s3.amazonaws.com/object`. But this style relies on advanced DNS server setup. So most self-hosted storage systems only implement the path style format. So we recommend to set this option to true. |
| `use_v4_signature`  | There are two versions of authentication protocols that can be used with S3 storage. Version 2 is the protocol supported by most self-hosted storage; version 4 is the current protocol used by AWS S3, but may not be supported by some self-hosted storage. If you don't set this option, Seafile will use the v2 protocol by default. We recommend to use V4 if possible. Please note that if you want to migrate from S3 storage to other storage, the migration script doesn't work with V2 authentication protocol due to limitation of third-party library. |
| `use_https` | Use https to connect to S3. It's recommended to use https. If your self-hosted storage doesn't support https, set this option to false. |


## Run and Test ##

Now you can start Seafile and test

[1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html "the bucket naming rules"
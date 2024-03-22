# Setup With Amazon S3

## Prepare

To setup Seafile Professional Server with Amazon S3:

- Setup the basic Seafile Professional Server following the guide on [Download and setup Seafile Professional Server](download_and_setup_seafile_professional_server.md)
- Install the python `boto` library. It's needed to access S3 service.
```
# Version 10.0 or earlier
sudo easy_install boto

# Since 11.0 version
sudo easy_install boto3
```
- Install and configure memcached or Redis. For best performance, Seafile requires enable memory cache for objects. We recommend to at least allocate 128MB memory for memcached or Redis.

## Modify Seafile.conf

Edit `seafile.conf`, add the following lines:

```
[commit_object_backend]
name = s3
# bucket name can only use lowercase characters, numbers, periods and dashes. Period cannot be used in Frankfurt region.
bucket = my-commit-objects
key_id = your-key-id
key = your-secret-key

[fs_object_backend]
name = s3
# bucket name can only use lowercase characters, numbers, periods and dashes. Period cannot be used in Frankfurt region.
bucket = my-fs-objects
key_id = your-key-id
key = your-secret-key

[block_backend]
name = s3
# bucket name can only use lowercase characters, numbers, periods and dashes. Period cannot be used in Frankfurt region.
bucket = my-block-objects
key_id = your-key-id
key = your-secret-key
```

You also need to add [memory cache configurations](/config/seafile-conf/#cache-pro-edition-only).

It's required to create separate buckets for commit, fs, and block objects.
The key_id and key are required to authenticate you to S3. You can find the key_id and key in the "security credentials" section on your AWS account page.

When creating your buckets on S3, please first read [S3 bucket naming rules][1]. Note especially not to use **UPPERCASE** letters in bucket names (don't use camel style names, such as MyCommitOjbects).

### Use S3 in newer regions

After Januaray 2014, new regions of AWS will only support authentication signature version 4 for S3. At this time, new region includes Frankfurt and China.

To use S3 backend in these regions, add following options to commit_object_backend, fs_object_backend and block_backend section in seafile.conf

```
use_v4_signature = true
# eu-central-1 for Frankfurt region
aws_region = eu-central-1
```

For file search and webdav to work with the v4 signature mechanism, you need to add following lines to ~/.boto

```
[s3]
use-sigv4 = True
```

### Use HTTPS connections to S3

To use HTTPS connections to S3, add the following options to seafile.conf:

```
[commit_object_backend]
name = s3
......
use_https = true

[fs_object_backend]
name = s3
......
use_https = true

[block_backend]
name = s3
......
use_https = true
```

Because the server package is built on CentOS 6, if you're using Debian/Ubuntu, you have to copy the system CA bundle to CentOS's CA bundle path. Otherwise Seafile can't find the CA bundle so that the SSL connection will fail.

```
sudo mkdir -p /etc/pki/tls/certs
sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt
sudo ln -s /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/cert.pem
```

Another important note is that you **must not use '.' in your bucket names**. Otherwise the wildcard certificate for AWS S3 cannot be resolved. This is a limitation on AWS.

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

`ssk_c_key` is a 32-byte random string.

## Use S3-compatible Object Storage

Many object storage systems are now compatible with the S3 API, such as OpenStack Swift and Ceph's RADOS Gateway. You can use these S3-compatible storage systems as backend for Seafile. Here is an example config:

```
[commit_object_backend]
name = s3
bucket = my-commit-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true

[fs_object_backend]
name = s3
bucket = my-fs-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true

[block_backend]
name = s3
bucket = my-block-objects
key_id = your-key-id
key = your-secret-key
host = 192.168.1.123:8080
path_style_request = true
```

`host` is the address and port of the S3-compatible service. You cannot prepend "http" or "https" to the `host` option. By default it'll use http connections. If you want to use https connection, please set `use_https = true` option.

`path_style_request` asks Seafile to use URLs like `https://192.168.1.123:8080/bucketname/object` to access objects. In Amazon S3, the default URL format is in virtual host style, such as `https://bucketname.s3.amazonaws.com/object`. But this style relies on advanced DNS server setup. So most S3-compatible storage systems only implement the path style format.

You also need to add [memory cache configurations](/config/seafile-conf/#cache-pro-edition-only).

## Run and Test ##

Now you can start Seafile by `./seafile.sh start` and `./seahub.sh start` and visit the website.

  [1]: http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html "the bucket naming rules"

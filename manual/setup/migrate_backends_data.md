# Migrate data between different backends

Seafile supports data migration between filesystem, s3, ceph, swift and Alibaba oss.

Data migration takes 3 steps:

1. Create a new temporary seafile.conf
2. Run migrate.sh to initially migrate objects
3. Run final migration
4. Replace the original seafile.conf

## Create a new temporary seafile.conf

We need to add new backend configurations to this file (including `[block_backend]`, `[commit_object_backend]`, `[fs_object_backend]` options) and save it under a readable path.
Let's assume that we are migrating data to S3 and create temporary seafile.conf under `/opt`

```
cat > seafile.conf << EOF
[commit_object_backend]
name = s3
bucket = seacomm
key_id = ******
key = ******

[fs_object_backend]
name = s3
bucket = seafs
key_id = ******
key = ******

[block_backend]
name = s3
bucket = seablk
key_id = ******
key = ******
EOF

mv seafile.conf /opt

```

If you want to migrate to a local file system, the seafile.conf temporary configuration example is as follows:

```
cat > seafile.conf << EOF
[commit_object_backend]
name = fs
# the dir configuration is the new seafile-data path
dir = /var/data_backup

[fs_object_backend]
name = fs
# the dir configuration is the new seafile-data path
dir = /var/data_backup

[block_backend]
name = fs
# the dir configuration is the new seafile-data path
dir = /var/data_backup

EOF

mv seafile.conf /opt

```

Repalce the configurations with your own choice.

### Migrating to SSE-C Encrypted S3 Storage

If you are migrating to S3 storage, and want your data to be encrypted at rest, you can configure SSE-C encryption options in the temporary seafile.conf. Note that you have to use Seafile Pro 11 or newer and make sure your S3 storage supports SSE-C.

```
cat > seafile.conf << EOF
[commit_object_backend]
name = s3
bucket = seacomm
key_id = ******
key = ******
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P

[fs_object_backend]
name = s3
bucket = seafs
key_id = ******
key = ******
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P

[block_backend]
name = s3
bucket = seablk
key_id = ******
key = ******
use_v4_signature = true
use_https = true
sse_c_key = XiqMSf3x5ja4LRibBbV0sVntVpdHXl3P
EOF

mv seafile.conf /opt

```

`sse_c_key` is a string of 32 characters.

You can generate `sse_c_key` with the following command：

```
openssl rand -base64 24
```

## Migrating large number of objects

If you have millions of objects in the storage (especially fs objects), it may take quite long time to migrate all objects. More than half of the time is spent on checking whether an object exists in the destination storage. **Since Pro edition 7.0.8**, a feature is added to speed-up the checking.

Before running the migration script, please set this env variable:

```
export OBJECT_LIST_FILE_PATH=/path/to/object/list/file

```

3 files will be created: `/path/to/object/list/file.commit`,`/path/to/object/list/file.fs`, `/path/to/object/list/file.blocks`.

When you run the script for the first time, the object list file will be filled with existing objects in the destination. Then, when you run the script for the second time, it will load the existing object list from the file, instead of querying the destination. And newly migrated objects will also be added to the file. During migration, the migration process checks whether an object exists by checking the pre-loaded object list, instead of asking the destination, which will greatly speed-up the migration process.

It's suggested that you don't interrupt the script during the "fetch object list" stage when you run it for the first time. Otherwise the object list in the file will be incomplete.

Another trick to speed-up the migration is to increase the number of worker threads and size of task queue in the migration script. You can modify the `nworker` and `maxsize` variables in the following code:

```
class ThreadPool(object):
    
def __init__(self, do_work, nworker=20):
        self.do_work = do_work
        self.nworker = nworker
        self.task_queue = Queue.Queue(maxsize = 2000)

```

The number of workers can be set to relatively large values, since they're mostly waiting for I/O operations to finished.

## Decrypting encrypted storage backend

If you have an encrypted storage backend (a deprecated feature no long supported now), you can use this script to migrate and decrypt the data from that backend to a new one. You can add the `--decrypt` option, which will decrypt the data while reading it, and then write the unencrypted data to the new backend. Note that you need add this option in all stages of the migration.

```
cd ~/haiwen/seafile-server-latest
./migrate.sh /opt --decrypt

```

## Run migrate.sh to initially migrate objects

This step will migrate **most of** objects from the source storage to the destination storage. You don't need to stop Seafile service at this stage as it may take quite long time to finish. Since the service is not stopped, some new objects may be added to the source storage during migration. Those objects will be handled in the next step.

We assume you have installed seafile pro server under `~/haiwen`, enter `~/haiwen/seafile-server-latest` and run migrate.sh with parent path of temporary seafile.conf as parameter, here is `/opt`.

```
cd ~/haiwen/seafile-server-latest
./migrate.sh /opt

```

!!! tip
    This script is completely reentrant. So you can stop and restart it, or run it many times. It will check whether an object exists in the destination before sending it.

## Run final migration

New objects added during the last migration step will be migrated in this step. To prevent new objects being added, you have to stop Seafile service during the final migration operation. This usually take short time. If you have large number of objects, please following the optimization instruction in previous section.

You just have to stop Seafile and Seahub service, then run the migration script again.

```
cd ~/haiwen/seafile-server-latest
./migrate.sh /opt

```

## Replace the original seafile.conf

After running the script, we need replace the original seafile.conf with new one:

```
mv /opt/seafile.conf ~/haiwen/conf

```

now we only have configurations about backend, more config options, e.g. memcache and quota, can then be copied from the original seafile.conf file.

After replacing seafile.conf, you can restart seafile server and access the data on the new backend.

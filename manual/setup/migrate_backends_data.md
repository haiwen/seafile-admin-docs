# Migrate data between different backends

Seafile supports data migration between filesystem, s3, ceph, swift and Alibaba oss by a built-in script. Before migration, you have to ensure that **both S3 hosts can be accessed normally**.

!!! warning "Migration to or from S3"

    Since version 11, when you migrate from S3 to other storage servers or from other storage servers to S3, you have to use V4 authentication protocol. This is because version 11 upgrades to Boto3 library, which fails to list objects from S3 when it's configured to use V2 authentication protocol.

## Copy `seafile.conf` and use new S3 configurations

During the migration process, Seafile needs to know where the data will be migrated to. The easiest way is to copy the original `seafile.conf` to a new path, and then use the new S3 configurations in this file.

=== "Deploy with Docker"

    !!! warning
        For deployment with Docker, the new `seafile.conf` has to **be put in the persistent directory** (e.g., `/opt/seafile-data/seafile.conf`) used by Seafile service. Otherwise the script cannot locate the new configurations file.

    ```sh
    cp /opt/seafile-data/seafile/conf/seafile.conf /opt/seafile-data/seafile.conf

    nano /opt/seafile-data/seafile.conf
    ```

=== "Deploy from binary package"

    ```sh
    cp /opt/seafile/conf/seafile.conf /opt/seafile.conf

    nano /opt/seafile.conf
    ```

Then you can follow [here](./setup_with_s3.md) to use the new S3 configurations in the new `seafile.conf`. By the way, if you want to migrate to a local file system, the new `seafile.conf` configurations for S3 example is as follows:

```conf
# ... other configurations

[commit_object_backend]
name = fs
dir = /var/data_backup

[fs_object_backend]
name = fs
dir = /var/data_backup

[block_backend]
name = fs
dir = /var/data_backup
```

## Stop Seafile Server

Since the data migration process will not affect the operation of the Seafile service, if the original S3 data is operated during this process, the data may not be synchronized with the migrated data. Therefore, we recommend that you stop the Seafile service before executing the migration procedure.

=== "Deploy with Docker"

    ```sh
    docker exec -it seafile bash
    cd /opt/seafile/seafile-server-latest
    ./seahub.sh stop
    ./seafile.sh stop
    ```

=== "Deploy from binary package"

    ```sh
    cd /opt/seafile/seafile-server-latest
    ./seahub.sh stop
    ./seafile.sh stop
    ```

## Run migrate.sh to initially migrate objects

This step will migrate **most of** objects from the source storage to the destination storage. You don't need to stop Seafile service at this stage as it may take quite long time to finish. Since the service is not stopped, some new objects may be added to the source storage during migration. Those objects will be handled in the next step:

!!! tip "Speed-up migrating large number of objects"
    If you have millions of objects in the storage (especially the ***fs*** objects), it may take quite long time to migrate all objects and more than half is using to check whether an object exists in the destination storage. In this situation, you can modify the `nworker` and `maxsize` variables in the `migrate.py`:

    ```py
    class ThreadPool(object):
        def __init__(self, do_work, nworker=20):
                self.do_work = do_work
                self.nworker = nworker
                self.task_queue = Queue.Queue(maxsize = 2000)
    ```

    However, if the two values (i.e., `nworker` and `maxsize`) ​​are too large, the improvement in data migration speed may not be obvious because the disk I/O bottleneck has been reached.

!!! note "Encrypted storage backend data (deprecated)"
    If you have an encrypted storage backend, you can use this script to migrate and decrypt the data from that backend to a new one. You can add the `--decrypt` option in calling the script, which will decrypt the data while reading it, and then write the unencrypted data to the new backend:

    ```sh
    ./migrate.sh /opt --decrypt
    ```

=== "Deploy with Docker"

    ```sh
    # make sure you are in the container and in directory `/opt/seafile/seafile-server-latest`
    ./migrate.sh /shared
    
    # exit container and stop it
    exit
    docker compose down
    ```

=== "Deploy from binary package"

    ```sh
    # make sure you are in the directory `/opt/seafile/seafile-server-latest`
    ./migrate.sh /opt
    ```

!!! success
    You can see the following message if the migration process is done:

    ```
    2025-01-15 05:49:39,408 Start to fetch [commits] object from destination
    2025-01-15 05:49:39,422 Start to fetch [fs] object from destination
    2025-01-15 05:49:39,442 Start to fetch [blocks] object from destination
    2025-01-15 05:49:39,677 [commits] [0] objects exist in destination
    2025-01-15 05:49:39,677 Start to migrate [commits] object
    2025-01-15 05:49:39,749 [blocks] [0] objects exist in destination
    2025-01-15 05:49:39,755 Start to migrate [blocks] object
    2025-01-15 05:49:39,752 [fs] [0] objects exist in destination
    2025-01-15 05:49:39,762 Start to migrate [fs] object
    2025-01-15 05:49:40,602 Complete migrate [commits] object
    2025-01-15 05:49:40,626 Complete migrate [blocks] object
    2025-01-15 05:49:40,790 Complete migrate [fs] object
    Done.
    ```

## Replace the original `seafile.conf` and start Seafile

After running the script, we recommend that you check whether your data already exists on the new S3 storage backend server (i.e., the migration is successful, and the number and size of files should be the same). Then you can remove the file from the old S3 storage backend and replace the original `seafile.conf` from the new one:

=== "Deploy with Docker"

    ```sh
    mv /opt/seafile-data/seafile.conf /opt/seafile-data/seafile/conf/seafile.conf
    ```
=== "Deploy from binary package"

    ```sh
    mv /opt/seafile.conf /opt/seafile/conf/seafile.conf
    ```

Finally, you can start Seafile server:

=== "Deploy with Docker"

    ```sh
    docker compose up -d
    ```

=== "Deploy from binary package"

    ```sh
    # make sure you are in the directory `/opt/seafile/seafile-server-latest`
    ./seahub.sh start
    ./seafile.sh start
    ```

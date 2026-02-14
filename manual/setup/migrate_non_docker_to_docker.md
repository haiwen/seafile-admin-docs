# Migrate from non-docker Seafile deployment to docker

!!! note
    - This document is written to about the single node, you have to do the following opeartions (except migtating database) in **all nodes** if you are using *Seafile Cluster*
    - Normally, we only recommend that you perform the migration operation **on two different machines** according to the solution in this document. If you decide to perform the operation on the same machine, **please pay attention to the corresponding tips in the document**.

The recommended steps to migrate from non-docker deployment to docker deployment on two different machines are:

1. Shutdown the Seafile, Nginx and cache server (e.g., Redis) according to your situations.
2. Backup MySQL databse and Seafile libraries data.
3. Deploy the Seafile Docker in the new machine.
4. Recover the Seafile libraries and MySQL database in the new machine.
5. Start Seafile Docker and shutdown the old MySQL (or Mariadb) according to your situations.

## Stop basic Services (except MySQL)

### Stop Seafile server
Run the following commands in `/opt/seafile/seafile-server-latest`:

!!! note
    For installations using python virtual environment, activate it if it isn't already active:

    ```sh
    source python-venv/bin/activate
    ```

!!! tip
    If you have integrated some components (e.g., *SeaDoc*) in your Seafile server, please shutdown them to avoid losting unsaved data

```sh
su seafile
./seafile.sh stop
./seahub.sh stop
```

### Stop Nginx, cache server (e.g., *Redis*), ElasticSearch

You have to stop the above services to avoid losing data before migrating.

```sh
systemctl stop nginx &&  systemctl disable nginx
systemctl stop redis &&  systemctl disable redis
docker stop es && docker remove es
```

## Backup MySQL database and Seafile server

Please follow [here](../administration/backup_recovery.md#backup-and-restore-for-binary-package-based-deployment) to backup:

- Backing up MySQL databases
- Backing up Seafile library data


## Deploy the Seafile Docker

You can follow [here](./overview.md#single-node-deployment) to deploy Seafile with Docker, please use your old configurations when modifying `.env`, and make sure the Seafile server is running normally after deployment.

!!! note "Use *external MySQL service* or the *old MySQL service*"
    This document is written to migrate from non-Docker version to Docker version Seafile between two different machines. We suggest using the Docker-compose *Mariadb* service (version 10.11 by default) as the database service in after-migration Seafile. If you would like to use an existed MySQL service, always in which situation you try to do migrate operation on the same host or the old MySQL service is the dependency of other services, you have to follow [here](./setup_with_an_existing_mysql_server.md) to deploy Seafile.

## Recovery libraries data for Seafile Docker

Firstly, you should stop the Seafile server before recovering Seafile libraries data:

```sh
docker compose down
```

Then recover the data from backuped file:

```sh
cp /backup/data/seafile/* /opt/seafile-data/seafile
```

## Recover the Database (only for the new MySQL service used in Seafile docker)

1. Start the database service **Only**:

    ```sh
    docker compose up -d --no-deps db
    ```

2. Follow [here](../administration/backup_recovery.md#restore-the-databases_1) to recover the database data.

3. Exit the container and stop the Mariadb service

    ```sh
    docker compose down
    ```

## Restart the services

Finally, the migration is complete. You can restart the Seafile server of Docker-base by restarting the service:

```sh
docker compose up -d
```

By the way, you can shutdown the old MySQL service, if it is not a dependency of other services, .

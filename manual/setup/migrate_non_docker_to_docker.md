# Migrate from non-docker Seafile deployment to docker

!!! note
    - This document is writting to about the single node, you have to do the following opeartions (except migtating database) in **all nodes** if you are using *Seafile Cluster*
    - Normally, we only recommend that you perform the migration operation **on two different machines** according to the solution in this document. If you decide to perform the operation on the same machine, **please pay attention to the corresponding tips in the document**.

The recommended steps to migrate from non-docker deployment to docker deployment on two different machines are:

1. Upgrade your Seafile server to the latest version.
2. Shutdown the Seafile, Nginx and Memcached according to your situations.
3. Backup MySQL databse and Seafile libraries data.
4. Recover the MySQL database and Seafile libraries in the new machine.
5. Download the `.yml` files and `.env`, and modify it according to your old Seafile configurations
6. Start Seafile Docker
7. Shutdown the old MySQL (or Mariadb) according to your situations.

## Upgrade your Seafile server

You have to upgrade the version of the binary package to [latest version](../upgrade/upgrade_notes_for_12.0.x.md) before the migration, and ensure that the system is running normally. 

!!! tip
    If you running a very old version of Seafile, you can following the [FAQ item](https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000&row-id=VYQI9DJfRmCv5NggcX4f0Q) to migrate to the latest version

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

### Stop Nginx, cache server (e.g., *Memcached*), ElasticSearch

You have to stop the above services to avoid losing data before migrating.

```sh
systemctl stop nginx &&  systemctl disable nginx
systemctl stop memcached &&  systemctl disable memcached
docker stop es && docker remove es
```

## Backup MySQL database and Seafile server

Please follow [here](../administration/backup_recovery.md#backup-and-restore-for-binary-package-based-deployment) to backup:

- Backing up MySQL Databases
- Backing up Seafile library data

!!! note "Use *external MySQL service* or the *old MySQL service*"
    You can skip the step *Backing up MySQL Databases* now for this situation, however, you have to configure the external MySQL server configuration information by following [here](./setup_with_an_existing_mysql_server.md) **after downloading `.yml` and `.env` section**.


## Create the directory and recovery data for Seafile Docker

In Docker-base Seafile, the default working directory for Seafile is `/opt/seafile-data` (you can modify them in the `.env` file). Here, you have to create this directory, and recovery from backuped file:

```sh
mkdir -p /opt/seafile-data/seafile

# recover seafile data
cp /backup/data/* /opt/seafile-data/seafile
```

## Recover the Database (only for the new MySQL service used in Seafile docker)

1. Pull *Mariadb* image

    !!! tip
        By default, Seafile Docker will use *Mariadb* as the database server and version **10.11** from Seafile 10 Docker. You can specify a new version tag or image according to your situation, but donot forget to modify the `.env` on the next section.

    ```sh
    docker pull mariadb:10.11
    ```

2. Start the *Mariadb* service with the persistent directory `/opt/seafile-mysql/db`, plase replace `<your_root_password>` to your `root` user password and `<your_database_backup_dir>` to the database backup directory:

    ```sh
    docker run -d --rm \
    --name seafile-mariadb \
    -e MYSQL_ROOT_PASSWORD=<your_root_password> \
    -e MYSQL_LOG_CONSOLE=true \
    -e MARIADB_AUTO_UPGRADE=1 \
    -v "/opt/seafile-mysql/db:/var/lib/mysql" \
    -v "<your_database_backup_dir>:/tmp_sqls" \
    mariadb:10.11
    ```

3. Enter the container and Mariadb environment:`

    ```sh
    docker exec -it seafile-mariadb bash
    mariadb -p<your_root_password>
    ```

4. Execute the following SQL sentences, please replace `<seafile-password>` to the password of the `seafile` user in the database: 

    !!! tip "Default database properties used in Seafile"
        You can modify the database configuration (e.g., the user used in Seafile server and relative database name in the following statement), and donot forget to modify in `.env` on the next section, please refer [here](./setup_pro_by_docker.md#downloading-and-modifying-env) for further details.

        
    ```sql
    CREATE DATABASE `seafile_db` CHARSET UTF8;
    CREATE DATABASE `ccnet_db` CHARSET UTF8;
    CREATE DATABASE `seahub_db` CHARSET UTF8;

    CREATE USER 'seafile'@'%' IDENTIFIED BY '<seafile_password>';

    GRANT ALL PRIVILEGES ON `ccnet_db`.* to 'seafile'@'%';
    GRANT ALL PRIVILEGES ON `seafile_db`.* to 'seafile'@'%';
    GRANT ALL PRIVILEGES ON `seahub_db`.* to 'seafile'@'%';
    ```

5. Then you can follow [here](../administration/backup_recovery.md#restore-the-databases-1) to restore the database data. Your database backup files should be in the directory `/tmp_sqls`

6. Finally, exit the container and stop the Mariadb service

    ```sh
    docker stop seafile-mariadb
    ```

## Download the docker-compose files

You have to download the latest docker-compose files (i.e., series of `.yml` and its configuration file `.env`) in order to startup the relative services:

=== "Seafile CE"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/repo/docker/ce/env
    wget https://manual.seafile.com/12.0/repo/docker/ce/seafile-server.yml
    wget https://manual.seafile.com/12.0/repo/docker/caddy.yml
    ```

=== "Seafile Pro"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/repo/docker/pro/env
    wget https://manual.seafile.com/12.0/repo/docker/pro/seafile-server.yml
    wget https://manual.seafile.com/12.0/repo/docker/caddy.yml
    ```

Then modify the `.env` according to your configurations, you can refer [here](./setup_pro_by_docker.md#downloading-and-modifying-env) for further details.

!!! warning "Important"
    **Do not** use the `.env` in the non-Docker Seafile server as the `.env` in Docker-base Seafile server directly, which misses some key variables in running Docker-base Seafile. Otherwise the Seafile server may **not work properly**.

## Restart the services

Finally, the migration is complete. You can restart the Seafile server of Docker-base by restarting the service:

```sh
docker compose up -d
```

!!! success
    After staring the services, you can use `docker logs -f seafile` to follow the logs output from *Seafile* to check the status of the server. When the service is running normally, you will get the following message:

    ```
    Starting seafile server, please wait ...
    Seafile server started

    Done.

    Starting seahub at port 8000 ...

    Seahub is started

    Done.
    ```

If your old MySQL service are not a dependency of other services, you can shutdown it.

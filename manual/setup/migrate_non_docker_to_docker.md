# Migrate from non-docker Seafile deployment to docker

!!! note "For Seafile cluster"
    This document is writting to about the single node, you have to do the following opeartions (except migtating database) in **all nodes**

The recommended steps to migrate from non-docker deployment to docker deployment are:

1. Shutdown Seafile and native Nginx, Memcached
2. Backup Seafile data (database also neet to backup if you are not use an existed MySQL database to deploy non-Docker version Seafile)
3. Create the directory needed for Seafile Docker image to run, and recover the data. (If you are use an existed MySQL database to deploy non-Docker version Seafile, the data from database also need to recover)
4. Download the `.yml` files and `.env`. 
5. Start Seafile Docker

## Before Migration

Upgrade the version of the binary package to [latest version](../upgrade/upgrade_notes_for_12.0.x.md), and ensure that the system is running normally. 

!!! tip
    If you running a very old version of Seafile, you can following the [FAQ item](https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000&row-id=VYQI9DJfRmCv5NggcX4f0Q) to migrate to the latest version

## Stop Services

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

### Stop Nginx, cached server (e.g., *Memcached*), ElasticSearch

You have to stop the above services to avoid losing data before migrating.

```sh
systemctl stop nginx &&  systemctl disable nginx
systemctl stop memcached &&  systemctl disable memcached
docker stop es && docker remove es
```

If you are not using an existed MySQL, you have to shutdown MySQL service too. 

## Backup Seafile

Please follow [here](../administration/backup_recovery.md#backup-and-restore-for-binary-package-based-deployment) to backup:

- Backing up Databases (only if you are not using an existed database to deploy non-Docker version Seafile)
- Backing up Seafile library data

## Download the docker-compose files

You have to download the latest docker-compose files (i.e., series of `.yml` and its configuration file `.env`) in order to startup the relative services:

=== "Seafile CE"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/docker/ce/env
    wget https://manual.seafile.com/12.0/docker/ce/seafile-server.yml
    wget https://manual.seafile.com/12.0/docker/caddy.yml
    ```

=== "Seafile Pro"

    ```sh
    wget -O .env https://manual.seafile.com/12.0/docker/pro/env
    wget https://manual.seafile.com/12.0/docker/pro/seafile-server.yml
    wget https://manual.seafile.com/12.0/docker/caddy.yml
    ```

Then modify the `.env` according to your configurations.

!!! warning "Important"
    **Do not** use the `.env` in the non-Docker Seafile server as the `.env` in Docker-base Seafile server directly, which misses some key variables in running Docker-base Seafile. Otherwise the Seafile server may **not work properly**.


## Create the directory and recovery data for Seafile Docker

In Docker-base Seafile, the default working directory for Seafile is `/opt/seafile-data` (you can modify them in the `.env` file). Here, you have to create this directory, and recovery from backuped file:

```sh
mkdir -p /opt/seafile-data/seafile

# recover seafile data
cp /backup/data/* /opt/seafile-data/seafile
```

## Recover the Database (only if not use an existed MySQL)

You should start the services Firstly, otherwise you cannot connect to MySQL service (`mariadb` now in docker-compose Seafile):

```sh
docker compose up -d
```

After startuping the MySQL service, you should create the MySQL user (e.g., `seafile`, defined in your `.env` file) and add related permissions:

```
## Note, change the password according to the actual password you use
GRANT ALL PRIVILEGES ON *.* TO 'seafile'@'%' IDENTIFIED BY 'your-password' WITH GRANT OPTION;

## Grant seafile user can connect the database from any IP address
GRANT ALL PRIVILEGES ON `ccnet_db`.* to 'seafile'@'%';
GRANT ALL PRIVILEGES ON `seafile_db`.* to 'seafile'@'%';
GRANT ALL PRIVILEGES ON `seahub_db`.* to 'seafile'@'%';
```

Then you can follow [here](../administration/backup_recovery.md#restore-the-databases-1) to restore the database data

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

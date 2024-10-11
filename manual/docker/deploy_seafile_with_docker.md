# Deploy Seafile with Docker

## Getting started

The following assumptions and conventions are used in the rest of this document:

- `/opt/seafile-data` is the directory of Seafile. If you decide to put Seafile in a different directory — which you can — adjust all paths accordingly.
- Seafile uses two [Docker volumes](https://docs.docker.com/storage/volumes/) for persisting data generated in its database and Seafile Docker container. The volumes' [host paths](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes) are `/opt/seafile-mysql` and `/opt/seafile-data`, respectively. It is not recommended to change these paths. If you do, account for it when following these instructions.
- All configuration and log files for Seafile and the webserver Nginx are stored in the volume of the Seafile container.

### Install docker

Use the [official installation guide for your OS to install Docker](https://docs.docker.com/engine/install/).

### Download and modify `.env`

From Seafile Docker 12.0, we recommend that you use `.env`, `seafile-server.yml`  and `caddy.yml` files for configuration.

**NOTE:** Different versions of Seafile have different compose files.

```bash
mkdir /opt/seafile
cd /opt/seafile

# Seafile CE 12.0
wget -O .env https://manual.seafile.com/docker/docker-compose/ce/12.0/env
wget https://manual.seafile.com/docker/docker-compose/ce/12.0/seafile-server.yml
wget https://manual.seafile.com/docker/docker-compose/ce/12.0/caddy.yml

nano .env
```

The following fields merit particular attention:

- `SEAFILE_VOLUMES`: The volume directory of Seafile data
- `SEAFILE_MYSQL_VOLUMES`: The volume directory of MySQL data
- `SEAFILE_CADDY_VOLUMES`: The volume directory of Caddy data
- `SEAFILE_MYSQL_ROOT_PASSWORD`: The user `root` password of MySQL
- `SEAFILE_MYSQL_DB_PASSWORD`: The user `seafile` password of MySQL
- `JWT`: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`
- `SEAFILE_SERVER_HOSTNAME`: Seafile server hostname or domain
- `SEAFILE_SERVER_PROTOCOL`: Seafile server protocol (http or https)
- `TIME_ZONE`: Time zone (default UTC)
- `SEAFILE_ADMIN_EMAIL`: Admin username
- `SEAFILE_ADMIN_PASSWORD`: Admin password

NOTE: SSL is now handled by the caddy server.

### Start Seafile server

Start Seafile server with the following command

```bash
# if `.env` file is in current directory:
docker compose up -d

# if `.env` file is elsewhere:
docker compose -f /path/to/.env up -d
```

Wait for a few minutes for the first time initialization, then visit `http://seafile.example.com` to open Seafile Web UI.

## Seafile directory structure

### `/opt/seafile-data`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files and upload directory outside. This allows you to rebuild containers easily without losing important information.

* /opt/seafile-data/seafile: This is the directory for seafile server configuration and data.
  * /opt/seafile-data/seafile/logs: This is the directory that would contain the log files of seafile server processes. For example, you can find seaf-server logs in `/opt/seafile-data/seafile/logs/seafile.log`.
* /opt/seafile-data/logs: This is the directory for operating system and Nginx logs.
  * /opt/seafile-data/logs/var-log: This is the directory that would be mounted as `/var/log` inside the container. For example, you can find the nginx logs in `/opt/seafile-data/logs/var-log/nginx/`.

### Find logs

To monitor container logs (from outside of the container), please use the following commands:

```bash
# if the `.env` file is in current directory:
docker compose logs --follow
# if the `.env` file is elsewhere:
docker compose -f /path/to/.env logs --follow

# you can also specify container name:
docker compose logs seafile --follow
# or, if the `.env` file is elsewhere:
docker compose -f /path/to/.env logs seafile --follow
```

The Seafile logs are under `/shared/logs/seafile` in the docker, or `/opt/seafile-data/logs/seafile` in the server that run the docker.

The system logs are under `/shared/logs/var-log`, or `/opt/seafile-data/logs/var-log` in the server that run the docker.

To monitor all Seafile logs simultaneously (from outside of the container), run

```bash
sudo tail -f $(find /opt/seafile-data/ -type f -name *.log 2>/dev/null)
```

## More configuration options

### Use an existing mysql-server

If you want to use an existing mysql-server, you can modify the `.env` as follows

```env
SEAFILE_MYSQL_DB_HOST=192.168.0.2
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_ROOT_PASSWORD=ROOT_PASSWORD
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD
```

NOTE: `SEAFILE_MYSQL_ROOT_PASSWORD` is needed during installation. Later, after Seafile is installed, the user `seafile` will be used to connect to the mysql-server (SEAFILE_MYSQL_DB_PASSWORD). You can remove the `SEAFILE_MYSQL_ROOT_PASSWORD`.

### Modify Seafile server configurations

The config files are under `/opt/seafile-data/seafile/conf`. You can modify the configurations according to [Seafile manual](https://manual.seafile.com/)

After modification, you need to restart the container:

```bash
docker compose restart
```

### Add a new admin

Ensure the container is running, then enter this command:

```bash
docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh
```

Enter the username and password according to the prompts. You now have a new admin account.

### Run Seafile as non root user inside docker

You can use run seafile as non root user in docker. (**NOTE:** Programs such as `my_init`, Nginx are still run as `root` inside docker.)

First add the `NON_ROOT=true` to the `.env`.

```env
NON_ROOT=true
```

Then modify `/opt/seafile-data/seafile/` permissions.

```bash
chmod -R a+rwx /opt/seafile-data/seafile/
```

Then destroy the containers and run them again:

```bash
docker compose down
docker compose up -d
```

Now you can run Seafile as `seafile` user. (**NOTE:** Later, when doing maintenance, other scripts in docker are also required to be run as `seafile` user, e.g. `su seafile -c ./seaf-gc.sh`)

## Backup and recovery

Follow the instructions in [Backup and restore for Seafile Docker](../maintain/backup_recovery.md)

## Garbage collection

When files are deleted, the blocks comprising those files are not immediately removed as there may be other files that reference those blocks (due to the magic of deduplication). To remove them, Seafile requires a ['garbage collection'](../maintain/seafile_gc.md) process to be run, which detects which blocks no longer used and purges them. (**NOTE:** for technical reasons, the GC process does not guarantee that _every single_ orphan block will be deleted.)

The required scripts can be found in the `/scripts` folder of the docker container. To perform garbage collection, simply run `docker exec seafile /scripts/gc.sh`. For the community edition, this process will stop the seafile server, but it is a relatively quick process and the seafile server will start automatically once the process has finished. The Professional supports an online garbage collection.

## FAQ

### You can run docker commands like `docker exec` to find errors

```bash
docker exec -it seafile /bin/bash
```

### LetsEncrypt SSL certificate is about to expire

If the certificate is not renewed automatically, you can execute the following command to manually renew the certificate.

```bash
# /scripts/ssl.sh /shared/ssl/ <your-seafile-domain>
/scripts/ssl.sh /shared/ssl/ example.seafile.com
```

### Change the environment variable `SEAFILE_SERVER_LETSENCRYPT=false` value to `true`

1. If you want to change to https after using http, first back up the `seafile.nginx.conf`:

```bash
mv /opt/seafile-data/nginx/conf/seafile.nginx.conf /opt/seafile-data/nginx/conf/seafile.nginx.conf.bak
# or
mv /opt/seafile-data/nginx/conf/seafile.nginx.conf{,.bak}
```

2. Destroy the containers with `docker compose down`.

3. Edit `docker-compose.yml`: change `SEAFILE_SERVER_LETSENCRYPT=false` value to `true`.

4. Run `docker compose up -d` again. The new Seafile container will automatically request for an SSL certificate to be generated and installed.

**Notes:**

- You need to manually change http to https in other configuration files.

- `SERVICE_URL` and `FILE_SERVER_ROOT` environment variables in the system admin page also need to be modified.

- If you have modified the old `seafile.nginx.conf`, now you can modify the new `seafile.nginx.conf` as you want. Then execute the following command:

```bash
# test the Nginx configuration and, if OK, reload nginx for configuration to take effect:
docker exec seafile nginx -t && docker exec seafile nginx -s reload
```

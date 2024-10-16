# Installation of Seafile Server Professional Edition with Docker

This manual explains how to deploy and run Seafile Server Professional Edition (Seafile PE) on a Linux server using Docker and Docker Compose. The deployment has been tested for Debian/Ubuntu and CentOS, but Seafile PE should also work on other Linux distributions.

## Requirements

Seafile PE requires a minimum of 2 cores and 2GB RAM. If Elasticsearch is installed on the same server, the minimum requirements are 4 cores and 4 GB RAM, and make sure the [mmapfs counts](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-store.html#mmapfs) do not cause excptions like out of memory, which can be increased by following command (see <https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html> for futher details):

```shell
sysctl -w vm.max_map_count=262144 #run as root
```

or modify **/etc/sysctl.conf** and reboot to set this value permanently:

```shell
nano /etc/sysctl.conf

# modify vm.max_map_count
vm.max_map_count=262144
```

Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at sales@seafile.com.

## Setup

The following assumptions and conventions are used in the rest of this document:

- `/opt/seafile-data` is the directory of Seafile. If you decide to put Seafile in a different directory - which you can - adjust all paths accordingly.
- Seafile uses two [Docker volumes](https://docs.docker.com/storage/volumes/) for persisting data generated in its database and Seafile Docker container. The volumes' [host paths](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes) are /opt/seafile-mysql and /opt/seafile-data, respectively. It is not recommended to change these paths. If you do, account for it when following these instructions.
- All configuration and log files for Seafile and the webserver Nginx are stored in the volume of the Seafile container.

### Installing Docker

Use the [official installation guide for your OS to install Docker](https://docs.docker.com/engine/install/).

### Downloading the Seafile Image

Log into Seafile's private repository and pull the Seafile image:

```bash
docker login docker.seadrive.org
docker pull docker.seadrive.org/seafileltd/seafile-pro-mc:12.0-latest
```

When prompted, enter the username and password of the private repository. They are available on the download page in the [Customer Center](https://customer.seafile.com/downloads).

NOTE: Older Seafile PE versions are also available in the repository (back to Seafile 7.0). To pull an older version, replace '12.0-latest' tag by the desired version.

### Downloading and Modifying `.env`

From Seafile Docker 12.0, we recommend that you use `.env`, `seafile-server.yml`  and `caddy.yml` files for configuration.

NOTE: Different versions of Seafile have different compose files.

```bash
mkdir /opt/seafile
cd /opt/seafile

# Seafile PE 12.0
wget -O .env https://manual.seafile.com/docker/docker-compose/pro/12.0/env
wget https://manual.seafile.com/docker/docker-compose/pro/12.0/seafile-server.yml
wget https://manual.seafile.com/docker/docker-compose/pro/12.0/caddy.yml

nano .env
```

The following fields merit particular attention:

- `SEAFILE_VOLUME`: The volume directory of Seafile data, default is `/opt/seafile-data`
- `SEAFILE_MYSQL_VOLUME`: The volume directory of MySQL data, default is `/opt/seafile-mysql/db`
- `SEAFILE_CADDY_VOLUME`: The volume directory of Caddy data used to store certificates obtained from Let's Encrypt's, default is `/opt/seafile-caddy`
- `SEAFILE_ELASTICSEARCH_VOLUME`: The volume directory of Elasticsearch data, default is `/opt/seafile-elasticsearch/data`
- `SEAFILE_MYSQL_ROOT_PASSWORD`: The `root` password of MySQL
- `SEAFILE_MYSQL_DB_USER`: The user of MySQL (`database` - `user` can be found in `conf/seafile.conf`)
- `SEAFILE_MYSQL_DB_PASSWORD`: The user `seafile` password of MySQL
- `JWT`: JWT_PRIVATE_KEY, A random string with a length of no less than 32 characters, generate example: `pwgen -s 40 1`
- `SEAFILE_SERVER_HOSTNAME`: Seafile server hostname or domain
- `SEAFILE_SERVER_PROTOCOL`: Seafile server protocol (http or https)
- `TIME_ZONE`: Time zone (default UTC)
- `SEAFILE_ADMIN_EMAIL`: Admin username
- `SEAFILE_ADMIN_PASSWORD`: Admin password

NOTE: SSL is now handled by the [caddy server](../deploy_seafile_with_docker.md#about-ssl-and-caddy) from 12.0.

To conclude, set the directory permissions of the Elasticsearch volumne:

```bash
mkdir -p /opt/seafile-elasticsearch/data
chmod 777 -R /opt/seafile-elasticsearch/data
```

### Starting the Docker Containers

Run docker compose in detached mode:

```bash
docker compose up -d
```

NOTE: You must run the above command in the directory with the `.env`.

Wait a few moment for the database to initialize. You can now access Seafile at the host name specified in the Compose file. (A 502 Bad Gateway error means that the system has not yet completed the initialization.)

### Find logs

To view Seafile docker logs, please use the following command

```shell
docker compose logs -f
```

The Seafile logs are under `/shared/logs/seafile` in the docker, or `/opt/seafile-data/logs/seafile` in the server that run the docker.

The system logs are under `/shared/logs/var-log`, or `/opt/seafile-data/logs/var-log` in the server that run the docker.

### Activating the Seafile License

If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container. The volumne's default path in the Compose file is `/opt/seafile-data`. If you have modified the path, save the license file under your custom path.

Then restart Seafile:

```bash
docker compose down

docker compose up -d
```

## Seafile directory structure

### `/opt/seafile-data`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files and upload directory outside. This allows you to rebuild containers easily without losing important information.

* /opt/seafile-data/seafile: This is the directory for seafile server configuration 、logs and data.
  * /opt/seafile-data/seafile/logs: This is the directory that would contain the log files of seafile server processes. For example, you can find seaf-server logs in `/opt/seafile-data/seafile/logs/seafile.log`.
* /opt/seafile-data/logs: This is the directory for operating system and Nginx logs.
  * /opt/seafile-data/logs/var-log: This is the directory that would be mounted as `/var/log` inside the container. For example, you can find the nginx logs in `/opt/seafile-data/logs/var-log/nginx/`.

### Reviewing the Deployment

The command `docker container list` should list the containers specified in the `.env`.

The directory layout of the Seafile container's volume should look as follows:

```bash
$ tree /opt/seafile-data -L 2
/opt/seafile-data
├── logs
│   └── var-log
├── nginx
│   └── conf
└── seafile
    ├── ccnet
    ├── conf
    ├── logs
    ├── pro-data
    ├── seafile-data
    └── seahub-data
```

All Seafile config files are stored in `/opt/seafile-data/seafile/conf`. The nginx config file is in `/opt/seafile-data/nginx/conf`.

Any modification of a configuration file requires a restart of Seafile to take effect:

```bash
docker compose restart
```

All Seafile log files are stored in `/opt/seafile-data/seafile/logs` whereas all other log files are in `/opt/seafile-data/logs/var-log`.

## Use an existing mysql-server

If you want to use an existing mysql-server, you can modify the `.env` as follows

```env
SEAFILE_MYSQL_DB_HOST=192.168.0.2
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_ROOT_PASSWORD=ROOT_PASSWORD
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD
```

NOTE: `SEAFILE_MYSQL_ROOT_PASSWORD` is needed during installation. Later, after Seafile is installed, the user `seafile` will be used to connect to the mysql-server (SEAFILE_MYSQL_DB_PASSWORD). You can remove the `SEAFILE_MYSQL_ROOT_PASSWORD`.

## Run Seafile as non root user inside docker

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

## Backup and Recovery

Follow the instructions in [Backup and restore for Seafile Docker](../../maintain/backup_recovery.md)

## Garbage Collection

When files are deleted, the blocks comprising those files are not immediately removed as there may be other files that reference those blocks (due to the magic of deduplication). To remove them, Seafile requires a ['garbage collection'](https://manual.seafile.com/maintain/seafile_gc/) process to be run, which detects which blocks no longer used and purges them. (NOTE: for technical reasons, the GC process does not guarantee that _every single_ orphan block will be deleted.)

The required scripts can be found in the `/scripts` folder of the docker container. To perform garbage collection, simply run `docker exec seafile /scripts/gc.sh`. For the community edition, this process will stop the seafile server, but it is a relatively quick process and the seafile server will start automatically once the process has finished. The Professional supports an online garbage collection.

## OnlyOffice with Docker

You need to manually add the OnlyOffice config to `.env`

* [OnlyOffice with Docker](deploy_onlyoffice_with_docker.md)

## Clamav with Docker

You need to manually add the Clamav config to `.env`

* [Deploy Clamav with Docker](../../deploy_pro/deploy_clamav_with_seafile.md)

## Other functions

### LDAP/AD Integration for Pro

* [Configure LDAP in Seafile Pro](../../deploy_pro/using_ldap_pro.md)
* [Syncing Groups from LDAP/AD](../../deploy_pro/ldap_group_sync.md)
* [Syncing Roles from LDAP/AD](../../deploy_pro/ldap_role_sync.md)

### S3/OpenSwift/Ceph Storage Backends

* [Setup Seafile Professional Server With Amazon S3](../../deploy_pro/setup_with_amazon_s3.md)
* [Setup Seafile Professional Server With OpenStack Swift](../../deploy_pro/setup_with_swift.md)
* [Setup Seafile Professional Server With Ceph](../../deploy_pro/setup_with_ceph.md)
* [Data migration between different backends](../../deploy_pro/migrate.md)
* [Using multiple storage backends](../../deploy_pro/multiple_storage_backends.md)

### Online File Preview and Editing

* [Enable Office/PDF Documents Online Preview](../../deploy_pro/office_documents_preview.md)
* [Integrating with Office Online Server](../../deploy_pro/office_web_app.md)

### Advanced User Management

* [Multi-Institutions Support](../../deploy_pro/multi_institutions.md)
* [Roles and Permissions](../../deploy_pro/roles_permissions.md)

### Advanced Authentication

* [Two-factor Authentication](../../deploy_pro/two_factor_authentication.md)
* [ADFS or SAML 2.0](../../deploy_pro/adfs.md)
* [CAS](../../deploy_pro/cas.md)

### Admin Tools

* [Import Directory to Seafile](../../deploy_pro/seaf_import.md)

## FAQ

Q: I forgot the Seafile admin email address/password, how do I create a new admin account?

A: You can create a new admin account by running

```shell
docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh
```

The Seafile service must be up when running the superuser command.

Q: If, for whatever reason, the installation fails, how do I to start from a clean slate again?

A: Remove the directories /opt/seafile, /opt/seafile-data, /opt/seafile-elasticsearch, and /opt/seafile-mysql and start again.

Q: Something goes wrong during the start of the containers. How can I find out more?

A: You can view the docker logs using this command: `docker compose logs -f`.

Q: I forgot the admin password. How do I create a new admin account?

A: Make sure the seafile container is running and enter `docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh`.

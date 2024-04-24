# Installation of Seafile Server Professional Edition with Docker

This manual explains how to deploy and run Seafile Server Professional Edition (Seafile PE) on a Linux server using Docker and Docker Compose. The deployment has been tested for Debian/Ubuntu and CentOS, but Seafile PE should also work on other Linux distributions.

## Requirements
Seafile PE requires a minimum of 2 cores and 2GB RAM. If Elasticsearch is installed on the same server, the minimum requirements are 4 cores and 4 GB RAM.

Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at sales@seafile.com or one of [our partners](https://www.seafile.com/en/partner/).

## Setup

The following assumptions and conventions are used in the rest of this document:

- `/opt/seafile-data` is the directory of Seafile. If you decide to put Seafile in a different directory - which you can - adjust all paths accordingly.
- Seafile uses two [Docker volumes](https://docs.docker.com/storage/volumes/) for persisting data generated in its database and Seafile Docker container. The volumes' [host paths](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes) are /opt/seafile-mysql and /opt/seafile-data, respectively. It is not recommended to change these paths. If you do, account for it when following these instructions.
- All configuration and log files for Seafile and the webserver Nginx are stored in the volume of the Seafile container.

### Installing Docker

Use the [official installation guide for your OS to install Docker](https://docs.docker.com/engine/install/).

### Downloading the Seafile Image

Log into Seafile's private repository and pull the Seafile image:

```
docker login docker.seadrive.org
docker pull docker.seadrive.org/seafileltd/seafile-pro-mc:latest
```

When prompted, enter the username and password of the private repository. They are available on the download page in the [Customer Center](https://customer.seafile.com/downloads).

NOTE: Older Seafile PE versions are also available in the repository (back to Seafile 7.0). To pull an older version, replace 'latest' tag by the desired version.

### Downloading and Modifying docker-compose.yml

Download the docker-compose.yml sample file into Seafile's directory and modify the Compose file to fit your environment and settings.

NOTE: Different versions of Seafile have different compose files.

```
mkdir /opt/seafile
cd /opt/seafile

# Seafile PE 7.1 and 8.0
wget -O "docker-compose.yml" "https://manual.seafile.com/docker/docker-compose/pro/7.1_8.0/docker-compose.yml"

# Seafile PE 9.0
wget -O "docker-compose.yml" "https://manual.seafile.com/docker/docker-compose/pro/9.0/docker-compose.yml"

# Seafile PE 10.0
wget -O "docker-compose.yml" "https://manual.seafile.com/docker/docker-compose/pro/10.0/docker-compose.yml"

# Seafile PE 11.0
wget -O "docker-compose.yml" "https://manual.seafile.com/docker/docker-compose/pro/11.0/docker-compose.yml"

nano docker-compose.yml
```

The following fields merit particular attention:

* The password of MariaDB root (MYSQL_ROOT_PASSWORD and DB_ROOT_PASSWD)
* The Seafile admin email address (SEAFILE_ADMIN_EMAIL)
* The Seafile admin password (SEAFILE_ADMIN_PASSWORD)
* The listening ports of the container seafile 
* The host name (SEAFILE_SERVER_HOSTNAME)
* The use of Let's Encrypt for HTTPS (SEAFILE_SERVER_LETSENCRYPT)

The new password for MYSQL_ROOT_PASSWORD and DB_ROOT_PASSWD must be identical.

To enable HTTPS access - which is required for production use - , enter the SEAFILE_SERVER_HOSTNAME and uncomment port 443 in the configuration of the container seafile. If you want to use Let's Encrypt to obtain a SSL certificate, set SEAFILE_SERVER_LETSENCRYPT to `true` (and do not comment out port 80 because it is required when requesting a Let's Encrypt certificate). If you want to use your own SSL certificate, leave SEAFILE_SERVER_LETSENCRYPT set to `false` and follow the instructions in section [Configuring a Custom SSL Certificate](https://manual.seafile.com/docker/pro-edition/deploy_seafile_pro_with_docker/#configuring-a-custom-ssl-certificate).

Additional customizable options in the Compose file are:

* The volume path for the container db
* The volume path for the container elasticsearch
* The volume path for the container seafile
* The image tag of the Seafile version to install (image)
* The time zone (TIME_ZONE)

If you have pulled a particular version, modify the image tag accordingly.

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

NOTE: You must run the above command in the directory with the docker-compose.yml.

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
* /opt/seafile-data/ssl: This is directory for certificate, which does not exist by default.

### Reviewing the Deployment

The command `docker container list` should list the four containers specified in the docker-compose.yml.

The directory layout of the Seafile container's volume should look as follows:

```
$ tree /opt/seafile-data -L 2
/opt/seafile-data
├── logs
│   └── var-log
├── nginx
│   └── conf
├── seafile
│   ├── ccnet
│   ├── conf
│   ├── logs
│   ├── pro-data
│   ├── seafile-data
│   └── seahub-data
└── ssl
    ├── account.conf
    ├── ca
    ├── http.header
    ├── SEAFILE_SERVER_HOSTNAME
    ├── SEAFILE_SERVER_HOSTNAME.crt
    └── SEAFILE_SERVER_HOSTNAME.key
```

NOTE: The directory `ssl` does not exist if Let's Encrypt is not used for HTTPS. SEAFILE_SERVER_HOSTNAME substitutes for the host name used in the docker-compose.yml file.

All Seafile config files are stored in `/opt/seafile-data/seafile/conf`. The nginx config file is in `/opt/seafile-data/nginx/conf`.

Any modification of a configuration file requires a restart of Seafile to take effect:

```
docker compose restart
```

All Seafile log files are stored in `/opt/seafile-data/seafile/logs` whereas all other log files are in `/opt/seafile-data/logs/var-log`.

## Configuring a Custom SSL Certificate

NOTE: This section is only relevant when you do not want to use a Let's Encrypt certificate, but a certificate of your own.

Create a folder for the certificate:

```
mkdir /opt/seafile-data/ssl
```

Save your certificate and private key in this folder.

Modify the nginx configuration `seafile.nginx.conf` in `/opt/seafile-data/nginx/conf` to look like this:

```
server {
    listen 80;
    server_name example.seafile.com default_server;

    location / {
        rewrite ^ https://$host$request_uri? permanent;
    }
}
server {
    listen 443;
    ssl on;
    ssl_certificate      /shared/ssl/your-ssl-crt.crt;
    ssl_certificate_key  /shared/ssl/your-ssl-key.key;
    ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;

    server_name example.seafile.com;
    ...

```

Modify the values for server_name, ssl_certificate, and ssl_certificate_key to correspond to your situation.

Now reload the nginx configuration:

```
docker exec -it seafile /usr/sbin/nginx -s reload
```

NOTE: If you got the following error when SEAFILE_SERVER_LETSENCRYPT=true is set:

```log
subprocess.CalledProcessError: Command '/scripts/ssl.sh /shared/ssl cloud.seafile-demo.de' returned non-zero exit status 128.
```

In /scripts/ssl.sh (script in seafile container), `git clone git://` has to be replaced with `git clone https://`.

Then restart the container:

```shell
docker compose restart
```

Since version 9.0.6, we use acme (not acme-tiny) to get certificate and fix this error.

Since version 10.0.x, if you want to use a reverse proxy and apply for a certificate outside docker, you can use `FORCE_HTTPS_IN_CONF` to force write `https://<your_host>` in the configuration file.

e.g.

```
seafile:
    ...
    environment:
        ...
        - SEAFILE_SERVER_LETSENCRYPT=false
        - SEAFILE_SERVER_HOSTNAME=seafile.example.com
        - FORCE_HTTPS_IN_CONF=true
        ...

```

## Use an existing mysql-server

If you want to use an existing mysql-server, you can modify the `docker-compose.yml` as follows

```yml
services:
  #db:
    #image: mariadb:10.11
    #...

  seafile:
    ...
    environment:
        ...
        - DB_HOST=192.168.0.2
        - DB_PORT=3306
        - DB_ROOT_PASSWD=mysql_root_password
        ...
    depends_on:
      #- db
      - memcached
```

* The entire db chapter needs to be removed
* The host of MySQL (DB_HOST)
* The port of MySQL (DB_PORT)
* The password of MySQL root (DB_ROOT_PASSWD)
* db in depends_on chapter needs to be removed
* When Seafile is installed, the user `seafile` will be used to connect to the mysql-server (in conf/seafile.conf). You can remove the `DB_ROOT_PASSWD`.

## Run Seafile as non root user inside docker

Since version 10.0, you can use run seafile as non root user in docker. (NOTE: Programs such as my_init, Nginx are still run as root inside docker.)

First add the `NON_ROOT=true` to the docker-compose.yml.

```
seafile:
    ...
    environment:
        ...
        - NON_ROOT=true
        ...
```

Then create a seafile user on the host. (NOTE: Do not change the uid and gid.)

```
groupadd --gid 8000 seafile
useradd --home-dir /home/seafile --create-home --uid 8000 --gid 8000 --shell /bin/sh --skel /dev/null seafile
```

Restarting the container run Seafile use seafile user. (NOTE: Later when do maintenance, other scripts in docker also required to run as seafile user, e.g. `su seafile -c ./seaf-gc.sh`)

```sh
docker compose down
docker compose up -d
```

## Backup and Recovery

Follow the instructions in [Backup and restore for Seafile Docker](../../maintain/backup_recovery.md)


## Garbage Collection

When files are deleted, the blocks comprising those files are not immediately removed as there may be other files that reference those blocks (due to the magic of deduplication). To remove them, Seafile requires a ['garbage collection'](https://manual.seafile.com/maintain/seafile_gc/) process to be run, which detects which blocks no longer used and purges them. (NOTE: for technical reasons, the GC process does not guarantee that _every single_ orphan block will be deleted.)

The required scripts can be found in the `/scripts` folder of the docker container. To perform garbage collection, simply run `docker exec seafile /scripts/gc.sh`. For the community edition, this process will stop the seafile server, but it is a relatively quick process and the seafile server will start automatically once the process has finished. The Professional supports an online garbage collection.

## OnlyOffice with Docker

You need to manually add the OnlyOffice config to docker-compose.yml

* [OnlyOffice with Docker](deploy_onlyoffice_with_docker.md)

## Clamav with Docker

Since version 9.0.6, you can deploy Clamav with Docker.

You need to manually add the Clamav config to docker-compose.yml

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

```
docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh
```

The Seafile service must be up when running the superuser command.

Q: If, for whatever reason, the installation fails, how do I to start from a clean slate again?

A: Remove the directories /opt/seafile, /opt/seafile-data, /opt/seafile-elasticsearch, and /opt/seafile-mysql and start again.

Q: Something goes wrong during the start of the containers. How can I find out more?

A: You can view the docker logs using this command: `docker compose logs -f`.

Q: I forgot the admin password. How do I create a new admin account?

A: Make sure the seafile container is running and enter `docker exec -it seafile /opt/seafile/seafile-server-latest/reset-admin.sh`.

Q: The Let's Encrypt SSL certificate is about to expire, how do I renew it?

A: The SSL certificate should be renewed automatically 30 days prior to its expiration. If the automatic renewal fails, these commands renew the certificate manually:
```
docker exec -it seafile /bin/bash
/scripts/ssl.sh /shared/ssl/ SEAFILE_SERVER_HOSTNAME
```
SEAFILE_SERVER_HOSTNAME is the host name used in the docker-compose.yml.

Q: **SEAFILE_SERVER_LETSENCRYPT=false change to true.**

A: If you want to change to https after using http, first backup and move the seafile.nginx.conf.

```sh
mv /opt/seafile-data/nginx/conf/seafile.nginx.conf /opt/seafile-data/nginx/conf/seafile.nginx.conf.bak
```

Starting the new container will automatically apply a certificate.

```sh
docker compose down
docker compose up -d
```

You need to manually change http to https in other configuration files, SERVICE_URL and FILE_SERVER_ROOT in the system admin page also need to be modified.

If you have modified the old seafile.nginx.conf, now you can modify the new seafile.nginx.conf as you want. Then execute the following command to make the nginx configuration take effect.

```sh
docker exec seafile nginx -s reload
```

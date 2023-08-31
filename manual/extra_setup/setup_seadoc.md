# SeaDoc Integration (Draft)

SeaDoc is an online collaborative document editor and workflow management system.

SeaDoc designed around the following key ideas:

* An expressive easy to use editor
* A review and approval workflow to better control how contents changes
* Inter-document linking for connecting related contents
* AI integration that streamlines content generation, summarization, and management
* Comprehensive APIs for automating document generating and processing

SeaDoc excels at:

* Authoring product and technical documents
* Creating knowledge base articles and online manuals
* Building internal Wikis

## Setup SeaDoc

> Seafile version 11.0 or later is required to work with SeaDoc.

### Create the SeaDoc database manually

SeaDoc and Seafile share the MySQL service.

Create the database sdoc_db in Seafile MySQL and authorize the user.

```sh
create database if not exists sdoc_db charset utf8mb4;
GRANT ALL PRIVILEGES ON `sdoc_db`.* to `seafile`@`sdoc_server_host`;
```

### Install docker

Use the [official installation guide for your OS to install Docker](https://docs.docker.com/engine/install/).

### Install docker-compose

SeaDoc docker image uses docker-compose. You should install the docker-compose command.

```bash
# for CentOS
yum install docker-compose -y

# for Ubuntu
apt-get install docker-compose -y

```

### Download and modify SeaDoc docker-compose.yml

Download [docker-compose.yml](https://manual.seafile.com/extra_setup/sdoc/docker-compose.yml) sample file to your host. Then modify the file according to your environment. The following fields are needed to be modified:

* MySQL host (DB_HOST)
* MySQL port (DB_PORT)
* MySQL user (DB_USER)
* MySQL password (DB_PASSWD)
* The volume directory of SeaDoc data (volumes)
* SeaDoc service url (SDOC_SERVER_HOSTNAME)
* Seafile service url (SEAHUB_SERVICE_URL)

### Deployment method

SeaDoc has three deployment methods

* Deploy SeaDoc on a new host.
* SeaDoc and Seafile are deployed on the same host.
* SeaDoc and Seafile docker are deployed on the same host.

### Deploy SeaDoc on a new host

Just follow the chapter: Start SeaDoc.

### SeaDoc and Seafile are deployed on the same host

#### Modify docker-compose.yml

The `ports` need to be modified additionally:

```yml
sdoc-server:
    ...
    ports:
        # - "80:80"
        # - "443:443"
        - "7070:7070"
```

#### Download and modify seafile.nginx.conf

Download [sdoc-server-nginx-conf](https://manual.seafile.com/extra_setup/sdoc/sdoc-server-nginx-conf) sample file to your host. Add its contents to the `seafile.nginx.conf` and reload nginx:

```sh
nginx -s reload
```

Then follow the chapter: Start SeaDoc.

### SeaDoc and Seafile docker are deployed on the same host

Add the SeaDoc docker-compose.yml contents to the Seafile docker-compose.yml, and the `ports` need to be modified additionally:

```yml
services:
  ...
  seafile:
    ...

  sdoc-server:
    image: seafileltd/sdoc-server:latest
    container_name: sdoc-server
    ports:
      # - 80:80
      # - 443:443
      - 7070:7070
    ...
```

#### Download and modify seafile.nginx.conf

Download [sdoc-server-nginx-conf](https://manual.seafile.com/extra_setup/sdoc/sdoc-server-nginx-conf) sample file to your host. Add its contents to the `seafile.nginx.conf` and reload nginx:

```sh
nginx -s reload
```

Then follow the chapter: Start SeaDoc.

## Start SeaDoc

Start SeaDoc server with the following command

```sh
docker-compose up -d
```

Wait for a few minutes for the first time initialization. Open `sdoc-server-path/sdoc-server/conf/sdoc_server_config.json`, and record `private_key` for modifying Seafile configuration file.

### Configure Seafile

Modify seahub_settings.py:

```python
ENABLE_SEADOC = True
SEADOC_PRIVATE_KEY = '***'  # sdoc-server private_key
SEADOC_SERVER_URL = 'http://sdoc-server.example.com'  # sdoc-server service url
# When SeaDoc and Seafile/Seafile docker are deployed on the same host it, SEADOC_SERVER_URL should be 'http://seafile.example.com/sdoc-server'
```

Restart Seafile server

```sh
./seahub.sh restart
```

Now you can use SeaDoc!

## More configuration options

### Let's encrypt SSL certificate

If you set `SDOC_SERVER_LETSENCRYPT` to `true`, the container would request a letsencrypt-signed SSL certificate for you automatically.

e.g.

```
sdoc-server:
    ...
    ports:
        - "80:80"
        - "443:443"
    ...
    environment:
        ...
        - SDOC_SERVER_LETSENCRYPT=true
        - SDOC_SERVER_HOSTNAME=sdoc-server.seafile.com
        ...

```

If you want to use your own SSL certificate and the volume directory of SeaDoc data is `/opt/seadoc-data`:

* create a folder `/opt/seadoc-data/ssl`, and put your certificate and private key under the ssl directory.
* Assume your site name is `sdoc-server.example.com`, then your certificate must have the name `sdoc-server.example.com.crt`, and the private key must have the name `sdoc-server.example.com.key`.

## Seafile directory structure

### `/shared`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files and upload directory outside. This allows you to rebuild containers easily without losing important information.

* /shared/sdoc-server: This is the directory for SeaDoc server configuration and data.
* /shared/nginx-logs: This is the directory for nginx logs.
* /shared/ssl: This is directory for certificate, which does not exist by default.

## Upgrading SeaDoc server

To upgrade to latest version of SeaDoc server:

```sh
docker pull seafileltd/sdoc-server:latest
docker-compose down
docker-compose up -d

```

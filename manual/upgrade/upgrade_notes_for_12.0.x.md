# Upgrade notes for 12.0 (In progress)

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 12.0 has four major changes:

* a new redesigned Web UI
* easy deployment of SeaDoc
* a new wiki module (still in beta, disabled by default)
* a new lightweight and fast search engine, SeaSearch. SeaSearch is optional, you can still use ElasticSearch.

### ElasticSearch change (pro edition only)

Elasticsearch version is not changed in Seafile version 11.0

## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

For Ubuntu 20.04/24.04

```sh
sudo pip3 install future==1.0.* mysqlclient==2.2.* pillow==10.4.* sqlalchemy==2.0.* captcha==0.6.* django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 python-ldap==3.4.*
```

## Upgrade to 12.0.x

### 1) Stop Seafile-11.0.x server

### 2) Start from Seafile 12.0.x, run the script

```sh
upgrade/upgrade_11.0_12.0.sh
```

### 3) Start Seafile-12.0.x server

## Upgrade SeaDoc from 0.8 to 1.0 (In progress)

SeaDoc 1.0 is based on Seafile 12.0

### Change the DB_NAME

From version 1.0, SeaDoc is based on the seahub_db database in Seafile MySQL and is not compatible with the sdoc_db database. You need to change the DB_NAME to seahub_db manually.

conf/sdoc_server_config.json

```json
"database": "seahub_db"
```

### Deploy SeaDoc 1.0

SeaDoc has two deployment methods:

* Deploy SeaDoc on a new host.
* SeaDoc and Seafile docker are deployed on the same host.

### Deploy SeaDoc on a new host

#### Download and modify SeaDoc .env

Download [.env](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/.env) and [docker-compose.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/standalone/docker-compose.yml), then modify .env file.

The following fields merit particular attention:

* MySQL host (SEAFILE_MYSQL_DB_HOST)
* MySQL user (SEAFILE_MYSQL_DB_USER)
* MySQL password (SEAFILE_MYSQL_DB_PASSWD)
* The volume directory of SeaDoc data (SEADOC_VOLUMES)
* SeaDoc service URL (SDOC_SERVER_HOSTNAME)
* Seafile service URL (SEAHUB_SERVICE_URL)

And enable this host's access to Seafile MySQL.

Then follow the section: Start SeaDoc.

### SeaDoc and Seafile 12.0 docker are deployed on the same host

#### Download seadoc.yml and modify Seafile .env

Download [seadoc.yml](https://manual.seafile.com/docker/docker-compose/seadoc/1.0/seadoc.yml) to the Seafile path, then modify Seafile .env file.

```env
COMPOSE_FILE='docker-compose.yml,seadoc.yml'


SEADOC_IMAGE=seafileltd/sdoc-server:latest
SEADOC_VOLUMES=/opt/seadoc-data

SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWD=PASSWORD

SEAHUB_SERVICE_URL=http://seafile.example.com
```

Note: modify the `COMPOSE_FILE` field, and add all other fields.

The following fields merit particular attention:

* MySQL user (SEAFILE_MYSQL_DB_USER)
* MySQL password (SEAFILE_MYSQL_DB_PASSWD)
* The volume directory of SeaDoc data (SEADOC_VOLUMES)
* Seafile service URL (SEAHUB_SERVICE_URL)

### Modify seafile.nginx.conf

Note: If you have installed version 0.8 before, you can skip this step.

Add the following to the `seafile.nginx.conf`:

```
    location /sdoc-server/ {
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
        add_header Access-Control-Allow-Headers "deviceType,token, authorization, content-type";
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
            add_header Access-Control-Allow-Headers "deviceType,token, authorization, content-type";
            return 204;
        }

        proxy_pass         http://sdoc-server:7070/;
        proxy_redirect     off;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host  $server_name;
        proxy_set_header   X-Forwarded-Proto $scheme;

        client_max_body_size 100m;
    }

    location /socket.io {
        proxy_pass http://sdoc-server:7070;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_redirect off;

        proxy_buffers 8 32k;
        proxy_buffer_size 64k;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
    }
```

And reload nginx

```sh
nginx -s reload
```

Then follow the section: Start SeaDoc.

### Start SeaDoc

Start SeaDoc server with the following command

```sh
docker compose up -d
```

Note: If you have installed version 0.8 before, you can skip the following steps.

Wait for a few minutes for the first time initialization. Open `/opt/seadoc-data/sdoc-server/conf/sdoc_server_config.json`, and record `private_key` for modifying Seafile configuration file.

#### Configure Seafile

Modify seahub_settings.py:

```python
ENABLE_SEADOC = True
SEADOC_PRIVATE_KEY = '***'  # sdoc-server private_key
SEADOC_SERVER_URL = 'https://sdoc-server.example.com'  # sdoc-server service url
# When SeaDoc and Seafile/Seafile docker are deployed on the same host, SEADOC_SERVER_URL should be 'https://seafile.example.com/sdoc-server'
FILE_CONVERTER_SERVER_URL = 'https://sdoc-server.example.com/seadoc-converter'  # converter-server url
# When SeaDoc and Seafile are deployed on the same host, FILE_CONVERTER_SERVER_URL should be LAN address 'http://127.0.0.1:8888'
# When SeaDoc and Seafile docker are deployed on the same host, FILE_CONVERTER_SERVER_URL should be http://sdoc-server:8888
```

Restart Seafile server

```sh
./seahub.sh restart
```

Now you can use SeaDoc!

## FAQ

We have documented common issues encountered by users when upgrading to version 12.0 in our FAQ <https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/?tid=0000&vid=0000>.

If you encounter any issue, please give it a check.

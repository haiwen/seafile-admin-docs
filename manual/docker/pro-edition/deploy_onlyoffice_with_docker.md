# Deploy OnlyOffice with Docker

## Add OnlyOffice to docker-compose.yml

The following section needs to be added to docker-compose.yml in the services section

```yml
services:
  ...

  oods:
    image: onlyoffice/documentserver:latest
    container_name: seafile-oods
    volumes:
      - /opt/seafile-oods/DocumentServer/logs:/var/log/onlyoffice
      - /opt/seafile-oods/DocumentServer/data:/var/www/onlyoffice/Data
      - /opt/seafile-oods/DocumentServer/lib:/var/lib/onlyoffice
      - /opt/seafile-oods/DocumentServer/local-production-linux.json:/etc/onlyoffice/documentserver/local-production-linux.json
    networks:
      - seafile-net
    environment:
      - JWT_ENABLED=true
      - JWT_SECRET=your-secret-string
```

## Initialize OnlyOffice local configuration file

```shell
mkdir -p /opt/seafile-oods/DocumentServer/
vim /opt/seafile-oods/DocumentServer/local-production-linux.json
```

```json
{
  "services": {
    "CoAuthoring": {
      "autoAssembly": {
        "enable": true,
        "interval": "5m"
      }
    }
  },
  "FileConverter": {
    "converter": {
      "downloadAttemptMaxCount": 1
    }
  }
}
```

## Add OnlyOffice to nginx conf

Add this to seafile.nginx.conf

```
# Required for only office document server
map $http_x_forwarded_proto $the_scheme {
    default $http_x_forwarded_proto;
    "" $scheme;
}
map $http_x_forwarded_host $the_host {
    default $http_x_forwarded_host;
    "" $host;
}
map $http_upgrade $proxy_connection {
    default upgrade;
    "" close;
}
server {
    listen 80;
    ...
}

server {
    listen 443 ssl;
    ...

    location /onlyofficeds/ {
        proxy_pass http://oods/;
        proxy_http_version 1.1;
        client_max_body_size 100M;
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $proxy_connection;
        proxy_set_header X-Forwarded-Host $the_host/onlyofficeds;
        proxy_set_header X-Forwarded-Proto $the_scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## Modify seahub_settings.py

Add this to seahub_settings.py

```python
# OnlyOffice
ENABLE_ONLYOFFICE = True
VERIFY_ONLYOFFICE_CERTIFICATE = True
ONLYOFFICE_APIJS_URL = 'http://<your-seafile-doamin>/onlyofficeds/web-apps/apps/api/documents/api.js'
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt',
'fodt', 'odp', 'fodp', 'ods', 'fods')
ONLYOFFICE_EDIT_FILE_EXTENSION = ('docx', 'pptx', 'xlsx')
ONLYOFFICE_JWT_SECRET = 'your-secret-string'
```

## Restart docker container

```shell
docker compose down
docker compose up -d 
```

Wait some minutes until OnlyOffice finished initializing.

Now OnlyOffice can be used.

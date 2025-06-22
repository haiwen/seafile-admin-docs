# Thumbnail Server Overview

Since Seafile 13.0, a new component thumbnail server is added. Thumbnail server can create thumbnails for images, videos, PDFs and other file types. Thumbnail server uses a task queue based architecture, it can better handle workloads than thumbnail generating inside Seahub component. 

## How to configure and run

First download `thumbnail-server.yml` to Seafile directory:

```sh
wget https://manual.seafile.com/13.0/repo/docker/thumbnail-server.yml
```

Modify `.env`, and insert `thumbnail-server.yml` into `COMPOSE_FILE`:

```env
COMPOSE_FILE='seafile-server.yml,caddy.yml,thumbnail-server.yml'
```

Finally, You can run thumbnail server with the following command:

```sh
docker compose down
docker compose up -d
```

## Thumbnail Server in Seafile cluster

There is no additional features for thumbnail server in the Pro Edition. It works the same as in community edition.

If you enable [clustering](../setup_binary/cluster_deployment.md), You need to deploy thumbnail server on one of the servers, or a separate server. The load balancer should forward websockets requests to this node.

Download `.env` and `thumbnail-server.yml` to thumbnail server directory:

```sh
wget https://manual.seafile.com/13.0/repo/docker/thumbnail-server/thumbnail-server.yml
wget -O .env https://manual.seafile.com/13.0/repo/docker/thumbnail-server/env
```

Then modify the `.env` file according to your environment. The following fields are needed to be modified:

| variable               | description                                                                                                   |  
|------------------------|---------------------------------------------------------------------------------------------------------------|  
| `SEAFILE_VOLUME`        | The volume directory of thumbnail server data                                                                            |  
| `SEAFILE_MYSQL_DB_HOST`| Seafile MySQL host                                                                                            |  
| `SEAFILE_MYSQL_DB_USER`| Seafile MySQL user, default is `seafile`                                                                       |  
| `SEAFILE_MYSQL_DB_PASSWORD`| Seafile MySQL password                                                                                    |  
| `TIME_ZONE`            | Time zone                                                                                                     |  
| `JWT_PRIVATE_KEY`      | JWT key, the same as the config in Seafile `.env` file                                                         |  
| `INNER_SEAHUB_SERVICE_URL`| Inner Seafile url                                                                                            |  

NOTE: The thumbnail server needs to access Seafile storage and read seafile.conf.

If you use local storage, you need to mount the `/opt/seafile-data` directory of the Seafile node to the thumbnail node. And set `SEAFILE_VOLUME` to the mounted directory.

If you use object storage, you need to copy the `seafile.conf` of the Seafile node to the `/opt/seafile-data/seafile/conf` directory of the thumbnail node.

Then you can run thumbnail server with the following command:

```sh
docker compose up -d
```

You need to configure load balancer according to the following forwarding rules:

1. Forward `/thumbnail` requests to thumbnail server via http protocol.

Here is a configuration that uses haproxy to support thumbnail server. Haproxy version needs to be >= 2.0.
You should use similar configurations for other load balancers.

```
#/etc/haproxy/haproxy.cfg

# Other existing haproxy configurations
......

frontend seafile
    bind 0.0.0.0:80
    mode http
    option httplog
    option dontlognull
    option forwardfor
    acl thumbnail_request url_sub -i /thumbnail/
    use_backend thumbnail_backend if thumbnail_request
    default_backend backup_nodes

backend backup_nodes
    cookie SERVERID insert indirect nocache
    server seafileserver01 192.168.0.2:80

backend thumbnail_backend
    option forwardfor
    server thumbnail 192.168.0.9:80

```

## Thumbnail server directory structure

`/opt/seafile-data`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files outside. This allows you to rebuild containers easily without losing important information.

* /opt/seafile-data/conf: This is the directory for config files.
* /opt/seafile-data/logs: This is the directory for logs.
* /opt/seafile-data/seafile-data: This is the directory for seafile storage.
* /opt/seafile-data/seahub-data/thumbnail: This is the directory for thumbnail files.

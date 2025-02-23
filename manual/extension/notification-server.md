# Notification Server Overview

Currently, the status updates of files and libraries on the client and web interface are based on polling the server. The latest status cannot be reflected in real time on the client due to polling delays. The client needs to periodically refresh the library modification, file locking, subdirectory permissions and other information, which causes additional performance overhead to the server.

When a directory is opened on the web interface, the lock status of the file cannot be updated in real time, and the page needs to be refreshed.

The notification server uses websocket protocol and maintains a two-way communication connection with the client or the web interface. When the above changes occur, seaf-server will notify the notification server of the changes. Then the notification server can notify the client or the web interface in real time. This not only improves the real-time performance, but also reduces the performance overhead of the server.

## Supported update reminder types

1. The library has been updated.
2. File lock status changes under the library.
3. Directory permission changes under the library.

## How to configure and run

Since Seafile 12.0, we use a separate Docker image to deploy the notification server. First download `notification-server.yml` to Seafile directory:

```sh
wget https://manual.seafile.com/13.0/repo/docker/notification-server.yml
```

Modify `.env`, and insert `notification-server.yml` into `COMPOSE_FILE`:

```env
COMPOSE_FILE='seafile-server.yml,caddy.yml,notification-server.yml'
```

And you need to add the following configurations under seafile.conf:

```conf
[notification]
enabled = true
# the ip of notification server. (default is `notification-server` in Docker)
host = notification-server
# the port of notification server
port = 8083
```

You can run notification server with the following command:

```sh
docker compose down
docker compose up -d
```

## Checking notification server status

When the notification server is working, you can access `http://127.0.0.1:8083/ping` from your browser, which will answer `{"ret": "pong"}`. If you have a proxy configured, you can access `https://{server}/notification/ping` from your browser instead.

## Compatible client

1. Seadrive 3.0.1 or later.
2. Seafile client 8.0.11 or later.

If the client works with notification server, there should be a log message in seafile.log or seadrive.log.

```
Notification server is enabled on the remote server xxxx
```

## Notification Server in Seafile cluster

There is no additional features for notification server in the Pro Edition. It works the same as in community edition.

If you enable [clustering](../setup_binary/cluster_deployment.md), You need to deploy notification server on one of the servers, or a separate server. The load balancer should forward websockets requests to this node.

Download `.env` and `notification-server.yml` to notification server directory:

```sh
wget https://manual.seafile.com/13.0/repo/docker/notification-server/standalone/notification-server.yml
wget -O .env https://manual.seafile.com/13.0/repo/docker/notification-server/standalone/env
```

Then modify the `.env` file according to your environment. The following fields are needed to be modified:

| variable               | description                                                                                                   |  
|------------------------|---------------------------------------------------------------------------------------------------------------|  
| `NOTIFICATION_SERVER_VOLUME`        | The volume directory of notification server data                                                                            |  
| `SEAFILE_MYSQL_DB_HOST`| Seafile MySQL host                                                                                            |  
| `SEAFILE_MYSQL_DB_USER`| Seafile MySQL user, default is `seafile`                                                                       |  
| `SEAFILE_MYSQL_DB_PASSWORD`| Seafile MySQL password                                                                                    |  
| `TIME_ZONE`            | Time zone                                                                                                     |  
| `JWT_PRIVATE_KEY`      | JWT key, the same as the config in Seafile `.env` file                                                         |  
| `SEAFILE_SERVER_HOSTNAME`| Seafile host name                                                                                           |  
| `SEAFILE_SERVER_PROTOCOL`| http or https                                                                                               |  

You can run notification server with the following command:

```sh
docker compose up -d
```

And you need to add the following configurations under `seafile.conf` and restart Seafile server:

```conf
[notification]
enabled = true
# the ip of notification server.
host = 192.168.0.83
# the port of notification server
port = 8083
```

You need to configure load balancer according to the following forwarding rules:

1. Forward `/notification/ping` requests to notification server via http protocol.
2. Forward websockets requests with URL prefix `/notification` to notification server.

Here is a configuration that uses haproxy to support notification server. Haproxy version needs to be >= 2.0.
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
    acl notif_ping_request  url_sub -i /notification/ping
    acl ws_requests  url -i /notification
    acl hdr_connection_upgrade hdr(Connection)  -i upgrade
    acl hdr_upgrade_websocket  hdr(Upgrade)     -i websocket
    use_backend ws_backend if hdr_connection_upgrade hdr_upgrade_websocket
    use_backend notif_ping_backend if notif_ping_request
    use_backend ws_backend if ws_requests
    default_backend backup_nodes

backend backup_nodes
    cookie SERVERID insert indirect nocache
    server seafileserver01 192.168.0.137:80

backend notif_ping_backend
    option forwardfor
    server ws 192.168.0.137:8083

backend ws_backend
    option forwardfor # This sets X-Forwarded-For
    server ws 192.168.0.137:8083
```

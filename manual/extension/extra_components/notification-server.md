# Notification Server Overview

Currently, the status updates of files and libraries on the client and web interface are based on polling the server. The latest status cannot be reflected in real time on the client due to polling delays. The client needs to periodically refresh the library modification, file locking, subdirectory permissions and other information, which causes additional performance overhead to the server.

When a directory is opened on the web interface, the lock status of the file cannot be updated in real time, and the page needs to be refreshed.

The notification server uses websocket protocol and maintains a two-way communication connection with the client or the web interface. When the above changes occur, seaf-server will notify the notification server of the changes. Then the notification server can notify the client or the web interface in real time. This not only improves the real-time performance, but also reduces the performance overhead of the server.

Note, the notification server cannot work if you config Seafile server with SQLite database.

## Supported update reminder types

1. The library has been updated.
2. File lock status changes under the library.
3. Directory permission changes under the library.

## How to configure and run

Since seafile-10.0.0, you can configure a notification server to send real-time notifications to clients. In order to run the notification server, you need to add the following configurations under seafile.conf：

```
# jwt_private_key are required.You should generate it manually.
[notification]
enabled = true
# the ip of notification server. (Do not modify the host when using Nginx or Apache, as Nginx or Apache will proxy the requests to this address)
host = 127.0.0.1
# the port of notification server
port = 8083
# the log level of notification server
# You can set log_level to debug to print messages sent to clients.
log_level = info
# jwt_private_key is used to generate jwt token and authenticate seafile server
jwt_private_key = M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F
```

You can generate jwt_private_key with the following command：

```
# generate jwt_private_key
openssl rand -base64 32

```

We generally recommend deploying notification server behind nginx, the notification server can be supported by adding the following nginx configuration:

```
map $http_upgrade $connection_upgrade {
default upgrade;
'' close;
}

server {
    location /notification/ping {
        proxy_pass http://127.0.0.1:8083/ping;
        access_log      /var/log/nginx/notif.access.log;
        error_log       /var/log/nginx/notif.error.log;
    }

    location /notification {
        proxy_pass http://127.0.0.1:8083/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        access_log      /var/log/nginx/notif.access.log;
        error_log       /var/log/nginx/notif.error.log;
    }
}

```

Or add the configuration for Apache:

```
    ProxyPass /notification/ping  http://127.0.0.1:8083/ping/
    ProxyPassReverse /notification/ping  http://127.0.0.1:8083/ping/

    ProxyPass /notification  ws://127.0.0.1:8083/
    ProxyPassReverse /notification ws://127.0.0.1:8083/
```

NOTE: according to [apache ProxyPass document](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html#proxypass)

```
The configured ProxyPass and ProxyPassMatch rules are checked in the order of configuration. The first rule that matches wins.
So usually you should sort conflicting ProxyPass rules starting with the longest URLs first.
Otherwise, later rules for longer URLS will be hidden by any earlier rule which uses a leading substring of the URL. Note that there is some relation with worker sharing.
```

the final configuration for Apache should be like:

```
    #
    # notification server
    #
    ProxyPass /notification/ping  http://127.0.0.1:8083/ping/
    ProxyPassReverse /notification/ping  http://127.0.0.1:8083/ping/

    ProxyPass /notification  ws://127.0.0.1:8083/
    ProxyPassReverse /notification ws://127.0.0.1:8083/

    #
    # seafile fileserver
    #
    ProxyPass /seafhttp http://127.0.0.1:8082
    ProxyPassReverse /seafhttp http://127.0.0.1:8082
    RewriteRule ^/seafhttp - [QSA,L]

    #
    # seahub
    #
    SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8000/
    ProxyPassReverse / http://127.0.0.1:8000/
```

After that, you can run notification server with the following command:

```
./seafile.sh restart

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

If you enable [clustering](../../setup_binary/pro/cluster/deploy_in_a_cluster.md), You need to deploy notification server on one of the servers, or a separate server. The load balancer should forward websockets requests to this node.

On each Seafile frontend node, the notification server configuration should be the same as in community edition:

```
[notification]
enabled = true
# the ip of notification server.
host = 192.168.1.134
# the port of notification server
port = 8083
# the log level of notification server
log_level = info
# jwt_private_key is used to generate jwt token and authenticate seafile server
jwt_private_key = M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F
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

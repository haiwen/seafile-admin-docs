# Notification Server Overview

In Seafile Pro edition, the notification server is same as [community edition notification server](../deploy/notification-server.md).

For [clustering](./deploy_in_a_cluster.md), You need to deploy notification server on one of the servers, and the nginx of other front-end nodes should forward websockets requests to this node. The notification server configuration corresponding to each node of the cluster is as follows.

The notification server configuration of the cluster nodes should be the same:

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

The nginx or Apache configuration of the cluster nodes should be the same.

We generally recommend deploying notification server behind nginx, the notification server can be supported by adding the following nginx configuration:

```
map $http_upgrade $connection_upgrade {
default upgrade;
'' close;
}

server {
    location /notification/ping {
        proxy_pass http://192.168.1.134:8083/ping;
        access_log      /var/log/nginx/notif.access.log;
        error_log       /var/log/nginx/notif.error.log;
    }

    location /notification {
        proxy_pass http://192.168.1.134:8083/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        access_log      /var/log/nginx/notif.access.log;
        error_log       /var/log/nginx/notif.error.log;
    }
}

```

Or add the configuration for Apache:

```
    ProxyPass /notification/ping  http://192.168.1.134:8083/ping/
    ProxyPassReverse /notification/ping  http://192.168.1.134:8083/ping/

    ProxyPass /notification  ws://192.168.1.134:8083/
    ProxyPassReverse /notification ws://192.168.1.134:8083/
```

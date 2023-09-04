# Notification Server in Seafile cluster

In Seafile Pro edition, the notification server is the same as [community edition notification server](../deploy/notification-server.md).

If you enable [clustering](./deploy_in_a_cluster.md), You need to deploy notification server on one of the servers. The load balance (haproxy) should forward websockets requests to this node. The notification server configuration corresponding to each node of the cluster is as follows.

The notification server configuration should be the same as in community edition:

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

We generally recommend deploying notification server behind haproxy, and haproxy version needs to be >= 2.0.
The notification server can be supported by adding the following configuration in `/etc/haproxy/haproxy.cfg`:

```
global
    log 127.0.0.1 local0 debug
    maxconn 4096
    user haproxy
    group haproxy


defaults
    log global
    mode http
    retries 3
    maxconn 2000
    timeout connect 10000
    timeout client 300000
    timeout server 300000
    option httplog
    option  http-server-close
    option  dontlognull
    option  redispatch
    option  contstats
    retries 3
    backlog 10000
    timeout client          25s
    timeout connect          5s
    timeout server          25s
    timeout tunnel        15m
    timeout http-keep-alive  1s
    timeout http-request    15s
    timeout queue           30s
    timeout tarpit          60s
    default-server inter 3s rise 2 fall 3
    option forwardfor

frontend seafile
    bind 0.0.0.0:80
    mode http
    option httplog
    option dontlognull
    option forwardfor
    acl notif_ping_request  url_sub -i /notification/ping
    acl ws_requests  url_sub -i /notification
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
    http-request set-path /ping
    server ws 192.168.0.137:8083

backend ws_backend
    option forwardfor # This sets X-Forwarded-For
    http-request set-path /
    server ws 192.168.0.137:8083
```

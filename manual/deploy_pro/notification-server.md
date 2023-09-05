# Notification Server in Seafile cluster

In Seafile Pro edition, the notification server is the same as [community edition notification server](../deploy/notification-server.md).

If you enable [clustering](./deploy_in_a_cluster.md), You need to deploy notification server on one of the servers. The load balance should forward websockets requests to this node. The notification server configuration corresponding to each node of the cluster is as follows.

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

You need to configure load balancing according to the following forwarding rules:

1. Forward `/notification/ping` requests to the ping interface of the notification server.
2. Forward websockets requests for `/notification` to the notification server.

Here is a configuration that uses haproxy to support notification server, and haproxy version needs to be >= 2.0.

```
#/etc/haproxy/haproxy.cfg

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
    server ws 192.168.0.137:8083

backend ws_backend
    option forwardfor # This sets X-Forwarded-For
    server ws 192.168.0.137:8083
```

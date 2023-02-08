# Notification Server Overview

Currently, the status updates of files and libraries on the client and web interface are based on polling the server. The latest status cannot be reflected in real time on the client due to polling delays. The client needs to periodically refresh the library modification, file locking, subdirectory permissions and other information, which causes additional performance overhead to the server.

When a directory is opened on the web interface, the lock status of the file cannot be updated in real time, and the page needs to be refreshed.

The notification server uses websocket protocol and maintains a two-way communication connection with the client or the web interface. When the above changes occur, seaf-server will notify the notification server of the changes. Then the notification server can notify the client or the web interface in real time. This not only improves the real-time performance, but also reduces the performance overhead of the server.

## Supported update reminder types

1. The library has been updated.
2. File lock status changes under the library.
3. Directory permission changes under the library.

## How to configure and run

Since seafile-10.0.0, you can configure a notification server to send real-time notifications to clients. In order to run the notification server, you need to add the following configurations under seafile.conf：

```
# seafile_auth_token and jwt_private_key are required.You should generate them manually.
[notification]
enabled = true
# the ip of notification server
host = 127.0.0.1
# the port of notification server
port = 8083
# the log level of notification server
log_level = info
# seafile_auth_token is used to authenticate seafile server
seafile_auth_token = xP7GGgGPVCQu8r0xNJ+k4Q==
# jwt_private_key is used to generate jwt token
jwt_private_key = M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F
```

You can generate seafile_auth_token and jwt_private_key with the following command：

```
# generate seafile_auth_token
openssl rand -base64 16

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
    location /notification {
        proxy_pass http://127.0.0.1:8083/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        access_log      /var/log/nginx/notif.access.log;
        error_log       /var/log/nginx/notif.error.log;
    }
}

```

After that, you can run notification server with the following command:

```
./notif_server.sh start

```

## Compatible client

1. Seadrive 3.0.1 or later.
2. Seafile client 8.0.11 or later.



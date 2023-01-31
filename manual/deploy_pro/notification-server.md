# Details about Notification Server

Currently, the status updates of files and libraries on the client and web interface are based on regular queries, and there is a certain delay, so the latest status cannot be reflected in real time. The client needs to periodically refresh the library modification, file locking, subdirectory permissions and other information, causing additional performance overhead to the server.

When a directory is opened on the web interface, the lock status of the file cannot be updated in real time, and the page needs to be refreshed.

The notification server is based on the websocket protocol and maintains a two-way communication connection with the client and the web interface. When the above changes occur, seaf-server will notify the notification server of the changes, and then the notification server can notify the client and the web interface in real time. This not only improves the real-time performance, but also reduces the performance overhead of the server.

## Supported update reminder types

1. The library has been updated.
2. File lock status changes under the library.
3. Directory permission changes under the library.

## How to configure and run

Since seafile-10.0.0, you can configure a notification server to send real-time notifications to clients. In order to run the notification server, you need to add the following configurations under seafile.conf and notification.conf：

```
## seafile.conf
# notification_token and private_key are required.You should generate them manually.
[notification]
# notification_url is the url of notification server
notification_url = 127.0.0.1:8083
notification_token = xP7GGgGPVCQu8r0xNJ+k4Q==
# private_key is used to generate jwt token
private_key = M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F

## notification.conf
# private_key and notification_token are required.You should generate them manually.
# private_key and notification_token should be the same as configured in seafile.conf.
[general]
# the ip of notification server
host = 127.0.0.1
# the port of notification server
port = 8083
# the log level of notification server
log_level = info
# notification_token is used to simply authenticate seafile server
notification_token = xP7GGgGPVCQu8r0xNJ+k4Q==
# private_key is used to check whether the request jwt token is valid
private_key = "M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F

```

You can generate notification_token and private_key with the following command：

```
# generate notification_token
openssl rand -base64 16

# generate private_key
python
>>> from django.core.management import utils
>>> utils.get_random_secret_key()

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



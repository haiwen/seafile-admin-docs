# Seafile Docker autostart

You can use one of the following methods to start Seafile container on system bootup.

## Method 1

1. Add docker-compose.service

    `vim /etc/systemd/system/docker-compose.service`

    ```
    [Unit]
    Description=Docker Compose Application Service
    Requires=docker.service
    After=docker.service

    [Service]
    Type=forking
    RemainAfterExit=yes
    WorkingDirectory=/opt/   
    ExecStart=/usr/bin/docker compose up -d
    ExecStop=/usr/bin/docker compose down
    TimeoutStartSec=0

    [Install]
    WantedBy=multi-user.target
    ```

    Note: `WorkingDirectory` is the absolute path to the docker-compose.yml file directory.

2. Set the docker-compose.service file to 644 permissions

    ```
    chmod 644 /etc/systemd/system/docker-compose.service
    ```

3. Load autostart configuration

    ```
    systemctl daemon-reload
    systemctl enable docker-compose.service
    ```

## Method 2

Add configuration `restart: unless-stopped` for each container in [components of Seafile docker](./overview.md). Take `seafile-server.yml` for example

```
services:
  db:
    image: mariadb:10.11
    container_name: seafile-mysql-1
    restart: unless-stopped

  memcached:
    image: memcached:1.6.18
    container_name: seafile-memcached
    restart: unless-stopped

  elasticsearch:
    image: elasticsearch:8.6.2
    container_name: seafile-elasticsearch
    restart: unless-stopped

  seafile:
    image: docker.seadrive.org/seafileltd/seafile-pro-mc:12.0-latest
    container_name: seafile
    restart: unless-stopped
```

Note: Add `restart: unless-stopped`, and the Seafile container will automatically start when Docker starts. If the Seafile container does not exist (execute docker compose down), the container will not start automatically.

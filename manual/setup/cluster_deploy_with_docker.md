# Seafile Docker Cluster Deployment

Seafile Docker cluster deployment requires "sticky session" settings in the load balancer. Otherwise sometimes folder download on the web UI can't work properly. Read the [Load Balancer Setting](../setup_binary/deploy_in_a_cluster.md#load-balancer-setting) for details.

## Environment

!!! note "Prerequisites"

    - We assume you have already deployed ***memcache***, ***MariaDB***, ***ElasticSearch*** in separate machines and use ***S3*** like object storage. 

    - Usually, each node of Seafile Cluster should have at least **2 cores** and **2G memory**. If the above services are deployed together with a node in the Seafile cluster, we recommend that you prepare **4 cores** and **4G memory** for the node (especially if ElasticSearch is also deployed on the node)

System: Ubuntu 24.04

Seafile Server: 2 frontend nodes, 1 backend node

## Deploy Seafile service

### Deploy the first Seafile frontend node

1. Create the mount directory

    ```sh
    mkdir -p /opt/seafile/shared
    ```

2. Pulling Seafile image

    !!! tip
        Since v12.0, Seafile PE versions are hosted on DockerHub and does not require username and password to download.

    ```bash
    docker pull seafileltd/seafile-pro-mc:12.0-latest
    ```

3. Download the `seafile-server.yml` and `.env`

    ```sh
    wget -O .env https://manual.seafile.com/12.0/docker/cluster/env
    wget https://manual.seafile.com/12.0/docker/cluster/seafile-server.yml
    ```

4. Modify the [variables](../config/env.md) in `.env` (especially the terms like `<...>`). 

    !!! tip
        If you have already deployed S3 storage backend and plan to apply it to Seafile cluster, you can modify the variables in `.env` to [set them synchronously during initialization](../config/env.md#s3-storage-backend-configurations-only-valid-in-pro-edition-at-deploying-first-time).


5. Start the Seafile docker

    ```sh
    docker compose up -d
    ```

    !!! success "Cluster init mode"
    
        Because CLUSTER_INIT_MODE is true in the `.env` file, Seafile docker will be started in init mode and generate configuration files. As the results, you can see the following lines if you trace the Seafile container (i.e., `docker logs seafile`):

        ```log
        ---------------------------------
        This is your configuration
        ---------------------------------
        
            server name:            seafile
            server ip/domain:       seafile.example.com
        
            seafile data dir:       /opt/seafile/seafile-data
            fileserver port:        8082
        
            database:               create new
            ccnet database:         ccnet_db
            seafile database:       seafile_db
            seahub database:        seahub_db
            database user:          seafile
        
        
        Generating seafile configuration ...
        
        done
        Generating seahub configuration ...
        
        
        -----------------------------------------------------------------
        Your seafile server configuration has been finished successfully.
        -----------------------------------------------------------------
        
        
        [2024-11-21 02:22:37] Updating version stamp
        Start init
        
        Init success
        
        ```

6. In initialization mode, the service will not be started. During this time you can check the generated configuration files (e.g., MySQL, Memcached, Elasticsearch) in configuration files:

    - [seafevents.conf](../config/seafevents-conf.md)
    - [seafile.conf](../config/seafile-conf.md)
    - [seahub_settings.py](../config/seahub_settings_py.md)

7. After initailizing the cluster, the following fields can be removed in `.env`
    - `CLUSTER_INIT_MODE`, must be removed from .env file
    - `CLUSTER_INIT_MEMCACHED_HOST`
    - `CLUSTER_INIT_ES_HOST`
    - `CLUSTER_INIT_ES_PORT`
    - `INIT_S3_STORAGE_BACKEND_CONFIG`
    - `INIT_S3_COMMIT_BUCKET`
    - `INIT_S3_FS_BUCKET`
    - `INIT_S3_BLOCK_BUCKET`
    - `INIT_S3_KEY_ID`
    - `INIT_S3_SECRET_KEY`

    !!! tip
        We recommend that you check that the relevant configuration files are correct and copy the `SEAFILE_VOLUME` directory before the service is officially started, because only the configuration files are generated after initialization. You can directly migrate the entire copied `SEAFILE_VOLUME` to other nodes later:

        ```sh
        cp -r /opt/seafile/shared /opt/seafile/shared-bak
        ```

8. Restart the container to start the service in frontend node

    ```sh
    docker compose down
    docker compose up -d
    ```

    !!! success "Frontend node starts successfully"

        After executing the above command, you can trace the logs of container `seafile` (i.e., `docker logs seafile`). You can see the following message if the frontend node starts successfully:

        ```logs
        *** Running /etc/my_init.d/01_create_data_links.sh...
        *** Booting runit daemon...
        *** Runit started as PID 20
        *** Running /scripts/enterpoint.sh...
        2024-11-21 03:02:35 Nginx ready 

        2024-11-21 03:02:35 This is an idle script (infinite loop) to keep container running. 
        ---------------------------------

        Seafile cluster frontend mode

        ---------------------------------


        Starting seafile server, please wait ...
        License file /opt/seafile/seafile-license.txt does not exist, allow at most 3 trial users
        Seafile server started

        Done.

        Starting seahub at port 8000 ...

        Seahub is started

        Done.
        ```

### Deploy the others Seafile frontend nodes

1. Create the mount directory

    ```
    $ mkdir -p /opt/seafile/shared

    ```

2. Pull Seafile image

3. Copy `seafile-server.yml`, `.env `and configuration files from the first frontend node

4. Start the service

    ```sh
    docker compose up -d
    ```

### Deploy seafile backend node

1. Create the mount directory

    ```
    $ mkdir -p /opt/seafile/shared

    ```

2. Pull Seafile image

3. Copy `seafile-server.yml`, `.env` and configuration files from frontend node

    !!! note
        The configuration files from frontend node have to be put in the same path as the frontend node, i.e., `/opt/seafile/shared/seafile/conf/*`

4. Modify `.env`, set `CLUSTER_MODE` to `backend`

5. Start the service in the backend node

    ```sh
    docker compose up -d
    ```

    !!! success "Backend node starts successfully"

        After executing the above command, you can trace the logs of container `seafile` (i.e., `docker logs seafile`). You can see the following message if the backend node starts successfully:

        ```logs
        *** Running /etc/my_init.d/01_create_data_links.sh...
        *** Booting runit daemon...
        *** Runit started as PID 21
        *** Running /scripts/enterpoint.sh...
        2024-11-21 03:11:59 Nginx ready 
        2024-11-21 03:11:59 This is an idle script (infinite loop) to keep container running. 

        ---------------------------------

        Seafile cluster backend mode

        ---------------------------------


        Starting seafile server, please wait ...
        License file /opt/seafile/seafile-license.txt does not exist, allow at most 3 trial users
        Seafile server started

        Done.

        Starting seafile background tasks ...
        Done.
        ```
 
## Deploy load balance (Optional)

Generally speaking, in order to better access the Seafile service, we recommend that you use a load balancing service to access the Seafile cluster and bind your domain name (such as `seafile.cluster.com`) to the load balancing service. Usually, you can use:

- Cloud service provider's load balancing service
- Deploy your own load balancing service, our document will give two of common load balance services:

    - Nginx
    - HAproxy

### Nginx

1. Install Nginx in the host if you would like to deploy load balance service

```sh
sudo apt update
sudo apt install nginx
```

2. Create the configurations file for Seafile cluster

```sh
sudo nano /etc/nginx/sites-available/seafile-cluster
```

and, add the following contents into this file:

```nginx
upstream seafile_cluster {
    server <IP: your frontend node 1>:80;
    server <IP: your frontend node 2>:80;
    ...
}

server {
    listen 80;
    server_name <your domain>;

    location / {
        proxy_pass http://seafile_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        http_502 http_503 http_504;
    }
}
```

3. Link the configurations file to `sites-enabled` directory:

```sh
sudo ln -s /etc/nginx/sites-available/seafile-cluster /etc/nginx/sites-enabled/
```

4. Test and enable configuration

```sh
sudo nginx -t
sudo nginx -s reload
```

### HAproxy and Keepalived services

Execute the following commands on the two Seafile frontend servers:

```
$ apt install haproxy keepalived -y

$ mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

$ cat > /etc/haproxy/haproxy.cfg << 'EOF'
global
    log 127.0.0.1 local1 notice
    maxconn 4096
    user haproxy
    group haproxy

defaults
    log global
    mode http
    retries 3
    timeout connect 10000
    timeout client 300000
    timeout server 36000000

listen seafile 0.0.0.0:80
    mode http
    option httplog
    option dontlognull
    option forwardfor
    cookie SERVERID insert indirect nocache
    server seafile01 Front-End01-IP:8001 check port 11001 cookie seafile01
    server seafile02 Front-End02-IP:8001 check port 11001 cookie seafile02
EOF

```

!!! warning
    Please **correctly** modify the IP address (`Front-End01-IP` and `Front-End02-IP`) of the frontend server in the above configuration file. Other wise it cannot work properly.

**Choose one of the above two servers as the master node, and the other as the slave node.**

Perform the following operations on the master node:

```bash
$ cat > /etc/keepalived/keepalived.conf << 'EOF'
! Configuration File for keepalived

global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node1
    vrrp_mcast_group4 224.0.100.18
}

vrrp_instance VI_1 {
    state MASTER
    interface eno1   # Set to the device name of a valid network interface on the current server, and the virtual IP will be bound to the network interface
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass seafile123
    }
    virtual_ipaddress {
        172.26.154.45/24 dev eno1  # Configure to the correct virtual IP and network interface device name
    }
}
EOF

```

!!! warning
    Please **correctly** configure the virtual IP address and network interface device name in the above file. Other wise it cannot work properly.

Perform the following operations on the standby node:

```bash
$ cat > /etc/keepalived/keepalived.conf << 'EOF'
! Configuration File for keepalived

global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node2
    vrrp_mcast_group4 224.0.100.18
}

vrrp_instance VI_1 {
    state BACKUP
    interface eno1   # Set to the device name of a valid network interface on the current server, and the virtual IP will be bound to the network interface
    virtual_router_id 50
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass seafile123
    }
    virtual_ipaddress {
        172.26.154.45/24 dev eno1   # Configure to the correct virtual IP and network interface device name
    }
}
EOF

```

Finally, run the following commands on the two Seafile frontend servers to start the corresponding services:

```
$ systemctl enable --now haproxy
$ systemctl enable --now keepalived

```

So far, Seafile cluster has been deployed.

## HTTPS

You can engaged HTTPS in your load balance service, as you can use certificates manager (e.g., [Certbot](https://certbot.eff.org)) to acquire and enable HTTPS to your Seafile cluster. You have to modify the relative URLs from the prefix `http://` to `https://` in `seahub_settings.py` and `.env`, after enabling HTTPS.

## (Optional) Deploy SeaDoc server

You can follow [here](../extension/setup_seadoc.md) to deploy SeaDoc server. And then modify `SEADOC_SERVER_URL` in your `.env` file

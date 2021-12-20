# Seafile Docker Cluster Deployment

## Environment

System: Ubuntu 20.04

docker-compose: 1.25.0

Seafile Server: 2 frontend node, 1 backend node

Mariadb, Memcached, Elasticsearch are all deployed on the backend node.

## Deploy Mariadb, Memcached and Elasticsearch

Install docker-compose on the backend node

```
$ apt update && apt install docker-compose -y

```

### MariaDB

Create the mount directory

```
$ mkdir -p /opt/seafile-mysql/mysql-data

```

Create the docker-compose.yml file

```
$ cd /opt/seafile-mysql
$ vim docker-compose.yml

```

```
version: '2.0'
services:
  db:
    image: mariadb:10.5
    container_name: seafile-mysql
    ports:
      - 172.26.6.23:3306:3306  # Change '172.26.6.23' to the IP of your backend node
    volumes:
      - /opt/seafile-mysql/mysql-data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=PASSWORD  # Set your MySQL root user's password
      - MYSQL_LOG_CONSOLE=true

```

Start MariaDB

```
$ cd /opt/seafile-mysql
$ docker-compose up -d

```

Create the three databases ccnet_db, seafile_db, and seahub_db required by Seafile on MariaDB, and authorize the \`seafile\` user to be able to access these three databases:

```
$ mysql -h{your backend node IP} -uroot -pPASSWORD

mysql>
create user 'seafile'@'%' identified by 'PASSWORD';

create database `ccnet_db` character set = 'utf8';
create database `seafile_db` character set = 'utf8';
create database `seahub_db` character set = 'utf8';

GRANT ALL PRIVILEGES ON `ccnet_db`.* to 'seafile'@'%';
GRANT ALL PRIVILEGES ON `seafile_db`.* to 'seafile'@'%';
GRANT ALL PRIVILEGES ON `seahub_db`.* to 'seafile'@'%';

```

You also need to create a table in \`seahub_db\`

```none
mysql>
use seahub_db;
CREATE TABLE `avatar_uploaded` (
  `filename` text NOT NULL,
  `filename_md5` char(32) NOT NULL,
  `data` mediumtext NOT NULL,
  `size` int(11) NOT NULL,
  `mtime` datetime NOT NULL,
  PRIMARY KEY (`filename_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

```

After the databases are created, the tables needed by seafile need to be imported into the database: [ccnet_db](SQL/ccnet.sql), [seafile_db](SQL/seafile.sql), [seahub_db](SQL/seahub.sql).

### Memcached

Create the mount directory

```
$ mkdir -p /opt/seafile-memcached

```

Create the docker-compose.yml file

```
$ cd /opt/seafile-memcached
$ vim docker-compose.yml

```

```
version: '2.0'
services:
  memcached:
    image: memcached:1.5.6
    container_name: seafile-memcached
    entrypoint: memcached -m 256
    ports:
      - 172.26.6.23:11211:11211  # Change '172.26.6.23' to the IP of your backend node

```

Start memcached

```
$ cd /opt/seafile-memcached
$ docker-compose up -d

```

Test if can connect to memcached

```
$ telnet {your backend node IP} 11211

```

### Elasticsearch

Create the mount directory

```
$ mkdir -p /opt/seafile-elasticsearch/data

```

chmod 777 -R /opt/seafile-elasticsearch/data

Create the docker-compose.yml file

```
$ cd /opt/seafile-elasticsearch
$ vim docker-compose.yml

```

```
version: '2.0'
services:
  elasticsearch:
    image: elasticsearch:6.8.20
    container_name: seafile-elasticsearch
    ports:
      - 172.26.6.23:9200:9200  # Change '172.26.6.23' to the IP of your backend node
    volumes:
      - /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data
    environment:
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - ES_JAVA_OPTS=-Xms1g -Xmx1g

```

**Among them, ES_JAVA_OPTS=-Xms1g -Xmx1g is to set the memory used by elasticsearch, which is set according to the memory size of your server.**

**Note ：**Need to pay attention to the version of elasticsearch, the seafile-pro-9.0.x version must correspond to the 6.8.X version of elasticsearch.

Start memcached

```
$ cd /opt/seafile-elasticsearch
$ docker-compose up -d

```

Test if elasticsearch is started normally

```
$ curl http://{your backend node IP}:9200/_cluster/health?pretty

```

## Deploy Seafile service

### Deploy seafile frontend nodes

Install docker-compose on the backend node

```
$ apt update && apt install docker-compose -y

```

Create the mount directory

```
$ mkdir -p /opt/seafile/shared

```

Create the docker-compose.yml file

```
$ cd /opt/seafile
$ vim docker-compose.yml

```

```
version: '2.0'
services:
  seafile:
    image: docker.seafile.top/seafileltd/seafile-pro-mc:9.0.2
    container_name: seafile
    ports:
      - 80:80
    volumes:
      - /opt/seafile/shared:/shared
    environment:
      - CLUSTER_SERVER=true
      - CLUSTER_MODE=frontend
      - TIME_ZONE=Asia/Shanghai  # Optional, default is UTC. Should be uncomment and set to your local time zone.

```

**Note**: **CLUSTER_SERVER=true** means seafile cluster mode, **CLUSTER_MODE=frontend** means this node is seafile frontend server.

Start the seafile docker container

```
$ cd /opt/seafile
$ docker-compose up -d

```

#### Initial configuration files

1\. Manually generate configuration files

```
$ docker exec -it seafile bash

# cd /scripts  && ./cluster_conf_init.py
# cd /opt/seafile/conf 

```

2\. Modify the mysql configuration options (user, host, password) in configuration files such as ccnet.conf, seafevents.conf, seafile.conf and seahub_settings.py.

3\. Modify the memcached configuration option in seahub_settings.py

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': 'memcached:11211',
    },
...
}
                         |
                         v

CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '{you backend node IP}:11211',
    },
...
}

```

4\. Modify the \[INDEX FILES] configuration option (es_host) in seafevents.conf

```
[INDEX FILES]
es_port = 9200
es_host = {you backend node IP}
external_es_server = true
enabled = true
interval = 10m
...

```

5\. Add some configurations in seahub_settings.py

```python
SERVICE_URL = 'http{s}://{you backend node IP or your sitename}/'
FILE_SERVER_ROOT = 'http{s}://{you backend node IP or your sitename}/seafhttp'
AVATAR_FILE_STORAGE = 'seahub.base.database_storage.DatabaseStorage'

```

6\. Add cluster special configuration in seafile.conf

```
[cluster]
enabled = true
memcached_options = --SERVER={you backend node IP} --POOL-MIN=10 --POOL-MAX=100

```

Start Seafile service

```
$ docker exec -it seafile bash

# cd /opt/seafile/seafile-server-latest
# ./seafile.sh start && ./seahub.sh start

```

When you start it for the first time, seafile will guide you to set up an admin user.

When deploying the second frontend node, you can directly copy all the directories generated by the first frontend node, including the docker-compose.yml file and modified configuration files, and then start the seafile docker container.

### Deploy seafile backend node

Create the mount directory

```
$ mkdir -p /opt/seafile/shared

```

Create the docker-compose.yml file

```
$ cd /opt/seafile
$ vim docker-compose.yml

```

```
version: '2.0'
services:
  seafile:
    image: docker.seafile.top/seafileltd/seafile-pro-mc:9.0.2
    container_name: seafile
    ports:
      - 80:80
    volumes:
      - /opt/seafile/shared:/shared      
    environment:
      - CLUSTER_SERVER=true
      - CLUSTER_MODE=backend
      - TIME_ZONE=Asia/Shanghai  # Optional, default is UTC. Should be uncomment and set to your local time zone.

```

**Note**: **CLUSTER_SERVER=true** means seafile cluster mode, **CLUSTER_MODE=backend** means this node is seafile backend server.

Start the seafile docker container

```
$ cd /opt/seafile
$ docker-compose up -d

```

Copy configuration files of the frontend node, and then start Seafile server of the backend node

```
$ docker exec -it seafile bash

# cd /opt/seafile/seafile-server-latest
# ./seafile.sh start && ./seafile-background-tasks.sh start

```

### Use S3 as backend storage

Modify the seafile.conf file on each node to configure S3 storage.

vim seafile.conf

```
[commit_object_backend]
name = s3
bucket = {your-commit-objects}  # The bucket name can only use lowercase letters, numbers, and dashes
key_id = {your-key-id}
key = {your-secret-key}
use_v4_signature = true
aws_region = eu-central-1  # eu-central-1 for Frankfurt region

[fs_object_backend]
name = s3
bucket = {your-fs-objects}
key_id = {your-key-id}
key = {your-secret-key}
use_v4_signature = true
aws_region = eu-central-1

[block_backend]
name = s3
bucket = {your-block-objects}
key_id = {your-key-id}
key = {your-secret-key}
use_v4_signature = true
aws_region = eu-central-1

```

### Deployment load balance

#### Install HAproxy and Keepalived services

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
    timeout server 300000

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

**Note**: Correctly modify the IP address (Front-End01-IP and Front-End02-IP) of the front-end server in the above configuration file.

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

**Note: **Correctly configure the virtual IP address and network interface device name in the above file.

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

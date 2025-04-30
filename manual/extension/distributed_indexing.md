---
status: new
---


# Distributed indexing

If you use a cluster to deploy Seafile, you can use distributed indexing to realize real-time indexing and improve indexing efficiency. The indexing process is as follows:

![](../images/distributed-indexing.png)

## Install redis and modify configuration files

### 1. Install redis on all frontend nodes

!!! tip 
    If you use redis cloud service, skip this step and modify the configuration files directly

=== "Ubuntu"
    ```
    $ apt install redis-server
    ```
=== "CentOS"
    ```
    $ yum install redis
    ```

### 2. Install python redis third-party package on all frontend nodes

```
$ pip install redis
```

### 3. Modify the `seafevents.conf` on all frontend nodes

Add the following config items

```
[EVENTS PUBLISH]
mq_type=redis   # must be redis
enabled=true

[REDIS]
server=127.0.0.1   # your redis server host
port=6379          # your redis server port
password=xxx       # your redis server password, if not password, do not set this item
```

### 4. Modify the `seafevents.conf` on the backend node

Disable the scheduled indexing task, because the scheduled indexing task and the distributed indexing task conflict.

```
[INDEX FILES]
enabled=true
     |
     V
enabled=false   
```

### 5. Restart Seafile

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /scripts
    ./seafile.sh restart && ./seahub.sh restart
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
    ./seafile.sh restart && ./seahub.sh restart
    ```

## Deploy distributed indexing

First, prepare a seafes master node and several seafes slave nodes, the number of slave nodes depends on your needs. Copy the configuration files in the `conf` directory from the Seafile frontend nodes to `/opt/seafile-data/seafile/conf`. The master node and slave nodes need to read the configuration files to obtain the necessary information.

Then download `.env` and `index-server.yml` to `/opt/seafile` in all nodes. Modify mysql and redis configurations in `.env`.

```env
SEAFILE_MYSQL_DB_HOST=192.168.0.x
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD

REDIS_HOST=192.168.0.x
REDIS_PORT=6379
REDIS_PASSWORD=

CLUSTER_MODE=master
```

!!! note
    CLUSTER_MODE needs to be configured as master on the master node, and needs to be configured as worker on the slave nodes.

Next, create a configuration file `index-master.conf` in the `conf` directory of the master node, e.g.

```conf
[DEFAULT]
mq_type=redis
```

Start master node.

```bash
docker compose up -d
```

Next, create a configuration file `index-slave.conf` in the `conf` directory of all slave nodes, e.g.

```conf
[DEFAULT]
mq_type=redis
index_workers=2
```

Start all slave nodes.

```bash
docker compose up -d
```

## Some commands in distributed indexing

Rebuild search index, execute in the `seafile-server-last` directory (or `/scripts` inner the Seafile-docker container):

```
$ ./pro/pro.py search --clear
$ ./run_index_master.sh python-env index_op.py --mode resotre_all_repo
```

List the number of indexing tasks currently remaining, execute in the `seafile-server-last` directory (or `/scripts` inner the Seafile-docker container):

```
$ ./run_index_master.sh python-env index_op.py --mode show_all_task
```

The above commands need to be run on the Seafile node.

_Note:_ Before you try to deploy file search office documents preview, make sure other parts of your seafile cluster are already working, e.g upload/download files in a web browser. Make sure memory cache is configured as described in ["Deploy in a cluster"](deploy_in_a_cluster.md).

# Enable search and background tasks in a cluster

In the seafile cluster, only one server should run the background tasks, including:

* indexing files for search
* email notification
* office documents converts service (Start from 9.0 version, office converts service is moved to a separate docker component)
* LDAP sync
* virus scan

Let's assume you have three nodes in your cluster: A, B, and C.

* Node A is backend node that run background tasks.
* Node B and C are frontend nodes that serving requests from clients.

![cluster-nodes](../images/cluster-nodes.png)


## Configuring Node A (the backend node)

If you following the steps on settings up a cluster, node B and node C should have already be configed as frontend node. You can copy the configuration of node B as a base for node A. Then do the following steps:
    
Since 9.0, ElasticSearch program is not part of Seafile package. You should deploy ElasticSearch service seperately. Then edit `seafevents.conf`, add the following lines:

```
[INDEX FILES]
enabled = true
es_host = <ip of elastic search service>
es_port = 9200
interval = 10m
highlight = fvh  # this is for improving the search speed
```

Edit **seafile.conf** to enable virus scan according to [virus scan document](../extension/virus_scan.md)


## Configure Other Nodes

On nodes B and C, you need to:

Edit `seafevents.conf`, add the following lines:

```
[INDEX FILES]
enabled = true
es_host = <ip of elastic search service>
es_port = 9200
```

## Start the background node

Type the following commands to start the background node (Note, one additional command `seafile-background-tasks.sh` is needed)

```shell
export CLUSTER_MODE=backend
./seafile.sh start
./seafile-background-tasks.sh start

```

To stop the background node, type:

```shell
./seafile-background-tasks.sh stop
./seafile.sh stop

```

You should also configure Seafile background tasks to start on system bootup. For systemd based OS, you can add `/etc/systemd/system/seafile-background-tasks.service`:

```
[Unit]
Description=Seafile Background Tasks Server
After=network.target seafile.service

[Service]
Type=forking
ExecStart=/opt/seafile/seafile-server-latest/seafile-background-tasks.sh start
ExecStop=/opt/seafile/seafile-server-latest/seafile-background-tasks.sh stop
User=root
Group=root

[Install]
WantedBy=multi-user.target

```

Then enable this task in systemd:

```
systemctl enable seafile-background-tasks.service

```

## The final configuration of the background node

Here is the summary of configurations at the background node that related to clustering setup.

For **seafile.conf**:

```
[cluster]
enabled = true

[memcached]
memcached_options = --SERVER=<you memcached server host> --POOL-MIN=10 --POOL-MAX=100

```

For **seafevents.conf**:

```
[INDEX FILES]
enabled = true
es_host = <ip of elastic search service>
es_port = 9200
interval = 10m
highlight = fvh  # this is for improving the search speed
```

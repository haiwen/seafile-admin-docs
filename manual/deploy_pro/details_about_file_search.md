# Details about File Search

## Search Options

The following options can be set in **seafevents.conf** to control the behaviors of file search. You need to restart seafile and seahub to make them take effect.

```
[INDEX FILES]
## must be "true" to enable search
enabled = true

## The interval the search index is updated. Can be s(seconds), m(minutes), h(hours), d(days)
interval=10m

## this is for improving the search speed
highlight = fvh                              

## If true, indexes the contents of office/pdf files while updating search index
## Note: If you change this option from "false" to "true", then you need to clear the search index and update the index again.
index_office_pdf=false

## From 9.0.7 pro, Seafile supports connecting to Elasticsearch through username and password, you need to configure username and password for the Elasticsearch server
username = elastic           # username to connect to Elasticsearch
password = elastic_password  # password to connect to Elasticsearch

## From 9.0.7 pro, Seafile supports connecting to elasticsearch via HTTPS, you need to configure HTTPS for the Elasticsearch server
scheme = https               # The default is http. If the Elasticsearch server is not configured with HTTPS, the scheme and cafile do not need to be configured
cafile = path/to/cert.pem    # The certificate path for user authentication. If the Elasticsearch server does not enable certificate authentication, do not need to be configured
```

## Enable full text search for Office/PDF files

Full text search is not enabled by default to save system resources. If you want to enable it, you need to follow the instructions below.

First you have to set the value of `index_office_pdf` option in `seafevents.conf` to `true`.

Then restart seafile server

```
  cd /data/haiwen/seafile-pro-server-1.7.0/
  ./seafile.sh restart

```

You need to delete the existing search index and recreate it.

```
  ./pro/pro.py search --clear
  ./pro/pro.py search --update

```

## Common problems

### How to rebuild the index if something went wrong

You can rebuild search index by running:

```
./pro/pro.py search --clear
./pro/pro.py search --update

```

If this does not work, you can try the following steps:

1. Stop Seafile
2. Remove the old search index `rm -rf pro-data/search`
3. Restart Seafile
4. Wait one minute then run `./pro/pro.py search --update`

### Access the AWS elasticsearch service using HTTPS

1. Create an elasticsearch service on AWS according to the [documentation](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsgcreate-domain.html).

2. Configure the seafevents.conf:

```
[INDEX FILES]
enabled = true
interval = 10m
index_office_pdf=true
external_es_server = true
es_host = your domain endpoint(for example, https://search-my-domain.us-east-1.es.amazonaws.com)
es_port = 443
scheme = https
username = master user
password = password
highlight = fvh

```

**NOTE**: The version of the Python third-party package `elasticsearch` cannot be greater than 7.14.0, otherwise the elasticsearch service cannot be accessed: <https://docs.aws.amazon.com/opensearch-service/latest/developerguide/samplecode.html#client-compatibility>, <https://github.com/elastic/elasticsearch-py/pull/1623>.

### I get no result when I search a keyword

The search index is updated every 10 minutes by default. So before the first index update is performed, you get nothing no matter what you search.

  To be able to search immediately,

* Make sure you have started Seafile Server
* Update the search index manually:


```
cd haiwen/seafile-pro-server-2.0.4
./pro/pro.py search --update

```

### Encrypted files cannot be searched

This is because the server cannot index encrypted files, since they are encrypted.

### Increase the heap size for the java search process

The search functionality is based on Elasticsearch, which is a java process. You can modify the memory size by modifying the jvm configuration file. For example, modify to 2G memory. Modify the following configuration in the `seafile-server-latest/pro/elasticsearch/config/jvm.options` file:

```sh
-Xms2g # Minimum available memory
-Xmx2g # Maximum available memory
### It is recommended to set the values of the above two configurations to the same size.

```

Restart the seafile service to make the above changes take effect:

```
./seafile.sh restart
./seahub.sh restart

```

## Distributed indexing

If you use a cluster to deploy Seafile, you can use distributed indexing to realize real-time indexing and improve indexing efficiency. The indexing process is as follows:

![](../images/distributed-indexing.png)

### Install redis and modify configuration files

First, install redis on all frontend nodes(If you use redis cloud service, skip this step and modify the configuration files directly):

For Ubuntu:

```
$ apt install redis-server
```

For CentOS:

```
$ yum install redis
```

Then, install python redis third-party package on all frontend nodes:

```
$ pip install redis
```

Next, modify the `seafevents.conf` on all frontend nodes, add the following config items:

```
[EVENTS PUBLISH]
mq_type=redis   # must be redis
enabled=true

[REDIS]
server=127.0.0.1   # your redis server host
port=6379          # your redis server port
password=xxx       # your redis server password, if not password, do not set this item
```

Next, modify the `seafevents.conf` on the backend node to disable the scheduled indexing task, because the scheduled indexing task and the distributed indexing task conflict.

```
[INDEX FILES]
enabled=true
     |
     V
enabled=false   
```

Next, restart Seafile to make the configuration take effect:

```
$ ./seafile.sh restart && ./seahub.sh restart
```

### Deploy distributed indexing

First, prepare a seafes master node and several seafes slave nodes, the number of slave nodes depends on your needs. Deploy Seafile on these nodes, and copy the configuration files in the `conf` directory from the frontend nodes. The master node and slave nodes do not need to start Seafile, but need to read the configuration files to obtain the necessary information.

Next, create a configuration file `index-master.conf` in the `conf` directory of the master node, e.g.

```
[DEFAULT]
mq_type=redis   # must be redis

[REDIS]
server=127.0.0.1   # your redis server host
port=6379          # your redis server port
password=xxx       # your redis server password, if not password, do not set this item
```

Execute `./run_index_master.sh [start/stop/restart]` in the `seafile-server-last` directory to control the program to start, stop and restart.

Next, create a configuration file `index-slave.conf` in the `conf` directory of all slave nodes, e.g.

```
[DEFAULT]
mq_type=redis     # must be redis
index_workers=2   # number of threads to create/update indexes, you can increase this value according to your needs

[REDIS]
server=127.0.0.1   # your redis server host
port=6379          # your redis server port
password=xxx       # your redis server password, if not password, do not set this item
```

Execute `./run_index_worker.sh [start/stop/restart]` in the `seafile-server-last` directory to control the program to start, stop and restart.

!!! note

    The index worker connects to backend storage directly. You don't need to run seaf-server in index worker node.

    

#### Some commands in distributed indexing

Rebuild search index, execute in the `seafile-server-last` directory:

```
$ ./pro/pro.py search --clear
$ ./run_index_master.sh python-env index_op.py --mode resotre_all_repo
```

List the number of indexing tasks currently remaining, execute in the `seafile-server-last` directory:

```
$ ./run_index_master.sh python-env index_op.py --mode show_all_task
```


The above commands need to be run on the master node.

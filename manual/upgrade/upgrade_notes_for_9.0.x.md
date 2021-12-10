# Upgrade notes for 9.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

9.0 version includes following major changes:

1. SERVICE_URL is moved from ccnet.conf to seahub_settings.py. The upgrade script will read it from ccnet.conf and write to seahub_settings.py
2. ElasticSearch is upgraded to version 6.8. ElasticSearch needs to be installed and managed individually. (As ElasticSearch changes license since 6.2, it can no longer be included in Seafile package). There are some benefits for ElasticSearch to be managed individually:
    * Reduce the size of Seafile package
    * You can change ElasticSearch setttings more easily
3. The built-in Office file preview is now implemented by a separate docker image. This makes is more easy to maintain. We also suggest users to use OnlyOffice as an alternative.
4. Seafile package for CentOS is no longer maintained. We suggest users to migrate to Docker images.5. We rewrite HTTP service in seaf-server with golang and move it to a separate component (turn off by default)

The new file-server written in golang serves HTTP requests to upload/download/sync files. It provides three advantages:

* The performance is better in a high-concurrency environment and it can handle long requests.
* Now you can sync libraries with large number of files.
* Now file zipping and downloading can be done simutaneously. When zip downloading a folder, you don't need to wait until zip is done.
* Support rate control for file uploading and downloading.

You can turn golang file-server on by adding following configuration in seafile.conf

```
[fileserver]
use_go_fileserver = true
```

## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

* For Ubuntu 18.04/20.04

```sh
sudo pip3 install pycryptodome==3.12.0
```


## Upgrade to 9.0.x

1. Stop Seafile-8.0.x server.
2. Start from Seafile 9.0.x, run the script:

    ```sh
    upgrade/upgrade_8.0_9.0.sh
    ```

3. Start Seafile-9.0.x server.


## Update ElasticSearch

Download ElasticSearch image：

```
docker pull elasticsearch:6.8.20
```

Create a new folder to store ES data

```
mkdir -p /opt/seafile-elasticsearch/data 
```

Move original data to the new folder

```
mv  /opt/seafile/pro-data/search/data/*  /opt/seafile-elasticsearch/data/
chmod -R 777 /opt/seafile-elasticsearch/data/
```

Start ES docker image

```
docker run -d --name es -p 9200:9200  -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:6.8.20

```

Note:`ES_JAVA_OPTS` can be adjusted according to your need.

Modify seafevents.conf （`external_es_server` need to be changed to true）

```
[INDEX FILES]
external_es_server = true
es_host = your server's IP
es_port = 9200
```

Restart seafile

```
su seafile
cd seafile-server-latest/
./seafile.sh stop && ./seahub.stop 
./seafile.sh start && ./seahub.start 
```

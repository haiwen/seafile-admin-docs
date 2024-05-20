# Upgrade notes for 9.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

9.0 version includes following major changes:

1. SERVICE_URL is moved from ccnet.conf to seahub_settings.py. The upgrade script will read it from ccnet.conf and write to seahub_settings.py
2. (pro edition only) ElasticSearch is upgraded to version 6.8. ElasticSearch needs to be installed and managed individually. (As ElasticSearch changes license since 6.2, it can no longer be included in Seafile package). There are some benefits for ElasticSearch to be managed individually:
    * Reduce the size of Seafile package
    * You can change ElasticSearch setttings more easily
3. (pro edition only) The built-in Office file preview is now implemented by a separate docker image. This makes is more easy to maintain. We also suggest users to use OnlyOffice as an alternative.
4. Seafile community edition package for CentOS is no longer maintained (pro editions will still be maintaied). We suggest users to migrate to Docker images.
5. We rewrite HTTP service in seaf-server with golang and move it to a separate component (turn off by default)

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
sudo pip3 install pycryptodome==3.12.0 cffi==1.14.0
```


## Upgrade to 9.0.x

1. Stop Seafile-8.0.x server.
2. Start from Seafile 9.0.x, run the script:

    ```sh
    upgrade/upgrade_8.0_9.0.sh
    ```

3. Start Seafile-9.0.x server.


### Update ElasticSearch (pro edition only)

#### Method one, rebuild the index and discard the old index data

If your elasticsearch data is not large, it is recommended to deploy the latest 7.x version of ElasticSearch and then rebuild the new index. Specific steps are as follows

Download ElasticSearch image

```
docker pull elasticsearch:7.16.2

```

Create a new folder to store ES data and give the folder permissions

```
mkdir -p /opt/seafile-elasticsearch/data  && chmod -R 777 /opt/seafile-elasticsearch/data/

```

_Note_: You must properly grant permission to access the es data directory, and run the Elasticsearch container as the root user, refer to [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/docker.html#_configuration_files_must_be_readable_by_the_elasticsearch_user).

Start ES docker image

```
sudo docker run -d --name es -p 9200:9200 -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms2g -Xmx2g" -e "xpack.security.enabled=false" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:7.16.2

```

Delete old index data

```
rm -rf /opt/seafile/pro-data/search/data/*

```

Modify seafevents.conf

```
[INDEX FILES]
external_es_server = true
es_host = your server's IP (use 127.0.0.1 if deployed locally)
es_port = 9200
```


Restart seafile

```
su seafile
cd seafile-server-latest/
./seafile.sh stop && ./seahub.stop 
./seafile.sh start && ./seahub.start 

```

#### Method two, reindex the existing data

If your data volume is relatively large, it will take a long time to rebuild indexes for all Seafile databases, so you can reindex the existing data. This requires the following steps

* Download and start Elasticsearch 7.x
* Use the existing data to execute ElasticSearch Reindex in order to build an index that can be used in 7.x

The detailed process is as follows

Download ElasticSearch image:

```
docker pull elasticsearch:7.16.2

```

PS：For seafile version 9.0, you need to manually create the elasticsearch mapping path on the host machine and give it 777 permission, otherwise elasticsearch will report path permission problems when starting, the command is as follows  

```
mkdir -p /opt/seafile-elasticsearch/data 

```

Move original data to the new folder and give the folder permissions

```
mv  /opt/seafile/pro-data/search/data/*  /opt/seafile-elasticsearch/data/
chmod -R 777 /opt/seafile-elasticsearch/data/
```

_Note_: You must properly grant permission to access the es data directory, and run the Elasticsearch container as the root user, refer to [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/docker.html#_configuration_files_must_be_readable_by_the_elasticsearch_user).

Start ES docker image

```
sudo docker run -d --name es -p 9200:9200 -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -e "xpack.security.enabled=false" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:7.16.2

```

Note:`ES_JAVA_OPTS` can be adjusted according to your need.

Create an index with 7.x compatible mappings.

```
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repo_head?include_type_name=false&pretty=true' -d '
{
  "mappings" : {
    "properties" : {
      "commit" : {
        "type" : "text",
        "index" : false
      },
      "repo" : {
        "type" : "text",
        "index" : false
      },
      "updatingto" : {
        "type" : "text",
        "index" : false
      }
    }
  }
}'

curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repofiles/?include_type_name=false&pretty=true' -d '
{
  "settings" : {
    "index" : {
      "number_of_shards" : 5,
      "number_of_replicas" : 1,
      "analysis" : {
        "analyzer" : {
          "seafile_file_name_ngram_analyzer" : {
            "filter" : [
              "lowercase"
            ],
            "type" : "custom",
            "tokenizer" : "seafile_file_name_ngram_tokenizer"
          }
        },
        "tokenizer" : {
          "seafile_file_name_ngram_tokenizer" : {
            "type" : "ngram",
            "min_gram" : "3",
            "max_gram" : "4"
          }
        }
      }
    }
  },
  "mappings" : {
    "properties" : {
      "content" : {
        "type" : "text",
        "term_vector" : "with_positions_offsets"
      },
      "filename" : {
        "type" : "text",
        "fields" : {
          "ngram" : {
            "type" : "text",
            "analyzer" : "seafile_file_name_ngram_analyzer"
          }
        }
      },
      "is_dir" : {
        "type" : "boolean"
      },
      "mtime" : {
        "type" : "date"
      },
      "path" : {
        "type" : "keyword"
      },
      "repo" : {
        "type" : "keyword"
      },
      "size" : {
        "type" : "long"
      },
      "suffix" : {
        "type" : "keyword"
      }
    }
  }
}'

```

Set the `refresh_interval` to `-1` and the `number_of_replicas` to `0` for efficient reindexing:

```
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repo_head/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : "-1",
    "number_of_replicas" : 0
  }
}'

curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repofiles/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : "-1",
    "number_of_replicas" : 0
  }
}'

```

Use the [reindex API](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/docs-reindex.html) to copy documents from the 5.x index into the new index.

```
curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_reindex/?pretty' -d '
{
  "source": {
    "index": "repo_head",
    "type": "repo_commit"
  },
  "dest": {
    "index": "new_repo_head",
    "type": "_doc"
  }
}'

curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_reindex/?pretty' -d '
{
  "source": {
    "index": "repofiles",
    "type": "file"
  },
  "dest": {
    "index": "new_repofiles",
    "type": "_doc"
  }
}'

```

Reset the `refresh_interval` and `number_of_replicas` to the values used in the old index.

```
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repo_head/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : null,
    "number_of_replicas" : 1
  }
}'

curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/new_repofiles/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : null,
    "number_of_replicas" : 1
  }
}'

```

Wait for the index status to change to `green`.

```
curl http{s}://{es server IP}:9200/_cluster/health?pretty

```

Use the [aliases API](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/indices-aliases.html) delete the old index and add an alias with the old index name to the new index.

```
curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_aliases?pretty' -d '
{
  "actions": [
    {"remove_index": {"index": "repo_head"}},
    {"remove_index": {"index": "repofiles"}},
    {"add": {"index": "new_repo_head", "alias": "repo_head"}},
    {"add": {"index": "new_repofiles", "alias": "repofiles"}}
  ]
}'

```

After reindex, modify the configuration in Seafile.

Modify seafevents.conf

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

#### Method three, if you are in a cluster environment

Deploy a new ElasticSeach 7.x service, use Seafile 9.0 version to deploy a new backend node, and connect to ElasticSeach 7.x. The background node does not start the Seafile background service, just manually run the command `./pro/pro.py search --update`, and then upgrade the other nodes to Seafile 9.0 version and use the new ElasticSeach 7.x after the index is created. Then deactivate the old backend node and the old version of ElasticSeach.

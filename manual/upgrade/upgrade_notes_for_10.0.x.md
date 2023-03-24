# Upgrade notes for 10.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes


### Memcached section in the seafile.conf (pro edition only)

If you use storage backend or cluster, make sure the memcached section is in the seafile.conf.

Since version 10.0, all memcached options are consolidated to the one below.

Modify the seafile.conf:

```
[memcached]
memcached_options = --SERVER=<the IP of Memcached Server> --POOL-MIN=10 --POOL-MAX=100
```

### SAML SSO change (pro edition only)

The configuration for SAML SSO in Seafile is greatly simplified. Now only three options are needed:

```
ENABLE_ADFS_LOGIN = True
SAML_REMOTE_METADATA_URL = 'https://login.microsoftonline.com/xxx/federationmetadata/2007-06/federationmetadata.xml?appid=xxx'
SAML_ATTRIBUTE_MAPPING = {
    'mail': 'contact_email',
    'name': 'display_name',
    ...
}
```

Please check the new document on [SAML SSO](../deploy_pro/saml2_in_10.0.md)


### ElasticSearch change (pro edition only)

Elasticsearch is upgraded to version 8.x, fixed and improved some issues of file search function.

Since elasticsearch 7.x, the default number of shards has changed from 5 to 1, because too many index shards will over-occupy system resources; but when a single shard data is too large, it will also reduce search performance. Starting from version 10.0, Seafile supports customizing the number of shards in the configuration file.

You can use the following command to query the current size of each shard to determine the best number of shards for you:

```
curl 'http{s}://<es IP>:9200/_cat/shards/repofiles?v'
```

The official recommendation is that the size of each shard should be between 10G-50G: <https://www.elastic.co/guide/en/elasticsearch/reference/8.6/size-your-shards.html#shard-size-recommendation>.

Modify the seafevents.conf:

```
[INDEX FILES]
...
shards = 10     # default is 5
...
```



## New Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

* For Ubuntu 20.04/22.04

```sh
sudo pip3 install future==0.18.* mysqlclient==2.1.* pillow==9.3.* captcha==0.4 django_simple_captcha==0.5.* djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1
```


## Upgrade to 10.0.x

1. Stop Seafile-9.0.x server.

2. Start from Seafile 10.0.x, run the script:

    ```sh
    upgrade/upgrade_9.0_10.0.sh
    ```
   
   If you are using pro edtion, modify memcached option in seafile.conf and SAML SSO configuration if needed.

3. Start Seafile-10.0.x server.

### Update Elasticsearch (pro edition only)

You can choose one of the methods to upgrade your index data.

#### Method one, reindex the old index data

1\. Download Elasticsearch image:

```
docker pull elasticsearch:7.17.9
```

Create a new folder to store ES data and give the folder permissions:

```
mkdir -p /opt/seafile-elasticsearch/data  && chmod -R 777 /opt/seafile-elasticsearch/data/
```

Start ES docker image:

```
sudo docker run -d --name es-7.17 -p 9200:9200  -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -e "xpack.security.enabled=false" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:7.17.9
```

**PS:** `ES_JAVA_OPTS` can be adjusted according to your need.

2\. Create an index with 8.x compatible mappings:

```
# create repo_head index
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repo_head_8?pretty=true' -d '
{
  "mappings" : {
    "properties" : {
      "commit" : {
        "type" : "keyword",
        "index" : false
      },
      "repo" : {
        "type" : "keyword",
        "index" : false
      },
      "updatingto" : {
        "type" : "keyword",
        "index" : false
      }
    }
  }
}'

# create repofiles index, number_of_shards is the number of shards, here is set to 5, you can also modify it to the most suitable number of shards
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repofiles_8/?pretty=true' -d '
{
  "settings" : {
    "index" : {
      "number_of_shards" : "5",
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

3\. Set the `refresh_interval` to `-1` and the `number_of_replicas` to `0` for efficient reindex:

```
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repo_head_8/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : "-1",
    "number_of_replicas" : 0
  }
}'

curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repofiles_8/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : "-1",
    "number_of_replicas" : 0
  }
}'
```

4\. Use the [reindex API](https://www.elastic.co/guide/en/elasticsearch/reference/8.6/docs-reindex.html) to copy documents from the 7.x index into the new index:

```
curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_reindex/?wait_for_completion=false&pretty=true' -d '
{
  "source": {
    "index": "repo_head"
  },
  "dest": {
    "index": "repo_head_8"
  }
}'

curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_reindex/?wait_for_completion=false&pretty=true' -d '
{
  "source": {
    "index": "repofiles"
  },
  "dest": {
    "index": "repofiles_8"
  }
}'
```

5\. Use the following command to check if the reindex task is complete:

```
# Get the task_id of the reindex task:
$ curl 'http{s}://{es server IP}:9200/_tasks?actions=*reindex&pretty'
# Check to see if the reindex task is complete:
$ curl 'http{s}://{es server IP}:9200/_tasks/:<task_id>?pretty'
```

6\. Reset the `refresh_interval` and `number_of_replicas` to the values used in the old index:

```
curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repo_head_8/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : null,
    "number_of_replicas" : 1
  }
}'

curl -X PUT -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/repofiles_8/_settings?pretty' -d '
{
  "index" : {
    "refresh_interval" : null,
    "number_of_replicas" : 1
  }
}'
```

7\. Wait for the elasticsearch status to change to `green` (or `yellow` if it is a single node).

```
curl 'http{s}://{es server IP}:9200/_cluster/health?pretty'
```

8\. Use the [aliases API](https://www.elastic.co/guide/en/elasticsearch/reference/8.6/indices-aliases.html) delete the old index and add an alias with the old index name to the new index:

```
curl -X POST -H 'Content-Type: application/json' 'http{s}://{es server IP}:9200/_aliases?pretty' -d '
{
  "actions": [
    {"remove_index": {"index": "repo_head"}},
    {"remove_index": {"index": "repofiles"}},
    {"add": {"index": "repo_head_8", "alias": "repo_head"}},
    {"add": {"index": "repofiles_8", "alias": "repofiles"}}
  ]
}'
```

9\. Deactivate the 7.17 container, pull the 8.x image and run:

```
$ docker stop es-7.17

$ docker rm es-7.17

$ docker pull elasticsearch:8.6.2

$ sudo docker run -d --name es -p 9200:9200 -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -e "xpack.security.enabled=false" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:8.6.2
```

#### Method two, rebuild the index and discard the old index data

1\. Pull Elasticsearch image:

```
docker pull elasticsearch:8.5.3
```

Create a new folder to store ES data and give the folder permissions:

```
mkdir -p /opt/seafile-elasticsearch/data  && chmod -R 777 /opt/seafile-elasticsearch/data/
```

Start ES docker image:

```
sudo docker run -d --name es -p 9200:9200 -e "discovery.type=single-node" -e "bootstrap.memory_lock=true" -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" -e "xpack.security.enabled=false" --restart=always -v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data -d elasticsearch:8.5.3
```

2\. Modify the seafevents.conf:

```
[INDEX FILES]
...
external_es_server = true
es_host = http{s}://{es server IP}
es_port = 9200
shards = 10   # default is 5.
...
```

Restart Seafile server:

```
su seafile
cd seafile-server-latest/
./seafile.sh stop && ./seahub.stop 
./seafile.sh start && ./seahub.start
```

3\. Delete old index data

```
rm -rf /opt/seafile-elasticsearch/data/*
```

4\. Create new index data:

```
$ cd /opt/seafile/seafile-server-latest
$ ./pro/pro.py search --update
```

#### Method three, if you are in a cluster environment

1\. Deploy elasticsearch 8.x according to method two. Use Seafile 10.0 version to deploy a new backend node and modify the `seafevents.conf` file. The background node does not start the Seafile background service, just manually run the command `./pro/pro.py search --update`.

2\. Upgrade the other nodes to Seafile 10.0 version and use the new Elasticsearch 8.x server.

3\. Then deactivate the old backend node and the old version of Elasticsearch.

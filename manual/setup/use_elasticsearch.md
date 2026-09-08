# Search with ElasticSearch (Pro)

Our recommendation for deploying ElasticSearch is using Docker. Detailed information about installing Docker on various Linux distributions is available at [Docker Docs](https://docs.docker.com/engine/install/).

Seafile PE 9.0 only supports ElasticSearch 7.x. Seafile PE 10.0 and later only supports ElasticSearch 8.x.

We use ElasticSearch version 8.15.0 as an example in this section. Version 8.15.0 and newer version have been successfully tested with Seafile.

### Deploying ElasticSearch

1. Download the `elasticsearch.yml`:

    ```sh
    wget https://manual.seafile.com/14.0/repo/docker/pro/elasticsearch.yaml
    ```

2. Modify `.env` to add `elasticsearch.yml` in list `COMPOSE_FILE`, and add relavent configurations

    ```env
    COMPOSE_FILE="...,elasticsearch.yml"
    SEAFILE_ELASTICSEARCH_VOLUME=/opt/seafile-elasticsearch/data
    ```

3. Provide read and write permissions for `/opt/seafile-elasticsearch/data` (you can modify this path as you want):

    ```sh
    chmod 744 /opt/seafile-elasticsearch/data
    ```

### Enable ElasticSearch in Seafile

Modify `.env` to use ES as the search engine:

```env
## for searching
ENABLE_SEARCH=true
SEARCH_ENGINE=elasticsearch
# Index document contents for full-text search. Set to false to disable it (supported since 13.0 Pro).
ENABLE_FULL_TEXT_SEARCH=true

### for elasticsearch
ELASTICSEARCH_SCHEME=http
ELASTICSEARCH_HOST=<Your ES host>
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_USER=
ELASTICSEARCH_PASSWORD=
```

## Advanced Search Options

The following options can be set in **seafevents.conf** to control the behaviors of file search. 

```
[INDEX FILES]
## The interval the search index is updated. Can be s(seconds), m(minutes), h(hours), d(days)
interval=10m

## this is for improving the search speed
highlight = fvh                              

## If true, indexes the contents of office/pdf files while updating search index
## Note: If you change this option from "false" to "true", then you need to clear the search index and update the index again.
## Since 14.0 Pro, ENABLE_FULL_TEXT_SEARCH in .env takes precedence over this setting.
enable_full_text_search=true

## From 9.0.7 pro, Seafile supports connecting to Elasticsearch through username and password, you need to configure username and password for the Elasticsearch server
## From 14.0 pro, the username and password can be set from `.env` with the higher priority
username = elastic           # username to connect to Elasticsearch
password = elastic_password  # password to connect to Elasticsearch

## From 9.0.7 pro, Seafile supports connecting to elasticsearch via HTTPS, you need to configure HTTPS for the Elasticsearch server
## From 14.0 pro, the scheme, es_host, es_port can be set from `.env` with the higher priority
scheme = https               # The default is http. If the Elasticsearch server is not configured with HTTPS, the scheme and cafile do not need to be configured
cafile = path/to/cert.pem    # The certificate path for user authentication. If the Elasticsearch server does not enable certificate authentication, do not need to be configured

## From version 11.0.5 Pro, you can custom ElasticSearch index names for distinct instances when intergrating multiple Seafile servers to a single ElasticSearch Server.
repo_status_index_name = your-repo-status-index-name  # default is `repo_head`
repo_files_index_name = your-repo-files-index-name    # default is `repofiles`
```

## Full-text search for document contents

Full-text search is enabled by default with `ENABLE_FULL_TEXT_SEARCH=true`. Set it to `false` to index file names only. If you change this setting, clear and rebuild the search index for the change to take effect.

## Start ElasticSearch and restart Seafile

```sh
docker compose down
docker compose up -d
```

### (Optional) Access the AWS elasticsearch service using HTTPS

1. Create an elasticsearch service on AWS according to the [documentation](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsgcreate-domain.html).

2. Modify `.env`:

    ```env
    ## for searching
    ENABLE_SEARCH=true
    SEARCH_ENGINE=elasticsearch
    ENABLE_FULL_TEXT_SEARCH=true

    ### for elasticsearch
    ELASTICSEARCH_SCHEME=http
    ELASTICSEARCH_HOST=https://search-my-domain.us-east-1.es.amazonaws.com
    ELASTICSEARCH_PORT=9200
    ELASTICSEARCH_USER=master_user
    ELASTICSEARCH_PASSWORD=password
    ```

2. Configure the seafevents.conf:

    ```
    [INDEX FILES]
    interval = 10m
    highlight = fvh
    repo_status_index_name = your-repo-status-index-name  # default is `repo_head`
    repo_files_index_name = your-repo-files-index-name    # default is `repofiles`
    ```

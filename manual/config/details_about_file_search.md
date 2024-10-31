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

## From version 11.0.5 Pro, you can custom ElasticSearch index names for distinct instances when intergrating multiple Seafile servers to a single ElasticSearch Server.
repo_status_index_name = your-repo-status-index-name  # default is `repo_head`
repo_files_index_name = your-repo-files-index-name    # default is `repofiles`
```

## Enable full text search for Office/PDF files

Full text search is not enabled by default to save system resources. If you want to enable it, you need to follow the instructions below.

### Modify `seafevents.conf`

=== "Deploy in Docker"
    ```sh
    cd /opt/seafile-data/seafile/conf
    nano seafevents.conf
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/conf
    nano seafevents.conf
    ```

set `index_office_pdf` to `true`

```conf
...
[INDEX FILES]
...
index_office_pdf=true
...
```

### Restart Seafile server

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /scripts
    ./seafile.sh restart

    # delete the existing search index and recreate it
    ./pro/pro.py search --clear
    ./pro/pro.py search --update
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
    ./seafile.sh restart

    # delete the existing search index and recreate it
    ./pro/pro.py search --clear
    ./pro/pro.py search --update
    ```


## Common problems

### How to rebuild the index if something went wrong

You can rebuild search index by running:

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /scripts
    ./pro/pro.py search --clear
    ./pro/pro.py search --update
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
    ./pro/pro.py search --clear
    ./pro/pro.py search --update
    ```

!!! tip
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
es_host = your domain endpoint(for example, https://search-my-domain.us-east-1.es.amazonaws.com)
es_port = 443
scheme = https
username = master user
password = password
highlight = fvh
repo_status_index_name = your-repo-status-index-name  # default is `repo_head`
repo_files_index_name = your-repo-files-index-name    # default is `repofiles`
```

!!! note
    The version of the Python third-party package `elasticsearch` cannot be greater than 7.14.0, otherwise the elasticsearch service cannot be accessed: <https://docs.aws.amazon.com/opensearch-service/latest/developerguide/samplecode.html#client-compatibility>, <https://github.com/elastic/elasticsearch-py/pull/1623>.

### I get no result when I search a keyword

The search index is updated every 10 minutes by default. So before the first index update is performed, you get nothing no matter what you search.

  To be able to search immediately,

* Make sure you have started Seafile Server
* Update the search index manually:

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /scripts
    ./pro/pro.py search --update
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
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

=== "Deploy in Docker"
    ```sh
    docker compose restart
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
    ./seafile.sh restart
    ./seahub.sh restart
    ```

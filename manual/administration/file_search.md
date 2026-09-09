# Details about File Search

From Seafile 12.0, there is two search engines has supported by Seafile:

- [Search with SeaSearch](../setup/use_seasearch.md) (and becomes the default-enabled search engine since 14.0)
- [Search with ElasticSearch](../setup/use_elasticsearch.md)

You can follow one of above two engines to enable your Seafile Pro server's search function

## Common problems

### How to rebuild the index if something went wrong

You can rebuild search index by running:

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /opt/seafile/seafile-server-latest
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

### I get no result when I search a keyword

The search index is updated every 10 minutes by default. So before the first index update is performed, you get nothing no matter what you search.

  To be able to search immediately,

* Make sure you have started Seafile Server
* Update the search index manually:

=== "Deploy in Docker"
    ```sh
    docker exec -it seafile bash
    cd /opt/seafile/seafile-server-latest
    ./pro/pro.py search --update
    ```
=== "Deploy from binary packages"
    ```sh
    cd /opt/seafile/seafile-server-latest
    ./pro/pro.py search --update
    ```

### Encrypted files cannot be searched

This is because the server cannot index encrypted files, since they are encrypted.

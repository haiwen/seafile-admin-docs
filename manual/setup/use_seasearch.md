# Use SeaSearch as search engine (Pro)

[SeaSearch](https://seasearch-manual.seafile.com/), a file indexer with more lightweight and efficiency than *Elasticsearch*, is supported from Seafile 12.

!!! note "For Seafile deploy from binary package"
    We currently **only support Docker-based** deployment for SeaSearch Server, so this document describes the configuration with the situation of using Docker to deploy Seafile server. 
    
    If your Seafile Server deploy from binary package, please refer [here](../setup_binary/installation_pro.md#starting-seafile-server) to start or stop Seafile Server.

!!! tip "For Seafile cluster"
    Theoretically, **at least** the backend node has to restart, if your Seafile server deploy in cluster mode, but we still suggest you configure and restart **all node** to make sure the consistency and synchronization in the cluster

## Deploy SeaSearch service

SeaSearch service is currently mainly deployed via docker. We have integrated it into the relevant docker-compose file. You only need to download it to the same directory as `seafile-server.yml`:

```sh
wget https://manual.seafile.com/13.0/repo/docker/pro/seasearch.yml
```

## Modify `.env`

We have configured the relevant variables in .env. Here you must pay special attention to the following variable information, which will affect the SeaSearch initialization process. For variables in `.env` of SeaSearch service, please refer [here](https://seasearch-manual.seafile.com/config/) for the details. We use `/opt/seasearch-data` as the persistent directory of SeaSearch (the information of administrator are same as Seafile's admin by default from Seafile 13):

!!! warning "For Apple's Chips"
    Since Apple's chips (such as M2) do not support [MKL](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html), you need to set the relevant image to `xxx-nomkl:latest`, e.g.:

    ```sh
    SEASEARCH_IMAGE=seafileltd/seasearch-nomkl:latest
    ```

```sh
COMPOSE_FILE='...,seasearch.yml' # ... means other docker-compose files

#SEASEARCH_IMAGE=seafileltd/seasearch-nomkl:latest  # for Apple's Chip
SEASEARCH_IMAGE=seafileltd/seasearch:latest

SS_DATA_PATH=/opt/seasearch-data
INIT_SS_ADMIN_USER=<admin-username>  
INIT_SS_ADMIN_PASSWORD=<admin-password>
```

!!! success "Easier to configure S3 for Seafile and its components"
    Since Seafile Pro 13.0, in order to facilitate users to deploy Seafile's related extension components and other services in the future, a section will be provided in `.env` to store the **S3 authorization Configurations**. You can locate it with the following title bar:
    
    ```sh
    ###################################
    # S3 authorization Configurations #
    #    (This configurations will    #
    #     apply to all components)    #
    ###################################
    ```
    
    The S3 authorization configuration part (i.e., ***without buckets name***) in Seafile and some extension components (such as *SeaSearch*, *Metadata server*) configuration will be read from this configuration by default. 

    In other words, if you deploy SeaSearch and Seafile together, and if you have deployed Seafile Pro following [here](../setup/setup_pro_by_docker.md#downloading-and-modifying-env) (and using the latest `.env`), you only need to specify the following variables in `.env` to make it work:

    ```sh
    S3_SS_BUCKET=<your s3 bucket name for SeaSearch>
    ```

## Modify `seafile-server.yml` to disable `elasticSearch` service

If you would like to use *SeaSearch* as the search engine, the `elasticSearch` service can be removed, which is no longer used: remove `elasticsearch.yml` in the list variable `COMPOSE_FILE` on the file `.env`.

## Modify `seafevents.conf`

1. Get your authorization token by base64 code consist of `INIT_SS_ADMIN_USER` and `INIT_SS_ADMIN_PASSWORD` defined in `.env` firsly, which is used to authorize when calling the SeaSearch API:

    ```sh
    echo -n 'username:password' | base64

    # example output
    YWRtaW46YWRtaW5fcGFzc3dvcmQ=
    ```

2. Add the following section in seafevents to enable seafile backend service to access SeaSearch APIs

    !!! note "SeaSearch server deploy on a different machine with Seafile"
        If your SeaSearch server deploy on a **different** machine with Seafile, please replace `http://seasearch:4080` to the url `<scheme>://<address>:<prot>` of your SeaSearch server 

    ```conf
    [SEASEARCH]
    enabled = true
    seasearch_url = http://seasearch:4080
    seasearch_token = <your auth token>
    interval = 10m
    ```

3. Disable the ElasticSearch, as you can set `enabled = false` in `INDEX FILES` section:

    ```conf
    [INDEX FILES]
    enabled = false
    ...
    ```

## Restart Seafile Server

```sh
docker compose down
docker compose up -d
```

After startup the SeaSearch service, you can check the following logs for Whether SeaSearch runs normally and Seafile is called successfully:

- container logs by command `docker logs -f seafile-seasearch`
- `/opt/seasearch-data/log/seafevents.log`


!!! tip "After first time start SeaSearch Server"
    You can remove the initial admin account informations in `.env` (e.g., `INIT_SS_ADMIN_USER`, `INIT_SS_ADMIN_PASSWORD`), which are only used in the SeaSearch initialization progress (i.e., the **first time** to start services). But make sure **you have recorded it somewhere else in case you forget the password**.


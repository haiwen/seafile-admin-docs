---
status: new
---

# Upgrade a Seafile cluster (Docker)

## Major and minor version upgrade

Seafile adds new features in major and minor versions. It is likely that some database tables need to be modified or the search index need to be updated. In general, upgrading a cluster contains the following steps:

1. Update Seafile image
2. Upgrade the database
3. Update configuration files at each node
4. Update search index in the backend node

In general, to upgrade a cluster, you need:

1. Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Start with docker compose up.
2. Run the upgrade script in container (for example, `/opt/seafile/seafile-server-latest/upgrade/upgrade_x_x_x_x.sh`) in one frontend node
3. Update configuration files at each node according to the documentation for each version
4. Delete old search index in the backend node if needed

## Upgrade a cluster from Seafile 11 to 12

1. Stop the seafile service in all nodes

    ```sh
    docker compose down
    ```

2. Download the docker-compose files for *Seafile 12*

    ```sh
    wget -O .env https://manual.seafile.com/12.0/docker/cluster/env
    wget https://manual.seafile.com/12.0/docker/cluster/seafile-server.yml
    ```

3. Modify `.env`:

    - Generate a JWT key

        ```sh
        pwgen -s 40 1

        # e.g., EkosWcXonPCrpPE9CFsnyQLLPqoPhSJZaqA3JMFw
        ```

    - Fill up the following field according to your configurations using in *Seafile 11*:

        ```sh
        SEAFILE_SERVER_HOSTNAME=<your loadbalance's host>
        SEAFILE_SERVER_PROTOCOL=https # or http
        SEAFILE_MYSQL_DB_HOST=<your mysql host>
        SEAFILE_MYSQL_DB_USER=seafile # if you don't use `seafile` as your Seafile server's account, please correct it
        SEAFILE_MYSQL_DB_PASSWORD=<your mysql password for user `seafile`>
        JWT_PRIVATE_KEY=<your JWT key generated in Sec. 3.1>
        ```

        !!! tip "Remove the variables using in Cluster initialization"
            Since Seafile has been initialized in Seafile 11, the variables related to Seafile cluster initialization can be removed from `.env`:

            - INIT_SEAFILE_MYSQL_ROOT_PASSWORD
            - CLUSTER_INIT_MODE
            - CLUSTER_INIT_MEMCACHED_HOST
            - CLUSTER_INIT_ES_HOST
            - CLUSTER_INIT_ES_PORT
            - INIT_S3_STORAGE_BACKEND_CONFIG
            - INIT_S3_COMMIT_BUCKET
            - INIT_S3_FS_BUCKET
            - INIT_S3_BLOCK_BUCKET
            - INIT_S3_KEY_ID
            - INIT_S3_USE_V4_SIGNATURE
            - INIT_S3_SECRET_KEY
            - INIT_S3_AWS_REGION
            - INIT_S3_HOST
            - INIT_S3_USE_HTTPS

4. Start the Seafile in a node

    !!! note
        According to this upgrade document, a **frontend** service will be started here. If you plan to use this node as a backend node, you need to modify this item in `.env` and set it to `backend`:

        ```sh
        CLUSTER_MODE=backend
        ```

    ```sh
    docker compose up -d
    ```

5. Upgrade Seafile

    ```sh
    docker exec -it seafile bash
    # enter the container `seafile`

    # stop servers
    cd /opt/seafile/seafile-server-latest
    ./seafile.sh stop
    ./seahub.sh stop
    
    # upgrade seafile
    cd upgrade
    ./upgrade_11.0_12.0.sh
    ```

    !!! success
        After upgrading the Seafile, you can see the following messages in your console:

        ```
        Updating seafile/seahub database ...

        [INFO] You are using MySQL
        [INFO] updating seafile database...
        [INFO] updating seahub database...
        [INFO] updating seafevents database...
        Done

        migrating avatars ...

        Done

        updating /opt/seafile/seafile-server-latest symbolic link to /opt/seafile/seafile-pro-server-12.0.6 ...



        -----------------------------------------------------------------
        Upgraded your seafile server successfully.
        -----------------------------------------------------------------
        ```

        Then you can exit the container by `exit`

6. Restart current node

    ```sh
        docker compose down
        docker compose up -d
    ```

    !!! tip 
        - You can use `docker logs -f seafile` to check whether the current node service is running normally

7. Operations for other nodes

    - Download and modify `.env` similar to the first node (for backend node, you should set `CLUSTER_MODE=backend`)

    - Start the Seafile server:
        ```sh
        docker compose up -d
        ```     

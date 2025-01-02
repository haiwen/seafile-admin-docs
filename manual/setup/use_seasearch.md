# Use SeaSearch as files indexer (Pro)

!!! success "New features"
    [SeaSearch](https://haiwen.github.io/seasearch-docs/), a file indexer with more lightweight and efficiency than *Elasticsearch*, is supported from Seafile 12.

!!! note "For Seafile deploy from binary package"
    We currently **only support Docker-based** deployment for SeaSearch Server, so this document describes the configuration with the situation of using Docker to deploy Seafile server. 
    
    If your Seafile Server deploy from binary package, please refer [here](../setup_binary/installation_pro.md#starting-seafile-server) to start or stop Seafile Server.

!!! tip "For Seafile cluster"
    Theoretically, **at least** the backend node has to restart, if your Seafile server deploy in cluster mode, but we still suggest you configure and restart **all node** to make sure the consistency and synchronization in the cluster

## Stop Seafile Server

```sh
docker compose down
```

!!! tip
    After shutdown Seafile server, we suggest you disable `elasticsearch` service **if it is not used by other services**. For [Seafile deploy in single node](./setup_pro_by_docker.md), you just need to remove or note whole section of `elasticsearch` in `seafile-server.yml`:

    ```yml
    services:
        ... # no change

        #elasticsearch: # note or remove
            # ... # and it's contents
        
        ... # no change
    ```

## Download `seasearch.yml`

```sh
wget https://manual.seafile.com/12.0/docker/pro/seasearch.yml
```

## Modify `.env`

```sh
COMPOSE_FILE='...,seasearch.yml' # ... means other docker-compose files

SEASEARCH_IMAGE=seafileltd/seasearch:latest

SS_DATA_PATH=<persistent-volume-path-of-seasearch>
INIT_SS_ADMIN_USER=<admin-username>  
INIT_SS_ADMIN_PASSWORD=<admin-password>
```

!!! tip
    For other available variables in `.env`, please refer [SeaSearch confgurations document](https://haiwen.github.io/seasearch-docs/config/)

## Modify `seafevents.conf`

```conf
# if your SeaSearch server dose not deploy on the same host as Seafile, please replace `seasearch` to your SeaSearch host address
es_host = seasearch 

es_port = 4080
```

## Restart Seafile Server

```sh
docker compose up -d
```

!!! success "You can browse SeaSearch services in [http://127.0.0.1:4080/](http://127.0.0.1:4080/)"

!!! danger "Important note"
    By default, the SeaSearch server **will accept all connection** by listening `4080` port. We suggest you to set firewall to set and enable only the Seafile server can connect:

    === "SeaSearch is deployed on the same machine as Seafile"
        1. Remove the exposed ports in the `seasearch.yml`

        2. Set `es_host` to `seasearch` in `seafevents.conf`

    === "SeaSearch is deployed on a different machine with Seafile"

        ```sh
        sudo iptables -A INPUT -p tcp -s <your seafile server host> --dport 4080 -j ACCEPT
        sudo iptables -A INPUT -p tcp --dport 4080 -j DROP
        ```


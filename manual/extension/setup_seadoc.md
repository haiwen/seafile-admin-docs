# SeaDoc Integration

SeaDoc is an extension of Seafile that providing an online collaborative document editor.

SeaDoc designed around the following key ideas:

* An expressive easy to use editor
* A review and approval workflow to better control how contents changes
* Inter-document linking for connecting related contents
* AI integration that streamlines content generation, summarization, and management
* Comprehensive APIs for automating document generating and processing

SeaDoc excels at:

* Authoring product and technical documents
* Creating knowledge base articles and online manuals
* Building internal Wikis

## Architecture

The SeaDoc archticture is demonstrated as below:

![SeaDoc](../images/seadoc-arch.png)

Here is the workflow when a user open sdoc file in browser

1. When a user open a sdoc file in the browser, a file loading request will be sent to Caddy, and Caddy proxy the request to SeaDoc server (see [Seafile instance archticture](../setup/overview.md) for the details).
2. SeaDoc server will send the file's content back if it is already cached, otherwise SeaDoc server will sends a request to Seafile server.
3. Seafile server loads the content, then sends it to SeaDoc server and write it to the cache at the same time.
4. After SeaDoc receives the content, it will be sent to the browser.

## Deployment SeaDoc

!!! success "Default extension in Docker deployment"
    This extension is already installed by default when deploying Seafile (single-node mode) by [Docker](../setup/setup_ce_by_docker.md). 

    If you would like to remove it, you can undo the steps in this section (i.e., remove the `seadoc.yml` in the field `COMPOSE_FILE` and set `ENABLE_SEADOC` to `false`) 

The easiest way to deployment SeaDoc is to deploy it with Seafile server on the same host using the same Docker network. If in some situations, you need to deployment SeaDoc standalone, you can follow the next section.

1. Download the `seadoc.yml` to `/opt/seafile`

    ```shell
    wget https://manual.seafile.com/13.0/repo/docker/seadoc.yml
    ```

2. Modify `.env`, and insert `seadoc.yml` into `COMPOSE_FILE`, and enable SeaDoc server

    ```shell
    COMPOSE_FILE='seafile-server.yml,caddy.yml,seadoc.yml'

    ENABLE_SEADOC=true
    SEADOC_SERVER_URL=https://seafile.example.com/sdoc-server
    ```

3. Start SeaDoc server server with the following command

    ```sh
    docker compose up -d
    ```

Now you can use SeaDoc!


## Deploy SeaDoc standalone

If you deploy Seafile in a cluster or if you deploy Seafile with binary package, you need to setup SeaDoc as a standalone service. Here are the steps:

1. Download and modify the `.env` and `seadoc.yml` files to directory `/opt/seadoc`

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/seadoc/seadoc.yml
    wget -O .env https://manual.seafile.com/13.0/repo/docker/seadoc/env
    ```

2. Then modify the `.env` file according to your environment. The following fields are needed to be modified:

    | variable               | description                                                                                                   |  
    |------------------------|---------------------------------------------------------------------------------------------------------------|  
    | `SEADOC_VOLUME`        | The volume directory of SeaDoc data                                                                            |  
    | `SEAFILE_MYSQL_DB_HOST`| Seafile MySQL host                                                                                            |  
    | `SEAFILE_MYSQL_DB_USER`| Seafile MySQL user, default is `seafile`                                                                       |  
    | `SEAFILE_MYSQL_DB_PASSWORD`| Seafile MySQL password                                                                                    |  
    | `TIME_ZONE`            | Time zone                                                                                                     |  
    | `JWT_PRIVATE_KEY`      | JWT key, the same as the config in Seafile `.env` file                                                         |  
    | `SEAFILE_SERVER_HOSTNAME`| Seafile host name                                                                                           |  
    | `SEAFILE_SERVER_PROTOCOL`| http or https                                                                                               |  

3. (Optional) By default, SeaDoc server will bind to port 80 on the host machine. If the port is already taken by another service, ***you have to change the listening port of SeaDoc***:

    Modify `seadoc.yml`

    ```yml
    services:
        seadoc:
        ...
        ports:
            - "<your SeaDoc server port>:80"
    ...
    ```

4. Add a reverse proxy for SeaDoc server. In cluster environtment, it means you need to add reverse proxy rules at load balance. Here, we use Nginx as an example  (**please replace `127.0.0.1:80` to `host:port` of your Seadoc server**)

=== "Nginx"

    ```
    ...
    server {
        ...

        location /sdoc-server/ {
            proxy_pass         http://127.0.0.1:80/;
            proxy_redirect     off;
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
            proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host  $server_name;
            proxy_set_header   X-Forwarded-Proto $scheme;

            client_max_body_size 100m;
        }

        location /socket.io {
            proxy_pass http://127.0.0.1:80;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_redirect off;

            proxy_buffers 8 32k;
            proxy_buffer_size 64k;

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-NginX-Proxy true;
        }
    }
    ```

=== "Apache"

    ```
        <Location /sdoc-server/>
            ProxyPass "http://127.0.0.1:80/"
            ProxyPassReverse "http://127.0.0.1:80/"
        </Location>

        <Location /socket.io/>
            # Since Apache HTTP Server 2.4.47
            ProxyPass "http://127.0.0.1:80/socket.io/" upgrade=websocket
        </Location>
    ```

5. Start SeaDoc server server with the following command

    ```sh
    docker compose up -d
    ```

6. Modify Seafile server's configuration and start SeaDoc server

    !!! warning
        After using a reverse proxy, your SeaDoc service will be located at the `/sdoc-server` path of your reverse proxy (i.e. `xxx.example.com/sdoc-server`). For example:

        - Proxy server host: xxx.example.com
        - SeaDoc server: seadoc.example.com:8888

        Then `SEADOC_SERVER_URL` will be
        ```
        http{s}://xxx.example.com/sdoc-server
        ```

    Modify `.env` in your **Seafile-server** host:

    ```sh
    ENABLE_SEADOC=true
    SEADOC_SERVER_URL=https://seafile.example.com/sdoc-server
    ```

    Restart Seafile server

    === "Deploy in Docker (including cluster mode)"
        ```sh
        docker compose down
        docker compose up -d
        ```
    === "Deploy from binary packages"
        ```sh
        cd /opt/seafile/seafile-server-latest
        ./seahub.sh restart
        ```


## SeaDoc directory structure

`/opt/seadoc-data`

Placeholder spot for shared volumes. You may elect to store certain persistent information outside of a container, in our case we keep various log files outside. This allows you to rebuild containers easily without losing important information.

* /opt/seadoc-data/logs: This is the directory for SeaDoc logs.

## Database used by SeaDoc

SeaDoc used one database table `seahub_db.sdoc_operation_log` to store operation logs. The database table is cleaned automatically.

## Common issues when settings up SeaDoc

### "Server is disconnected. Reconnecting…" error when open a sdoc

This is because websocket for sdoc-server has not been properly configured. If you use the default Caddy proxy, it should be setup correctly.

But if you use your own proxy, you need to make sure it properly proxy `your-sdoc-server-domain/socket.io` to `sdoc-server-docker-image-address/socket.io`

### "Load doc content error" when open a sdoc

This is because the browser cannot correctly load content from sdoc-server. Make sure

* SEADOC_SERVER_URL is correctly set in `.env`
* Make sure sdoc-server can be accessed via the browser.

You can open developer console of the browser to further debug the issue.

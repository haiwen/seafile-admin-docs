# Deploy Seafile cluster with Kubernetes (K8S) by Seafile Helm Chart

This manual explains how to deploy and run Seafile cluster on a Linux server using [*Seafile Helm Chart*](https://github.com/seafileltd/seafile-helm-chart) (***chart*** thereafter). You can also refer to here to use K8S resource files to deploy Seafile cluster in your K8S cluster.

## Prerequisites

## Cluster requirements

Please refer [here](./system_requirements.md#seafile-cluster) for the details about the cluster requirements for **all nodes** in Seafile cluster. In general, we recommend that each node should have at least 2G RAM and a 2-core CPU (> 2GHz).

### K8S tools

Two tools are suggested and can be installed with [official installation guide](https://kubernetes.io/docs/tasks/tools/) **on all nodes**:

- ***kubectl***
- ***k8s control plane tool*** (e.g., ***kubeadm***)

After installation, you need to start the k8s control plane service on each node and refer to the k8s official manual for [creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

!!! tip
    Although we recommend installing the *k8s control plane tool* on each node, it does not mean that we will use each node as a control plane node, but it is a necessary tool to create or join a K8S cluster. For details, please refer to the above [link](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) about **creating or joining into a cluster**.

### Install Seafile helm chart

1. Create namespace

    ```
    kubectl create namespace seafile
    ```

2. Create a secret for sensitive data

    ```sh
    kubectl create secret generic seafile-secret --namespace seafile \
    --from-literal=JWT_PRIVATE_KEY='<required>' \
    --from-literal=SEAFILE_MYSQL_DB_PASSWORD='<required>' \
    --from-literal=INIT_SEAFILE_ADMIN_PASSWORD='<required>' \
    --from-literal=INIT_SEAFILE_MYSQL_ROOT_PASSWORD='<required>' \
    --from-literal=INIT_S3_SECRET_KEY=''  
    ```

    where the `JWT_PRIVATE_KEY` can be generate by `pwgen -s 40 1`

3. Download and modify the `my-values.yaml` according to your configurations. By the way, you can follow [here](./setup_pro_by_docker.md#downloading-and-modifying-env) for the details:

    ```sh
    wget -O my-values.yaml https://haiwen.github.io/seafile-helm-chart/values/latest/cluster.yaml

    nano my-values.yaml
    ```

    !!! tip
        - It is not necessary to use the `my-values.yaml` we provided (i.e., you can create an empty `my-values.yaml` and add required field, as others have defined default values in our chart), because it destroys the flexibility of deploying with Helm, but it contains some formats of how Seafile Helm Chart reads these configurations, as well as all the environment variables and secret variables that can be read directly.
        - In addition, you can also create a custom ***storageClassName*** for the persistence directory used by Seafile. You only need to specify `storageClassName` in the `seafile.config.seafileDataVolume` object in `my-values.yaml`:

            ```yaml
            seafile:
              configs:
                seafileDataVolume:
                  storageClassName: <your seafile storage class name>
              ...
            ```

4. Then install the chart use the following command:

    ```sh
    helm repo add seafile https://haiwen.github.io/seafile-helm-chart/repo
    helm upgrade --install seafile seafile/cluster  --namespace seafile --create-namespace --values my-values.yaml
    ```
    !!! success
        After installing the chart, the cluster is going to initial progress, you can see the following message by `kubectl logs seafile-<string> -n seafile`:

        ```log
        Defaulted container "seafile-backend" out of: seafile-backend, set-ownership (init)
        *** Running /etc/my_init.d/01_create_data_links.sh...
        *** Booting runit daemon...
        *** Runit started as PID 15
        *** Running /scripts/enterpoint.sh...
        2025-02-13 08:58:35 Nginx ready 
        2025-02-13 08:58:35 This is an idle script (infinite loop) to keep container running. 

        ---------------------------------

        Seafile cluster backend mode

        ---------------------------------

        [2025-02-13 08:58:35] Now running setup-seafile-mysql.py in auto mode.
        Checking python on this machine ...


        verifying password of user root ...  done

        ---------------------------------
        This is your configuration
        ---------------------------------

            server name:            seafile
            server ip/domain:       10.0.0.138

            seafile data dir:       /opt/seafile/seafile-data
            fileserver port:        8082

            database:               create new
            ccnet database:         ccnet_db
            seafile database:       seafile_db
            seahub database:        seahub_db
            database user:          seafile


        Generating seafile configuration ...

        done
        Generating seahub configuration ...

        ----------------------------------------
        Now creating seafevents database tables ...

        ----------------------------------------
        ----------------------------------------
        Now creating ccnet database tables ...

        ----------------------------------------
        ----------------------------------------
        Now creating seafile database tables ...

        ----------------------------------------
        ----------------------------------------
        Now creating seahub database tables ...

        ----------------------------------------


        -----------------------------------------------------------------
        Your seafile server configuration has been finished successfully.
        -----------------------------------------------------------------


        [2025-02-13 08:58:36] Updating version stamp
        Start init

        Init success

        ```

5. After the first-time startup, you have to turn off (i.e., set `initMode` to `false`) in your `my-values.yaml`, then upgrade the chart:

    ```sh
    helm upgrade --install seafile seafile/cluster  --namespace seafile --create-namespace --values my-values.yaml
    ```

    !!! success
        You can check any front-end node in Seafile cluster. If the following information is output, Seafile cluster will run normally in your cluster:

        ```log
        Defaulted container "seafile-frontend" out of: seafile-frontend, set-ownership (init)
        *** Running /etc/my_init.d/01_create_data_links.sh...
        *** Booting runit daemon...
        *** Runit started as PID 21
        *** Running /scripts/enterpoint.sh...
        2025-02-13 09:23:49 Nginx ready 
        2025-02-13 09:23:49 This is an idle script (infinite loop) to keep container running. 

        ---------------------------------

        Seafile cluster frontend mode

        ---------------------------------


        Starting seafile server, please wait ...
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(86): fileserver: web_token_expire_time = 3600
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(98): fileserver: max_index_processing_threads= 3
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(111): fileserver: fixed_block_size = 8388608
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(123): fileserver: max_indexing_threads = 1
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(138): fileserver: put_head_commit_request_timeout = 10
        [seaf-server] [2025-02-13 09:23:50] [INFO] seafile-session.c(150): fileserver: skip_block_hash = 0
        [seaf-server] [2025-02-13 09:23:50] [INFO] ../common/seaf-utils.c(581): Use database Mysql
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(243): fileserver: worker_threads = 10
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(256): fileserver: backlog = 32
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(267): fileserver: verify_client_blocks = 1
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(289): fileserver: cluster_shared_temp_file_mode = 600
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(336): fileserver: check_virus_on_web_upload = 0
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(362): fileserver: enable_async_indexing = 0
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(374): fileserver: async_indexing_threshold = 700
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(386): fileserver: fs_id_list_request_timeout = 300
        [seaf-server] [2025-02-13 09:23:50] [INFO] http-server.c(399): fileserver: max_sync_file_count = 100000
        [seaf-server] [2025-02-13 09:23:50] [WARNING] ../common/license.c(716): License file /opt/seafile/seafile-license.txt does not exist, allow at most 3 trial users
        License file /opt/seafile/seafile-license.txt does not exist, allow at most 3 trial users
        [seaf-server] [2025-02-13 09:23:50] [INFO] filelock-mgr.c(1397): Cleaning expired file locks.
        [2025-02-13 09:23:52] Start Monitor 
        [2025-02-13 09:23:52] Start seafevents.main 
        /opt/seafile/seafile-pro-server-12.0.9/seahub/seahub/settings.py:1101: SyntaxWarning: invalid escape sequence '\w'
        match = re.search('^EXTRA_(\w+)', attr)
        /opt/seafile/seafile-pro-server-12.0.9/seahub/thirdpart/seafobj/mc.py:13: SyntaxWarning: invalid escape sequence '\S'
        match = re.match('--SERVER\\s*=\\s*(\S+)', mc_options)
        Seafile server started

        Done.

        Starting seahub at port 8000 ...



        ----------------------------------------
        Successfully created seafile admin
        ----------------------------------------

        [seafevents] [2025-02-13 09:23:55] [INFO] root:82 LDAP is not set, disable ldap sync.
        [seafevents] [2025-02-13 09:23:55] [INFO] virus_scan:51 [virus_scan] scan_command option is not found in seafile.conf, disable virus scan.
        [seafevents] [2025-02-13 09:23:55] [INFO] seafevents.app.mq_handler:127 Subscribe to channels: {'seaf_server.stats', 'seahub.stats', 'seaf_server.event', 'seahub.audit'}
        [seafevents] [2025-02-13 09:23:55] [INFO] root:534 Start counting user activity info..
        [seafevents] [2025-02-13 09:23:55] [INFO] root:547 [UserActivityCounter] update 0 items.
        [seafevents] [2025-02-13 09:23:55] [INFO] root:240 Start counting traffic info..
        [seafevents] [2025-02-13 09:23:55] [INFO] root:268 Traffic counter finished, total time: 0.0003578662872314453 seconds.
        [seafevents] [2025-02-13 09:23:55] [INFO] root:23 Start file updates sender, interval = 300 sec
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:57 Can not start work weixin notice sender: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [INFO] root:131 search indexer is started, interval = 600 sec
        [seafevents] [2025-02-13 09:23:55] [INFO] root:56 seahub email sender is started, interval = 1800 sec
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:17 Can not start ldap syncer: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:18 Can not start virus scanner: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [INFO] root:35 Start data statistics..
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:40 Can not start content scanner: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:46 Can not scan repo old files auto del days: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [INFO] root:182 Start counting total storage..
        [seafevents] [2025-02-13 09:23:55] [WARNING] root:78 Can not start filename index updater: it is not enabled!
        [seafevents] [2025-02-13 09:23:55] [INFO] root:113 search wiki indexer is started, interval = 600 sec
        [seafevents] [2025-02-13 09:23:55] [INFO] root:87 Start counting file operations..
        [seafevents] [2025-02-13 09:23:55] [INFO] root:403 Start counting monthly traffic info..
        [seafevents] [2025-02-13 09:23:55] [INFO] root:491 Monthly traffic counter finished, update 0 user items, 0 org items, total time: 0.0905158519744873 seconds.
        [seafevents] [2025-02-13 09:23:55] [INFO] root:203 [TotalStorageCounter] No results from seafile-db.
        [seafevents] [2025-02-13 09:23:55] [INFO] root:169 [FileOpsCounter] Finish counting file operations in 0.09510159492492676 seconds, 0 added, 0 deleted, 0 visited, 0 modified

        Seahub is started

        Done.
        ```

6. If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container. The volumne's default path in the Compose file is `/opt/seafile/shared`. If you have modified the path, save the license file under your custom path.

    !!! danger "If the license file has a different name or cannot be read, Seafile server will start with in trailer mode with most THREE users"

    Then restart Seafile:

    ```bash
    kubectl delete pods -n seafile $(kubectl get pods -n seafile -o jsonpath='{.items[*].metadata.name}' | grep seafile)
    ```

    !!! tip "A safer way to use your Seafile license file"
        You can also create a *secret* resource to encrypt your license file in your K8S cluster, which is a safer way:

        ```sh
        kubectl create secret generic seafile-license --from-file=seafile-license.txt=$PATH_TO_YOUR_LICENSE_FILE --namespace seafile
        ```

        Then modify `my-values.yaml` to add the information extra volumes:

        ```yaml
        seafile:
        ...
        extraVolumes:
            backend:
                - name: seafileLicense
                volumeInfo:
                    secret:
                    secretName: seafile-license
                        items:
                        - key: seafile-license.txt
                            path: seafile-license.txt
                subPath: seafile-license.txt
                mountPath: /shared/seafile/seafile-license.txt
                readOnly: true
            frontend:
                - name: seafileLicense
                volumeInfo:
                    secret:
                    secretName: seafile-license
                        items:
                        - key: seafile-license.txt
                            path: seafile-license.txt
                subPath: seafile-license.txt
                mountPath: /shared/seafile/seafile-license.txt
                readOnly: true
        ```

        Finally you can upgrade your chart by:

        ```sh
        helm upgrade --install seafile seafile/cluster  --namespace seafile --create-namespace --values my-values.yaml
        ```

## Version control

Seafile Helm Chart is designed to provide fast deployment and version control. You can update and rollback versions using the following setps:

1. Update Helm repo

    ```sh
    helm repo update
    ```

    !!! tip
        When using the repo update command, this will not always take effect immediately, as the previous repo will be stored in the cache.

2. Download (optional) and modify the new `my-values.yaml`

    ```sh
    wget -O my-values.yaml https://haiwen.github.io/seafile-helm-chart/values/<release-version>/cluster.yaml

    nano my-values.yaml
    ```

    !!! tip "About version of *Seafile Helm Chart* and *Seafile*"
        The version of Seafile Helm Chart is same as the major version of Seafile, i.e.:

        - latest Seafile: 12.0.9
        - latest Seafile Helm Chart release: 12.0

        By default, it will follow the latest Chart and the latest Seafile

3. Upgrade release to a new version

    ```sh
    helm upgrade --install seafile seafile/cluster --namespace seafile --create-namespace --values my-values.yaml --version <release-version>
    ```

4. (Rollback) if you would like rollback to your old-running release, you can use following command to rollback your current instances

    ```sh
    helm rollback seafile -n seafile <revision>
    ```

## Uninstall chart

You can uninstall chart by the following command:

```sh
helm delete seafile --namespace seafile
```

## Advanced operations

Please refer from [here](./k8s_advanced_management.md) for futher advanced operations.
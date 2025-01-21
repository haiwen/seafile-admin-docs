# Deploy Seafile cluster with Kubernetes (K8S)

This manual explains how to deploy and run Seafile cluster on a Linux server using *Kubernetes* (***k8s*** thereafter). 

## Prerequisites

### System requirements

In theory, you only need to prepare one node to deploy a cluster, but this does not conform to the K8S design concept, so we recommend that you prepare at least 3 nodes ():

- **Two** nodes for starting the Seafile frontend service
- **One** node for starting the Seafile backend service

For each node, you have to prepare at least **2 cores** cpu, **2G RAM** and 10G disk space.

!!! note "More details about System requirements"
    We assume you have already deployed memory cache server (e.g., ***Memcached***), ***MariaDB***, file indexer (e.g., ***ElasticSearch***) in separate machines and use ***S3*** like object storage. 
    
    - If some of the above services are deployed on one of the nodes, you may need to prepare more space for the node. Especially for ***ElasticSearch***, you need to prepare at least **4 cores** cpu, **4GB** memory and more disk space on the node. If you donnot have enough hardware requirements for *ElasticSearch*, you can use [*SeaSearch*](./use_seasearch.md) as search engine, which is more lightweight.

    - Generally, when deploying Seafile in a cluster, we recommend that you use a storage backend (such as AWS S3) to store Seafile data. However, according to the Seafile image startup rules and K8S persistent storage strategy, you still need to prepare a persistent directory for configuring the startup of the Seafile container. In this document, we use the following path for the persistent directory with maximum 10GB space:

        ```
        /opt/seafile/shared
        ```

        If you would like to change it or increase the space, you should modify the `seafile-persistentvolume.yaml` and `seafile-persistentvolumeclaim.yaml` in this document.

!!! tip "More details about the number of nodes"
    1. If your number of nodes does not meet our recommended number (i.e. 3 nodes), please adjust according to the following strategies:
        - **2 nodes**: A frontend service and a backend service on the same node
        - **1 node**: Please refer [here](./k8s_single_node.md) to deploy Seafile in a K8S single node instead a cluster.
    2. If you have more available nodes for Seafile server, please provide them to the Seafile frontend service and **make sure there is only one backend service running**. Here is a simple relationship between the number of Seafile frontent services ($N_f$) and total nodes ($N_t$):
        $$
        N_f = N_t - 1,
        $$
        where the number **1** means one node for Seafile backend service.

### K8S tools

Two tools are suggested and can be installed with [official installation guide](https://kubernetes.io/docs/tasks/tools/) **on all nodes**:

- ***kubectl***
- ***k8s control plane tool*** (e.g., ***kubeadm***)

After installation, you need to start the k8s control plane service on each node and refer to the k8s official manual for [creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

!!! tip
    Although we recommend installing the *k8s control plane tool* on each node, it does not mean that we will use each node as a control plane node, but it is a necessary tool to create or join a K8S cluster. For details, please refer to the above [link](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) about **creating or joining into a cluster**.

## Download K8S YAML files for Seafile cluster (without frontend node)

```sh
mkdir -p /opt/seafile-k8s-yaml

wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-backend-deployment.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-persistentvolume.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-persistentvolumeclaim.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-service.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-env.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-secret.yaml
```


In here we suppose you download the YAML files in `/opt/seafile-k8s-yaml`, which mainly include about:

- `seafile-xx-deployment.yaml` for frontend and backend services pod management and creation, 
- `seafile-service.yaml` for exposing Seafile services to the external network, 
- `seafile-persistentVolume.yaml` for defining the location of a volume used for persistent storage on the host
- `seafile-persistentvolumeclaim.yaml` for declaring the use of persistent storage in the container.

For futher configuration details, you can refer [the official documents](https://kubernetes.io/docs/tasks/configure-pod-container/).

## Modify `seafile-env.yaml` and `seafile-secret.yaml`

Similar to Docker-base deployment, Seafile cluster in K8S deployment also supports use files to configure startup progress, you can modify common [environment variables](./setup_pro_by_docker.md#downloading-and-modifying-env) by

```sh
nano /opt/seafile-k8s-yaml/seafile-env.yaml
```

and sensitive information (e.g., password) by

```sh
nano /opt/seafile-k8s-yaml/seafile-secret.yaml
```

!!! note "For `seafile-secret.yaml`"
    To modify sensitive information (e.g., password), you need to convert the password into base64 encoding before writing it into the `seafile-secret.yaml` file:

    ```sh
    echo -n '<your-value>' | base64
    ```

!!! warning
    For the fields marked with `<...>` are **required**, please make sure these items are filled in, otherwise Seafile server may not run properly.

## Initialize Seafile cluster
You can use following command to initialize Seafile cluster now:

```shell
kubectl apply -f /opt/seafile-k8s-yaml/
```

!!! note "About Seafile cluster initialization"
    When Seafile cluster is initializing, it will run with the following conditions:

    - Only have backend service (i.e., only has the Seafile backend K8S resouce file)
    - `CLUSTER_INIT_MODE=true`

!!! success
    You can get the following information through `kubectl logs seafile-xxxx` (for details about this opeartions, please refer to [here](#container-management)) to check the initialization process is done or not:

    ```
    ---------------------------------
    This is your configuration
    ---------------------------------
    
        server name:            seafile
        server ip/domain:       seafile.example.com
    
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
    
    
    -----------------------------------------------------------------
    Your seafile server configuration has been finished successfully.
    -----------------------------------------------------------------
    
    
    [2024-11-21 02:22:37] Updating version stamp
    Start init
    
    Init success
    ```

    When the initialization is complete, the server will stop automaticlly (because no operations will be performed after the initialization is completed). 
    
    We recommend that you check whether the contents of the configuration files in `/opt/seafile/shared/seafile/conf` are correct when going to next step, which are automatically generated during the initialization process.

## Put the license into `/opt/seafile/shared`

You have to locate the `/opt/seafile/shared` directory generated during initialization firsly, then simply put it in this path, if you have a `seafile-license.txt` license file. 

Finally you can use the `tar -zcvf` and `tar -zxvf` commands to package the entire `/opt/seafile/shared` directory of the current node, copy it to other nodes, and unpack it to the same directory to take effect on all nodes.

!!! danger "If the license file has a different name or cannot be read, Seafile server will start with in trailer mode with most THREE users"

## Download frontend service's YAML and restart pods to start Seafile server

1. Download frontend service's YAML by:

    ```sh
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/cluster/seafile-frontend-deployment.yaml
    ```

2. Modify `seafile-env.yaml`, and set `CLUSTER_INIT_MODE` to `false` (i.e., disable initialization mode)

3. Run the following command to restart pods to restart Seafile cluster:

    !!! tip
        If you modify some configurations in `/opt/seafile/shared/seafile/conf` or YAML files in `/opt/seafile-k8s-yaml/`, you still need to restart services to make modifications.

    ```shell
    kubectl delete -f /opt/seafile-k8s-yaml/
    kubectl apply -f /opt/seafile-k8s-yaml/
    ```

!!! sucess
    You can [view the pod's log](#container-management) to check the startup progress is normal or not. You can see the following message if server is running normally:

    ```
    *** Running /etc/my_init.d/01_create_data_links.sh...
    *** Booting runit daemon...
    *** Runit started as PID 20
    *** Running /scripts/enterpoint.sh...
    2024-11-21 03:02:35 Nginx ready 

    2024-11-21 03:02:35 This is an idle script (infinite loop) to keep container running. 
    ---------------------------------

    Seafile cluster frontend mode

    ---------------------------------


    Starting seafile server, please wait ...
    Seafile server started

    Done.

    Starting seahub at port 8000 ...

    Seahub is started

    Done.
    ```

## Container management

Similar to docker installation, you can also manage containers through [some kubectl commands](https://kubernetes.io/docs/reference/kubectl/#operations). For example, you can use the following command to check whether the relevant resources are started successfully and whether the relevant services can be accessed normally. First, execute the following command and remember the pod name with `seafile-<node type>-` as the prefix (such as `seafile-frontend-748b695648-d6l4g`)

```shell
kubectl get pods
```

You can check a status of a pod by 

```shell
kubectl logs seafile-frontend-748b695648-d6l4g
```

and enter a container by

```shell
kubectl exec -it seafile-frontend-748b695648-d6l4g --  bash
```

## Load balance and HTTPS

When deploying a Seafile cluster using K8S, you can enable HTTPS and use load balance in the following two ways:

- External load balancing server, such as *Nginx*. Typically you will need to reverse proxy `http://<your control plane>/`
- K8S Gateway API, e.g., [Nginx-gateway](https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/) and [Istio-gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/)

Finally, you should modify the related URLs in `seahub_settings.py`, from `http://` to `https://`:

```py
SERVICE_URL = "https://seafile.example.com"
FILE_SERVER_ROOT = 'https://seafile.example.com/seafhttp'
```

## Log routing and aggregation system

Similar to [Single-pod Seafile](./k8s_single_node.md), you can browse the log files of Seafile running directly in the persistent volume directory. The difference is that when using K8S to deploy a Seafile cluster (especially in a cloud environment), the persistent volume created is usually shared and synchronized for all nodes. However, ***the logs generated by the Seafile service do not record the specific node information where these logs are located***, so browsing the files in the above folder may make it difficult to identify which node these logs are generated from. Therefore, one solution proposed here is:

1. Record the generated logs to the standard output. In this way, the logs can be distinguished under each node by `kubectl logs` (but all types of logs will be output together now). You can enable this feature (**it should be enabled by default in K8S Seafile cluster but not in K8S single-pod Seafile**) by modifing `SEAFILE_LOG_TO_STDOUT` to `true` in `seafile-env.yaml`:

    ```yaml
    ...
    data:
      ...
      SEAFILE_LOG_TO_STDOUT: "true"
      ...
    ```

    Then restart the Seafile server:

    ```sh
    kubectl delete -f /opt/seafile-k8s-yaml/
    kubectl apply -f /opt/seafile-k8s-yaml/
    ```

2. Since the logs in step 1 can be distinguished between nodes, but they are aggregated and output together, it is not convenient for log retrieval. So you have to route the standard output logs (i.e., distinguish logs by corresponding components name) and re-record them in a new file or upload them to a log aggregation system (e.g., [*Loki*](https://grafana.com/oss/loki/)).

Currently in the K8S environment, the commonly used log routing plugins are:

- [*Fluent Bit*](https://fluentbit.io/)
- [*Fluentd*](https://www.fluentd.org/)
- [*Logstash*](https://www.elastic.co/logstash/)
- [*Promtail*](https://grafana.com/loki/docs/sources/promtail/) (also a part of Loki)

***Fluent Bit*** and ***Promtail*** are more lightweight (i.e., consume less system resources), while *Promtail* only supports transferring logs to *Loki*. Therefore, this document will mainly introduce log routing through ***Fluent Bit*** which is a fast, lightweight logs and metrics agent. It is also a CNCF graduated sub-project under the umbrella of *Fluentd*. *Fluent Bit* is licensed under the terms of the Apache License v2.0. You should deploy the *Fluent Bit* in your K8S cluster by following [offical document](https://docs.fluentbit.io/manual/installation/kubernetes) firstly. Then modify Fluent-Bit pod settings to mount a new directory to load the configuration files:

```yaml
#kubectl edit ds fluent-bit

...
spec:
    ...
    spec:
        ...
        containers:
        - name: fluent-bit
          volumeMounts:
            ...
            - mountPath: /fluent-bit/etc/seafile
              name: fluent-bit-seafile
            - mountPath: /
        ...
    ...
    volumes:
    ...
    - hostPath:
        path: /opt/fluent-bit
      name: fluent-bit-seafile
```

and

```yaml
#kubectl edit cm fluent-bit

data:
    ...
    fluent-bit.conf: |
        [SERVICE]
            ...
            Parsers_File /fluent-bit/etc/seafile/confs/parsers.conf
        ...
        @INCLUDE /fluent-bit/etc/seafile/confs/*-log.conf
```

For example in here, we use `/opt/fluent-bit/confs` (**it has to be non-shared**). What's more, the parsers will be defined in `/opt/fluent-bit/confs/parsers.conf`, and for each type log (e.g., *seahub*'s log, *seafevent*'s log) will be defined in `/opt/fluent-bit/confs/*-log.conf`. Each `.conf` file defines several Fluent-Bit data pipeline components:

| **Pipeline** | **Description** | **Required/Optional** |
| ------------- | --------------- | --------------------- |
| **INPUT**     | Specifies where and how Fluent-Bit can get the original log information, and assigns a tag for each log record after read.       | Required |
| **PARSER**    | Parse the read log records. For K8S Docker runtime logs, they are usually in Json format.     | Required |
| **FILTER**    | Filters and selects log records with a specified tag, and assigns a new tag to new records.    | Optional |
| **OUTPUT**    | tells Fluent-Bit what format the log records for the specified tag will be in and where to output them (such as file, *Elasticsearch*, *Loki*, etc.).      | Required |

!!! warning
    For ***PARSER***, it can only be stored in `/opt/fluent-bit/confs/parsers.conf`, otherwise the Fluent-Bit cannot startup normally.

### Inputer

According to the above, a container will generate a log file (usually in `/var/log/containers/<container-name>-xxxxxx.log`), so you need to prepare an importer and add the following information (for more details, please refer to offical document about [*TAIL inputer*](https://docs.fluentbit.io/manual/pipeline/inputs/tail)) in `/opt/fluent-bit/confs/seafile-log.conf`:

```conf
[INPUT]
    Name              tail
    Path              /var/log/containers/seafile-frontend-*.log
    Buffer_Chunk_Size 2MB
    Buffer_Max_Size   10MB
    Docker_Mode       On
    Docker_Mode_Flush 5
    Tag               seafile.*
    Parser            Docker # for definition, please see the next section as well

[INPUT]
    Name              tail
    Path              /var/log/containers/seafile-backend-*.log
    Buffer_Chunk_Size 2MB
    Buffer_Max_Size   10MB
    Docker_Mode       On
    Docker_Mode_Flush 5
    Tag               seafile.*
    Parser            Docker
```

The above defines two importers, which are used to monitor seafile-frontend and seafile-backend services respectively. The reason why they are written together here is that for a node, you may not know when it will run the frontend service and when it will run the backend service, but they have the same tag prefix `seafile.`.

### Parser

Each input has to use a parser to parse the logs and pass them to the filter. Here, a parser named `Docker` is created to parse the logs generated by the *K8S-docker-runtime container*. The parser is placed in `/opt/fluent-bit/confs/parser.conf` (for more details, please refer to offical document about [JSON parser](https://docs.fluentbit.io/manual/pipeline/parsers/json)):

```conf
[PARSER]
    Name        Docker
    Format      json
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%LZ

```

!!! tip "Log records after parsing"
    The logs of the Docker container are saved in /var/log/containers in **Json** format (see the sample below), which is why we use the `Json` format in the above parser.

    ```json
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(86): fileserver: web_token_expire_time = 3600\n","stream":"stdout","time":"2025-01-17T07:43:48.294638442Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(98): fileserver: max_index_processing_threads= 3\n","stream":"stdout","time":"2025-01-17T07:43:48.294810145Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(111): fileserver: fixed_block_size = 8388608\n","stream":"stdout","time":"2025-01-17T07:43:48.294879777Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(123): fileserver: max_indexing_threads = 1\n","stream":"stdout","time":"2025-01-17T07:43:48.295002479Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(138): fileserver: put_head_commit_request_timeout = 10\n","stream":"stdout","time":"2025-01-17T07:43:48.295082733Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] seafile-session.c(150): fileserver: skip_block_hash = 0\n","stream":"stdout","time":"2025-01-17T07:43:48.295195843Z"}
    {"log":"[seaf-server] [2025-01-17 07:43:48] [INFO] ../common/seaf-utils.c(553): Use database Mysql\n","stream":"stdout","time":"2025-01-17T07:43:48.29704895Z"}
    ```

    When these logs are obtained by the importer and parsed by the parser, they will become independent log records with the following fields:

    - `log`: The original log content (i.e., same as you seen in `kubectl logs seafile-xxx`) and an extra line break at the end (i.e., `\n`). **This is also the field we need to save or upload to the log aggregation system in the end**.
    - `stream`: The original log come from. `stdout` means the *standard output*.
    - `time`: The time when the log is recorded in the corresponding stream (ISO 8601 format).


### Filter

Add two filters in `/opt/fluent-bit/confs/seafile-log.conf` for records filtering and routing. Here, the [*record_modifier* filter](https://docs.fluentbit.io/manual/pipeline/filters/record-modifier) is to select useful keys (see the contents in above *tip* label, only the `log` field is what we need) in the log records and [*rewrite_tag* filter](https://docs.fluentbit.io/manual/pipeline/filters/rewrite-tag) is used to route logs according to specific rules:

```conf
[FILTER]        
    Name record_modifier
    Match seafile.*
    Allowlist_key log


[FILTER]
    Name        rewrite_tag
    Match       seafile.*
    Rule        $log ^.*\[seaf-server\].*$ seaf-server false # for seafile's logs
    Rule        $log ^.*\[seahub\].*$ seahub false # for seahub's logs
    Rule        $log ^.*\[seafevents\].*$ seafevents false # for seafevents' lgos
    Rule        $log ^.*\[seafile-slow-rpc\].*$ seafile-slow-rpc false # for slow-rpc's logs
```

### Output log's to *Loki*

Loki is multi-tenant log aggregation system inspired by *Prometheus*. It is designed to be very cost effective and easy to operate. The Fluent-Bit *loki* built-in output plugin allows you to send your log or events to a *Loki service*. It supports data enrichment with Kubernetes labels, custom label keys and Tenant ID within others.

!!! tip "Alternative Fluent-Bit Loki plugin by *Grafana*"
    For sending logs to Loki, there are [two plugins](https://grafana.com/docs/loki/latest/send-data/fluentbit/) for Fluent-Bit:

    - The [built-in *Loki* plugin](https://docs.fluentbit.io/manual/pipeline/outputs/loki) maintained by the Fluent-Bit officially, and we will use it in this part because it provides the most complete features.
    - [*Grafana-loki* plugin](https://grafana.com/docs/loki/latest/send-data/fluentbit/community-plugin/) maintained by *Grafana Labs*.


Due to each outputer dose not have a distinguishing marks in the configuration files (because Fluent-Bit takes each plugin as a tag workflow): 

- ***Seaf-server log***: Add an outputer to `/opt/fluent-bit/confs/seaf-server-log.conf`:

    ```conf
    [OUTPUT]
        Name        loki
        Match       seaf-server
        Host        <your Loki's host>
        port        <your Loki's port>
        labels      job=fluentbit, node_name=<your-node-name>, node_id=<your-node-id> # node_name and node_id is optional, but recommended for identifying the source node
    ```

- ***seahub log***: Add an outputer to `/opt/fluent-bit/confs/seahub-log.conf`:

    ```conf
    [OUTPUT]
        Name        loki
        Match       seahub
        Host        <your Loki's host>
        port        <your Loki's port>
        labels      job=fluentbit, node_name=<your-node-name>, node_id=<your-node-id> # node_name and node_id is optional, but recommended for identifying the source node
    ```

- ***seafevents log***: Add an outputer to `/opt/fluent-bit/confs/seafevents-log.conf`:

    ```conf
    [OUTPUT]
        Name        loki
        Match       seafevents
        Host        <your Loki's host>
        port        <your Loki's port>
        labels      job=fluentbit, node_name=<your-node-name>, node_id=<your-node-id> # node_name and node_id is optional, but recommended for identifying the source node
    ```

- ***seafile-slow-rpc log***: Add an outputer to `/opt/fluent-bit/confs/seafile-slow-rpc-log.conf`:

    ```conf
    [OUTPUT]
        Name        loki
        Match       seafile-slow-rpc
        Host        <your Loki's host>
        port        <your Loki's port>
        labels      job=fluentbit, node_name=<your-node-name>, node_id=<your-node-id> # node_name and node_id is optional, but recommended for identifying the source node
    ```

!!! tip "Cloud Loki instance"
    If you are using a cloud Loki instance, you can follow the [Fluent-Bit Loki plugin document](https://docs.fluentbit.io/manual/pipeline/outputs/loki) to fill up all necessary fields. Usually, the following fields are **additional needs** in cloud Loki service:

    - `tls`
    - `tls.verify`
    - `http_user`
    - `http_passwd`

# Seafile K8S advanced management

This document mainly describes how to manage and maintain Seafile deployed through our K8S deployment document. At the same time, if you are already proficient in using kubectl commands to manage K8S resources, you can also customize the deployment solutions we provide.

!!! note "Namespaces for Seafile K8S deployment"
    Our documentation provides two deployment solutions for both single-node and cluster deployment (via Seafile Helm Chart and K8S resource files), both of which can be highly customized.

    Regardless of which deployment method you use, in our newer manuals (usually in versions after Seafile 12.0.9), Seafile-related K8S resources (including related Pods, services, and persistent volumes, etc.) are defined in the `seafile` namespace. In previous versions, you may deploy Seafile in the `default` namespace, so in this case, when referring to this document for Seafile K8S resource management, be sure to remove `-n seafile` in the command.

## Seafile K8S Container management

Similar to docker installation, you can also manage containers through [some kubectl commands](https://kubernetes.io/docs/reference/kubectl/#operations). For example, you can use the following command to check whether the relevant resources are started successfully and whether the relevant services can be accessed normally. First, execute the following command and remember the pod name with `seafile-` as the prefix (such as `seafile-748b695648-d6l4g`)

```shell
kubectl get pods -n seafile
```

You can check a status of a pod by 

```shell
kubectl logs seafile-748b695648-d6l4g -n seafile
```

and enter a container by

```shell
kubectl exec -it seafile-748b695648-d6l4g -n seafile --  bash
```

Also, you can restart the services by the following commands:

```sh
kubectl delete pods -n seafile $(kubectl get pods -n seafile -o jsonpath='{.items[*].metadata.name}' | grep seafile)
```

## K8S Gateway and HTTPS

Since the support of Ingress feature [is frozen](https://kubernetes.io/docs/concepts/services-networking/ingress/) in the new version of K8S, this article will introduce how to use the new version of K8S feature [*K8S Gateway*](https://kubernetes.io/docs/concepts/services-networking/gateway/) to implement Seafile service exposure and load balancing.

!!! tip "Still use *Nginx-Ingress*"
    If your K8S is still using *Nginx-Ingress*, you can follow [here](https://artifacthub.io/packages/helm/datamate/seafile#deploy-an-ingress-controller-ingress-nginx) to setup ingress controller and HTTPS. We sincerely thanks *Datamate* to give an example to this configuration.

For the details and features about ***K8S Gateway***, please refer to the K8S [official document](https://kubernetes.io/docs/concepts/services-networking/gateway/#design-principles), you can simpily install it by

```sh
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

The *Gateway API* requires configuration of three API categories in its [resource model](https://kubernetes.io/docs/concepts/services-networking/gateway/#resource-model):
- `GatewayClass`: Defines a group of gateways with the same configuration, managed by the controller that implements the class.
- `Gateway`: Defines an instance of traffic handling infrastructure, which can be thought of as a load balancer.
- `HTTPRoute`: Defines HTTP-specific rules for mapping traffic from gateway listeners to representations of backend network endpoints. These endpoints are typically represented as Services.

### GatewayClass

The ***GatewayClass*** resource serves the same purpose as the `IngressClass` in the old-ingress API, similar to the *StorageClass* in the *Storage API.* It defines the categories of Gateways that can be created. Typically, this resource is provided by your infrastructure platform, such as EKS or GKE. It can also be provided by a third-party Ingress Controller, such as [Nginx-gateway](https://docs.nginx.com/nginx-gateway-fabric/overview/gateway-architecture/) or [Istio-gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/).

Here, we take the *Nginx-gateway* for the example, and you can install it with the [official document](https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/). After installation, you can view the installation status with the following command:

```sh
# `gc` means the `gatewayclass`, and its same as `kubectl get gatewayclass`
kubectl get gc 

#NAME    CONTROLLER                                   ACCEPTED   AGE
#nginx   gateway.nginx.org/nginx-gateway-controller   True       22s
```

Typically, after you install GatewayClass, your cloud provider will provide you with a load balancing IP, which is visible in GatewayClass. If this IP is not assigned, you can manually bind it to a IP that can be accessed from exteranl network.

```sh
kubectl edit svc nginx-gateway -n nginx-gateway
```

and modify the following section:

```yaml
...
spec:
    ...
    externalIPs:
    - <your external IP>
    externalTrafficPolicy: Cluster
    ...
...
```

### Gateway

***Gateway*** is used to describe an instance of traffic processing infrastructure. Usually, *Gateway* defines a network endpoint that can be used to process traffic, that is, to filter, balance, split, etc. Service and other backends. For example, it can represent a cloud load balancer, or a cluster proxy server configured to accept HTTP traffic. As above, please refer to the official documentation for a detailed description of [Gateway](https://kubernetes.io/docs/concepts/services-networking/gateway/#api-kind-gateway). Here is only a simple reference configuration for Seafile:

```yaml
# nano seafile-gateway/gateway.yaml

apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: seafile-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: seafile-http
    protocol: HTTP
    port: 80
```

### HTTPRoute

The ***HTTPRoute*** category specifies the routing behavior of HTTP requests from the *Gateway* listener to the backend network endpoints. For service backends, the implementation can represent the backend network endpoint as a service IP or a supporting endpoint of the service. it represents the configuration that will be applied to the underlying *Gateway* implementation. For example, defining a new *HTTPRoute* may result in configuring additional traffic routes in a cloud load balancer or in-cluster proxy server. As above, please refer to the official documentation for a detailed description of the [HTTPRoute](https://kubernetes.io/docs/concepts/services-networking/gateway/#api-kind-httproute) resource. Here is only a reference configuration solution that is only applicable to this document.

```yaml
# nano seafile-gateway/httproute.yaml

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: seafile-httproute
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: seafile-gateway
  hostnames:
  - "<your domain>"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: seafile
      port: 80

```

After installing or defining ***GatewayClass***, ***Gateway*** and ***HTTPRoute***, you can now enable this feature by following command and view your Seafile server by the URL `http://seafile.example.com/`:

```sh
kubectl apply -f seafile-gateway -n seafile
```

### Enable HTTPS (Optional)

When using *K8S Gateway*, a common way to enable HTTPS is to add relevant information about the TLS listener in *Gateway* resource. You can [refer here](https://gateway-api.sigs.k8s.io/guides/tls/#examples) for futher details. We will provide a simple way here so that you can quickly enable HTTPS for your Seafile K8S.

1. Create a *secret* resource (`seafile-tls-cert`) for your TLS certificates:

    ```sh
    kubectl create secret tls seafile-tls-cert \
    --cert=<your path to fullchain.pem> \
    --key=<your path to privkey.pem>
    ```
2. Use the TLS in your *Gateway* resource and enable HTTPS:

    ```yaml
    # nano seafile-gateway/gateway.yaml

    ...
    spec:
      ...
      listeners:
        - name: seafile-http
          ...
          tls:
            certificateRefs:
            - kind: Secret
                group: ""
                name: seafile-tls-cert
    ...
    ```

3. Modify `seahub_settings.py`:
    
    ```py
    SERVICE_URL = "https://<your domain>/"
    ```

4. Restart Seafile K8S Gateway:

    ```sh
    kubectl delete -f seafile-gateway -n seafile
    kubectl apply -f seafile-gateway -n seafile
    ```

    Now you can access your Seafile service in `https://<your domain>/`

## Log routing and aggregating system

Similar to single-node deployment, you can browse the log files of Seafile running directly in the persistent volume directory (i.e., `<path>/seafile/logs`). The difference is that when using K8S to deploy a Seafile cluster (especially in a cloud environment), the persistent volume created is usually shared and synchronized for all nodes. However, ***the logs generated by the Seafile service do not record the specific node information where these logs are located***, so browsing the files in the above folder may make it difficult to identify which node these logs are generated from. Therefore, one solution proposed here is:

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
    kubectl delete pods -n seafile $(kubectl get pods -n seafile -o jsonpath='{.items[*].metadata.name}' | grep seafile)
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

    - `log`: The original log content (i.e., same as you seen in `kubectl logs seafile-xxx -n seafile`) and an extra line break at the end (i.e., `\n`). **This is also the field we need to save or upload to the log aggregation system in the end**.
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

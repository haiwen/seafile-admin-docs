# Deploy Seafile cluster with Kubernetes (K8S)

This manual explains how to deploy and run Seafile Server on a Linux server using *Kubernetes* (***k8s*** thereafter). 

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
        - **1 node**: Please refer [here](./setup_pro_by_docker.md) to deploy Seafile in a single node instead of K8S.
    2. If you have more available nodes for Seafile server, please provide them to the Seafile frontend service and **make sure there is only one backend service running**. Here is a simple relationship between the number of Seafile frontent services ($N_f$) and total nodes ($N_t$):
        $$
        N_f = N_t - 1,
        $$
        where the number **1** means one node for Seafile backend service.

### About kubectl and k8s control plane

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

Similar to Docker-base deployment, Seafile cluster in K8S deployment also supports use files to configure startup progress, you can modify common environment variables by

```sh
nano /opt/seafile-k8s-yaml/seafile-env.yaml
```

and sensitive information (e.g., password) by

```sh
nano /opt/seafile-k8s-yaml/seafile-secret.yaml
```

!!! note "For `seafile-secret.yaml`"
    To modify sensitive words, you need to convert the password into base64 encoding and write it into the `seafile-secret.yaml` file:

    ```sh
    echo -n '<your-value>' | base64
    ```

!!! warning
    For the fields marked with `<...>` are **required**, please make sure these items are filled in, otherwise Seafile server may not run properly.

## Initialize Seafile cluster
You can use following command to initialize Seafile cluster:

```shell
kubectl apply -f /opt/seafile-k8s-yaml/
```

!!! note "About Seafile cluster initialization"
    When Seafile cluster is initialized, it will run under the following conditions:

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

    When the initialization is complete, the service will not run normally (because no operations will be performed after the initialization is completed). 
    
    We recommend that you check whether the contents of the configuration files in `/opt/seafile/shared/seafile/conf` are correct when going to next step, which are automatically generated during the initialization process.

## Put the license into `/opt/seafile/shared`

If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container (i.e., `/opt/seafile/shared`).

!!! danger "If the license file has a different name or cannot be read, Seafile server will start with in trailer mode with most THREE users"

## Copy `/opt/seafile/shared` to other nodes

You can use the `tar -zcvf` and `tar -zxvf` commands to package the entire `/opt/seafile/shared` directory of the current node, copy it to other nodes, and unpack it to the same directory.

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
    You can [view the pod's log](#container-management) to check the startup progress is normal or not, you will see the following message if server is running normally:

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

Similar to docker installation, you can also manage containers through [some kubectl commands](https://kubernetes.io/docs/reference/kubectl/#operations). For example, you can use the following command to check whether the relevant resources are started successfully and whether the relevant services can be accessed normally. First, execute the following command and remember the pod name with `seafile-` as the prefix (such as seafile-748b695648-d6l4g)

```shell
kubectl get pods
```

You can check a status of a pod by 

```shell
kubectl logs seafile-748b695648-d6l4g
```

and enter a container by

```shell
kubectl exec -it seafile-748b695648-d6l4g --  bash
```

## Load balance and HTTPS

When deploying a Seafile cluster using K8S, you can enable HTTPS and use load balance in the following two ways:

- External load balancing server, such as *Nginx*. Typically you will need to reverse proxy `http://<your control plane>/`
- K8S Gateway API, e.g., [Nginx-gateway](https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/) and [Istio-gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/)

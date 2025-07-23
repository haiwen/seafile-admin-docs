# Deploy Seafile cluster with Kubernetes (K8S) by K8S resources files

This manual explains how to deploy and run Seafile cluster on a Linux server using *Kubernetes* (***k8s*** thereafter). 

## Prerequisites

## Cluster requirements

Please refer [here](./system_requirements.md#seafile-cluster) for the details about the cluster requirements for **all nodes** in Seafile cluster.  In general, we recommend that each node should have at least 2G RAM and a 2-core CPU (> 2GHz).

### K8S tools

Two tools are suggested and can be installed with [official installation guide](https://kubernetes.io/docs/tasks/tools/) **on all nodes**:

- ***kubectl***
- ***k8s control plane tool*** (e.g., ***kubeadm***)

After installation, you need to start the k8s control plane service on each node and refer to the k8s official manual for [creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

!!! tip
    Although we recommend installing the *k8s control plane tool* on each node, it does not mean that we will use each node as a control plane node, but it is a necessary tool to create or join a K8S cluster. For details, please refer to the above [link](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) about **creating or joining into a cluster**.

## Create namespace and secretMap

```sh
kubectl create ns seafile

kubectl create secret generic seafile-secret --namespace seafile \
--from-literal=JWT_PRIVATE_KEY='<required>' \
--from-literal=SEAFILE_MYSQL_DB_PASSWORD='<required>' \
--from-literal=INIT_SEAFILE_ADMIN_PASSWORD='<required>' \
--from-literal=INIT_SEAFILE_MYSQL_ROOT_PASSWORD='<required>' \
--from-literal=REDIS_PASSWORD='' \
--from-literal=S3_SECRET_KEY='' \
--from-literal=S3_SSE_C_KEY=''
```

## Download K8S YAML files for Seafile cluster (without frontend node)

```sh
mkdir -p /opt/seafile-k8s-yaml

wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-backend-deployment.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-persistentvolume.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-persistentvolumeclaim.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-service.yaml
wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-env.yaml
```


In here we suppose you download the YAML files in `/opt/seafile-k8s-yaml`, which mainly include about:

- `seafile-xx-deployment.yaml` for frontend and backend services pod management and creation, 
- `seafile-service.yaml` for exposing Seafile services to the external network, 
- `seafile-persistentVolume.yaml` for defining the location of a volume used for persistent storage on the host
- `seafile-persistentvolumeclaim.yaml` for declaring the use of persistent storage in the container.

For futher configuration details, you can refer [the official documents](https://kubernetes.io/docs/tasks/configure-pod-container/).

!!! tip "Use PV bound from a storage class"
    If you would like to use automatically allocated persistent volume (PV) by a storage class, please modify `seafile-persistentvolumeclaim.yaml` and specify `storageClassName`. On the other hand, the PV defined by `seafile-persistentvolume.yaml` can be disabled:

    ```sh
    rm /opt/seafile-k8s-yaml/seafile-persistentvolume.yaml
    ```

## Modify `seafile-env.yaml`

Similar to Docker-base deployment, Seafile cluster in K8S deployment also supports use files to configure startup progress, you can modify common [environment variables](./setup_pro_by_docker.md#downloading-and-modifying-env) by

```sh
nano /opt/seafile-k8s-yaml/seafile-env.yaml
```

## Initialize Seafile cluster
You can use following command to initialize Seafile cluster now (the Seafile's K8S resources will be specified in namespace `seafile` for easier management):

```shell
kubectl apply -f /opt/seafile-k8s-yaml/ -n seafile
```

!!! note "About Seafile cluster initialization"
    When Seafile cluster is initializing, it will run with the following conditions:

    - Only have backend service (i.e., only has the Seafile backend K8S resouce file)
    - `CLUSTER_INIT_MODE=true`

!!! success
    You can get the following information through `kubectl logs seafile-xxxx -n seafile` to check the initialization process is done or not:

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
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/13.0/repo/k8s/cluster/seafile-frontend-deployment.yaml
    ```

2. Modify `seafile-env.yaml`, and set `CLUSTER_INIT_MODE` to `false` (i.e., disable initialization mode), then re-apply `seafile-env.yaml` again:

    ```sh
    kubectl apply -f /opt/seafile-k8s-yaml
    ```

3. Run the following command to restart pods to restart Seafile cluster:

    !!! tip
        If you modify some configurations in `/opt/seafile/shared/seafile/conf` or YAML files in `/opt/seafile-k8s-yaml/`, you still need to restart services to make modifications.

    ```shell
    kubectl delete pods -n seafile $(kubectl get pods -n seafile -o jsonpath='{.items[*].metadata.name}' | grep seafile)
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

## Uninstall Seafile K8S

You can uninstall the Seafile K8S by the following command:

```sh
kubectl delete -f /opt/seafile-k8s-yaml/ -n seafile
```

## Advanced operations

Please refer from [here](./k8s_advanced_management.md) for futher advanced operations.

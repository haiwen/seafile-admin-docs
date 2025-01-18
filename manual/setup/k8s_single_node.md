# Setup Seafile with a single K8S pod

This manual explains how to deploy and run Seafile server on a Linux server using *Kubernetes* (***k8s*** thereafter) in a single pod (i.e., single node mode). So this document is essentially an extended description of the [Docker-based Seafile single-node deployment](./overview.md) (support both CE and Pro). 

For specific environment and configuration requirements, please refer to the description of the [Docker-based Seafile single-node deployment](./setup_pro_by_docker.md#requirements). Please also refer to the description of the ***K8S tool*** section in [here](./cluster_deploy_with_k8s.md#k8s-tools).

## Gettings started

For persisting data using in the docker-base deployment, `/opt/seafile-data`, is still adopted in this manual. What's more, all K8S YAML files will be placed in `/opt/seafile-k8s-yaml` (replace it when following these instructions if you would like to use another path).

By the way, we don't provide the deployment methods of basic services (e.g., **Memcached**, **MySQL** and **Elasticsearch**) and seafile-compatibility components (e.g., **SeaDoc**) for K8S in our document. If you need to install these services in K8S format, ***you can refer to the rewrite method of this document.***

## Down load the YAML files for Seafile Server

=== "Pro edition"

    ```sh
    mkdir -p /opt/seafile-k8s-yaml

    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-deployment.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-persistentvolume.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-persistentvolumeclaim.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-service.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-env.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/pro/seafile-secret.yaml
    ```

=== "Community edition"

    ```sh
    mkdir -p /opt/seafile-k8s-yaml

    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-deployment.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-persistentvolume.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-persistentvolumeclaim.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-service.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-env.yaml
    wget -P /opt/seafile-k8s-yaml https://manual.seafile.com/12.0/repo/k8s/ce/seafile-secret.yaml
    ```

In here we suppose you download the YAML files in `/opt/seafile-k8s-yaml`, which mainly include about:

- `seafile-deployment.yaml` for Seafile server pod management and creation, 
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

## Start Seafile server

You can start Seafile server simply by

```sh
kubectl apply -f /opt/seafile-k8s-yaml/
```

!!! warning
    By default, Seafile will access the ***Memcached*** and ***Elasticsearch*** with the specific service name:

    - ***Memcached***: `memcached` with port 11211
    - ***Elasticsearch***: `elasticsearch` with port 9200

    If the above services are:

    - Not in your K8S pods (including using an external service)
    - With different service name
    - With different server port

    Please modfiy the files in `/opt/seafile-data/seafile/conf` (especially the `seafevents.conf`, `seafile.conf` and `seahub_settings.py`) to make correct the configurations for above services, otherwise the Seafile server cannot start normally. Then restart Seafile server:

    ```sh
    kubectl delete -f /opt/seafile-k8s-yaml/
    kubectl apply -f /opt/seafile-k8s-yaml/
    ```

## Activating the Seafile License

If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container. The volumne's default path in the Compose file is `/opt/seafile-data`. If you have modified the path, save the license file under your custom path.

!!! danger "If the license file has a different name or cannot be read, Seafile server will start with in trailer mode with most THREE users"

Then restart Seafile:

```bash
kubectl delete -f /opt/seafile-k8s-yaml/
kubectl apply -f /opt/seafile-k8s-yaml/
```

## Container management

Similar to docker installation, you can also manage containers through [some kubectl commands](https://kubernetes.io/docs/reference/kubectl/#operations). For example, you can use the following command to check whether the relevant resources are started successfully and whether the relevant services can be accessed normally. First, execute the following command and remember the pod name with `seafile-` as the prefix (such as `seafile-748b695648-d6l4g`)

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

## HTTPS

Please refer [here](./cluster_deploy_with_k8s.md#load-balance-and-https) about suggestions of enabling HTTPS in K8S.

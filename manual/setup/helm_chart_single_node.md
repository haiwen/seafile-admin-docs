# Setup Seafile with a single K8S pod with Seafile Helm Chart

This manual explains how to deploy and run Seafile server on a Linux server using [*Seafile Helm Chart*](https://github.com/seafileltd/seafile-helm-chart) (***chart*** thereafter) in a single pod (i.e., single node mode). Comparing to [Setup by K8S resource files](./k8s_single_node.md), deployment with helm chart can simplify the deployment process and provide more flexible deployment control, which the way we recommend in deployment with K8S.

For specific environment and configuration requirements, please refer to the description of the [Docker-based Seafile single-node deployment](./setup_pro_by_docker.md#requirements). Please also refer to the description of the ***K8S tool*** section in [here](./cluster_deploy_with_k8s.md#k8s-tools).

## Preparation

For persisting data using in the docker-base deployment, `/opt/seafile-data`, is still adopted in this manual. What's more, all K8S YAML files will be placed in `/opt/seafile-k8s-yaml` (replace it when following these instructions if you would like to use another path).

By the way, we don't provide the deployment methods of basic services (e.g., **Memcached**, **MySQL** and **Elasticsearch**) and seafile-compatibility components (e.g., **SeaDoc**) for K8S in our document. If you need to install these services in K8S format, ***you can refer to the rewrite method in [this document](./k8s_single_node.md).***

### System requirements

Please refer [here](./system_requirements.md) for the details of system requirements about Seafile service. By the way, this will apply to all nodes where Seafile pods may appear in your K8S cluster. In general, we recommend that each node should have at least 2G RAM and a 2-core CPU (> 2GHz).

## Install Seafile helm chart

1. Create namespace

    ```
    kubectl create namespace seafile
    ```

2. Create a secret for sensitive data

    === "Seafile Pro"

        ```sh
        kubectl create secret generic seafile-secret --namespace seafile \
        --from-literal=JWT_PRIVATE_KEY='<required>' \
        --from-literal=SEAFILE_MYSQL_DB_PASSWORD='<required>' \
        --from-literal=INIT_SEAFILE_ADMIN_PASSWORD='<required>' \
        --from-literal=INIT_SEAFILE_MYSQL_ROOT_PASSWORD='<required>' \
        --from-literal=INIT_S3_SECRET_KEY=''  
        ```
    === "Seafile CE"

        ```sh
        kubectl create secret generic seafile-secret --namespace seafile \
        --from-literal=JWT_PRIVATE_KEY='<required>' \
        --from-literal=SEAFILE_MYSQL_DB_PASSWORD='<required>' \
        --from-literal=INIT_SEAFILE_ADMIN_PASSWORD='<required>' \
        --from-literal=INIT_SEAFILE_MYSQL_ROOT_PASSWORD='<required>'
        ```

    where the `JWT_PRIVATE_KEY` can be generate by `pwgen -s 40 1`

3. Download and modify the `my-values.yaml` according to your configurations. By the way, you can follow [here](../config/env.md) for the details:

    === "Seafile Pro"

        ```sh
        wget -O my-values.yaml https://haiwen.github.io/seafile-helm-chart/values/latest/pro.yaml

        nano my-values.yaml
        ```

    === "Seafile CE"

        ```sh
        wget -O my-values.yaml https://haiwen.github.io/seafile-helm-chart/values/latest/ce.yaml

        nano my-values.yaml
        ```

    !!! tip "About installation with Helm chart"

        - It is not necessary to use the `my-values.yaml` we provided (i.e., you can create an empty `my-values.yaml` and add required field, as others have defined default values in our chart), because it destroys the flexibility of deploying with Helm, but it contains some formats of how Seafile Helm Chart reads these configurations, as well as all the environment variables and secret variables that can be read directly.
        - In addition, you can also create a custom ***storageClassName*** for the persistence directory used by Seafile. You only need to specify `storageClassName` in the `seafile.config.seafileDataVolume` object in `my-values.yaml`:

            ```yaml
            seafile:
              configs:
                seafileDataVolume:
                  storageClassName: <your seafile storage class name>
              ...
            ```

            On the other hand, if you would like to create a persistence volume (PV) for Seafile with a real host path (like `/opt/seafile-data`), you can download, modify the path and apply the `seafile-persistentvolume.yaml`:

            === "Seafile Pro"

                ```sh
                wget -P https://manual.seafile.com/12.0/repo/k8s/pro/seafile-persistentvolume.yaml

                kubectl apply -f seafile-persistentvolume.yaml
                ```
            === "Seafile CE"

                ```sh
                wget -P https://manual.seafile.com/12.0/repo/k8s/ce/seafile-persistentvolume.yaml

                kubectl apply -f seafile-persistentvolume.yaml
                ```

4. Then install the chart use the following command:

    === "Seafile Pro"

        ```sh
        helm repo add seafile https://haiwen.github.io/seafile-helm-chart/repo
        helm upgrade --install seafile seafile/pro  --namespace seafile --create-namespace --values my-values.yaml
        ```

    === "Seafile CE"

        ```sh
        helm repo add seafile https://haiwen.github.io/seafile-helm-chart/repo
        helm upgrade --install seafile seafile/ce  --namespace seafile --create-namespace --values my-values.yaml
        ```

After installing the chart, the Seafile pod should startup automaticlly. 

!!! note "About Seafile service"
    The default service type of Seafile is ***ClusterIP***. You need to use an [appropriate ingress strategy](./k8s_advanced_management.md#k8s-gateway-and-https) to make Seafile accessible from the external network.

!!! warning "Important for Pro edition"
    By default, Seafile (***Pro***) will access the ***Memcached*** and ***Elasticsearch*** with the specific service name:

    - ***Memcached***: `memcached` with port 11211
    - ***Elasticsearch***: `elasticsearch` with port 9200

    If the above services are:

    - Not in your K8S pods (including using an external service)
    - With different service name
    - With different server port

    Please modfiy the files in `/opt/seafile-data/seafile/conf` (especially the `seafevents.conf`, `seafile.conf` and `seahub_settings.py`) to make correct the configurations for above services, otherwise the Seafile server cannot start normally. Then restart Seafile server:

    ```sh
    kubectl delete pods -n seafile $(kubectl get pods -n seafile -o jsonpath='{.items[*].metadata.name}' | grep seafile)
    ```

## Activating the Seafile License (Pro)

If you have a `seafile-license.txt` license file, simply put it in the volume of the Seafile container. The volumne's default path in the Compose file is `/opt/seafile-data`. If you have modified the path, save the license file under your custom path.

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

    === "Seafile Pro"

        ```sh
        helm upgrade --install seafile seafile/pro  --namespace seafile --create-namespace --values my-values.yaml
        ```

    === "Seafile CE"

        ```sh
        helm upgrade --install seafile seafile/ce  --namespace seafile --create-namespace --values my-values.yaml
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

    === "Seafile Pro"

        ```sh
        wget -O my-values.yaml https://haiwen.github.io/seafile-helm-chart/values/<release-version>/cluster.yaml

        nano my-values.yaml
        ```
    === "Seafile CE"
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

    === "Seafile Pro"

        ```sh
        helm upgrade --install seafile seafile/pro --namespace seafile --create-namespace --values my-values.yaml --version <release-version>
        ```
    === "Seafile CE"
        ```sh
        helm upgrade --install seafile seafile/ce --namespace seafile --create-namespace --values my-values.yaml --version <release-version>
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
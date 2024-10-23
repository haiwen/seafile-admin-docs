# Setup with Kubernetes

This manual explains how to deploy and run Seafile Server on a Linux server using Kubernetes (k8s thereafter). 

## Gettings started 

The two volumes for persisting data, `/opt/seafile-data` and `/opt/seafile-mysql`, are still adopted in this manual. What's more, all k8s YAML files will be placed in `/opt/seafile-k8s-yaml`. It is not recommended to change these paths. If you do, account for it when following these instructions.

## Install kubectl and k8s control plane

The two tools, **kubectl** and a **k8s control plane** tool (i.e., ***kubeadm***), are required and can be installed with [official installation guide](https://kubernetes.io/docs/tasks/tools/). 

Note that if it is a multi-node deployment, k8s control plane needs to be installed on each node. After installation, you need to start the k8s control plane service on each node and refer to the k8s official manual for [creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/). Since this manual still uses the same image as docker deployment, we need to add the following repository to k8s:

```shell
kubectl create secret docker-registry regcred --docker-server=docker.seadrive.org/seafileltd --docker-username=seafile --docker-password=zjkmid6rQibdZ=uJMuWS
```

## YAML

Seafile mainly involves three different services, namely database service, cache service and seafile service. Since these three services do not have a direct dependency relationship, we need to separate them from the entire docker-compose.yml (in this manual, we use [Seafile 12 PRO](../docker/pro/seafile-server.yml)) and divide them into three pods. For each pod, we need to define a series of YAML files for k8s to read, and we will store these YAMLs in `/opt/seafile-k8s-yaml`. This series of YAML mainly includes **Deployment** for pod management and creation, **Service** for exposing services to the external network, **PersistentVolume** for defining the location of a volume used for persistent storage on the host and **Persistentvolumeclaim** for declaring the use of persistent storage in the container. For futher configuration details, you can refer [the official documents](https://kubernetes.io/docs/tasks/configure-pod-container/).

### mariadb

#### mariadb-deployment.yaml

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
spec:
  selector:
    matchLabels:
      app: mariadb
  replicas: 1
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
        - name: mariadb
          image: mariadb:10.11
          env:
            - name: MARIADB_ROOT_PASSWORD
              value: "db_dev"
            - name: MARIADB_AUTO_UPGRADE
              value: "true"
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mariadb-data
              mountPath: /var/lib/mysql
      volumes:
        - name: mariadb-data
          persistentVolumeClaim:
            claimName: mariadb-data
```

Please replease `MARIADB_ROOT_PASSWORD` to your own mariadb password. In the above Deployment configuration file, no restart policy for the pod is specified. The default restart policy is **Always**. If you need to modify it, add the following to the spec attribute:

```YAML
restartPolicy: OnFailure

#Note:
#    Always: always restart (include normal exit)
#    OnFailure: restart only with unexpected exit
#    Never: do not restart
```

#### mariadb-service.yaml

```YAML
apiVersion: v1
kind: Service
metadata:
  name: mariadb
spec:
  selector:
    app: mariadb
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
```

#### mariadb-persistentvolume.yaml

```YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /opt/seafile-mysql/db
```

#### mariadb-persistentvolumeclaim.yaml

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### memcached

#### memcached-deployment.yaml

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memcached
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memcached
  template:
    metadata:
      labels:
        app: memcached
    spec:
      containers:
        - name: memcached
          image: memcached:1.6.18
          args: ["-m", "256"]
          ports:
            - containerPort: 11211
```

#### memcached-service.yaml

```YAML
apiVersion: v1
kind: Service
metadata:
  name: memcached
spec:
  selector:
    app: memcached
  ports:
    - protocol: TCP
      port: 11211
      targetPort: 11211
```

### Seafile

#### seafile-deployment.yaml

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: seafile
spec:
  replicas: 1
  selector:
    matchLabels:
      app: seafile
  template:
    metadata:
      labels:
        app: seafile
    spec:
      containers:
        - name: seafile
          #        image: seafileltd/seafile-mc:9.0.10
          #        image: seafileltd/seafile-mc:11.0-latest
          image: docker.seadrive.org/seafileltd/seafile-pro-mc:12.0-latest
          env:
            - name: DB_HOST
              value: "mariadb"
            - name: DB_ROOT_PASSWD
              value: "db_dev" #db's password
            - name: TIME_ZONE
              value: "Europe/Berlin"
            - name: SEAFILE_ADMIN_EMAIL
              value: "admin@seafile.com" #admin email
            - name: SEAFILE_ADMIN_PASSWORD
              value: "admin_password" #admin password
            - name: SEAFILE_SERVER_LETSENCRYPT
              value: "false"
            - name: SEAFILE_SERVER_HOSTNAME
              value: "you_seafile_domain" #hostname
          ports:
            - containerPort: 80
          #        - containerPort: 443
          #          name:  seafile-secure
          volumeMounts:
            - name: seafile-data
              mountPath: /shared
      volumes:
        - name: seafile-data
          persistentVolumeClaim:
            claimName: seafile-data
      restartPolicy: Always
      # to get image from protected repository
      imagePullSecrets:
        - name: regcred
```
Please replease the above configurations, such as database root password, admin in seafile.

#### seafile-service.yaml

```YAML
apiVersion: v1
kind: Service
metadata:
  name: seafile
spec:
  selector:
    app: seafile
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30000
```

#### seafile-persistentvolume.yaml

```YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: seafile-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /opt/seafile-data
```

#### seafile-persistentvolumeclaim.yaml

```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: seafile-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

## Deploy pods

You can use following command to deploy pods:

```shell
kubectl apply -f /opt/seafile-k8s-yaml/
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

If you modify some configurations in `/opt/seafile-data/conf` and need to restart the container, the following command can be refered:

```shell
kubectl delete deployments --all
kubectl apply -f /opt/seafile-k8s-yaml/
```

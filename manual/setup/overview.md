# Seafile Docker overview

Seafile docker based installation consist of the following components (docker images):

- Seafile server: Seafile core services, see [Seafile Components](../introduction/components.md) for the details.
- Sdoc server: SeaDoc server, provide a lightweight online collaborative document editor, see [SeaDoc](../extension/setup_seadoc.md#architecture) for the details.
- Database: Stores data related to Seafile and SeaDoc.
- Memcached: Cache server.
- Caddy: Caddy server enables user to access the Seafile service (i.e., Seafile server and Sdoc server) externally and handles `SSL` configuration

![Seafile Docker Structure](../images/seafile-12.0-docker-structure.png)

!!! note "Seafile version 11.0 or later is required to work with SeaDoc"

## Document guidelines

### Single Node deployment
- Deploy from Docker image:
    - [Seafile CE](./setup_ce_by_docker.md)
    - [Seafile Pro](./setup_pro_by_docker.md)
- Deploy from Kubernetes (K8S) with [*Docker-cri*](https://mirantis.github.io/cri-dockerd/usage/install/):
    - Deploy by [Seafile Helm Chart](./helm_chart_single_node.md)
    - Deploy by [Seafile K8S resources files](./k8s_single_node.md)

### Cluster (Pro only)
- Deploy from [Docker](./cluster_deploy_with_docker.md)
- Deploy from Kubernetes (K8S) with [*Docker-cri*](https://mirantis.github.io/cri-dockerd/usage/install/):
    - Deploy by [Seafile Helm Chart](./helm_chart_cluster.md)
    - Deploy by [Seafile K8S resources files](./cluster_deploy_with_k8s.md)
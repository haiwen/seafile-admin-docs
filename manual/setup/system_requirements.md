# System requirements

This page shows the minimal requirements of Seafile.

!!! note "About the system requirements"
    The system requirements in this document refer to the **minimum system hardware requirements** are the suggestions to smooth operation of Seafile (**network connection is not discussed here**). If not otherwise specified, it will apply to **all deployment scenarios**, but for ***binary installations***, the libraries we provided in the documents are only supporting the **following operation systems**:

    - Ubuntu 24.04
    - Ubuntu 22.04
    - Debian 12
    - Debian 11


!!! warning "Important: Information of *Docker-base deployment integration services*"
    - **In each case**, we have shown the services integrated names ***Docker-base deployment integration services*** by standard installation with *Docker*. If these services are already installed and you do not need them in your deployment, you need to refer to the corresponding documentation and disable them in the Docker resource file.However, **we do not recommend that you reduce the corresponding system resource requirements on our suggestions**, unless otherwise specified.
    
    - However, if you use other installation methods (e.g., *binary deployment*, *K8S deployment*) you have to make sure you have installed these services, because **it will not include the installation of that**. 

    - If you need to install other extensions not included here (e.g., *OnlyOffice*), you should **increase the system requirements** appropriately above our recommendations.

## Seafile CE

- **Memory requirements**: 2G
- **CPU requirements**: 2 cores, more than 2G Hz are recommended
- **Hard disk requirements**: 10G availables, more than 50G are recommended
- **Docker-base deployment integration services**:
    - *Seafile*
    - *Memcached*
    - *Mariadb*
    - *Seadoc*
    - *Caddy*

## Seafile Pro

- **CPU and Memory requirements**:

    | Deployment Scenarios | CPU Requirements | Memory Requirements | Indexer / Search Engine |
    | :--: | :--: | :--: | :--: |
    | Docker deployment | 4 Cores | 4G | Default |
    | All | 4 Cores | 4G | With existing ***ElasticSearch*** service, but on the same machine / node |
    | All | 2 Cores | 2G | With existing ***ElasticSearch*** service, and on another machine / node |
    | All | 2 Cores | 2G | Use *SeaSearch* as the search engine, instead of *ElasticSearch* |

- **Hard disk requirements**: More than 50G are recommended
- **Docker-base deployment integration services**:
    - *Seafile*
    - *Memcached*
    - *Mariadb*
    - *ElasticSearch*
    - *Seadoc*
    - *Caddy*

!!! tip "More details of files indexer used in Seafile PE"
    - **By default**, Seafile Pro will use ***Elasticsearch*** as the files indexer

        Please make sure the [mmapfs counts](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules-store.html#mmapfs) do not cause excptions like out of memory, which can be increased by following command (see <https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html> for futher details):

        ```shell
        sysctl -w vm.max_map_count=262144 #run as root
        ```

        or modify **/etc/sysctl.conf** and reboot to set this value permanently:

        ```shell
        nano /etc/sysctl.conf

        # modify vm.max_map_count
        vm.max_map_count=262144
        ```
    - If your machine **dose not** have enough requirements, 2 Cores and 2GB RAM are minimum by chosing one of following two ways **after first-time deployment**:

        - Use [*SeaSearch*](./use_seasearch.md), a lightweight search engine built on open source search engine [*ZincSearch*](https://zincsearch-docs.zinc.dev/), as the indexer
    
        - Deploy *Elasticsearch* in another machine, and modify `es_host` and `es_port` in [seafevents.conf](../config/seafevents-conf.md)

## Seafile Cluster

- **Node requirements**: Minimal 2 nodes (one frontend and one backend), but recommend more than 3 nodes (two frontend and three backend)

!!! tip "More details about the number of nodes"
    1. If your number of nodes does not meet our recommended number (i.e. 3 nodes), please adjust according to the following strategies:
        - **2 nodes**: A frontend service and a backend service on the same node
        - **1 node**: Please deploy Seafile in a single node instead a cluster.
    2. If you have more available nodes for Seafile server, please provide them to the Seafile frontend service and **make sure there is only one backend service running**. Here is a simple relationship between the number of Seafile frontent services ($N_f$) and total nodes ($N_t$):
        $$
        N_f = N_t - 1,
        $$
        where the number **1** means one node for Seafile backend service.

- **Other system requirements**: similar with [Seafile Pro](#seafile-pro), but make sure that **all nodes** should meet this condition
- **Docker-base deployment integration services**: *Seafile* only

!!! note "More suggestions in Seafile cluster"
    - We assume you have already deployed ***Memcached*** (or *redis*), ***MariaDB***, file indexer (e.g., ***ElasticSearch***) in separate machines and use ***S3*** like object storage. 

    - Generally, when deploying Seafile in a cluster, we recommend that you use a **storage backend** (such as AWS S3) to store Seafile data. However, according to the Seafile image startup rules and K8S persistent storage strategy, you still need to **prepare a persistent directory** for configuring the startup of the Seafile container. 
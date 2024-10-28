# Deploying Seafile

We provide two ways to deploy Seafile services. **Docker is the recommended way**. 

!!! note "Deployment notes"

    Since version 12.0, binary based deployment for community edition is **deprecated** and will not be supported in a future release.

* Using [Docker](../setup/single_node_installation.md)
* Manually installing Seafile and setting up database, memcached and Nginx/Apache. See the following section:

    * [Deploying Seafile with MySQL](installation_by_binary.md)
    * [Enabling Https with Nginx](https_with_nginx.md)
    * [Enabling Https with Apache](https_with_apache.md)
    * [Start Seafile at System Bootup](start_seafile_at_system_bootup.md)
    * [Logrotate](using_logrotate.md)

## Advanced operations for Seafile Pro Edition (Seafile PE)

<!--### Migration from community edition

- [Migrate from Seafile Community edition](migrate_from_seafile_community_server.md)-->

### S3 Storage Backends

- [Setup Seafile Professional Server With S3](../setup/setup_with_amazon_s3.md)
- [Setup Seafile Professional Server With OpenStack Swift](../setup/setup_with_swift.md)
- [Data migration between different backends](../setup/migrate_backends_data.md)
- [Using multiple storage backends](../setup/setup_with_multiple_storage_backends.md)

### Cluster

- [Deploy seafile servers in a cluster](./deploy_in_a_cluster.md)
- [Enable search and background tasks in a cluster](./enable_search_and_background_tasks_in_a_cluster.md)
- [Setup Seafile cluster with NFS](./setup_seafile_cluster_with_nfs.md)

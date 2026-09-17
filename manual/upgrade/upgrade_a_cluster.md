# Upgrade a Seafile cluster

## Major and minor version upgrade

Seafile adds new features in major and minor versions. It is likely that some database tables need to be modified or the search index need to be updated. In general, upgrading a cluster contains the following steps:

1. Update Seafile image
2. Upgrade the database
3. Update configuration files at each node
4. Update search index in the backend node

In general, to upgrade a cluster, you need:

1. Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Start with docker compose up.
2. Run the upgrade script in container (for example, `/opt/seafile/seafile-server-latest/upgrade/upgrade_x_x_x_x.sh`) in one frontend node
3. Update configuration files at each node according to the documentation for each version
4. Delete old search index in the backend node if needed

## Version-specific upgrade guides

### Upgrade a cluster from Seafile 12 to 13

Refer to [Upgrade a Seafile cluster from 12.0 to 13.0](./upgrade_a_cluster_13.0.md).

### Upgrade a cluster from Seafile 11 to 12

Refer to [Upgrade a Seafile cluster from 11.0 to 12.0](./upgrade_a_cluster_12.0.md).

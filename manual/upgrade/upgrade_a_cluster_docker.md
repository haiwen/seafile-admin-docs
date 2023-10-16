# Upgrade a Seafile cluster (Docker)

## Major and minor version upgrade

Seafile adds new features in major and minor versions. It is likely that some database tables need to be modified or the search index need to be updated. In general, upgrading a cluster contains the following steps:

1. Update Seafile image
2. Upgrade the database
3. Update configuration files at each node
4. Update search index in the backend node

In general, to upgrade a cluster, you need:

1. Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Start with docker compose up.
2. Run the upgrade script in container (for example, /opt/seafile/seafile-server-latest/upgrade/upgrade_10_0_11_0.sh) in one frontend node
3. Update configuration files at each node according to the documentation for each version
4. Delete old search index in the backend node if needed

## Maintanence upgrade

Maintanence upgrade only needs to download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Start with docker compose up.

## Upgrade from 10.0 to 11.0

Migrate your configuration for LDAP and OAuth according to <https://manual.seafile.com/upgrade/upgrade_notes_for_11.0.x>

## Upgrade from 9.0 to 10.0

If you are using with ElasticSearch, SAML SSO and storage backend features, follow the upgrading manual on how to update the configuration for these features: <https://manual.seafile.com/upgrade/upgrade_notes_for_10.0.x>

If you want to use the new notification server and rate control (pro edition only), please refer to the upgrading manual: <https://manual.seafile.com/upgrade/upgrade_notes_for_10.0.x>

## Upgrade from 8.0 to 9.0

If you are using with ElasticSearch, follow the upgrading manual on how to update the configuration: <https://manual.seafile.com/upgrade/upgrade_notes_for_9.0.x>

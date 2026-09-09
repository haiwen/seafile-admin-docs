# Upgrade Seafile Docker

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 9.0 to 10.0, see instructions below.

Please check the **upgrade notes** for an overview about changes in this major version before upgrading.


## Upgrade from 9.0 to 10.0

Just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

If you are using pro edition with ElasticSearch, SAML SSO and storage backend features, follow the upgrading manual on how to update the configuration for these [features](upgrade_notes_for_10.0.md).

If you want to use the new notification server and rate control (pro edition only), please refer to the [upgrading manual](upgrade_notes_for_10.0.md).

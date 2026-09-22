# Upgrade manual

There are two types of upgrade, i.e., major version upgrade and maintenance version upgrade.

## Major upgrade

!!! note "Clean database tables before upgrade"

    If you have a large number of `Activity` records in MySQL, clean the table before upgrading by following [Clean Database](../administration/clean_database.md). Otherwise, the database upgrade may take a long time.

For major upgrade, if you are using a Docker based deployment, please read the upgrade documents for docker based deployment. If you are using a binary package based deployment, please read the upgrade documents for binary based deployment.

Please check the [upgrade notes](./upgrade_notes.md) for any special configuration or changes before upgrading.

## Maintenance version upgrade

For maintenance version upgrade, like from version 14.0.1 to version 14.0.4, if you are using a Docker based deployment, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For binary based maintenance version upgrade, for example from 14.0.1 to 14.0.4, you can use the following steps:

1. Shutdown Seafile server if it's running
2. For this type of upgrade, you only need to update the symbolic links (for avatar and a few other folders). 
   A script to perform a minor upgrade is provided with Seafile server (for history reasons, the script is called `minor-upgrade.sh`):

    ```
    cd seafile-server-14.0.4/upgrade/ && ./minor-upgrade.sh
    ```

3. Start Seafile
4. If the new version works, the old version can be removed

    ```
    rm -rf seafile-server-14.0.1/
    ```

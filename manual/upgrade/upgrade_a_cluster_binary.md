# Upgrade a Seafile cluster (binary)

## Major and minor version upgrade

Seafile adds new features in major and minor versions. It is likely that some database tables need to be modified or the search index need to be updated. In general, upgrading a cluster contains the following steps:

1. Upgrade the database
2. Update symbolic link at frontend and backend nodes to point to the newest version
3. Update configuration files at each node
4. Update search index in the backend node

In general, to upgrade a cluster, you need:

1. Run the upgrade script (for example, ./upgrade/upgrade_4_0_4_1.sh) in one frontend node
2. Run the minor upgrade script (./upgrade/minor_upgrade.sh) in all other nodes to update symbolic link
3. Update configuration files at each node according to the documentation for each version
4. Delete old search index in the backend node if needed

## Maintanence upgrade

Doing maintanence upgrading is simple, you only need to run the script `./upgrade/minor_upgrade.sh` at each node to update the symbolic link.

## Upgrade a cluster from Seafile 12 to 13

!!! tip "Clean Database"
    If you have a large number of `Activity` in MySQL, clear this table first [Clean Database](../../administration/clean_database). Otherwise, the database upgrade will take a long time.

1. Stop Seafile server

    !!! note
        For installations using python virtual environment, activate it if it isn't already active

        ```sh 
        source python-venv/bin/activate
        ```

    === "Frontend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh stop
        ./seahub.sh stop
        ```
    === "Backend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh stop
        ./seafile-background-tasks.sh stop
        ```

2. Install [new Python libraries](./upgrade_notes_for_13.0.x.md#new-python-libraries)

3. [Download](../setup_binary/installation.md#downloading-the-install-package) and [uncompress](../setup_binary/installation.md#uncompressing-the-package) the package

4. Run the upgrade script in a single node

    ```sh
    seafile-pro-server-13.x.x/upgrade/upgrade_12.0_13.0.sh
    ```
   
5. Follow [here](./upgrade_notes_for_13.0.x.md#5-modify-the-env-file-in-conf-directory) to modify the `.env` file in `conf/` directory

6. Start Seafile server

    === "Frontend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh start
        ./seahub.sh start
        ```
    === "Backend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh start
        ./seafile-background-tasks.sh start
        ```

7. (Optional) Refer [here](./upgrade_notes_for_13.0.x.md#8-optional-upgrade-notification-server) to upgrade notification server

8. (Optional) Refer [here](./upgrade_notes_for_13.0.x.md#9-optional-upgrade-seadoc-from-10-to-20) to upgrade SeaDoc server

## Upgrade a cluster from Seafile 11 to 12

!!! tip "Clean Database"
    If you have a large number of `Activity` in MySQL, clear this table first [Clean Database](../../administration/clean_database). Otherwise, the database upgrade will take a long time.

1. Stop Seafile server

    !!! note
        For installations using python virtual environment, activate it if it isn't already active

        ```sh 
        source python-venv/bin/activate
        ```

    === "Frontend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh stop
        ./seahub.sh stop
        ```
    === "Backend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh stop
        ./seafile-background-tasks.sh stop
        ```

2. Install [new Python libraries](./upgrade_notes_for_12.0.x.md#new-python-libraries)

3. [Download](../setup_binary/installation.md#downloading-the-install-package) and [uncompress](../setup_binary/installation.md#uncompressing-the-package) the package

4. Run the upgrade script in a single node

    ```sh
    seafile-pro-server-12.x.x/upgrade/upgrade_11.0_12.0.sh
    ```

5. Follow [here](./upgrade_notes_for_12.0.x.md#3-create-the-env-file-in-conf-directory) to create the `.env` file in `conf/` directory

6. Start Seafile server

    === "Frontend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh start
        ./seahub.sh start
        ```
    === "Backend node"
        ```sh
        cd /opt/seafile/seafile-server-latest
        su seafile
        ./seafile.sh start
        ./seafile-background-tasks.sh start
        ```

7. (Optional) Refer [here](./upgrade_notes_for_12.0.x.md#5-upgrade-notification-server) to upgrade notification server

8. (Optional) Refer [here](./upgrade_notes_for_12.0.x.md#upgrade-seadoc-from-08-to-10) to upgrade SeaDoc server

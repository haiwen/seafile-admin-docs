# Upgrade manual

There are three types of upgrade, i.e., major version upgrade, minor version upgrade and maintenance version upgrade. This page contains general instructions for the three types of upgrade.

* After upgrading, you may need to clean ***seahub cache*** if it doesn't behave as expect.
* If you are using a Docker based deployment, please read [upgrade a Seafile docker instance](upgrade_docker.md)
* If you are running a **cluster**, please read [upgrade a Seafile cluster](upgrade_a_cluster.md).
* If you are using a binary package based deployment, please read instructions below.

## Special upgrade notes

Please check the **upgrade notes** for any special configuration or changes before/while upgrading.

* [Upgrade notes for 13.0.x](./upgrade_notes_for_13.0.x.md)
* [Upgrade notes for 12.0.x](./upgrade_notes_for_12.0.x.md)
* [Upgrade notes for 11.0.x](./upgrade_notes_for_11.0.x.md)
* [Upgrade notes for 10.0.x](./upgrade_notes_for_10.0.x.md)
* [Upgrade notes for 9.0.x](./upgrade_notes_for_9.0.x.md)


## Upgrade a binary package based deployment

### Major version upgrade (e.g. from 5.x.x to 6.y.y)

Suppose you are using version 5.1.0 and like to upgrade to version 6.1.0. First download and extract the new version. You should have a directory layout similar to this:

```
seafile
   -- seafile-server-5.1.0
   -- seafile-server-6.1.0
   -- ccnet
   -- seafile-data
```

Now upgrade to version 6.1.0.

Shutdown Seafile server if it's running

```sh
cd seafile/seafile-server-latest
./seahub.sh stop
./seafile.sh stop
# or via service
/etc/init.d/seafile-server stop
```

Check the upgrade scripts in seafile-server-6.1.0 directory.

```sh
cd seafile/seafile-server-6.1.0
ls upgrade/upgrade_*
```

You will get a list of upgrade files:

```
...
upgrade_5.0_5.1.sh
upgrade_5.1_6.0.sh
upgrade_6.0_6.1.sh
```

Start from your current version, run the script(s one by one)

```
upgrade/upgrade_5.1_6.0.sh
upgrade/upgrade_6.0_6.1.sh
```

Start Seafile server

```sh
cd seafile/seafile-server-latest/
./seafile.sh start
./seahub.sh start # or "./seahub.sh start-fastcgi" if you're using fastcgi
# or via service
/etc/init.d/seafile-server start
```

If the new version works fine, the old version can be removed

```sh
rm -rf seafile-server-5.1.0/
```

### Minor version upgrade (e.g. from 6.1.x to 6.2.y)

Suppose you are using version 6.1.0 and like to upgrade to version 6.2.0. First download and extract the new version. You should have a directory layout similar to this:

```
seafile
   -- seafile-server-6.1.0
   -- seafile-server-6.2.0
   -- ccnet
   -- seafile-data
```

Now upgrade to version 6.2.0.

1. Shutdown Seafile server if it's running

```sh
cd seafile/seafile-server-latest
./seahub.sh stop
./seafile.sh stop
# or via service
/etc/init.d/seafile-server stop
```

Check the upgrade scripts in seafile-server-6.2.0 directory.

```sh
cd seafile/seafile-server-6.2.0
ls upgrade/upgrade_*
```

You will get a list of upgrade files:

```
...
upgrade/upgrade_5.1_6.0.sh
upgrade/upgrade_6.0_6.1.sh
upgrade/upgrade_6.1_6.2.sh
```

Start from your current version, run the script(s one by one)

```
upgrade/upgrade_6.1_6.2.sh
```

Start Seafile server

```sh
./seafile.sh start
./seahub.sh start
# or via service
/etc/init.d/seafile-server start
```

If the new version works, the old version can be removed

```sh
rm -rf seafile-server-6.1.0/
```

### Maintenance version upgrade (e.g. from 6.2.2 to 6.2.3)

A maintenance upgrade is for example an upgrade from 6.2.2 to 6.2.3.

1. Shutdown Seafile server if it's running
2. For this type of upgrade, you only need to update the symbolic links (for avatar and a few other folders). 
   A script to perform a minor upgrade is provided with Seafile server (for history reasons, the script is called `minor-upgrade.sh`):

    ```
    cd seafile-server-6.2.3/upgrade/ && ./minor-upgrade.sh
    ```

3. Start Seafile
4. If the new version works, the old version can be removed

    ```
    rm -rf seafile-server-6.2.2/
    ```

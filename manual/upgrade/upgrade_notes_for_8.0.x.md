# Upgrade notes for 8.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

From 8.0, ccnet-server component is removed. But ccnet.conf is still needed.

There are no special steps needed when upgrading from 7.1 to 8.0.

### Deploy

Note, you should install Python libraries system wide using root user or sudo mode.

* For Ubuntu 16.04/18.04 or Debian 10

```sh
apt-get install libmysqlclient-dev

sudo pip3 install future mysqlclient

```

* For CentOS 7/8

```sh
yum install python3-devel mysql-devel gcc gcc-c++ -y

sudo pip3 install future mysqlclient

```

### Upgrade to 8.0.x

1. Stop Seafile-7.1.x server.
2. Start from Seafile 7.1.x, run the script:

```sh
upgrade/upgrade_7.1_8.0.sh

```

3. Start Seafile-8.0.x server.

## FAQ



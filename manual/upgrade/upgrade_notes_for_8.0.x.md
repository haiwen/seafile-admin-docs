# Upgrade notes for 8.0

These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

## Important release changes

From 8.0, ccnet-server component is removed. But ccnet.conf is still needed.

## Install new Python libraries

Note, you should install Python libraries system wide using root user or sudo mode.

* For Ubuntu 18.04/20.04

```sh
apt-get install libmysqlclient-dev

sudo pip3 install -U future mysqlclient sqlalchemy==1.4.3
```

* For Debian 10

```sh
apt-get install  default-libmysqlclient-dev 

sudo pip3 install future mysqlclient sqlalchemy==1.4.3
```

* For CentOS 7

```sh
yum install python3-devel mysql-devel gcc gcc-c++ -y

sudo pip3 install future
sudo pip3 install mysqlclient==2.0.1 sqlalchemy==1.4.3
```

* For CentOS 8

```sh
yum install python3-devel mysql-devel gcc gcc-c++ -y

sudo pip3 install future mysqlclient sqlalchemy==1.4.3
```

## Upgrade to 8.0.x

1. Stop Seafile-7.1.x server.
2. Start from Seafile 7.1.x, run the script:

```sh
upgrade/upgrade_7.1_8.0.sh
```

3. Start Seafile-8.0.x server.

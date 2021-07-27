# Deployment of Seafile Server Professional Edition

## Requirements

Seafile Server Professional Edition (Seafile PE) requires a minimum of 2 cores and 2GB RAM. If elasticsearch is installed on the same server, the minimum requirements are 4 cores and 4 GB RAM.

Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at sales@seafile.com or one of [our partners](https://www.seafile.com/en/partner/).



## Setup

These instructions assume that MySQL/MariaDB server and client are installed and a MySQL/MariaDB root user can authenticate using the mysql_native_password plugin. (For more information, see [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).)

Seafile prior to and including Seafile 7.0 use Python 2. More recent versions rely on Python 3.

### Installing prerequisites

**For Seafile 7.0.x**

```
# Ubuntu 16.04/Ubuntu 18.04
sudo apt-get update
sudo apt-get install python2.7 python-setuptools python-mysqldb python-urllib3 python-ldap -y

```



```
# CentOS 7
sudo yum install python python-setuptools python-imaging MySQL-python python-urllib3 python-ldap -y

```

**For Seafile 7.1.x**

```
# Debian 10/Ubuntu 18.04
sudo apt-get update
sudo apt-get install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```



```
# Ubuntu 20.04
sudo apt-get update
sudo apt-get install python3 python3-setuptools python3-pip memcached libmemcached-dev -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap
```



```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```

**For Seafile 8.0.x**

```
# Debian 10
sudo apt-get update
sudo apt-get install python3 python3-setuptools python3-pip default-libmysqlclient-dev -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient
```



```
# Ubuntu 18.04
sudo apt-get update
sudo apt-get install python3 python3-setuptools python3-pip libmysqlclient-dev -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap

```



```
# Ubuntu 20.04
sudo apt-get update
sudo apt-get install python3 python3-setuptools python3-pip libmysqlclient-dev memcached libmemcached-dev -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient
```



```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip python3-devel mysql-devel gcc -y

sudo pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient

```



### Installing Java Runtime Environment

Java Runtime Environment (JRE) is a requirement for full text search with elasticsearch.

```
# Debian 10
sudo apt-get install default-jre -y

```



```
# Ubuntu 16.04/Ubuntu 18.04/Ubuntu 20.04
sudo apt-get install openjdk-8-jre -y
sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/

```



```
# CentOS
sudo yum install java-1.8.0-openjdk -y

```



### Installing poppler-utils

The package poppler-utils is required for full text search of pdf files.

```
# Ubuntu/Debian
sudo apt-get install poppler-utils -y

```



```
# CentOS
sudo yum install poppler-utils -y

```



### Creating the programm directory

The standard directory for Seafile's program files is `/opt/seafile`. Create this directory and change into it:

```
mkdir /opt/seafile
cd /opt/seafile

```

The  program directory can be changed. The standard directory `/opt/seafile` is assumed for the remainder of these instructions. If you decide to put Seafile in another directory, some commands need to be modified accordingly.



### Creating user seafile

Elasticsearch, the indexing server, cannot be run as root. More generally, it is good practice to avoid running applications as root. 

Create a new user and follow the instructions on the screen:

```
adduser seafile
```

Change ownership of the created directory to the new user:

```
chown -R seafile: /opt/seafile
```

All the following steps are done as user seafile.

Change to user seafile:

```
su seafile
```



### Activating Seafile PE license

Save the license file in Seafile's programm directory `/opt/seafile`. Make sure that the name is `seafile-license.txt`. (If the file has a different name or cannot be read, Seafile PE will not start.)



### Downloading the install package

The install packages for Seafile PE are available for download in the the [Seafile Customer Center](https://customer.seafile.com). To access the Customer Center, a  user account is necessary. The registration is free.

Beginning with Seafile PE 7.0.17, the Seafile Customer Center provides two install packages for every version (using Seafile PE 8.0.4 as an example):

* _seafile-pro-server_8.0.4_x86-64_Ubuntu.tar.gz_, compiled in Ubuntu 18.04 environment
* _seafile-pro-server_8.0.4_x86-64_CentOS.tar.gz_, compiled in CentOS 7 environment

The former is suitable for installation on Ubuntu/Debian servers, the latter for CentOS servers.

Download the install package using wget (replace the x.x.x with the downloaded version):

```
# Debian/Ubuntu
wget -O 'seafile-pro-server_x.x.x_x86-64_Ubuntu.tar.gz' 'VERSION_SPECIFIC_LINK_FROM_SEAFILE_CUSTOMER_CENTER'

# CentOS
wget -O 'seafile-pro-server_x.x.x_x86-64_CentOS.tar.gz' 'VERSION_SPECIFIC_LINK_FROM_SEAFILE_CUSTOMER_CENTER'
```

We use Seafile version 8.0.4 as an example in the remainder of these instructions.


### Uncompressing the package

The install package is downloaded as a compressed tarball which needs to be uncompressed.

Uncompress the package using tar:

```
# Debian/Ubuntu
tar xf seafile-pro-server_8.0.4_x86-64_Ubuntu.tar.gz

```

```
# CentOS
tar xf seafile-pro-server_8.0.4_x86-64_CentOS.tar.gz
```



Now you have:

```
#tree -L 1
.
├── seafile-license.txt
└── seafile-pro-server-8.0.4
└── seafile-pro-server_8.0.4_x86-64.tar.gz

```

Note: The names of the install packages differ for Seafile CE and Seafile PE. Using Seafile CE and Seafile PE 8.0.4 as an example, the names are as follows:

* Seafile CE: `seafile-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-server-8.0.4`
* Seafile PE: `seafile-pro-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-pro-server-8.0.4`



### Setting up Seafile PE

The setup process of Seafile Professional Server is the same as the Seafile Community Server. See [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).

If you have any problem during the setup up, check [Common problems in setting up Seafile server](../deploy/common_problems_for_setting_up_server.md).

After the successful completition of the setup script, the directory layout of Seafile PE looks as follows :

**For Seafile 7.0.x**

```
#tree -L 2
.
├── seafile-license.txt 			# license file
├── ccnet               			# configuration files
│   ├── mykey.peer
│   ├── PeerMgr
│   └── seafile.ini
├── conf
│   └── ccnet.conf
│   └── seafile.conf
│   └── seahub_settings.py
│   └── seafevents.conf
├── logs
├── pids
├── pro-data            			# data specific for professional version
├── seafile-data
├── seafile-pro-server-7.0.7
│   ├── reset-admin.sh
│   ├── runtime
│   ├── seafile
│   ├── seafile.sh
│   ├── seahub
│   ├── seahub-extra
│   ├── seahub.sh
│   ├── setup-seafile.sh
│   ├── setup-seafile-mysql.py
│   ├── setup-seafile-mysql.sh
│   └── upgrade
├── seafile-server-latest -> seafile-pro-server-7.0.7
├── seahub-data
│   └── avatars         			# for user avatars
├── seahub.db

```

**For Seafile 7.1.x and younger**

```
#tree -L 2
.
├── seafile-license.txt             # license file
├── ccnet               
├── conf
│   └── ccnet.conf
│   └── gunicorn.conf.py
│   └── __pycache__
│   └── seafdav.conf
│   └── seafevents.conf
│   └── seafile.conf
│   └── seahub_settings.py
├── logs
│   ├── controller.log
│   ├── elasticsearch_deprecation.log
│   ├── elasticsearch_index_indexing_slowlog.log
│   ├── elasticsearch_index_search_slowlog.log
│   ├── elasticsearch.log
│   ├── file_updates_sender.log
│   ├── index.log
│   ├── seafevents.log
│   ├── seafile.log
│   ├── seahub.log
│   └── slow_logs
├── pids
│   ├── elasticsearch.pid
│   ├── seafevents.pid
│   ├── seaf-server.pid
│   └── seahub.pid
├── pro-data                        # data specific for Seafile PE
│   └── search
├── seafile-data
│   ├── httptemp
│   ├── library-template
│   ├── storage
│   └── tmpfiles
├── seafile-pro-server-8.0.4
│   ├── check-db-type.py
│   ├── check_init_admin.py
│   ├── create-db
│   ├── index_op.py
│   ├── migrate.py
│   ├── migrate-repo.py
│   ├── migrate-repo.sh
│   ├── migrate.sh
│   ├── pro
│   ├── reset-admin.sh
│   ├── run_index_master.sh
│   ├── run_index_worker.sh
│   ├── runtime
│   ├── seaf-backup-cmd.py
│   ├── seaf-backup-cmd.sh
│   ├── seaf-encrypt.sh
│   ├── seaf-fsck.sh
│   ├── seaf-fuse.sh
│   ├── seaf-gc.sh
│   ├── seaf-gen-key.sh
│   ├── seafile
│   ├── seafile-background-tasks.sh
│   ├── seafile.sh
│   ├── seaf-import.sh
│   ├── seahub
│   ├── seahub-extra
│   ├── seahub.sh
│   ├── setup-seafile-mysql.py
│   ├── setup-seafile-mysql.sh
│   ├── setup-seafile.sh
│   ├── sql
│   └── upgrade
├── seafile-server-latest -> seafile-pro-server-8.0.4
├── seahub-data
│   └── avatars                        # for user avatars


```

### Tweaking conf files

Unless you proceed immediately with the installation of a reverse proxy, you need to modify two configuration files: ccnet.conf and gunicorn.conf.py

In ccnet.conf, add the port 8000 to the `SERVICE_URL` (i.e., SERVICE_URL = http://1.2.3.4:8000/)

In gunicorn.conf.py, change the bind to "0.0.0.0:8000" (i.e., bind = "0.0.0.0:8000")



## Starting Seafile Server

Run the following commands in `/opt/seafile-server-latest`:

```
./seafile.sh start # Start Seafile service
./seahub.sh start  # Start seahub website, port defaults to 127.0.0.1:8000

```

The first time you start Seahub, the script prompts you to create an admin account for your Seafile Server. Enter the email address of the admin user followed by the password.

Now you can access Seafile via the web interface at the host address and port 8000 (e.g., http://1.2.3.4:8000)

## Enabling access per HTTPS

It is strongly recommended to switch from unencrypted HTTP (via port 8000) to encrypted HTTPS (via port 443).

This manual provides instructions for enabling HTTPS for

* [Nginx](https://manual.seafile.com/deploy/https_with_nginx/)
* [Apache](https://manual.seafile.com/deploy/https_with_apache/)

Before enable HTTPS, install and configure [Nginx](https://manual.seafile.com/deploy/deploy_with_nginx/) and [Apache](https://manual.seafile.com/deploy/deploy_with_apache/) first.



## Performance tuning

For more than 50 users, we recommend [adding memcached](../deploy/add_memcached.md). Memcached increases the response time of Seahub, Seafile's web interface, significantly.

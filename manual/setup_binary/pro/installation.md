# Installation of Seafile Server Professional Edition

This manual explains how to deploy and run Seafile Server Professional Edition (Seafile PE) on a Linux server from a pre-built package using MySQL/MariaDB as database. The deployment has been tested for Debian/Ubuntu and CentOS, but Seafile PE should also work on other Linux distributions.

**Tip:** If you have little experience with Seafile Server, we recommend that you use an installation script for deploying Seafile Server.

## Requirements

Seafile PE requires a minimum of 2 cores and 2GB RAM. If elasticsearch is installed on the same server, the minimum requirements are 4 cores and 4 GB RAM.

Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at sales@seafile.com or one of [our partners](https://www.seafile.com/en/partner/).

## Setup

### Installing and preparing the SQL database

These instructions assume that MySQL/MariaDB server and client are installed and a MySQL/MariaDB root user can authenticate using the mysql_native_password plugin.

### Installing prerequisites


**For Seafile 8.0.x**

```
# Ubuntu 20.04 (on Debian 10/Ubuntu 18.04, it is almost the same)
sudo apt-get update
sudo apt-get install -y python3 python3-setuptools python3-pip libmysqlclient-dev
sudo apt-get install -y memcached libmemcached-dev
sudo apt-get install -y poppler-utils

sudo pip3 install --timeout=3600 Pillow==9.4.0 pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient
```

```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip python3-devel mysql-devel gcc -y
sudo yum install poppler-utils -y

sudo pip3 install --timeout=3600 Pillow==9.4.0 pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient
```

**For Seafile 9.0.x**

```
# on Ubuntu 20.04 (on Debian 10/Ubuntu 18.04, it is almost the same)
apt-get update
apt-get install -y python3 python3-setuptools python3-pip python3-ldap libmysqlclient-dev
apt-get install -y memcached libmemcached-dev
apt-get install -y poppler-utils

pip3 install --timeout=3600 django==3.2.* future mysqlclient pymysql Pillow pylibmc \ 
captcha jinja2 sqlalchemy==1.4.3 psd-tools django-pylibmc django-simple-captcha pycryptodome==3.12.0 cffi==1.14.0 lxml
```

```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip python3-devel mysql-devel gcc -y
sudo yum install poppler-utils -y

sudo pip3 install --timeout=3600 django==3.2.* Pillow==9.4.0 pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient pycryptodome==3.12.0 cffi==1.14.0 lxml
```

**For Seafile 10.0.x**

```
# on Ubuntu 22.04 (on Ubuntu 20.04/Debian 11/Debian 10, it is almost the same)
apt-get update
apt-get install -y python3 python3-setuptools python3-pip python3-ldap libmysqlclient-dev
apt-get install -y memcached libmemcached-dev
apt-get install -y poppler-utils

sudo pip3 install --timeout=3600 django==3.2.* future==0.18.* mysqlclient==2.1.* \
    pymysql pillow==10.2.* pylibmc captcha==0.5.* markupsafe==2.0.1 jinja2 sqlalchemy==1.4.44 \
    psd-tools django-pylibmc django_simple_captcha==0.5.20 djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 lxml
```

```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip python3-devel mysql-devel gcc -y
sudo yum install poppler-utils -y

sudo pip3 install --timeout=3600 django==3.2.* future==0.18.* mysqlclient==2.1.* \
    pymysql pillow==10.2.* pylibmc captcha==0.5.* markupsafe==2.0.1 jinja2 sqlalchemy==1.4.44 \
    psd-tools django-pylibmc django_simple_captcha==0.5.20 pycryptodome==3.16.* cffi==1.15.1 lxml
```

**For Seafile 11.0.x (Debian 11, Ubuntu 22.04, Centos 8, etc.)**

```
# on Ubuntu 22.04 (on Ubuntu 20.04/Debian 11/Debian 10, it is almost the same)
apt-get update
apt-get install -y python3 python3-dev python3-setuptools python3-pip python3-ldap libmysqlclient-dev ldap-utils libldap2-dev dnsutils
apt-get install -y memcached libmemcached-dev
apt-get install -y poppler-utils

sudo pip3 install --timeout=3600 django==4.2.* future==0.18.* mysqlclient==2.1.* \
    pymysql pillow==10.2.* pylibmc captcha==0.5.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.18 \
    psd-tools django-pylibmc django_simple_captcha==0.6.* djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.4.3 lxml
```

```
# CentOS 8
sudo yum install python3 python3-setuptools python3-pip python3-devel mysql-devel gcc bind-utils -y
sudo yum install poppler-utils -y

sudo pip3 install --timeout=3600 django==4.2.* future==0.18.* mysqlclient==2.1.* \
    pymysql pillow==10.2.* pylibmc captcha==0.5.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.18 \
    psd-tools django-pylibmc django_simple_captcha==0.6.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.4.3 lxml
```

**Note**: The recommended deployment option for Seafile PE on CentOS/Redhat is [Docker](../../setup/single_node_installation/setup_pro_edition.md).


**For Seafile 11.0.x on Debian 12 and Ubuntu 24.04 with virtual env**

Debian 12 and Ubuntu 24.04 are now discouraging system-wide installation of python modules with pip.  It is preferred now to install modules into a virtual environment which keeps them separate from the files installed by the system package manager, and enables different versions to be installed for different applications.  With these python virtual environments (venv for short) to work, you have to activate the venv to make the packages installed in it available to the programs you run.  That is done here with "source python-venv/bin/activate".

```
# Debian 12
sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmariadb-dev-compat ldap-utils libldap2-dev libsasl2-dev python3.11-venv
sudo apt-get install -y memcached libmemcached-dev

mkdir /opt/seafile
cd /opt/seafile

# create the vitual environment in the python-venv directory
python3 -m venv python-venv

# activate the venv
source python-venv/bin/activate
# Notice that this will usually change your prompt so you know the venv is active

# install packages into the active venv with pip (sudo isn't needed because this is installing in the venv, not system-wide).
pip3 install --timeout=3600  django==4.2.* future==0.18.* mysqlclient==2.1.* pymysql pillow==10.0.* pylibmc captcha==0.4 markupsafe==2.0.1 jinja2 sqlalchemy==2.0.18 psd-tools django-pylibmc django_simple_captcha==0.5.* djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 lxml python-ldap==3.4.3
```

```
# Ubuntu 24.04
sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmysqlclient-dev ldap-utils libldap2-dev python3.12-venv
sudo apt-get install -y memcached libmemcached-dev

mkdir /opt/seafile
cd /opt/seafile

# create the vitual environment in the python-venv directory
python3 -m venv python-venv

# activate the venv
source python-venv/bin/activate
# Notice that this will usually change your prompt so you know the venv is active

# install packages into the active venv with pip (sudo isn't needed because this is installing in the venv, not system-wide).
pip3 install --timeout=3600 django==4.2.* future==0.18.* mysqlclient==2.1.* \
    pymysql pillow==10.2.* pylibmc captcha==0.5.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.18 \
    psd-tools django-pylibmc django_simple_captcha==0.6.* djangosaml2==1.5.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.16.0 lxml python-ldap==3.4.3
```

### Installing Java Runtime Environment


Java Runtime Environment (JRE) is a requirement for full text search with ElasticSearch. It is used in extracting contents from PDF and Office files.

```
# Debian 10/Debian 11
sudo apt-get install default-jre -y
```

```
# Ubuntu 16.04/Ubuntu 18.04/Ubuntu 20.04/Ubuntu 22.04
sudo apt-get install openjdk-8-jre -y
sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/
```

```
# CentOS
sudo yum install java-1.8.0-openjdk -y
```

### Creating the programm directory

The standard directory for Seafile's program files is `/opt/seafile`. Create this directory and change into it:

```
mkdir /opt/seafile
cd /opt/seafile
```

The  program directory can be changed. The standard directory `/opt/seafile` is assumed for the rest of this manual. If you decide to put Seafile in another directory, some commands need to be modified accordingly.

### Creating user seafile

Elasticsearch, the indexing server, cannot be run as root. More generally, it is good practice not to run applications as root. 

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

### Placing the Seafile PE license

Save the license file in Seafile's programm directory `/opt/seafile`. Make sure that the name is `seafile-license.txt`. (If the file has a different name or cannot be read, Seafile PE will not start.)

### Downloading the install package

The install packages for Seafile PE are available for download in the the [Seafile Customer Center](https://customer.seafile.com). To access the Customer Center, a  user account is necessary. The registration is free.

Beginning with Seafile PE 7.0.17, the Seafile Customer Center provides two install packages for every version (using Seafile PE 8.0.4 as an example):

* _seafile-pro-server_8.0.4_x86-64_Ubuntu.tar.gz_, compiled in Ubuntu 18.04 environment
* _seafile-pro-server_8.0.4_x86-64_CentOS.tar.gz_, compiled in CentOS 7 environment

The former is suitable for installation on Ubuntu/Debian servers, the latter for CentOS servers.

Download the install package using wget (replace the x.x.x with the version you wish to download):


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
$ tree -L 2 /opt/seafile
.
├── seafile-license.txt
└── seafile-pro-server-8.0.4
│   ├── check-db-type.py
│   ├── check_init_admin.py
│   ├── create-db
│   ├── index_op.py
│   ├── migrate.py
│   ├── migrate-repo.py
│   ├── migrate-repo.sh
│   ├── migrate.sh
│   ├── pro
│   ├── remove-objs.py
│   ├── remove-objs.sh
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
└── seafile-pro-server_8.0.4_x86-64.tar.gz

```

**Note**: The names of the install packages differ for Seafile CE and Seafile PE. Using Seafile CE and Seafile PE 8.0.4 as an example, the names are as follows:

* Seafile CE: `seafile-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-server-8.0.4`
* Seafile PE: `seafile-pro-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-pro-server-8.0.4`

### Run the setup script

The setup process of Seafile PE is the same as the Seafile CE. See [Installation of Seafile Server Community Edition with MySQL/MariaDB](../ce/installation.md).

After the successful completition of the setup script, the directory layout of Seafile PE looks as follows (some folders only get created after the first start, e.g. `logs`):

**For Seafile 7.1.x and later**

```
$ tree -L 2 /opt/seafile
.
├── seafile-license.txt             # license file
├── ccnet               
├── conf                            # configuration files
│   └── ccnet.conf
│   └── gunicorn.conf.py
│   └── __pycache__
│   └── seafdav.conf
│   └── seafevents.conf
│   └── seafile.conf
│   └── seahub_settings.py
├── logs                            # log files
├── pids                            # process id files
├── pro-data                        # data specific for Seafile PE
├── seafile-data                    # object database
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
    └── avatars                        # user avatars
```

### Setup Memory Cache

Memory cache is mandatory for pro edition. You may use Memcached or Reids as cache server.

#### Use Memcached

Use the following commands to install memcached and corresponding libraies on your system:

```
# on Debian/Ubuntu 18.04+
apt-get install memcached libmemcached-dev -y
pip3 install --timeout=3600 pylibmc django-pylibmc

systemctl enable --now memcached
```


Add the following configuration to `seahub_settings.py`.

```
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
}

```

#### Use Redis

Redis is supported since version 11.0.

First, install Redis with package installers in your OS.

Then refer to [Django's documentation about using Redis cache](https://docs.djangoproject.com/en/4.2/topics/cache/#redis) to add Redis configurations to `seahub_settings.py`.


### Enabling HTTP/HTTPS

You need at least setup HTTP to make Seafile's web interface work. This manual provides instructions for enabling HTTP/HTTPS for the two most popular web servers and reverse proxies:

* [Nginx](../ce/https_with_nginx.md)
* [Apache](../ce/https_with_apache.md)

## Starting Seafile Server

Run the following commands in `/opt/seafile/seafile-server-latest`:

```
# For installations using python virtual environment, activate it if it isn't already active
source python-venv/bin/activate

./seafile.sh start # Start Seafile service
./seahub.sh start  # Start seahub website, port defaults to 127.0.0.1:8000
```

The first time you start Seahub, the script prompts you to create an admin account for your Seafile Server. Enter the email address of the admin user followed by the password.

Now you can access Seafile via the web interface at the host address (e.g., http://1.2.3.4:80).


## Enabling full text search

Seafile uses the indexing server ElasticSearch to enable full text search. In versions prior to Seafile 9.0, Seafile's install packages included ElasticSearch. A separate deployment was not necessary. Due to licensing conditions, ElasticSearch 7.x can no longer be bundled in Seafile's install package. As a consequence, a separate deployment of ElasticSearch is required to enble full text search in Seafile newest version.


### Deploying ElasticSearch

Our recommendation for deploying ElasticSearch is using Docker. Detailed information about installing Docker on various Linux distributions is available at [Docker Docs](https://docs.docker.com/engine/install/).

Seafile PE 9.0 only supports ElasticSearch 7.x. Seafile PE 10.0 and 11.0 only supports ElasticSearch 8.x.

We use ElasticSearch version 7.16.2 as an example in this section. Version 7.16.2 and newer version have been successfully tested with Seafile.


Pull the Docker image:
```
sudo docker pull elasticsearch:7.16.2
```

Create a folder for persistent data created by ElasticSearch and change its permission:
```
sudo mkdir -p /opt/seafile-elasticsearch/data  && chmod -R 777 /opt/seafile-elasticsearch/data/
```

Now start the ElasticSearch container using the docker run command:
```
sudo docker run -d \
--name es \
-p 9200:9200 \
-e "discovery.type=single-node" -e "bootstrap.memory_lock=true" \
-e "ES_JAVA_OPTS=-Xms2g -Xmx2g" -e "xpack.security.enabled=false" \
--restart=always \
-v /opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data \
-d elasticsearch:7.16.2
```


### Modifying seafevents

Add the following configuration to `seafevents.conf`:

```
[INDEX FILES]
external_es_server = true                   # required when ElasticSearch on separate host
es_host = your elasticsearch server's IP    # IP address of ElasticSearch host
                                            # use 127.0.0.1 if deployed on the same server
es_port = 9200                              # port of ElasticSearch host
interval = 10m                              # frequency of index updates in minutes
highlight = fvh                             # parameter for improving the search performance
```

Finally, restart Seafile:

```
./seafile.sh restart  && ./seahub.sh restart 
```

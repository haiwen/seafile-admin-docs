# Deployment of Seafile Server Professional Edition

## Requirements

Seafile Server Professional Edition (Seafile PE) requires 2 cores and 2GB RAM. If elasticsearch is installed on the same server, the minimum requirements are 4 cores and 4 GB RAM.

Seafile PE can be used without a paid license with up to three users. Licenses for more user can be purchased in the [Seafile Customer Center](https://customer.seafile.com) or contact Seafile Sales at sales@seafile.com or one of [our partners](https://www.seafile.com/en/partner/).



## Setup

Seafile prior and including Seafile 7.0 use Python 2. More recent versions use on Python 3.

### Installing prerequisites

**For Seafile 7.0.x**

```
# Ubuntu 16.04/Ubuntu 18.04
apt-get update
apt-get install python2.7 python-setuptools python-mysqldb python-urllib3 python-ldap -y

```



```
# CentOS 7
yum install python python-setuptools MySQL-python python-urllib3 python-ldap -y

```

**For Seafile 7.1.x**

```
# Debian 10/Ubuntu 18.04
apt-get update
apt-get install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```



```
# Ubuntu 20.04
apt-get update
apt-get install python 3 python3-setuptools python3-pip memcached libmemcached-dev -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap
```



```
# CentOS 8
yum install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```

**For Seafile 8.0.x**

```
# Debian 10/Ubuntu 18.04
apt-get update
apt-get install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap

```



```
# Ubuntu 20.04
apt-get update
apt-get install python3 python3-setuptools python3-pip memcached libmemcached-dev libmysqlclient-dev -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap mysqlclient
```



```
# CentOS 8
yum install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap

```



### Installing Java Runtime Environment

Java Runtime Environment (JRE) is a requirement for full text search with elasticsearch.

```
# Debian
sudo apt-get install openjdk-8-jre

```



```
# Ubuntu 16.04/Ubuntu 18.04/Ubuntu 20.04
sudo apt-get install openjdk-8-jre
sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/

```



```
# CentOS
sudo yum install java-1.8.0-openjdk

```



### Installing poppler-utils

The package poppler-utils is required for full text search of pdf files.

```
# Ubuntu/Debian
sudo apt-get install poppler-utils

```



```
# CentOS
sudo yum install poppler-utils

```

### Installing Python libraries

**For Seafile 7.1.x and younger **

First make sure your have installed Python 3.6 or a new version. Then install the following packages:

```
# Debian 10/Ubuntu 18.04
sudo easy_install pip
sudo pip install boto

```

If you receive an error about "Wheel installs require setuptools >= ...", run this between the pip and boto lines above

```
sudo pip install setuptools --no-use-wheel --upgrade

```



````
# Ubuntu 20.04
sudo pip install boto
````



### Installing all libraries required by the Community Edition

See [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).



### Creating programm directory for Seafile PE

The standard directory for Seafile's program files is `/opt/seafile`. Create this directory and change into it:

```
mkdir /opt/seafile
cd /opt/seafile

```

The  program directory can be changed. The standard directory `/opt/seafile` is assumed for the remainder of these instructions. If you decide to put Seafile in another directory, some commmands need to be modified accordingly.



### Activating Seafile PE license

Save the license file in Seafile's programm directory `/opt/seafile`. Make sure that the name is `seafile-license.txt`, rename it. (If the file has a different name or cannot be read, Seafile PE will not start.)



### Downloading the Seafile PE install package

Since Seafile PE 7.0.17, two install packages are available for every version in the [Seafile Customer Center](https://customer.seafile.com) (a user account is necessary, but registration is free):

* _seafile-pro-server_8.x.x_x86-64_Ubuntu.tar.gz_, compiled in Ubuntu 18.04 enviroment
* _seafile-pro-server_8.x.x_x86-64_CentOS.tar.gz_, compiled in CentOS 7 enviroment

The former is for installation on Ubuntu/Debian servers, the latter for CentOS.

Download the install package using wget.




### Uncompressing Seafile PE

The install package is a compressed tarball. Uncompress the package using tar:

```
tar xf seafile-pro-server_8.0.4_x86-64.tar.gz

```

Now you have:

```
#tree -L 1
seafile
├── seafile-license.txt
└── seafile-pro-server-8.0.4
└── seafile-pro-server_8.0.4_x86-64.tar.gz

```

Note: The names of the install packages differ for Seafile CE and Seafile PE. Taking the 8.0.4 64bit version as an example, the names are as follows:

* Seafile CE: `seafile-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-server-8.0.4`
* Seafile PE: `seafile-pro-server_8.0.4_x86-86.tar.gz`; uncompressing into folder `seafile-pro-server-8.0.4`



### Setup

The setup process of Seafile Professional Server is the same as the Seafile Community Server. See [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).

If you have any problem during the setup up, check [Common problems in setting up Seafile server](../deploy/common_problems_for_setting_up_server.md).

After you have succesfully setup Seafile PE, the directory layout looks like this:

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
│   └── seafdav.conf
│   └── seafevents.conf
│   └── seafile.conf
│   └── seahub_settings.py
├── pro-data                        # data specific for Seafile PE
├── seafile-data
│   └── library-template
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
├── seahub-data
│   └── avatars                        # for user avatars


```



## Performance tuning

For more than 50 users, we recommend [adding memcached](../deploy/add_memcached.md). Memcached increases the response time of Seahub, Seafile's web interface, significantly.

## FAQ

You may want to read more about Seafile Professional Server:

* [FAQ For Seafile Professional Server](faq_for_seafile_pro_server.md)

# Download and Setup Seafile Professional Server

## Preparation

Now when we release a new version, we will always provide 2 compressed files, for example:

* _seafile-pro-server_7.1.3_x86-64_Ubuntu.tar.gz_, is compiled in Ubuntu 18.04 enviroment.
* _seafile-pro-server_7.1.3_x86-64_CentOS.tar.gz_, is compiled in CentOS 7 enviroment.

If you are using Ubuntu/Debian server, please use _seafile-pro-server_7.1.3_x86-64_Ubuntu.tar.gz_, for CentOS please use _seafile-pro-server_7.1.3_x86-64.tar.gz_.

### Install thirdpart Requirements

The Seafile server package requires the following packages to be installed on your system:

**For Seafile 7.0.x**

```
# on Ubuntu 16.04
apt-get update
apt-get install python2.7 python-setuptools python-mysqldb python-urllib3 python-ldap -y

```

```
# on CentOS 7
yum install python python-setuptools MySQL-python python-urllib3 python-ldap -y

```

**For Seafile 7.1.x**

```
# on Debian 10/Ubuntu 18.04
apt-get update
apt-get install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```

```
# on CentOS 8
yum install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.3.8 \
    django-pylibmc django-simple-captcha python3-ldap

```

**For Seafile 8.0.x**

```
# on Debian 10/Ubuntu 18.04
apt-get update
apt-get install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap

```

```
# on CentOS 8
yum install python3 python3-setuptools python3-pip -y

pip3 install --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy==1.4.3 \
    django-pylibmc django-simple-captcha python3-ldap

```

For more information please see bellow.

### Minimum System Requirements

* A Linux server with 2GB RAM

### Install Java Runtime Environment (JRE)

On Debian:

```
sudo apt-get install openjdk-8-jre

```

On Ubuntu 16.04:

```
sudo apt-get install openjdk-8-jre
sudo ln -sf /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java /usr/bin/

```

On CentOS/Red Hat:

```
sudo yum install java-1.8.0-openjdk

```

### Install poppler-utils

The package poppler-utils is required for full text search of pdf files.

On Ubuntu/Debian:

```
sudo apt-get install poppler-utils

```

On CentOS/Red Hat:

```
sudo yum install poppler-utils

```

### Install Python libraries

First make sure your have installed Python 3.6 or a new version. Then install the following packages:

```
sudo easy_install pip
sudo pip install boto

```

If you receive an error about "Wheel installs require setuptools >= ...", run this between the pip and boto lines above

```
sudo pip install setuptools --no-use-wheel --upgrade

```

### Install all libraries required by the Community Edition

See [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).

## Download and Setup Seafile Professional Server

### Get the license

If the license you received is not named as `seafile-license.txt`, rename it to `seafile-license.txt`. Then put the license file under the top level diretory. In this manual, we use the diretory `/data/haiwen/` as the top level directory.

### Download & uncompress Seafile Professional Server

```
tar xf seafile-pro-server_7.0.7_x86-64.tar.gz

```

Now you have:

```
haiwen
├── seafile-license.txt
└── seafile-pro-server-7.0.7/

```

---

You should notice the difference between the names of the Community Server and Professional Server. Take the 7.0.7 64bit version as an example:

* Seafile Community Server tarball is `seafile-server_7.0.7_x86-86.tar.gz`; After uncompressing, the folder is `seafile-server-7.0.7`
* Seafile Professional Server tarball is `seafile-pro-server_7.0.7_x86-86.tar.gz`; After uncompressing, the folder is `seafile-pro-server-7.0.7`

### Setup

The setup process of Seafile Professional Server is the same as the Seafile Community Server. See [Download and Setup Seafile Server With MySQL](../deploy/using_mysql.md).

If you have any problem with setting up the service, please check [Common problems in setting up Seafile server](../deploy/common_problems_for_setting_up_server.md).

After you have succesfully setup Seafile Professional Server, you have a directory layout like this:

```
#tree haiwen -L 2
haiwen
├── seafile-license.txt # license file
├── ccnet               # configuration files
│   ├── mykey.peer
│   ├── PeerMgr
│   └── seafile.ini
├── conf
│   └── ccnet.conf
│   └── seafile.conf
│   └── seahub_settings.py
│   └── seafevents.conf
├── pro-data            # data specific for professional version
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
│   └── avatars         # for user avatars
├── seahub.db

```

## Performance tuning

If you have more than 50 Seafile users, we highly recommend to [add memcached](../deploy/add_memcached.md). This is going to speedup Seahub (the web front end) significantly.

## Done

At this point, the basic setup of Seafile Professional Server is done.

You may want to read more about Seafile Professional Server:

* [FAQ For Seafile Professional Server](faq_for_seafile_pro_server.md)

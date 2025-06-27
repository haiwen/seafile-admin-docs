# Installation of Seafile Server Community Edition with MySQL/MariaDB

This manual explains how to deploy and run Seafile Server Community Edition (Seafile CE) on a Linux server from a pre-built package using MySQL/MariaDB as database. The deployment has been tested for Debian/Ubuntu.

## Requirements

Please refer [here](../setup/system_requirements.md#seafile-ce) for system requirements about Seafile CE. In general, we recommend that you should have at least 2G RAM and a 2-core CPU (> 2GHz).


## Setup


### Installing and preparing the SQL database

Seafile supports MySQL and MariaDB. We recommend that you use the preferred SQL database management engine included in the package repositories of your distribution.

You can find step-by-step how-tos for installing MySQL and MariaDB in the [tutorials on the Digital Ocean website](https://www.digitalocean.com/community/tutorials).

Seafile uses the mysql_native_password plugin for authentication. The versions of MySQL and MariaDB installed on CentOS 8, Debian 10, and Ubuntu 20.04 use a different authentication plugin by default. It is therefore required to change to authentication plugin to mysql_native_password for the root user prior to the installation of Seafile. The above mentioned tutorials explain how to do it.

### Installing prerequisites

!!! tip
    The standard directory `/opt/seafile` is assumed for Seafile's program and we will use it on the rest of this manual. If you decide to put Seafile in another directory, modify the commands accordingly.

1. Install cache server (e.g., *Memcached*)

    ```sh
    sudo apt-get update
    sudo apt-get install -y memcached libmemcached-dev
    ```

2. Install Python and related libraries

    === "Ubuntu 24.04"
        !!! note
            Debian 12 and Ubuntu 24.04 are now discouraging system-wide installation of python modules with pip.  It is preferred now to install modules into a virtual environment which keeps them separate from the files installed by the system package manager, and enables different versions to be installed for different applications.  With these python virtual environments (venv for short) to work, you have to activate the venv to make the packages installed in it available to the programs you run.  That is done here with `source python-venv/bin/activate`.

        ```sh
        sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmysqlclient-dev ldap-utils libldap2-dev python3.12-venv default-libmysqlclient-dev build-essential pkg-config libmemcached-dev

        mkdir /opt/seafile
        cd /opt/seafile

        # create the vitual environment in the python-venv directory
        python3 -m venv python-venv

        # activate the venv
        source python-venv/bin/activate
        # Notice that this will usually change your prompt so you know the venv is active

        # install packages into the active venv with pip (sudo isn't needed because this is installing in the venv, not system-wide).
        pip3 install --timeout=3600 django==4.2.* future==1.0.* mysqlclient==2.2.* \
            pymysql pillow==10.4.* pylibmc captcha==0.6.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.* \
            psd-tools django-pylibmc django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.3.* pycryptodome==3.20.* cffi==1.17.0 lxml python-ldap==3.4.* gevent==24.2.*
        ```
    === "Debian 12"
        !!! note
            Debian 12 and Ubuntu 24.04 are now discouraging system-wide installation of python modules with pip.  It is preferred now to install modules into a virtual environment which keeps them separate from the files installed by the system package manager, and enables different versions to be installed for different applications.  With these python virtual environments (venv for short) to work, you have to activate the venv to make the packages installed in it available to the programs you run.  That is done here with `source python-venv/bin/activate`.

        ```sh
        sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmariadb-dev-compat ldap-utils libldap2-dev libsasl2-dev python3.11-venv 

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
    === "Ubuntu 22.04"

        ```sh
        sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmysqlclient-dev ldap-utils libldap2-dev default-libmysqlclient-dev build-essential pkg-config libmemcached-dev

        sudo mkdir /opt/seafile
        cd /opt/seafile

        sudo pip3 install --timeout=3600 django==4.2.* future==1.0.* mysqlclient==2.1.*  \
            pymysql pillow==10.4.* pylibmc captcha==0.6.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.* \
            psd-tools django-pylibmc django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.4.3 lxml gevent==24.2.*

        ```

    === "Debian 11"

        ```sh
        sudo apt-get install -y python3 python3-dev python3-setuptools python3-pip libmysqlclient-dev-compat ldap-utils libldap2-dev libsasl2-dev

        sudo mkdir /opt/seafile
        cd /opt/seafile

        sudo pip3 install --timeout=3600 django==4.2.* future==1.0.* mysqlclient==2.2.*  \
            pymysql pillow==10.4.* pylibmc captcha==0.6.* markupsafe==2.0.1 jinja2 sqlalchemy==2.0.* \
            psd-tools django-pylibmc django_simple_captcha==0.6.* djangosaml2==1.9.* pysaml2==7.2.* pycryptodome==3.16.* cffi==1.15.1 python-ldap==3.4.3 lxml gevent==24.2.*

        ```

### Creating user seafile

It is good practice not to run applications as root. 

Create a new user and follow the instructions on the screen:

=== "Ubuntu 24.04/22.04"
    ```
    adduser seafile
    ```
=== "Debian 12/11"
    ```
    /usr/sbin/adduser seafile
    ```

Change ownership of the created directory to the new user:

```
sudo chown -R seafile: /opt/seafile
```

All the following steps are done as user seafile.

Change to user seafile:

```
su seafile
```

### Downloading the install package

Download the install package from the [download page](https://www.seafile.com/en/download/) on Seafile's website using wget.

We use Seafile CE version 12.0.6 as an example in the rest of this manual.

### Uncompressing the package

The install package is downloaded as a compressed tarball which needs to be uncompressed.

Uncompress the package using tar:

```
tar xf seafile-server_12.0.6_x86-64.tar.gz
```

Now you have:

```
$ tree -L 2
.
├── python-venv # you will not see this directory if you use ubuntu 22/debian 10
│   ├── bin
│   ├── include
│   ├── lib
│   ├── lib64 -> lib
│   └── pyvenv.cfg
├── seafile-server-12.0.6
│   ├── check_init_admin.py
│   ├── migrate_ldapusers.py
│   ├── pro
│   ├── reset-admin.sh
│   ├── runtime
│   ├── seaf-fsck.sh
│   ├── seaf-fuse.sh
│   ├── seaf-gc.sh
│   ├── seafile
│   ├── seafile-monitor.sh
│   ├── seafile.sh
│   ├── seahub
│   ├── seahub.sh
│   ├── setup-seafile-mysql.py
│   ├── setup-seafile-mysql.sh
│   ├── setup-seafile.sh
│   ├── sql
│   └── upgrade
└── seafile-server_12.0.6_x86-64.tar.gz
```

### Setting up Seafile CE

The install package comes with a script that sets Seafile up for you. Specifically, the script creates the required directories and extracts all files in the right place. It can also create a MySQL user and the three databases that [Seafile's components](../introduction/components.md) require:

* ccnet server
* seafile server
* seahub

!!! note "While ccnet server was merged into the seafile-server in Seafile 8.0, the corresponding database is still required for the time being"

!!! tip
    For installations using python virtual environment, activate it if it isn't already active

    ```sh
    source python-venv/bin/activate
    ```

Run the script as user seafile:

```
cd seafile-server-12.0.6
./setup-seafile-mysql.sh

```

!!! note
    If you don't have the root password, you need someone who has the privileges, e.g., the database admin, to create the three databases required by Seafile, as well as a MySQL user who can access the databases. For example, to create three databases `ccnet_db` / `seafile_db` / `seahub_db` for ccnet/seafile/seahub respectively, and a MySQL user "seafile" to access these databases run the following SQL queries:

    ```
    create database `ccnet_db` character set = 'utf8';
    create database `seafile_db` character set = 'utf8';
    create database `seahub_db` character set = 'utf8';

    create user 'seafile'@'localhost' identified by 'seafile';

    GRANT ALL PRIVILEGES ON `ccnet_db`.* to `seafile`@localhost;
    GRANT ALL PRIVILEGES ON `seafile_db`.* to `seafile`@localhost;
    GRANT ALL PRIVILEGES ON `seahub_db`.* to `seafile`@localhost;

    ```

Configure your Seafile Server by specifying the following three parameters:

| Option                | Description                                          | Note                                                         |
| --------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| server name           | Name of the Seafile Server                           | 3-15 characters, only English letters, digits and underscore ('\_') are allowed |
| server's ip or domain | IP address or domain name used by the Seafile Server | Seafile client program will access the server using this address |
| fileserver port       | TCP port used by the Seafile fileserver              | Default port is 8082, it is recommended to use this port and to only change it if is used by other service |

In the next step, choose whether to create new databases for Seafile or to use existing databases. The creation of new databases requires the root password for the SQL server. 

![grafik](../images/seafile-setup-database.png)

=== "\[1] Create new ccnet/seafile/seahub databases"
    The script creates these databases and a MySQL user that Seafile Server will use to access them. To this effect, you need to answer these questions:

    | Question                        | Description                                                  | Note                                                         |
    | ------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
    | mysql server host               | Host address of the MySQL server                             | Default is localhost                                         |
    | mysql server port               | TCP port used by the MySQL server                            | Default port is 3306; almost every MySQL server uses this port |
    | mysql root password             | Password of the MySQL root account                           | The root password is required to create new databases and a MySQL user |
    | mysql user for Seafile          | MySQL user created by the script, used by Seafile's components to access the databases | Default is seafile; the user is created unless it exists     |
    | mysql password for Seafile user | Password for the user above, written in Seafile's config files | Percent sign ('%') is not allowed                            |
    | database name                   | Name of the database used by ccnet                           | Default is "ccnet_db", the database is created if it does not exist |
    | seafile database name           | Name of the database used by Seafile                         | Default is "seafile_db", the database is created if it does not exist |
    | seahub database name            | Name of the database used by seahub                          | Default is "seahub_db", the database is created if it does not exist |

=== "\[2] Use existing ccnet/seafile/seahub databases"
    The prompts you need to answer: 

    | Question                        | Description                                                  | Note                                                         |
    | ------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
    | mysql server host               | Host address of the MySQL server                             | Default is localhost                                         |
    | mysql server port               | TCP port used by MySQL server                                | Default port is 3306; almost every MySQL server uses this port |
    | mysql user for Seafile          | User used by Seafile's components to access the databases    | The user must exists                                         |
    | mysql password for Seafile user | Password for the user above                                  |                                                              |
    | ccnet database name             | Name of the database used by ccnet, default is "ccnet_db"    | The database must exist                                      |
    | seafile database name           | Name of the database used by Seafile, default is "seafile_db" | The database must exist                                      |
    | seahub dabase name              | Name of the database used by Seahub, default is "seahub_db"  | The database must exist                                      |

If the setup is successful, you see the following output:

![grafik](../images/seafile-setup-output.png)

The directory layout then looks as follows:

```sh
$ tree /opt/seafile -L 2
/opt/seafile
├── ccnet
├── conf
│   ├── gunicorn.conf.py
│   ├── seafdav.conf
│   ├── seafevents.conf
│   ├── seafile.conf
│   └── seahub_settings.py
├── pro-data
├── python-venv # you will not see this directory if you use ubuntu 22/debian 10
│   ├── bin
│   ├── include
│   ├── lib
│   ├── lib64 -> lib
│   └── pyvenv.cfg
├── seafile-data
│   └── library-template
├── seafile-server-12.0.6
│   ├── check_init_admin.py
│   ├── migrate_ldapusers.py
│   ├── pro
│   ├── reset-admin.sh
│   ├── runtime
│   ├── seaf-fsck.sh
│   ├── seaf-fuse.sh
│   ├── seaf-gc.sh
│   ├── seafile
│   ├── seafile-monitor.sh
│   ├── seafile.sh
│   ├── seahub
│   ├── seahub.sh
│   ├── setup-seafile-mysql.py
│   ├── setup-seafile-mysql.sh
│   ├── setup-seafile.sh
│   ├── sql
│   └── upgrade
├── seafile-server-latest -> seafile-server-12.0.6
├── seafile-server_12.0.6_x86-64.tar.gz
└── seahub-data
    └── avatars

```

The folder `seafile-server-latest` is a symbolic link to the current Seafile Server folder. When later you upgrade to a new version, the upgrade scripts update this link to point to the latest Seafile Server folder.

### Setup Memory Cache

Seahub caches items(avatars, profiles, etc) on file system by default(/tmp/seahub_cache/). You can replace with Memcached or Redis.

=== "Memcached"

    Use the following commands to install memcached and corresponding libraies on your system:

    ```sh
    # on Debian/Ubuntu 18.04+
    apt-get install memcached libmemcached-dev -y
    pip3 install --timeout=3600 pylibmc django-pylibmc

    systemctl enable --now memcached
    ```

    Add the following configuration to `seahub_settings.py`.

    ```py
    CACHES = {
        'default': {
            'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
            'LOCATION': '127.0.0.1:11211',
        },
    }

    ```

=== "Redis"

    !!! success "Redis is supported since version 11.0"

    1. Install Redis with package installers in your OS.

    2. Refer to [Django's documentation about using Redis cache](https://docs.djangoproject.com/en/4.2/topics/cache/#redis) to add Redis configurations to `seahub_settings.py`.

### Create the `.env` file in `conf/` directory

```sh
nano /opt/seafile/conf/.env
```

!!! tip
    `JWT_PRIVATE_KEY`, A random string with a length of no less than 32 characters can be generated from: 
    ```sh
    pwgen -s 40 1
    ```

```sh
JWT_PRIVATE_KEY=<Your jwt private key>
SEAFILE_SERVER_PROTOCOL=https
SEAFILE_SERVER_HOSTNAME=seafile.example.com
SEAFILE_MYSQL_DB_HOST=<your database host>
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_DB_USER=seafile
SEAFILE_MYSQL_DB_PASSWORD=<your MySQL password>
SEAFILE_MYSQL_DB_CCNET_DB_NAME=ccnet_db
SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=seafile_db
SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=seahub_db
```

## Starting Seafile Server

Run the following commands in `/opt/seafile/seafile-server-latest`:

!!! tip
    For installations using python virtual environment, activate it if it isn't already active

    ```sh
    source python-venv/bin/activate
    ```

```sh
./seafile.sh start # starts seaf-server
./seahub.sh start  # starts seahub
```

!!! success
    The first time you start Seahub, the script prompts you to create an admin account for your Seafile Server. Enter the email address of the admin user followed by the password.

Now you can access Seafile via the web interface at the host address and port 8000 (e.g., http://seafile.example.com:8000)


## Stopping and Restarting Seafile and Seahub

### Stopping

```sh
./seahub.sh stop 	# stops seahub
./seafile.sh stop 	# stops seaf-server

```

### Restarting

!!! tip
    For installations using python virtual environment, activate it if it isn't already active

    ```sh
    source python-venv/bin/activate
    ```

```
./seafile.sh restart
./seahub.sh restart

```

## Enabling HTTPS

It is strongly recommended to switch from unencrypted HTTP (via port 8000) to encrypted HTTPS (via port 443).

This manual provides instructions for enabling HTTPS for the two most popular web servers and reverse proxies (e.g, [Nginx](https_with_nginx.md))

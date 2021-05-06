# Migrate From SQLite to MySQL

**NOTE**: The tutorial is only available for Seafile CE version.

First make sure the python module for MySQL is installed. On Ubuntu, use `sudo apt-get install python-mysqldb` to install it.

Steps to migrate Seafile from SQLite to MySQL:

1. Stop Seafile and Seahub.

2. Download [sqlite2mysql.sh](https://raw.githubusercontent.com/haiwen/seafile-server/master/scripts/sqlite2mysql.sh) and [sqlite2mysql.py](https://raw.githubusercontent.com/haiwen/seafile-server/master/scripts/sqlite2mysql.py) to the top directory of your Seafile installation path. For example, `/opt/seafile`.

3. Run `sqlite2mysql.sh`:

```
chmod +x sqlite2mysql.sh
./sqlite2mysql.sh
```

This script will produce three files: `ccnet-db.sql`, `seafile-db.sql`, `seahub-db.sql`.

4. Create 3 databases ccnet_db, seafile_db, seahub_db and seafile user.

```
mysql> create database ccnet_db character set = 'utf8';
mysql> create database seafile_db character set = 'utf8';
mysql> create database seahub_db character set = 'utf8';
```

5. Import ccnet data to MySql.

```
mysql> use ccnet_db;
mysql> source ccnet-db.sql;
```

6. Import seafile data to MySql.

```
mysql> use seafile_db;
mysql> source seafile-db.sql;
```

7. Import seahub data to MySql.

```
mysql> use seahub_db;
mysql> source seahub-db.sql;
```

8. Modify configure files.

Append following lines to [ccnet.conf](../config/ccnet-conf.md):

```
[Database]
ENGINE=mysql
HOST=127.0.0.1
USER=root
PASSWD=root
DB=ccnet_db
CONNECTION_CHARSET=utf8
```
Note: Use `127.0.0.1`, don't use `localhost`.

Replace the database section in `seafile.conf` with following lines:

```
[database]
type=mysql
host=127.0.0.1
user=root
password=root
db_name=seafile_db
connection_charset=utf8
```

Append following lines to `seahub_settings.py`:

```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'USER' : 'root',
        'PASSWORD' : 'root',
        'NAME' : 'seahub_db',
        'HOST' : '127.0.0.1',
        # This is only needed for MySQL older than 5.5.5.
        # For MySQL newer than 5.5.5 INNODB is the default already.
        'OPTIONS': {
            "init_command": "SET storage_engine=INNODB",
        }
    }
}
```

9. Restart seafile and seahub

**NOTE**

User notifications will be cleared during migration due to the slight difference between MySQL and SQLite, if you only see the busy icon when click the notitfications button beside your avatar, please remove `user_notitfications` table manually by:

```
use seahub_db;
delete from notifications_usernotification;
```

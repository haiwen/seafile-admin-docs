## Overview

There are generally two parts of data to backup

* Seafile library data
* Databases

If you setup seafile server according to our manual, you should have a directory layout like:

```
/opt/seafile
  --seafile-server-9.0.x # untar from seafile package
  --seafile-data   # seafile configuration and data (if you choose the default)
  --seahub-data    # seahub data
  --logs
  --conf
```

All your library data is stored under the '/opt/seafile' directory.

Seafile also stores some important metadata data in a few databases. The names and locations of these databases depends on which database software you use.

For SQLite, the database files are also under the 'haiwen' directory. The locations are:

* ccnet/PeerMgr/usermgr.db: contains user information
* ccnet/GroupMgr/groupmgr.db: contains group information
* seafile-data/seafile.db: contains library metadata
* seahub.db: contains tables used by the web front end (seahub)

For MySQL, the databases are created by the administrator, so the names can be different from one deployment to another. There are 3 databases:

* ccnet_db: contains user and group information
* seafile_db: contains library metadata
* seahub_db: contains tables used by the web front end (seahub)

## Backup steps

The backup is a three step procedure:

1. Optional: Stop Seafile server first if you're using SQLite as database.
2. Backup the databases;
3. Backup the seafile data directory;

### Backup Order: Database First or Data Directory First

* backup data directory first, SQL later: When you're backing up data directory, some new objects are written and they're not backed up. Those new objects may be referenced in SQL database. So when you restore, some records in the database cannot find its object. So the library is corrupted.
* backup SQL first, data directory later: Since you backup database first, all records in the database have valid objects to be referenced. So the libraries won't be corrupted. But new objects written to storage when you're backing up are not referenced by database records. So some libraries are out of date. When you restore, some new data are lost.

The second sequence is better in the sense that it avoids library corruption. Like other backup solutions, some new data can be lost in recovery. There is always a backup window.
However, if your storage backup mechanism can finish quickly enough, using the first sequence can retain more data.

We assume your seafile data directory is in `/opt/seafile`. And you want to backup to `/backup` directory. The `/backup` can be an NFS or Windows share mount exported by another machine, or just an external disk. You can create a layout similar to the following in `/backup` directory:

```
/backup
---- databases/  contains database backup files
---- data/  contains backups of the data directory

```

### Backing up Databases

It's recommended to backup the database to a separate file each time. Don't overwrite older database backups for at least a week.

**MySQL**

Assume your database names are `ccnet_db`, `seafile_db` and `seahub_db`. mysqldump automatically locks the tables so you don't need to stop Seafile server when backing up MySQL databases. Since the database tables are usually very small, it won't take long to dump.

```
mysqldump -h [mysqlhost] -u[username] -p[password] --opt ccnet_db > /backup/databases/ccnet-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`

mysqldump -h [mysqlhost] -u[username] -p[password] --opt seafile_db > /backup/databases/seafile-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`

mysqldump -h [mysqlhost] -u[username] -p[password] --opt seahub_db > /backup/databases/seahub-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`

```

**SQLite**

You need to stop Seafile server first before backing up SQLite database.

```
sqlite3 /data/haiwen/ccnet/GroupMgr/groupmgr.db .dump > /backup/databases/groupmgr.db.bak.`date +"%Y-%m-%d-%H-%M-%S"`

sqlite3 /data/haiwen/ccnet/PeerMgr/usermgr.db .dump > /backup/databases/usermgr.db.bak.`date +"%Y-%m-%d-%H-%M-%S"`

sqlite3 /data/haiwen/seafile-data/seafile.db .dump > /backup/databases/seafile.db.bak.`date +"%Y-%m-%d-%H-%M-%S"`

sqlite3 /data/haiwen/seahub.db .dump > /backup/databases/seahub.db.bak.`date +"%Y-%m-%d-%H-%M-%S"`

```

### Backing up Seafile library data

The data files are all stored in the `/opt/seafile` directory, so just back up the whole directory. You can directly copy the whole directory to the backup destination, or you can use rsync to do incremental backup. 

To directly copy the whole data directory,

```
cp -R /opt/seafile /backup/data/seafile-`date +"%Y-%m-%d-%H-%M-%S"`
```

This produces a separate copy of the data directory each time. You can delete older backup copies after a new one is completed.

If you have a lot of data, copying the whole data directory would take long. You can use rsync to do incremental backup.

```
rsync -az /opt/seafile /backup/data

```

This command backup the data directory to `/backup/data/seafile`.

## Restore from backup

Now supposed your primary seafile server is broken, you're switching to a new machine. Using the backup data to restore your Seafile instance:

1. Copy `/backup/data/seafile` to the new machine. Let's assume the seafile deployment location new machine is also `/opt/seafile`.
2. Restore the database.
3. Since database and data are backed up separately, they may become a little inconsistent with each other. To correct the potential inconsistency, run seaf-fsck tool to check data integrity on the new machine. See [seaf-fsck documentation](seafile_fsck.md).

### Restore the databases

Now with the latest valid database backup files at hand, you can restore them.

**MySQL**

```
mysql -u[username] -p[password] ccnet_db < ccnet-db.sql.2013-10-19-16-00-05
mysql -u[username] -p[password] seafile_db < seafile-db.sql.2013-10-19-16-00-20
mysql -u[username] -p[password] seahub_db < seahub-db.sql.2013-10-19-16-01-05

```

**SQLite**

```
cd /data/haiwen
mv ccnet/PeerMgr/usermgr.db ccnet/PeerMgr/usermgr.db.old
mv ccnet/GroupMgr/groupmgr.db ccnet/GroupMgr/groupmgr.db.old
mv seafile-data/seafile.db seafile-data/seafile.db.old
mv seahub.db seahub.db.old
sqlite3 ccnet/PeerMgr/usermgr.db < usermgr.db.bak.xxxx
sqlite3 ccnet/GroupMgr/groupmgr.db < groupmgr.db.bak.xxxx
sqlite3 seafile-data/seafile.db < seafile.db.bak.xxxx
sqlite3 seahub.db < seahub.db.bak.xxxx

```

## Backup and recovery for Seafile Docker

### Structure

We assume your seafile volumns path is in `/opt/seafile-data`. And you want to backup to `/opt/seafile-backup` directory.
You can create a layout similar to the following in /opt/seafile-backup directory:

```
/opt/seafile-backup
---- databases/  MySQL contains database backup files
---- data/  Seafile contains backups of the data directory

```

The data files to be backed up:

```
/opt/seafile-data/seafile/conf  # configuration files
/opt/seafile-data/seafile/seafile-data # data of seafile
/opt/seafile-data/seafile/seahub-data # data of seahub

```

### Backup

Steps:

1. Backup the databases;
2. Backup the seafile data directory;

Backup Order: Database First or Data Directory First

#### Backing up Database

```bash
# It's recommended to backup the database to a separate file each time. Don't overwrite older database backups for at least a week.
cd /opt/seafile-backup/databases
docker exec -it seafile-mysql mysqldump  -uroot --opt ccnet_db > ccnet_db.sql
docker exec -it seafile-mysql mysqldump  -uroot --opt seafile_db > seafile_db.sql
docker exec -it seafile-mysql mysqldump  -uroot --opt seahub_db > seahub_db.sql
```

#### Backing up Seafile library data

##### To directly copy the whole data directory

```bash
cp -R /opt/seafile-data/seafile /opt/seafile-backup/data/
cd /opt/seafile-backup/data && rm -rf ccnet
```

##### Use rsync to do incremental backup

```bash
rsync -az /opt/seafile-data/seafile /opt/seafile-backup/data/
cd /opt/seafile-backup/data && rm -rf ccnet
```

### Recovery

#### Restore the databases

```bash
docker cp /opt/seafile-backup/databases/ccnet_db.sql seafile-mysql:/tmp/ccnet_db.sql
docker cp /opt/seafile-backup/databases/seafile_db.sql seafile-mysql:/tmp/seafile_db.sql
docker cp /opt/seafile-backup/databases/seahub_db.sql seafile-mysql:/tmp/seahub_db.sql

docker exec -it seafile-mysql /bin/sh -c "mysql -uroot ccnet_db < /tmp/ccnet_db.sql"
docker exec -it seafile-mysql /bin/sh -c "mysql -uroot seafile_db < /tmp/seafile_db.sql"
docker exec -it seafile-mysql /bin/sh -c "mysql -uroot seahub_db < /tmp/seahub_db.sql"
```

### Restore the seafile data

```bash
cp -R /opt/seafile-backup/data/* /opt/seafile-data/seafile/
```

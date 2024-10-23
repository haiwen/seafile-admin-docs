# Deploy with an existing MySQL server

If you want to use an existing MySQL server, you can modify the `.env` as follows

```env
SEAFILE_MYSQL_DB_HOST=192.168.0.2
SEAFILE_MYSQL_DB_PORT=3306
SEAFILE_MYSQL_ROOT_PASSWORD=ROOT_PASSWORD
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD
```

NOTE: `SEAFILE_MYSQL_ROOT_PASSWORD` is needed during installation (i.e., the deployment in the first time). After Seafile is installed, the user `seafile` will be used to connect to the MySQL server (SEAFILE_MYSQL_DB_PASSWORD), then you can remove the `SEAFILE_MYSQL_ROOT_PASSWORD`.
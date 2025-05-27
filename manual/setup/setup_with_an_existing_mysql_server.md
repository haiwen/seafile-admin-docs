---
status: new
---

# Deploy with an existing MySQL server

The entire `db` service needs to be removed (or noted) in `seafile-server.yml` if you would like to use an existing MySQL server, otherwise there is a redundant database service is running 

```yml
service:

  # note or remove the entire `db` service
  #db:
    #image: ${SEAFILE_DB_IMAGE:-mariadb:10.11}
    #container_name: seafile-mysql
    # ... other parts in service `db`

  # do not change other services
...
```

What's more, you have to modify the `.env` to set correctly the fields with MySQL:

```env
SEAFILE_MYSQL_DB_HOST=192.168.0.2
SEAFILE_MYSQL_DB_PORT=3306
INIT_SEAFILE_MYSQL_ROOT_PASSWORD=ROOT_PASSWORD
SEAFILE_MYSQL_DB_PASSWORD=PASSWORD
```

!!! tip
    `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` is needed during installation (i.e., the deployment in the first time). After Seafile is installed, the user `seafile` will be used to connect to the MySQL server (SEAFILE_MYSQL_DB_PASSWORD), then you can remove the `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`.

# ccnet.conf


Ccnet is the internal RPC framework used by Seafile server and also manages the user database. A few useful options are in ccnet.conf. 

!!! warning "`ccnet.conf` is removed in version 12.0"

## Options that moved to .env file

Due to `ccnet.conf` is removed in version 12.0, the following informaiton is read from `.env` file

```
SEAFILE_MYSQL_DB_USER: The database user, the default is seafile
SEAFILE_MYSQL_DB_PASSWORD: The database password
SEAFILE_MYSQL_DB_HOST: The database host
SEAFILE_MYSQL_DB_CCNET_DB_NAME: The database name for ccnet db, the default is ccnet_db
```


## Changing MySQL Connection Pool Size

> In version 12.0, the following information is read from the same option in seafile.conf

When you configure ccnet to use MySQL, the default connection pool size is 100, which should be enough for most use cases. You can change this value by adding following options to ccnet.conf:

```
[Database]
......
# Use larger connection pool
MAX_CONNECTIONS = 200
```

## Using Encrypted Connections

> In version 12.0, the following information is read from the same option in seafile.conf

Since Seafile 10.0.2, you can enable the encrypted connections to the MySQL server by adding the following configuration options:

```
[Database]
USE_SSL = true
SKIP_VERIFY = false
CA_PATH = /etc/mysql/ca.pem
```

When set `use_ssl` to true and `skip_verify` to false, it will check whether the MySQL server certificate is legal through the CA configured in `ca_path`. The `ca_path` is a trusted CA certificate path for signing MySQL server certificates. When `skip_verify` is true, there is no need to add the `ca_path` option. The MySQL server certificate won't be verified at this time.

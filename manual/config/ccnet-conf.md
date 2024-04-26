# ccnet.conf


Ccnet is the internal RPC framework used by Seafile server and also manages the user database. A few useful options are in ccnet.conf. Ccnet component is merged into seaf-server in version 7.1, but the configuration file are still needed.


## Changing MySQL Connection Pool Size

When you configure ccnet to use MySQL, the default connection pool size is 100, which should be enough for most use cases. You can change this value by adding following options to ccnet.conf:

```
[Database]
......
# Use larger connection pool
MAX_CONNECTIONS = 200
```

## Using Encrypted Connections

Since Seafile 10.0.2, you can enable the encrypted connections to the MySQL server by adding the following configuration options:

```
[Database]
USE_SSL = true
SKIP_VERIFY = false
CA_PATH = /etc/mysql/ca.pem
```

When set `use_ssl` to true and `skip_verify` to false, it will check whether the MySQL server certificate is legal through the CA configured in `ca_path`. The `ca_path` is a trusted CA certificate path for signing MySQL server certificates. When `skip_verify` is true, there is no need to add the `ca_path` option. The MySQL server certificate won't be verified at this time.

## Changing name of table 'Group'

There is a table named 'Group' in ccnet database, however, 'Group' is the key word in some of databases, you can configure this table name to avoid conflicts if necessary:

```
[GROUP]
TABLE_NAME=new_group_name
```

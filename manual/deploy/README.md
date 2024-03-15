# Deploying Seafile

We provide three ways to deploy Seafile services. Since version 8.0, **Docker is the recommended way**.

* Using [Docker](../docker/deploy_seafile_with_docker.md)
* Using [installation script](https://github.com/haiwen/seafile-server-installer)
* Manually installing Seafile and setting up database, memcached and Nginx/Apache. See the following section.

## Manually deployment options

* [Deploying Seafile with MySQL](using_mysql.md)
* [Deploying Seafile with SQLite](using_sqlite.md), note, deploy Seafile with SQLite is not supported since version 11.0
* [Config Seahub with Nginx](deploy_with_nginx.md)
* [Enabling Https with Nginx](https_with_nginx.md)
* [Config Seahub with Apache](deploy_with_apache.md)
* [Enabling Https with Apache](https_with_apache.md)
* [Start Seafile at System Bootup](start_seafile_at_system_bootup.md)
* [Firewall settings](using_firewall.md)
* [Logrotate](using_logrotate.md)

## LDAP and AD integration

[LDAP/AD Integration](using_ldap.md)

## Single Sign On

Seafile supports a few Single Sign On authentication protocols. See [Single Sign On](single_sign_on.md) for a summary.

## Other Deployment Issues

* [Deploy Seafile behind NAT](deploy_seafile_behind_nat.md)
* [Deploy Seahub at Non-root domain](deploy_seahub_at_non-root_domain.md)
* [Migrate From SQLite to MySQL](migrate_from_sqlite_to_mysql.md)


## Trouble shooting

1. Read [Seafile Server Components Overview](../overview/components.md) to understand how Seafile server works. This will save you a lot of time.
2. Read [FAQ](https://cloud.seatable.io/dtable/external-links/7b976c85f504491cbe8e/)
3. Go to our [forum](https://forum.seafile.com/) for help.

## Upgrade Seafile Server

* [Upgrade Seafile server](../upgrade/upgrade.md)

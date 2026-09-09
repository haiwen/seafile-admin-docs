# Upgrade Seafile Docker from 10.0 to 11.0

For maintenance upgrade, like from version 10.0.1 to version 10.0.4, just download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version, then start with docker compose up.

For major version upgrade, like from 10.0 to 11.0, see instructions below.

Please check the **upgrade notes** for any special configuration or changes before/while upgrading.

----

Download the new image, stop the old docker container, modify the Seafile image version in docker-compose.yml to the new version. Taking the [community edition](../setup/setup_ce_by_docker.md) as an example, you have to modify

```yml
...
service:
    ...
    seafile:
        image: seafileltd/seafile-mc:10.0-latest
        ...
    ...
```

to

```yml
service:
    ...
    seafile:
        image: seafileltd/seafile-mc:11.0-latest
        ...
    ...
```

 It is also recommended that you upgrade **mariadb** and **memcached** to newer versions as in the v11.0 docker-compose.yml file. Specifically, in version 11.0, we use the following versions:

- MariaDB: 10.11
- Memcached: 1.6.18

What's more, you have to migrate configuration for LDAP and OAuth according to [here](upgrade_notes_for_11.0.md)

Start with docker compose up.

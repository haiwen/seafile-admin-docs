# Run Seafile as non root user inside docker

You can use run Seafile as non root user in docker.

Note: In non root mode, the `seafile` user is automatically created in the container, with uid 8000 and gid 8000.

First deploy Seafile with docker, and destroy the containers.

```bash
docker compose down
```

Then add the `NON_ROOT=true` to the `.env`.

```env
NON_ROOT=true
```

Then modify `/opt/seafile-data/seafile/` permissions.

```bash
chmod -R a+rwx /opt/seafile-data/seafile/
```

Start Seafile:

```bash
docker compose up -d
```

Now you can run Seafile as `seafile` user.

!!! tip
    When doing maintenance, other scripts in docker are also required to be run as `seafile` user, e.g. `su seafile -c ./seaf-gc.sh`

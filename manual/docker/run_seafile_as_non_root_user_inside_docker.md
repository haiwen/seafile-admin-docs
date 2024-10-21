# Run Seafile as non root user inside docker

You can use run seafile as non root user in docker. (**NOTE:** Programs such as `my_init`, Nginx are still run as `root` inside docker.)

First add the `NON_ROOT=true` to the `.env`.

```env
NON_ROOT=true
```

Then modify `/opt/seafile-data/seafile/` permissions.

```bash
chmod -R a+rwx /opt/seafile-data/seafile/
```

Then destroy the containers and run them again:

```bash
docker compose down
docker compose up -d
```

Now you can run Seafile as `seafile` user. (**NOTE:** Later, when doing maintenance, other scripts in docker are also required to be run as `seafile` user, e.g. `su seafile -c ./seaf-gc.sh`)
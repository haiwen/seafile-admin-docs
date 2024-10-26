# Migrate CE to Pro with Docker

## Preparation

1. Make sure you are running a Seafile Community edition that match the latest version of pro edition. For example, if the latest pro edition is version 11.0, you should first upgrade the community edition to version 11.0.
2. Purchase Seafile Professional license file.
3. Download the `seafile-server.yml` of Seafile Pro.

```sh
wget "https://manual.seafile.com/12.0/docker/pro/seafile-server.yml"
```

## Migrate

### Stop the Seafile CE

```sh
docker compose down

```

**To ensure data security, it is recommended that you back up your MySQL data.**

### Put your licence file

Copy the `seafile-license.txt` to the volume directory of the Seafile CE's data. If the directory is `/opt/seafile-data`, so you should put it in the `/opt/seafile-data/seafile/`.

### Modify the new docker-compose.yml

Replace the old `docker-compose.yml` file with the new `docker-compose.yml` file and modify its configuration based on your actual situation:

* The Seafile Pro docker tag must be equal to or newer than the old Seafile CE docker tag.
* The certificate of MySQL users (e.g., `MYSQL_ROOT_PASSWORD` and `DB_ROOT_PASSWD`) should be consistent with the old;
* The volume directory of MySQL data (volumes) should be consistent with the old one;
* The volume directory of Seafile data (volumes) should be consistent with the old one;
* The volume directory of Caddy data (volumes) should be consistent with the old one;
* The volume directory of Elasticsearch data (volumes), this is the directory used to store the Elasticsearch's index data, E.g：`/opt/seafile-elasticsearch/data:/usr/share/elasticsearch/data`;

### Do the migration

The Seafile Pro container needs to be running during the migration process, which means that end users may access the Seafile service during this process. In order to avoid the data confusion caused by this, it is recommended that you take the necessary measures to temporarily prohibit users from accessing the Seafile service. For example, modify the firewall policy.

Run the following command to run the Seafile-Pro container：

```sh
docker compose up

```

Then run the migration script by executing the following command:

```sh
docker exec -it seafile /opt/seafile/seafile-server-latest/pro/pro.py setup --migrate

```

After the migration script runs successfully, modify `es_host, es_port` in `/opt/seafile-data/seafile/conf/seafevents.conf` manually.

```conf
[INDEX FILES]
es_host = elasticsearch
es_port = 9200
enabled = true
interval = 10m
```

Restart the Seafile Pro container.

```sh
docker restart seafile
```

Now you have a Seafile Professional service.

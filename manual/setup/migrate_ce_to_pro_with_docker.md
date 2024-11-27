# Migrate CE to Pro with Docker

## Preparation

1. Make sure you are running a Seafile Community edition that match the latest version of pro edition. For example, if the latest pro edition is version 12.0, you should first upgrade the community edition to version 12.0.
2. Purchase Seafile Professional license file.
3. Download the `.env` and `seafile-server.yml` of Seafile Pro.

```sh
wget -O .env https://manual.seafile.com/12.0/docker/pro/env
wget https://manual.seafile.com/12.0/docker/pro/seafile-server.yml
```

## Migrate

### Stop the Seafile CE

```sh
docker compose down

```

!!! tip
    To ensure data security, it is recommended that you back up your MySQL data

### Put your licence file

Copy the `seafile-license.txt` to the volume directory of the Seafile CE's data. If the directory is `/opt/seafile-data`, so you should put it in the `/opt/seafile-data/seafile/`.

### Modify the new seafile-server.yml and .env

Modify `.env` based on the old configurations from the old `.env` file. The following fields should be paid special attention and **others should be the same as the old configurations**:

| Variable                        | Description                                                                                                   | Default Value                   | 
| ------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------- |  
| `SEAFILE_IMAGE`                | The Seafile pro docker image, which the tag must be **equal to or newer than** the old Seafile CE docker tag                                                                       | `seafileltd/seafile-pro-mc:12.0-latest`             |
| `SEAFILE_ELASTICSEARCH_VOLUME`  | The volume directory of Elasticsearch data | `/opt/seafile-elasticsearch/data` |

For other fileds (e.g., `SEAFILE_VOLUME`, `SEAFILE_MYSQL_VOLUME`, `SEAFILE_MYSQL_DB_USER`, `SEAFILE_MYSQL_DB_PASSWORD`), **must be consistent** with the old configurations.

!!! tip
    For the configurations using to do the initializations (e.g, `INIT_SEAFILE_ADMIN_EMAIL`, `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`, `INIT_S3_STORAGE_BACKEND_CONFIG`), you can remove it from `.env` as well

### Replace seafile-server.yml and .env

Replace the old `seafile-server.yml` and `.env` by the new and modified files, i.e. (if your old `seafile-server.yml` and `.env` are in the `/opt`)

```sh
mv -b seafile-server.yml /opt/seafile-server.yml
mv -b .env /opt/.env
```

### Do the migration

The Seafile Pro container needs to be running during the migration process, which means that end users may access the Seafile service during this process. In order to avoid the data confusion caused by this, it is recommended that you take the necessary measures to temporarily prohibit users from accessing the Seafile service. For example, modify the firewall policy.

Run the following command to run the Seafile-Pro container：

```sh
docker compose up -d

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

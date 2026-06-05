# Migrate CE to Pro with Docker

## Preparation

1. Make sure you are running a Seafile Community edition that match the latest version of pro edition. For example, if the latest pro edition is version 14.0, you should first upgrade the community edition to version 14.0.
2. Purchase Seafile Professional license file.
3. Download the `.env` and `seafile-server.yml` of Seafile Pro.

```sh
wget -O .env https://manual.seafile.com/14.0/repo/docker/pro/env
wget https://manual.seafile.com/14.0/repo/docker/pro/seafile-server.yml
wget https://manual.seafile.com/14.0/repo/docker/pro/seasearch.yml
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
| `SEAFILE_IMAGE`                | The Seafile pro docker image, which the tag must be **equal to or newer than** the old Seafile CE docker tag                                                                       | `seafileltd/seafile-pro-mc:14.0-latest`             |
| `SS_DATA_PATH`                  | The volume directory of SeaSearch data | `/opt/seasearch-data` |

For other fileds (e.g., `SEAFILE_VOLUME`, `SEAFILE_MYSQL_VOLUME`, `SEAFILE_MYSQL_DB_USER`, `SEAFILE_MYSQL_DB_PASSWORD`), **must be consistent** with the old configurations.

!!! tip
    For initialization configurations that are not required by SeaSearch (e.g., `INIT_SEAFILE_MYSQL_ROOT_PASSWORD`), you can remove them from `.env` as well. Keep `INIT_SS_ADMIN_USER` and `INIT_SS_ADMIN_PASSWORD` for the first SeaSearch startup.

### Replace `seafile-server.yml` and `.env`

Replace the old `seafile-server.yml` and `.env` by the new and modified files, i.e. (if your old `seafile-server.yml` and `.env` are in the `/opt`)

```sh
mv -b seafile-server.yml /opt/seafile-server.yml
mv -b .env /opt/.env
```

### Configure SeaSearch

Since Seafile Pro 14.0, SeaSearch is the default search engine. For SeaSearch deployment and configuration details, refer to [SeaSearch configuration](./use_seasearch.md).

### Start Seafile Pro

Run the following command to run the Seafile-Pro container：

```sh
docker compose up -d
```

Now you have a Seafile Professional service.

# Use Docker compose secrets

To keep sensitive information (like passwords) out of your `docker-compose.yml` or `.env` files, you can use Docker Compose secrets.

You need to complete the Seafile Docker deployment first, remove the `INIT_***`, `SEAFILE_MYSQL_DB_PASSWORD`, `REDIS_PASSWORD`, `JWT_PRIVATE_KEY`, `S3_SECRET_KEY` environment variables, and then use Docker compose secrets.

## Create secrets files

First, create a plain text file on your host machine to store your sensitive environment variables in `KEY=value` format for Seafile. For example, create a file named `seafile_secrets.txt` in the `./secrets/` directory :

```bash
mkdir secrets/
```

seafile_secrets.txt

```env
JWT_PRIVATE_KEY=jwt_key
S3_SECRET_KEY=s3_key
```

Then create separate text files for specific passwords for databases like MySQL and Redis (which only need the raw password string, not `KEY=value`).

- `mysql_password.txt` (contains only: `db_password`)
- `redis_password.txt` (contains only: `redis_password`)

## Modify seafile-server.yml

Update `seafile-server.yml` to define the secrets and mount them into the respective containers.

- The Seafile container expects its secret file to be mounted at `/run/secrets/seafile_secrets`. You can also configure a custom secret file path using the `SEAFILE_SECRETS_FILE`, `MYSQL_PASSWORD_FILE`, and `REDIS_PASSWORD_FILE` environment variables.
- After the initial deployment, MySQL does not need to read the password.
- Redis can read the secret file using a custom startup command.

Here is an example snippet showing how to configure all of them:

```yaml
  redis:
    command:
      - /bin/sh
      - -c
      - exec redis-server --requirepass "$$(cat /run/secrets/redis_password)" --save "" --appendonly no
    secrets:
      - redis_password

  seafile:
    environment:
      - SEAFILE_SECRETS_FILE=/run/secrets/seafile_secrets
      - MYSQL_PASSWORD_FILE=/run/secrets/mysql_password
      - REDIS_PASSWORD_FILE=/run/secrets/redis_password
    secrets:
      - seafile_secrets
      - mysql_password
      - redis_password

secrets:
  seafile_secrets:
    file: ./secrets/seafile_secrets.txt
  mysql_password:
    file: ./secrets/mysql_password.txt
  redis_password:
    file: ./secrets/redis_password.txt
```

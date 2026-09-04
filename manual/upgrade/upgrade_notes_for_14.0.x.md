# Upgrade notes for 14.0

- These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

- For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 14.0 has the following configuration changes:

* WebDAV is configured via environment variables in the Seafile server `.env`. 
* Metadata server is configured via environment variables in the Seafile server `.env`. 
* Seafile AI models are configured via `seafile_ai_config.yaml`.
* Face recognition has been removed. 
* Thumbnail server configurations in `seahub_settings.py` have changed. Please refer to [Thumbnail server](../extension/thumbnail-server.md) for details.
* SeaSearch is the default search engine for new Seafile Pro Docker deployments.
* Local-password policy for externally authenticated users is now controlled by `DISABLE_SSO_USER_LOCAL_PWD_LOGIN` in `seahub_settings.py`.

## Seafile AI configuration changes

Seafile AI configuration has changed in Seafile 14.0.

1. LLM configuration is moved from the Seafile `.env` file to `$SEAFILE_VOLUME/seafile/conf/seafile_ai_config.yaml`. After `LLM_MODELS` is configured, remove the following legacy model environment variables:

    ```env
    SEAFILE_AI_LLM_TYPE=
    SEAFILE_AI_LLM_URL=
    SEAFILE_AI_LLM_KEY=
    SEAFILE_AI_LLM_MODEL=
    ```

    Configure one or more models in `LLM_MODELS` instead. Set one model as the default and assign model tiers as needed.

2. The following environment variables are added for Seafile AI:

    ```env
    INNER_METADATA_SERVER_URL=
    SEASEARCH_URL=
    SEASEARCH_TOKEN=

    SEAFILE_MYSQL_DB_HOST=
    SEAFILE_MYSQL_DB_PORT=
    SEAFILE_MYSQL_DB_USER=
    SEAFILE_MYSQL_DB_PASSWORD=
    SEAFILE_MYSQL_DB_CCNET_DB_NAME=
    SEAFILE_MYSQL_DB_SEAFILE_DB_NAME=
    SEAFILE_MYSQL_DB_SEAHUB_DB_NAME=

    SEAF_SERVER_STORAGE_TYPE=
    S3_COMMIT_BUCKET=
    S3_FS_BUCKET=
    S3_BLOCK_BUCKET=
    S3_KEY_ID=
    S3_SECRET_KEY=
    S3_USE_V4_SIGNATURE=
    S3_AWS_REGION=
    S3_HOST=
    S3_USE_HTTPS=
    S3_PATH_STYLE_REQUEST=
    S3_SSE_C_KEY=
    ```

3. Face recognition and the face-embedding service have been removed. Remove the following configuration and any `face-embedding.yml` file from your `COMPOSE_FILE` setting:

    ```env
    ENABLE_FACE_RECOGNITION=
    FACE_EMBEDDING_SERVICE_URL=
    FACE_EMBEDDING_SERVICE_KEY=
    FACE_EMBEDDING_VOLUME=
    ```

For configuration details, refer to [Seafile AI extension](../extension/seafile-ai.md).

## Local password configuration changes

The following `seahub_settings.py` options have been removed in Seafile 14.0:

```python
DISABLE_ADFS_USER_PWD_LOGIN = True
ENABLE_CHANGE_PASSWORD = True
ENABLE_SSO_USER_CHANGE_PASSWORD = True
```

Remove these options from `seahub_settings.py`. To prevent users authenticated through external providers from using passwords stored in Seafile, add the following option instead:

```python
DISABLE_SSO_USER_LOCAL_PWD_LOGIN = True # default: False
```

When enabled, this option disables local-password login and local password change/reset operations for users authenticated through SAML/ADFS, OAuth, LDAP, and so on. 

# Upgrade notes for 14.0

- These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

- For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 14.0 has the following configuration changes:

* WebDAV is configured via environment variables in the Seafile server `.env`. Please refer to [WebDAV extension](../extension/webdav.md) for details.
* Metadata server is configured via environment variables in the Seafile server `.env`. Please refer to [Metadata server](../extension/metadata-server.md) for details.
* Seafile AI models are configured via `seafile_ai_config.yaml`. If you are upgrading an existing Seafile AI deployment, please update the Seafile AI model configuration accordingly. Please refer to [Seafile AI extension](../extension/seafile-ai.md) for details.
* Face recognition has been removed. Remove `ENABLE_FACE_RECOGNITION` and any face-embedding service configuration from your deployment configuration.
* Thumbnail server configurations in `seahub_settings.py` have changed. Please refer to [Thumbnail server](../extension/thumbnail-server.md) for details.
* SeaSearch is the default search engine for new Seafile Pro Docker deployments.
* Local-password policy for externally authenticated users is now controlled by `DISABLE_SSO_USER_LOCAL_PWD_LOGIN` in `seahub_settings.py`.

### Local password configuration changes

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

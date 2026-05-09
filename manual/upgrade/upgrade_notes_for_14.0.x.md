# Upgrade notes for 14.0

- These notes give additional information about changes.
Please always follow the main [upgrade guide](./upgrade.md).

- For docker based version, please check [upgrade Seafile Docker image](./upgrade_docker.md)

## Important release changes

Seafile version 14.0 has the following configuration changes:

* WebDAV is configured via environment variables in the Seafile server `.env`. Please refer to [WebDAV extension](../extension/webdav.md) for details.
* Metadata server is configured via environment variables in the Seafile server `.env`. Please refer to [Metadata server](../extension/metadata-server.md) for details.
* Thumbnail server configurations in `seahub_settings.py` have changed. Please refer to [Thumbnail server](../extension/thumbnail-server.md) for details.

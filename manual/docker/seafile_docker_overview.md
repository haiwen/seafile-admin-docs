# Seafile Docker overview

Seafile Docker consists of the following components:

- Seafile server: Seafile core services, see [Seafile Components](../overview/components.md) for the details.
- Sdoc server: SeaDoc server, provide a lightweight online collaborative document editor, see [SeaDoc](../extra_setup/setup_seadoc.md#architecture) for the details.
- Database: Stores data related to Seafile and SeaDoc.
- Memcached: Cache server.
- Caddy: Caddy server enables user to access the Seafile service (i.e., Seafile server and Sdoc server) externally and handles `SSL` configuration

![Seafile Docker Structure](../images/seafile-12.0-docker-structure.png)

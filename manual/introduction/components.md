# Seafile Components

Seafile Server consists of the following two components:

- **Seahub** (django)：the web frontend. Seafile server package contains a light-weight Python HTTP server gunicorn that serves the website. By default, Seahub runs as an application within gunicorn. 
- **Seafile server** (``seaf-server``)：data service daemon, handles raw file upload, download and synchronization. Seafile server by default listens on port 8082. You can configure Nginx/Apache to proxy traffic to the local 8082 port.

The picture below shows how Seafile clients access files when you configure Seafile behind Nginx/Apache.

![Seafile Sync](../images/seafile-arch-new-http.png)

!!! tip
    All access to the Seafile service (including Seahub and Seafile server) can be configured behind Nginx or Apache web server. This way all network traffic to the service can be encrypted with HTTPS.

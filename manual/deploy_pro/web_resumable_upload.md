# Web Resumable File Upload

When uploading a large file in the web interface, if the network is unreliable, the upload can be interrupted. It's convenient if the upload can be resumed from where it stopped last time. In Seafile Professional Server 4.4.0 and above, this feature is supported.

This feature works as following:

1. A user uploads a large file on the web interface, and the connection is interrupted after some part of the file has been uploaded.
2. The server remembers where the upload stopped.
3. When the same file is uploaded to the same library and folder, the server tells the browser where to start the upload.

Limitations:

1. Only supports resumble upload. File update and folder upload is not resumable.
2. Only supports Chrome, Firefox, IE 10+.

To enable this feature, add following options to seahub_settings.py:

```
ENABLE_RESUMABLE_FILEUPLOAD = True
```

In Seafile cluster, in order to make this feature work as espected, one of the following two special configurations must be done:

1. seafile-server-latest/seafile-data/httptemp folder should be shared amoung all front end Seafile Servers via NFS.
2. Or, configure the load balancer to always send requests from the same IP address to a fixed back end server.

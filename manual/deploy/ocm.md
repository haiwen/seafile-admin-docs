# Open Cloud Mesh

From 8.0.0, Seafile supports [OCM protocol](https://rawgit.com/GEANT/OCM-API/v1/docs.html). With OCM, user can share library to other server which enabled OCM too.

Seafile currently support sharing between Seafile servers with version greater than 8.0, and sharing from NextCloud to Seafile since 9.0.

## Configuration

### Sharing between Seafile servers

Add the following configuration to `seahub_settings.py`.

```python
# Enable OCM
ENABLE_OCM = True
OCM_PROVIDER_ID = '71687320-6219-47af-82f3-32012707a5ae' # the unique id of this server
OCM_REMOTE_SERVERS = [
    {
        "server_name": "dev",
        "server_url": "https://seafile-domain-1/", # should ends with '/'
    },
    {
        "server_name": "download",
        "server_url": "https://seafile-domain-2/", # should ends with '/'
    },
]
```

OCM_REMOTE_SERVERS is the list of servers that you want your users to share libraries with.

### Sharing from NextCloud to Seafile

Add the following configuration to `seahub_settings.py`.

```python
# Enable OCM
ENABLE_OCM_VIA_WEBDAV = True
OCM_PROVIDER_ID = '71687320-6219-47af-82f3-32012707a5ae' # the unique id of this server
OCM_REMOTE_SERVERS = [
    {
        "server_name": "nextcloud",
        "server_url": "https://nextcloud-domain-1/", # should ends with '/'
    }
]
```

## Usage

### Share library to other server

In the library sharing dialog, jump to "Share to other server", you can share this library to user of other server with "Read-Only" or "Read-Write" permission. Also you can view shared records and cancel sharing.
![ocm-share-to-other-server](../images/ocm-share-to-other-server.png)

### View be shared libraries

You can jump to "Shared from other servers" page to view the libraries shared by other servers and cancel the sharing.
![ocm-list-be-shared-libraries](../images/ocm-list-be-shared-libraries.png)

And enter the library to view, download or upload files.
![ocm-view-download-upload-files-in-library](../images/ocm-view-download-upload-files-in-library.png)

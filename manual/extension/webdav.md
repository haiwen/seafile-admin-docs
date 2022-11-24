# WebDAV extension

In the document below, we assume your seafile installation folder is `/opt/seafile`.

## SeafDAV Configuration for 7.1+

The configuration file is `/opt/seafile/conf/seafdav.conf`. If it is not created already, you can just create the file.

```
[WEBDAV]

# Default is false. Change it to true to enable SeafDAV server.
enabled = true

port = 8080

# If you deploy seafdav behind nginx/apache, you need to modify "share_name".
share_name = /

# SeafDAV uses Gunicorn as web server.
# This option maps to Gunicorn's 'workers' setting. https://docs.gunicorn.org/en/stable/settings.html?#workers
# By default it's set to 5 processes.
workers = 5

# This option maps to Gunicorn's 'timeout' setting. https://docs.gunicorn.org/en/stable/settings.html?#timeout
# By default it's set to 1200 seconds, to support large file uploads.
timeout = 1200

```

Every time the configuration is modified, you need to restart seafile server to make it take effect.

```
./seafile.sh restart

```

Your WebDAV client would visit the Seafile WebDAV server at `http://example.com:8080`

**After Seafile 7.1.x, Seafdav does not support Fastcgi, only Wsgi**. So if you want to configure seafdav behind a proxy server, you have to use proxy configuration instead of fastcgi.

In Pro edition 7.1.8 version and community edition 7.1.5, an option is added to append library ID to the library name returned by SeafDAV.

```
show_repo_id=true

```

### Proxy with Nginx

For Seafdav, the configuration of Nginx is as follows:

```
.....
    location /seafdav {
        proxy_pass         http://127.0.0.1:8080/seafdav;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout  1200s;
        client_max_body_size 0;
﻿
        access_log      /var/log/nginx/seafdav.access.log seafileformat;
        error_log       /var/log/nginx/seafdav.error.log;
    }

```

### Proxy with Apache

For Seafdav, the configuration of Apache is as follows:

```
......
    <Location /seafdav>
        ProxyPass "http://127.0.0.1:8080/seafdav"
    </Location>

```

### HTTPS proxy

If you configure https in Nginx or Apache, you have to configure the reverse proxy to rewrite the `Destination` headers protocol from `https` to `http`. This is a limitation on the WebDAV framework SeafDAV is based on. See more details:

* <https://forum.seafile.com/t/seafdav-move-command-causing-502/11582>
* <https://github.com/mar10/wsgidav/issues/183>

## SeafDAV Configuration for 7.0 or older versions

The configuration file is `/opt/seafile/conf/seafdav.conf`. If it is not created already, you can just create the file.

```
[WEBDAV]

# Default is false. Change it to true to enable SeafDAV server.
enabled = true

port = 8080

# Change the value of fastcgi to true if fastcgi is to be used
fastcgi = false

# If you deploy seafdav behind nginx/apache, you need to modify "share_name".
share_name = /

```

Every time the configuration is modified, you need to restart seafile server to make it take effect.

```
./seafile.sh restart

```


### Sample Configuration with Nginx

Your WebDAV client would visit the Seafile WebDAV server at `http://example.com/seafdav`

```
[WEBDAV]
enabled = true
port = 8080
fastcgi = true
share_name = /seafdav
```

In the above config, the value of `share_name` is changed to `/seafdav`, which is the address suffix you assign to seafdav server.

Nginx conf:

```
     location /seafdav {
        fastcgi_pass    127.0.0.1:8080;
        fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
        fastcgi_param   PATH_INFO           $fastcgi_script_name;

        fastcgi_param   SERVER_PROTOCOL     $server_protocol;
        fastcgi_param   QUERY_STRING        $query_string;
        fastcgi_param   REQUEST_METHOD      $request_method;
        fastcgi_param   CONTENT_TYPE        $content_type;
        fastcgi_param   CONTENT_LENGTH      $content_length;
        fastcgi_param   SERVER_ADDR         $server_addr;
        fastcgi_param   SERVER_PORT         $server_port;
        fastcgi_param   SERVER_NAME         $server_name;
        fastcgi_param   HTTPS               on;
        fastcgi_param   HTTP_SCHEME         https;
        
        client_max_body_size 0;
        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;
        send_timeout  36000s;
        
        # This option is only available for Nginx >= 1.8.0. See more details below.
        proxy_request_buffering off;

        access_log      /var/log/nginx/seafdav.access.log;
        error_log       /var/log/nginx/seafdav.error.log;
    }

```

By default Nginx will buffer large request body in temp file. After the body is completely received, Nginx will send the body to the upstream server (seafdav in our case). But it seems when file size is very large, the buffering mechanism dosen't work well. It may stop proxying the body in the middle. So if you want to support file upload larger for 4GB, we suggest you install Nginx version >= 1.8.0 and add `proxy_request_buffering off` to Nginx configuration.


## Notes on Clients

Please first note that, there are some known performance limitation when you map a Seafile webdav server as a local file system (or network drive).

* Uploading large number of files at once is usually much slower than the syncing client. That's because each file needs to be committed separately.
* The access to the webdav server may be slow sometimes. That's because the local file system driver sends a lot of unnecessary requests to get the files' attributes.

So WebDAV is more suitable for infrequent file access. If you want better performance, please use the sync client instead.

### Windows

The client recommendation for WebDAV depends on your Windows version:

* For Windows XP: Only non-encryped HTTP connection is supported by the Windows Explorer. So for security, the only viable option is to use third-party clients, such as Cyberduck or Bitkinex.
* For Vista and later versions: Windows Explorer supports HTTPS connection. But it requires a valid certificate on the server. It's generally recommended to use Windows Explorer to map a webdav server as network dirve. If you use a self-signed certificate, you have to add the certificate's CA into Windows' system CA store.

### Linux

On Linux you have more choices. You can use file manager such as Nautilus to connect to webdav server. Or you can use davfs2 from the command line.

To use davfs2

```
sudo apt-get install davfs2
sudo mount -t davfs -o uid=<username> https://example.com/seafdav /media/seafdav/

```

The -o option sets the owner of the mounted directory to <username> so that it's writable for non-root users.

It's recommended to disable LOCK operation for davfs2. You have to edit /etc/davfs2/davfs2.conf

```
 use_locks       0

```

### Mac OS X

Finder's support for WebDAV is also not very stable and slow. So it is recommended to use a webdav client software such as Cyberduck.

## Frequently Asked Questions

### Clients can't connect to seafdav server

By default, seafdav is disabled. Check whether you have `enabled = true` in `seafdav.conf`.
If not, modify it and restart seafile server.

### The client gets "Error: 404 Not Found"

If you deploy SeafDAV behind Nginx/Apache, make sure to change the value of `share_name` as the sample configuration above. Restart your seafile server and try again.

### Windows Explorer reports "file size exceeds the limit allowed and cannot be saved"

This happens when you map webdav as a network drive, and tries to copy a file larger than about 50MB from the network drive to a local folder.

This is because Windows Explorer has a limit of the file size downloaded from webdav server. To make this size large, change the registry entry on the client machine. There is a registry key named `FileSizeLimitInBytes` under `HKEY_LOCAL_MACHINE -> SYSTEM -> CurrentControlSet -> Services -> WebClient -> Parameters`.

# Configuration of Seahub behind Nginx



[Both components of Seafile Server](https://manual.seafile.com/overview/components/), Seahub and seaf-server, can be configured to run behind a reverse proxy. A reverse proxy increases the performance of Seafile and allows the encryption of inbound and outbound traffic.

For production use, a setup with a reverse proxy and HTTPS encryption is a MUST .

[Nginx](http://nginx.org/), a popular and resource-friendly HTTP server and reverse proxy, is a good option.  Nginx's documentation is available at http://nginx.org/en/docs/.

## Setup

The configuration of Seafile behind Nginx as a reverse proxy is demonstrated using the sample host name `seafile.example.com`. 

These instructions assume the following requirements:

* Seafile Server Community Edition/Professional Edition was setup according to the instructions in this manual (i.e., a dedicated user seafile exists and all Seafile files are stored in /opt/seafile)
* A host name points at the IP address of the server and the server is available on port 80

If your setup differs from thes requirements, adjust the following instructions accordingly.

### Installing Nginx

Install Nginx:

```bash
# CentOS
sudo yum install nginx -y

# Debian/Ubuntu
sudo apt install nginx -y
```

After the installation, start the server and enable it so that Nginx starts at system boot:

```bash
# CentOS/Debian/Ubuntu
sudo systemctl start nginx
sudo systemctl enable nginx
```



### Configuring Nginx

Create a configuration file for seafile in `/etc/nginx/sites-available/`:

```bash
touch /etc/nginx/sites-available/seafile.conf
```

Delete the default files in `/etc/nginx/sites-enabled/` and `/etc/nginx/sites-available`: 

````bash
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
````

Create a symbolic link: 

````
ln -s /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf
````

Copy the following sample Nginx config file into `/etc/nginx/sites-available/seafile.conf` and modify the content to fit your needs:

```nginx

log_format seafileformat '$http_x_forwarded_for $remote_addr [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $upstream_response_time';

server {
    listen 80;
    server_name seafile.example.com;

    proxy_set_header X-Forwarded-For $remote_addr;

    location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log seafileformat;
         error_log       /var/log/nginx/seahub.error.log;
    }

# If you are using [FastCGI](http://en.wikipedia.org/wiki/FastCGI),
# which is not recommended, you should use the following config for location `/`.
#
#    location / {
#         fastcgi_pass    127.0.0.1:8000;
#         fastcgi_param   SCRIPT_FILENAME     $document_root$fastcgi_script_name;
#         fastcgi_param   PATH_INFO           $fastcgi_script_name;
#
#         fastcgi_param	 SERVER_PROTOCOL	 $server_protocol;
#         fastcgi_param   QUERY_STRING        $query_string;
#         fastcgi_param   REQUEST_METHOD      $request_method;
#         fastcgi_param   CONTENT_TYPE        $content_type;
#         fastcgi_param   CONTENT_LENGTH      $content_length;
#         fastcgi_param	 SERVER_ADDR         $server_addr;
#         fastcgi_param	 SERVER_PORT         $server_port;
#         fastcgi_param	 SERVER_NAME         $server_name;
#         fastcgi_param   REMOTE_ADDR         $remote_addr;
#     	 fastcgi_read_timeout 36000;
#
#         client_max_body_size 0;
#
#         access_log      /var/log/nginx/seahub.access.log;
#     	 error_log       /var/log/nginx/seahub.error.log;
#    }

    location /seafhttp {
        rewrite ^/seafhttp(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8082;
        client_max_body_size 0;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout  36000s;
        proxy_read_timeout  36000s;
        proxy_send_timeout  36000s;

        send_timeout  36000s;

        access_log      /var/log/nginx/seafhttp.access.log seafileformat;
        error_log       /var/log/nginx/seafhttp.error.log;
    }
    location /media {
        root /opt/seafile/seafile-server-latest/seahub;
    }
}
```

The following options must be modified in the CONF file:

* Server name (server_name)

Optional customizable options in the seafile.conf are:

* Server listening port (listen)- if Seafile server should be available on a non-standard port
* Proxy pass for location / - if Seahub is configured to start on a different port than 8000
* Proxy pass for location /seafhttp - if seaf-server is configured to start on a different port than 8082
* Maximum allowed size of the client request body (client_max_body_size)

The default value for `client_max_body_size` is 1M. Uploading larger files bigger will result in an error message HTTP error code 413 ("Request Entity Too Large"). It is recommended to syncronize the value of client_max_body_size with the parameter `max_upload_size` in section `[fileserver]` of [seafile.conf](../config/seafile-conf.md). Optionally, the value can also be set to 0 to disable this feature.

Client uploads are only partly effected by this limit. With a limit of 100 MiB they can safely upload files of any size.

Note for very large files (> 4GB): By default Nginx will buffer large request bodies in temp files. After the body is completely received, Nginx will send the body to the upstream server (seaf-server in our case). But it seems when the file size is very large, the buffering mechanism dosen't work well. It may stop proxying the body in the middle. So if you want to support file uploads larger than 4GB, we suggest to install Nginx version >= 1.8.0 and add the following options to Nginx config file:

```nginx
    location /seafhttp {
        ... ...
        proxy_request_buffering off;
    }
```

Finally, make sure your seafile.conf does not contain syntax error and restart Nginx for the configuration changes to take effect:

```bash
# CentOS/Debian/Ubuntu
nginx -t
nginx -s reload
```

### Modifying ccnet.conf

The `SERVICE_URL` in [ccnet.conf](../config/ccnet-conf.md) informs Seafile about the chosen domain, protocol and port. Change the `SERVICE_URL`so as to correspond to your host name (the `http://`must not be removed):

```python
SERVICE_URL = http://seafile.example.com
```

Note: The`SERVICE_URL` can also be modified in Seahub via System Admininstration > Settings.  If `SERVICE_URL` is configured via System Admin and in ccnet.conf, the value System Admin will take precedence.

### Modifying seahub_settings.py

The `FILE_SERVER_ROOT` in [seahub_settings.py](../config/seahub_settings_py/) informs Seafile about the location of and the protocol used by the file server. Change the `FILE_SERVER_ROOT`so as to correspond to your host name (the `http://`and the trailing `/seafhttp`must not be removed):


```python
FILE_SERVER_ROOT = 'http://seafile.example.com/seafhttp'
```

Note: The`FILE_SERVER_ROOT` can also be modified in Seahub via System Admininstration > Settings.  If `FILE_SERVER_ROOT` is configured via System Admin and in seahub_settings.py, the value System Admin will take precedence.

### Starting Seafile and Seahub

Restart the seaf-server and Seahub for the config changes to take effect:

```bash
su seafile
cd /opt/seafile/seafile-server-latest
./seafile.sh restart
./seahub.sh restart # or "./seahub.sh start-fastcgi" if you're using fastcgi
```

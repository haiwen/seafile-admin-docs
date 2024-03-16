# Start Seafile at System Bootup

## Seafile component

Create systemd service file /etc/systemd/system/seafile.service

```
sudo vim /etc/systemd/system/seafile.service

```

The content of the file is:

```
[Unit]
Description=Seafile
# add mysql.service or postgresql.service depending on your database to the line below
After=network.target

[Service]
Type=forking
ExecStart=${seafile_dir}/seafile-server-latest/seafile.sh start
ExecStop=${seafile_dir}/seafile-server-latest/seafile.sh stop
LimitNOFILE=infinity
User=seafile
Group=seafile

[Install]
WantedBy=multi-user.target

```


## Seahub component

Create systemd service file /etc/systemd/system/seahub.service

```
sudo vim /etc/systemd/system/seahub.service

```

The content of the file is (please dont forget to change it if you want to run fastcgi):

```
[Unit]
Description=Seafile hub
After=network.target seafile.service

[Service]
Type=forking
# change start to start-fastcgi if you want to run fastcgi
ExecStart=${seafile_dir}/seafile-server-latest/seahub.sh start
ExecStop=${seafile_dir}/seafile-server-latest/seahub.sh stop
User=seafile
Group=seafile

[Install]
WantedBy=multi-user.target

```


## Seafile cli client (optional)

Create systemd service file /etc/systemd/system/seafile-client.service 

You need to create this service file only if you have **seafile**
console client and you want to run it on system boot.

```
sudo vim /etc/systemd/system/seafile-client.service

```

The content of the file is:

```
[Unit]
Description=Seafile client
# Uncomment the next line you are running seafile client on the same computer as server
# After=seafile.service
# Or the next one in other case
# After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/seaf-cli start
ExecStop=/usr/bin/seaf-cli stop
RemainAfterExit=yes
User=seafile
Group=seafile

[Install]
WantedBy=multi-user.target

```

## Enable service start on system boot

```
sudo systemctl enable seafile.service
sudo systemctl enable seahub.service
sudo systemctl enable seafile-client.service   # optional

```

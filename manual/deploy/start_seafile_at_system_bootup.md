# Start Seafile at System Bootup

## For systems running systemd and python virtual environments

* For example Debian 12
Create systemd service files, change **${seafile_dir}** to your
**seafile** installation location and **seafile** to user, who runs
**seafile** (if appropriate). Then you need to reload systemd's daemons:
**systemctl daemon-reload**.

Firstly, you should create a script to activate the python virtual environment, which goes in the **${seafile_dir}** directory.  Put another way, it does not go in "seafile-server-latest", but the directory above that.  Throughout this manual the examples use /opt/seafile for this directory, but you might have chosen to use a different directory.

```
sudo vim /opt/seafile/run_with_venv.sh
```

The content of the file is:

```
#!/bin/bash
# Activate the python virtual environment (venv) before starting one of the seafile scripts

dir_name="$(dirname $0)"
source "${dir_name}/python-venv/bin/activate"
script="$1"
shift 1

echo "${dir_name}/seafile-server-latest/${script}" "$@"
"${dir_name}/seafile-server-latest/${script}" "$@"
```
make this script executable
```
sudo chmod 755 /opt/seafile/run_with_venv.sh
```

### Seafile component

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
ExecStart=bash ${seafile_dir}/run_with_venv.sh seafile.sh start
ExecStop=bash ${seafile_dir}/seafile-server-latest/seafile.sh stop
LimitNOFILE=infinity
User=seafile
Group=seafile

[Install]
WantedBy=multi-user.target

```

### Seahub component

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
ExecStart=bash ${seafile_dir}/run_with_venv.sh seahub.sh start
ExecStop=bash ${seafile_dir}/seafile-server-latest/seahub.sh stop
User=seafile
Group=seafile

[Install]
WantedBy=multi-user.target

```

### Seafile cli client (optional)

The client doesn't require any packages from pip, so this is the same as for systems without pythong virtual environments.  See that section below.

### Enable service start on system boot

```
sudo systemctl enable seafile.service
sudo systemctl enable seahub.service
sudo systemctl enable seafile-client.service   # optional
```

## For systems running systemd without python virtual environment

* For example Debian 8 through Debian 11, Linux Ubuntu 15.04 and newer

Create systemd service files, change **${seafile_dir}** to your
**seafile** installation location and **seafile** to user, who runs
**seafile** (if appropriate). Then you need to reload systemd's daemons:
**systemctl daemon-reload**.


### Seafile component

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


### Seahub component

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


### Seafile cli client (optional)

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

### Enable service start on system boot

```
sudo systemctl enable seafile.service
sudo systemctl enable seahub.service
sudo systemctl enable seafile-client.service   # optional

```

# Set up logrotate for server

## How it works

seaf-server, ccnet-server (since version 3.1) and seafile-controller (since version 6.0.8) support reopenning
logfiles by receiving a `SIGUR1` signal.

This feature is very useful when you need cut logfiles while you don't want
to shutdown the server. All you need to do now is cutting the logfile on the fly.

## Default logrotate configuration directory

For debian, the default directory for logrotate should be `/etc/logrotate.d/`

## Sample configuration

Assuming your ccnet-server's logfile is `/home/haiwen/logs/ccnet.log` and your
ccnet-server's pidfile for ccnet-server is `/home/haiwen/pids/ccnet.pid`.

Assuming your seaf-server's logfile is setup to `/home/haiwen/logs/seafile.log` and your
seaf-server's pidfile for seaf-server is setup to `/home/haiwen/pids/seaf-server.pid`:

The configuration for logrotate could be like this:

```
/home/haiwen/logs/seafile.log
{
        daily
        missingok
        rotate 15
        compress
        delaycompress
        notifempty
        sharedscripts
        postrotate
                [ ! -f /home/haiwen/pids/seaf-server.pid ] || kill -USR1 `cat /home/haiwen/pids/seaf-server.pid`
        endscript
}

/home/haiwen/logs/ccnet.log
{
        daily
        missingok
        rotate 15
        compress
        delaycompress
        notifempty
        sharedscripts
        postrotate
                [ ! -f /home/haiwen/pids/ccnet.pid ] || kill -USR1 `cat /home/haiwen/pids/ccnet.pid`
        endscript
}

/home/haiwen/logs/index.log
{
	monthly
	missingok
	rotate 15
	compress
	delaycompress
	notifempty
	sharedscripts
}

```

You can save this file, in debian for example, at `/etc/logrotate.d/seafile`.

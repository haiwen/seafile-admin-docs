# Set up logrotate for server

## How it works

seaf-server and seafile-controller support reopenning logfiles by receiving a `SIGUR1` signal.

This feature is very useful when you need cut logfiles while you don't want
to shutdown the server. All you need to do now is cutting the logfile on the fly.

## Default logrotate configuration directory

For debian, the default directory for logrotate should be `/etc/logrotate.d/`

## Sample configuration

Assuming your seaf-server's logfile is setup to `/home/haiwen/logs/seafile.log` and your
seaf-server's pidfile is setup to `/home/haiwen/pids/seaf-server.pid`:

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

You can save this file, in Debian for example, at `/etc/logrotate.d/seafile`.

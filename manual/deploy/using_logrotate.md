# Set up logrotate for server

## How it works

seaf-server and seafile-controller support reopenning logfiles by receiving a `SIGUR1` signal.

This feature is very useful when you need cut logfiles while you don't want
to shutdown the server. All you need to do now is cutting the logfile on the fly.

## Default logrotate configuration directory

For Debian, the default directory for logrotate should be `/etc/logrotate.d/`

## Sample configuration

Assuming your seaf-server's logfile is setup to `/opt/seafile/logs/seafile.log` and your
seaf-server's pidfile is setup to `/opt/seafile/pids/seaf-server.pid`:

The configuration for logrotate could be like this:

```
/opt/seafile/logs/seafile.log
/opt/seafile/logs/seahub.log
/opt/seafile/logs/seafdav.log
/opt/seafile/logs/fileserver-access.log
/opt/seafile/logs/fileserver-error.log
/opt/seafile/logs/fileserver.log
/opt/seafile/logs/file_updates_sender.log
/opt/seafile/logs/repo_old_file_auto_del_scan.log
/opt/seafile/logs/seahub_email_sender.log
/opt/seafile/logs/index.log
{
        daily
        missingok
        rotate 7
        # compress
        # delaycompress
        dateext
        dateformat .%Y-%m-%d
        notifempty
        # create 644 root root
        sharedscripts
        postrotate
                if [ -f /opt/seafile/pids/seaf-server.pid ]; then
                        kill -USR1 `cat /opt/seafile/pids/seaf-server.pid`
                fi

                if [ -f /opt/seafile/pids/fileserver.pid ]; then
                        kill -USR1 `cat /opt/seafile/pids/fileserver.pid`
                fi

                if [ -f /opt/seafile/pids/seahub.pid ]; then
                        kill -HUP `cat /opt/seafile/pids/seahub.pid`
                fi

                if [ -f /opt/seafile/pids/seafdav.pid ]; then
                        kill -HUP `cat /opt/seafile/pids/seafdav.pid`
                fi

                find /opt/seafile/logs/ -mtime +7 -name "*.log*" -exec rm -f {} \;
        endscript
}

```

You can save this file, in Debian for example, at `/etc/logrotate.d/seafile`.

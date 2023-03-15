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
/home/haiwen/logs/seahub.log
/home/haiwen/logs/file_updates_sender.log
/home/haiwen/logs/repo_old_file_auto_del_scan.log
/home/haiwen/logs/seahub_email_sender.log
/home/haiwen/logs/work_weixin_notice_sender.log
/home/haiwen/logs/index.log
/home/haiwen/logs/content_scan.log
/home/haiwen/logs/fileserver-access.log
/home/haiwen/logs/fileserver-error.log
/home/haiwen/logs/fileserver.log
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
                if [ -f /home/haiwen/pids/seaf-server.pid ]; then
                        kill -USR1 `cat /home/haiwen/pids/seaf-server.pid`
                fi

                if [ -f /home/haiwen/pids/fileserver.pid ]; then
                        kill -USR1 `cat /home/haiwen/pids/fileserver.pid`
                fi

                if [ -f /home/haiwen/pids/seahub.pid ]; then
                        kill -HUP `cat /home/haiwen/pids/seahub.pid`
                fi

                find /home/haiwen/logs/ -mtime +7 -name "*.log*" -exec rm -f {} \;
        endscript
}

```

You can save this file, in Debian for example, at `/etc/logrotate.d/seafile`.

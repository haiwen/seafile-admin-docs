# Notification.conf settings

Since seafile-10.0.0, you can configure a notification server to send real-time notifications to clients of repo updates, file lock status changes, and directory permission changes.

```
# private_key and notification_token are required, change is for you need
# private_key and notification_token  should be the same as configured in seafile.conf.
[general]
# the ip of notification server
host = 0.0.0.0
# the port of notification server
port = 8083
# the log level of notification server
log_level = info
# the log level of notification server
private_key = "M@O8VWUb81YvmtWLHGB2I_V7di5-@0p(MF*GrE!sIws23F
notification_token = Ub81YvmtWLHGB2
```

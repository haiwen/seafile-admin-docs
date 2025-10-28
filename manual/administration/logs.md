# Seafile server logs

### Log files of seafile server

* seafile.log: logs of seaf-server
* seahub.log: logs from Django framework
* fileserver.log: logs of the golang file server component
* seafevents.log: logs for background tasks and office file conversion
* seahub_email_sender.log: logs for periodically email sending of background tasks


### Log files for seafile background node in cluster mode

* seafile.log: logs of seaf-server
* seafevents.log: Empty
* seafile-background-tasks.log: logs for background tasks and office file convertion
* seahub_email_sender.log: logs for periodically email sending of background tasks


### Log files for seadoc server

The logs for seadoc server are located in the `/opt/seadoc-data/logs` directory.

* sdoc-access.log: logs for recording each API request’s method, URL, response status, and processing time to support access auditing and performance monitoring.
* sdoc-access-slow.log: logs for sdoc-server's slow requests.
* sdoc-server.log: logs for tracking the sdoc-server’s periodic background save tasks to verify autosave behavior and service health.
* sdoc-socket.log: logs for tracking real-time collaborative editing operations over the document WebSocket connection to monitor realtime sync performance and diagnose lag.
* sdoc-socket-slow.log: logs for capturing collaborative editing socket operations that exceed the latency threshold to detect realtime performance bottlenecks and diagnose editing lag.
* sdoc_operation_log_clean.log: logs for recording the periodic cleanup task that purges old operation_log records from the database to control log growth and maintain storage health.
* seadoc-converter.log: logs for recording the scheduler activity of the seadoc-converter service’s operation log cleanup job to verify the maintenance task is running on schedule.


### Log files for seasearch server 

The logs for seasearch server are located in the `/opt/seasearch-data/log` directory.

* seasearch.log: logs for recording the SeaSearch service startup and runtime status to confirm the search engine is initialized and ready to serve requests.
* seasearch-access.log: logs for recording incoming HTTP requests to the SeaSearch service to audit search/index queries and detect auth or access issues.


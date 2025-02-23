# Configurable Options

In the file `seafevents.conf`:

```
[DATABASE]
type = mysql
host = 192.168.0.2
port = 3306
username = seafile
password = password
name = seahub_db

[STATISTICS]
## must be "true" to enable statistics
enabled = false

[SEAHUB EMAIL]
## must be "true" to enable user email notifications when there are new unread notifications
enabled = true

## interval of sending Seahub email. Can be s(seconds), m(minutes), h(hours), d(days)
interval = 30m

[FILE HISTORY]
enabled = true
threshold = 5
suffix = md,txt,...

## From seafile 7.0.0
## Recording file history to database for fast access is enabled by default for 'Markdown, .txt, ppt, pptx, doc, docx, xls, xlsx'. 
## After enable the feature, the old histories version for markdown, doc, docx files will not be list in the history page.
## (Only new histories that stored in database will be listed) But the users can still access the old versions in the library snapshots.
## For file types not listed in the suffix , histories version will be scanned from the library history as before.
## The feature default is enable. You can set the 'enabled = false' to disable the feature.

## The 'threshold' is the time threshold for recording the historical version of a file, in minutes, the default is 5 minutes. 
## This means that if the interval between two adjacent file saves is less than 5 minutes, the two file changes will be merged and recorded as a historical version. 
## When set to 0, there is no time limit, which means that each save will generate a separate historical version.

## If you need to modify the file list format, you can add 'suffix = md, txt, ...' configuration items to achieve.

# From Seafile 13.0 Redis also support using in CE, and is the default cached server
[REDIS]
## redis use the 0 database and "repo_update" channel
server = 192.168.1.1
port = 6379
password = q!1w@#123

```


## The following configurations for Pro Edition only

```
[AUDIT]
## Audit log is disabled default.
## Leads to additional SQL tables being filled up, make sure your SQL server is able to handle it.
enabled = true

[INDEX FILES]
## must be "true" to enable search
enabled = true

## The interval the search index is updated. Can be s(seconds), m(minutes), h(hours), d(days)
interval=10m

## From Seafile 6.3.0 pro, in order to speed up the full-text search speed, you should setup
highlight = fvh

## If true, indexes the contents of office/pdf files while updating search index
## Note: If you change this option from "false" to "true", then you need to clear the search index and update the index again.
## Refer to file search manual for details.
index_office_pdf=false

## The default size limit for doc, docx, ppt, pptx, xls, xlsx and pdf files. Files larger than this will not be indexed.
## Since version 6.2.0
## Unit: MB
office_file_size_limit = 10

## From 9.0.7 pro, Seafile supports connecting to Elasticsearch through username and password, you need to configure username and password for the Elasticsearch server
username = elastic           # username to connect to Elasticsearch
password = elastic_password  # password to connect to Elasticsearch

## From 9.0.7 pro, Seafile supports connecting to elasticsearch via HTTPS, you need to configure HTTPS for the Elasticsearch server
scheme = https               # The default is http. If the Elasticsearch server is not configured with HTTPS, the scheme and cafile do not need to be configured
cafile = path/to/cert.pem    # The certificate path for user authentication. If the Elasticsearch server does not enable certificate authentication, do not need to be configured

## From version 11.0.5 Pro, you can custom ElasticSearch index names for distinct instances when intergrating multiple Seafile servers to a single ElasticSearch Server.
repo_status_index_name = your-repo-status-index-name  # default is `repo_head`
repo_files_index_name = your-repo-files-index-name    # default is `repofiles`

## The default loglevel is `warning`.
## Since version 11.0.4
loglevel = info

[EVENTS PUBLISH]
## must be "true" to enable publish events messages
enabled = false
## message format: repo-update\t{{repo_id}}}\t{{commit_id}}
## Currently only support redis message queue
mq_type = redis

[AUTO DELETION]
enabled = true     # Default is false, when enabled, users can use file auto deletion feature
interval = 86400   # The unit is second(s), the default frequency is one day, that is, it runs once a day

[SEASEARCH]
enabled = true # Default is false, when enabled, seafile can use SeaSearch as the search engine
seasearch_url = http://seasearch:4080 # If your SeaSearch server deploy on another machine, replace it to the truth address
seasearch_token = <your auth token> # base64 code consist of `username:password`
interval = 10m # The interval the search index is updated. Can be s(seconds), m(minutes), h(hours), d(days)

```


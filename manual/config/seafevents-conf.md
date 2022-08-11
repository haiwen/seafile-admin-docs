# Configurable Options

> seafevents.conf is for pro edition only 

In the file `seafevents.conf`:

```
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

[AUDIT]
## Audit log is disabled default.
## Leads to additional SQL tables being filled up, make sure your SQL server is able to handle it.
enabled = true

[STATISTICS]
## must be "true" to enable statistics
enabled = false

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

## Starting from 9.0.7 pro, Seafile supports connecting to Elasticsearch through username and password, you need to configure username and password for the Elasticsearch server
username = elastic           # username to connect to Elasticsearch
password = elastic_password  # password to connect to Elasticsearch

## Since 9.0.7 pro, Seafile supports connecting to elasticsearch via HTTPS, you need to configure HTTPS for the Elasticsearch server
scheme = https               # The default is http. If the Elasticsearch server is not configured with HTTPS, the scheme and cafile do not need to be configured
cafile = path/to/cert.pem    # The certificate path for user authentication. If the Elasticsearch server does not enable certificate authentication, do not need to be configured

[SEAHUB EMAIL]

## must be "true" to enable user email notifications when there are new unread notifications
enabled = true

## interval of sending Seahub email. Can be s(seconds), m(minutes), h(hours), d(days)
interval = 30m


[OFFICE CONVERTER]

## must be "true" to enable office/pdf online preview
enabled = true

## how many libreoffice worker processes should run concurrenlty
workers = 1

## where to store the converted office/pdf files. Deafult is /tmp/.
outputdir = /tmp/

[EVENTS PUBLISH]
## must be "true" to enable publish events messages
enabled = false
## message format: repo-update\t{{repo_id}}}\t{{commit_id}}
## Currently only support redis message queue
mq_type = redis

[REDIS]
## redis use the 0 database and "repo_update" channel
server = 192.168.1.1
port = 6379
password = q!1w@#123

```

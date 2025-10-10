# Seafile Professional Server Changelog (old)

## 7.1

**Upgrade**

Please check our document for how to upgrade to [7.1](../upgrade/upgrade_notes_for_7.1.x.md).

### 7.1.22 (2021/07/29)

* [fix] Fix a UI bug for setting sharing permission

### 7.1.21 (2021/07/13)

* Make file download link generated for OnlyOffice can be used by multiple times
* Improve OnlyOffice integration logs

### 7.1.20 (2021/07/02)

* [fix] Fix a cache bug for OnlyOffice integration.

### 7.1.19 (2021/06/04)

* [fix] Fix a bug that some threads are set as daemon in seafevents
* [fix] Improve performance in system admin listing users by removing some redundent code in fetching users' last active time
* [fix] Fix a bug in password protected sharing link with direct download set (?dl=1)

### 7.1.18 (2021/05/13)

* [fix] Fix a bug in library list cache
* [fix] Fix a webdav crash bug
* [fix] Fix a library can't be synced immidiately after creating
* [fix] disable max_sync_file_count and fs_id_list_request_timeout options by default
* [fix] Fix office files can't be viewd with builtin office file preview (caused by incompatible JWT library version)

### 7.1.17 (2021/04/26)

* [fix] Fix manual file lock can't work
* [fix] Fix webdav file range request
* Improve OnlyOffice cache handling

### 7.1.16 (2021/04/19)

* [fix] Fix deleting libraries without owner in admin panel
* Add an API to change a user's email
* [fix] Fix a bug in storage migration script
* [fix] Fix a bug that will cause fsck crash
* [fix] Fix a XSS problem in notification

Potential breaking change in Seafile Pro 7.1.16: You can set the maximum number of files contained in a library that can be synced by the Seafile client. The default is 100000. When you download a repo, Seafile client will request fs id list, and you can control the timeout period of this request through `fs_id_list_request_timeout` configuration, which defaults to 5 minutes. These two options are added to prevent long fs-id-list requests from overloading the server. If you have large libraries on the server, this can cause "internal server error" returned to the client. You have to set a large enough limit for these two options.

```
[fileserver]
max_sync_file_count = 100000
fs_id_list_request_timeout = 300
```

### 7.1.15 (2021/03/18)

* [fix] Fix sometimes uploading via API returning 400 error
* Improve file locking handlering for OnlyOffice and Office Online integration
* [fix] Fix sometimes traffic statistics not correct

### 7.1.14 (2021/02/26)

* Add importing group members via a xlsx file
* [fix] Fix a bug in login via Shibboleth
* [fix] Fix remote wipe
* [fix] Fix setting a role's default quota via ADFS login

### 7.1.13 (2021/02/08)

* [fix] Fix file audit logs are not recorded if seaf-server restarted
* [fix] Fix a crash bug in seaf-server

### 7.1.12 (2021/02/03)

* [fix] Fix listing more than 100+ users in group member management dialog
* [fix] Fix guest invitation email sending problem
* ccnet-server and seaf-server close database connection when there are errors

### 7.1.11 (2021/01/28)

* Add cache for listing libraries request from drive clients
* Show users' last active time in admin panel
* Library owner can unlock a file
* Show image thumbnail in search result
* WebDAV support range request
* [fix] Fix WebDAV can't be used with secret when 2FA is enabled
* [fix] Fix SSO users are not created after login when LDAP is also enabled

### 7.1.10 (2020/01/11)

* [fix] Fix user can't login in WebDAV via secret key after two-fa is turned on
* [fix] Enable copy multiple folders/files in read-only libraries
* [fix] Add back filter functions in admin file access logs
* Enable setting work number in realtime backup
* [fix] Fix a bug in multi-tenancy mode when transfer a library from a user to a department

### 7.1.9 (2020/12/02)

* \[new] Add pagination when listing group/department members
* \[fix] Disable webdav for users that have 2fa enabled
* \[fix] Fix OnlyOffice JWT broken for public shared links / PR for fix available
* \[fix] Fix database crash will causing clients to unsync libraries
* \[fix] Fix webdav LOCK issue
* \[new, OnlyOffice] Pass user id to OnlyOffice
* \[fix] Fix check_user_quote command for LDAP users
* \[fix] Fix LIBRARY_TEMPLATES support
* \[fix] Fix Markdown print in Firefox
* \[fix] Fix a bug in OAuth
* \[fix] Remove unused rest_framework files
* \[fix] Fix a bug in getting file history
* \[new] Admin can delete pending invitations
* \[fix] Fix can not save markdown/text file for shared libraries with advanced permission control
* \[fix, multi-tenancy] Fix organization traffic stats seem to not work correctly
* \[fix, multi-tenancy] Fix orginization admin update user status error
* \[fix] Fix Affiliation-Role-Mapping not working 

### 7.1.8 (2020/10/12)

* \[fix] Fix user name encoding for Shibboleth SSO
* \[fix] Add back the remote wipe feature when deleting a linked devices in admin panel
* \[fix] Fix sorting problem in some tables in admin panel
* \[fix] Fix auto-reactive user when a user deleted from LDAP and then added back
* \[fix] Fix a few bugs in organization admin panel in multi-tenancy mode
* \[fix] Fix libraries unsynced in a client if database crash at the server side

### 7.1.7 (2020/08/28)

* \[fix] Fix a bug in returned group library permission for  SeaDrive client
* Support pagination when listing libraries in a group
* Update wsgidav used in WebDAV
* Remove redundent logs in seafile.log
* \[fix] Fix "save to..." in share link
* Add an option to show a user's email in sharing dialog (ENABLE_SHOW_CONTACT_EMAIL_WHEN_SEARCH_USER)
* \[fix] Fix virus scan results page can't be opened in system admin panel

### 7.1.6 (2020/07/28)

* Add database connection pool to reduce database connection usage
* \[fix] Fix WebDAV error if a file is moved immediately after uploading
* Enable generating internal links for files in an encrypted library

### 7.1.5 (2020/06/30)

* Indexing LibreOffice files in file search
* Support setting the expire date time of a share link to a specific date time
* GC add --id-prefix option to scan a specific range of libraries
* fsck add an option to not check block integrity to speed up scanning
* \[fix] ccnet no longer listen on port 10001
* \[fix] Fix virus scan via upload link not work
* \[fix] Fix WebDAV failed login via WebDAV secret
* \[fix] Fix some bugs in LDAP sync
* \[fix] Fix term and condition feature
* \[fix] Fix support for institution feature
* Other UI fixes

### 7.1.4 (2020/05/14)

* \[fix] Fix listing LDAP imported users when number of users is greater than 500
* \[fix] Fix visiting folder share links with password and default path
* Use preview-and-download as default permission when generating share links
* Support selecting and downloading multiple files in a sharing link
* Show share link expiration time in system admin
* \[multi-tenancy] Support sorting for users and libraries in organization admin panel
* FUSE extension now support multiple storage backends
* \[fix] Fix file download links in public libraries
* \[fix] fix seaf-backup-cmd.sh
* Other UI improvements and fixes

### 7.1.3 (2020/04/08)

* A library admin can see all the shared links for a library
* Sort libraries and users in admin panel
* Delete all the users and libraries in an organization when deleting that organization
* \[fix] Fix some bugs in multiple storage backend feature
* Other UI fixes

### 7.1.1 Beta (2020/02/27)

* Fix full text search
* Fix office file preview in cluster mode

### 7.1.0 Beta (2020/02/19)

* Rewrite the system admin pages with React
* Upgrade to Python3
* Add library API Token, you can now generate API tokens for a library and use them in third party programs.
* Add a feature abuse report for reporting abuse for download links.
* Improved guest invitation: you can now invite a guest and share a library to the guest in one step.

## 7.0

Since seafile-pro 7.0.0, we have upgraded Elasticsearch to 5.6. As Elasticsearch 5.6 relies on the Java 8 environment and can't run with root, you need to run Seafile with a non-root user and upgrade the Java version.


### 7.0.19 (2020/09/07)

* Fix translation

### 7.0.18 (2020/05/21)

* Fix a bug in adding tag for files using context menu
* Add missing translations for French language

### 7.0.17 (2020/04/28)

* Fix bug for EXTRA_ABOUT_DIALOG_LINKS
* Modify the default permission to "Download and preview" for share links

### 7.0.16 (2020/04/01)

* Add progress dialog when moving files across libraries
* Add more customization options (EXTRA_SHARE_DIALOG_NOTE, EXTRA_APP_BOTTOM_LINKS, EXTRA_ABOUT_DIALOG_LINKS)
* \[fix] Fix a bug with domain-name that contains "file" when previewing markdown file via share link
* \[fix] Do not show download link for a preview-only share link
* \[fix] Fix searching files in a public library for login users
* Some UI improvements

### 7.0.15 (Deprecated)

### 7.0.14 (2020/03/06)

* \[fix] Fix seaf-server crash problem when calculating library size for a corrupted library
* \[fix] Fix a bug when sending file update notice
* Write virus scan log to file virus_scan.log

### 7.0.13 (2020/01/16)

* Fix Shibboleth login bug (added in 7.0.12)

### 7.0.12 (2020/01/10)

* Fix department support in multi-tenancy mode
* Fix a performance problem when deleting cache files for resume file upload

### 7.0.11 (2019/11/15)

* set jvm.options in ElasticSearch to `-Xms1g -Xmx1g` 
* \[fix] Fix revert library button missing in multi-tenancy mode
* \[fix] Remove redundant log OnlineOffice file lock is expired 
* \[fix] Fix S3 support in multiple storage backend feature
* \[LDAP Sync] Support setting default permission for automatically created library for department
* \[LDAP Sync] Support get department name from a configured attribute
* \[fix] Fix support for Shibboleth single log out
* \[fix] Fix support for sharing a sub-folder in a department library

### 7.0.10 (2019/10/22)

* \[fix] Fix showing NaN when uploading a file with 0 size.
* \[fix] Fix email notifications for file changes not sent
* \[fix] Remove two redundant logs in seafile.log
* \[fix] Fix opening a shared library with special characters
* \[fix] Fix duplicated two-scrollbars when browsing a published library in Windows using Firefox
* \[fix] Users can now create sharing links for files with permission "online-preview only" and "online-read-write".
* \[fix] Fix links in email notification for a shared folder
* \[fix] Fix the path shown for public share links of folders
* \[fix] Fix a bug in loading a file's history
* \[fix] Fix a case when using SAML login with LDAP configured
* \[fix] Fix a bug that a broken library can't be deleted via web UI

### 7.0.9 (2019/09/20)

* \[fix] Add institution admin back
* \[fix] Fix '\\n' in system wide notification will lead to blank page
* \[fix] Remove all metadata in docx template
* \[fix] Fix redirection after login
* \[fix] Fix group order is not alphabetic
* \[fix] Fix download button in sharing link
* Mobile UI Improvement (Now all major pages can be used in Mobile smoothly)

### 7.0.8 (2019/08/26)

* Inviter can cancel invitation after the user has accepted the invitation. The user will be set as inactive.
* Improve organization admin panel in multi-tenancy mode
* Add notification when a user try to leave a page during file transfer
* Add UI waiting notification when resetting a user's password in admin panel
* Add generating internal link (smart-link) for folders
* Add command line tool for admin to export reports
* \[fix] Fix file drag and drop in IE and Firefox
* \[fix] Add back the feature of letting user to select storage backend
* Improve UI for file uploading, support re-upload after error
* \[fix] Fix devices login via Shibboleth not show in devices list
* \[fix] Fix support of OnlyOffice force-save option 
* \[fix] Fix zip download when user selecting a long list of files
* Other UI fixes

### 7.0.7 (2019/07/29)

* \[fix] Fix a bug in multiple storage backend support
* Fix avatar problem when deployed under non-root domain
* Add get internal link in share dialog
* Fix newly created DOCX files are not empty and have a Chinese font set as default font
* Fix system does not send email to new user when adding new user in system admin
* Fix thumbnail for TIFF files
* Fix direct download link for sharing links
* Fix report in statictics module has no file extension when downloading in Firefox
* Fix "Preview-only" share link
* Fix file comment
* Other UI fixes

### 7.0.6 (2019/07/22)

* \[fix] Fix a memcache bug when using S3 backend

### 7.0.5 (2019/07/16)

* \[fix] Fix Zip download multiple files
* \[fix] Fix a bug in "System Admin -> Logs -> File Update -> details"
* \[fix] Fix there is an extra history item for newly created docs/pptx
* \[fix] Fix a bug in traffic statistics
* \[fix] Fix file modification report email are not sent out
* Support show department libraries in fuse
* Add expiring date for upload link
* Add search feature in pubished libraries for anonymous users

### 7.0.4 (2019/07/05)

* UI Improvement and fixes
* Fix file upload button with Safari, IE edge
* Support setting history and cleaning trash for department libraries
* Fix compatibility with "Open library in web" from the old version desktop client
* Support "." in group name
* Add back "can edit" permission for sharing links for office file
* Add back "send link" for upload links
* Add back grid view for folder sharing links
* Support creating encrypted libraries for department libraries
* Fix preview for PSD, TIFF files
* Fix deleting of favorate items when they are shared items but the sharing are revoked
* Fix avatar broken problem when using a non-stardard port
* Fix resumable file uploading

### 7.0.3 (2019/06/13)

* UI fixes
* Support index.md in published library
* Add sub-folder permission for deparment libraries
* Enable new file history by default
* Make published library feature turned on by default
* Fix IE Edge support
* Fix LDAP group sync

### 7.0.2 beta (2019/05/17)

* UI fixes
* Support using different salt for each encrypted libraries
* Add back sub-folder permission feature
* Improved user's settings page and file search page
* Support transfer personal library to department
* Add pubishing library to role permission
* \[wopi] Pass last modified time to WOPI
* Improve image resizing in Markdown

### 7.0.1 beta (2019/04/18)

* Improved Markdown editor
* Add columns view mode (Wiki view mode)
* Add context menu
* Realtime search
* Support search libraries
* Record file history to database for Markdown, Text and Docx, xlsx, pptx files
* Redesigned activities page
* Add preview-edit-on-cloud, preview-on-cloud permissions
* Redesigned file tags
* Support editing share link permission after creating a link

## 6.3

In version 6.3, Django is upgraded to version 1.11. Django 1.8, which is used in version 6.2, is deprecated in 2018 April.

With this upgrade, the fast-cgi mode is no longer supported. You need to config Seafile behind Nginx/Apache in WSGI mode.

The way to run Seahub in another port is also changed. You need to modify the configuration file `conf/gunicorn.conf` instead of running `./seahub.sh start <another-port>`.

Version 6.3 also changed the database table for file comments, if you have used this feature, you need migrate old file comments using the following commends after upgrading to 6.3:

```
./seahub.sh python-env seahub/manage.py migrate_file_comment

```

> Note, this command should be run while Seafile server is running.

Version 6.3 changed '/shib-login' to '/sso'. If you use Shibboleth, you need to to update your Apache/Nginx config. Please check the updated document: [shibboleth config v6.3](../config/shibboleth_authentication.md)

Version 6.3 add a new option for file search (`seafevents.conf`):

```
[INDEX FILES]
...
highlight = fvh
...

```

This option will make search speed improved significantly (10x) when the search result contains large pdf/doc files. But you need to rebuild search index if you want to add this option.

### 6.3.14 (2019/05/21)

* \[fix] Fix a bug in LDAP group sync

### 6.3.13 (2019/03/20)

* \[fix] Fix some bugs in accessing S3 for some special configurations
* \[fix] Fix OnlyOffice integration when OnlyOffice using invalid CA
* \[fix] Fix sometimes users can't login into WebDAV
* \[fix] Fix a crash bug in realtime backup server
* \[fix] Fix the last modified time is not updated for shared sub-folders
* \[fix] Keep last modified time when moving or copying files from on library to another
* \[fix] Fix can't sync a sub-folder of a shared sub-folder
* \[fix] Fix URL in email notification for sub-folder shared event

### 6.3.12 (2019/02/21)

* \[fix] Fix using WebDAV with Single Sign On
* \[fix] Fix a bug in importing users via excel file
* Redirect users to home page after setting up 2FA
* \[fix] Fix can't send email when non-ascii symbols in filename in virus scan
* \[fix] Fix a bug in syncing LDAP when a user belong to multiple groups
* Add slow log for accessing object storage for debugging purpose
* \[fix] Fix a SQL bug in multi-tenancy mode
* Set the chunk size to 8MB during uploading files via chunk to speed up file transfer

### 6.3.11 (2019/01/15)

* \[fix] Fix support for two-factor authentication using SMS
* \[fix] Fix support for traffic statistics
* \[fix] Improve performance for getting group library list
* \[fix] Fix file access audit log
* Remove file count and size count for directories as it will lead to performance problem

### 6.3.10 (2019/01/02)

* \[fix] Fix folder upload problem
* \[fix] Fix file audit page can't be load
* \[fix] Fix MIME type for .xls
* Add RPC slow log
* Add admin API for manage organizations in multi-tenancy mode
* Add warning when close page during file uploading

### 6.3.9 (2018/12/13)

* Fix a seaf-server crash problem

### 6.3.8 (2018/12/10)

* Improve online PDF view for large PDF files (In the old version, a large PDF file consumes a lot of memory)
* Admin can force a user to use two-factor authentication
* Improve performance of upgdating a library's size and file numbers
* Don't print a lot of "Repo size compute queue is 0"
* Enable using WebDAV with Single Sign On (A new option ENABLE_WEBDAV_SECRET)
* Enable login to WebDAV via contact email
* \[fix] A shared empty folder name will be updated if the folder's name is changed
* Support preview for PSD and AI files
* \[fix] Fix license information display problem
* \[fix] Fix video preview for shared link on mobile browsers
* Redirect old wiki URL to new wiki URL
* Hide save as button for files viewed by Office Online Server
* When a library be transfer to another user, don't clear the syncing tokens
* Support syncing both department and groups at the same time in LDAP sync (deprecating old config options for department sync)
* Set default quota for department synced from LDAP
* Allow more independent LDAP configurations for multi-LDAP server sync
* \[fix] Fix problems when downloading large list of files via Zip download
* \[fix] Fix a performance problem when get the list of all groups
* \[fix] Can change history settings for library in admin area even if the change of history settings is disable for normal users
* Make multi-threads mode as default for Seahub

### 6.3.7 (2018/10/16)

* \[fix] Fix a bug of lock by online office
* Anyone that can write a file can unlock the file if it is locked by online office
* \[fix] Fix a bug in sending mails in background node
* \[fix] Remove forcesave option in OnlyOffice since it have a bug
* \[fix] Fix a bug that wiki page can't be loaded
* Add traffic statistics
* \[fix] Remove unnecessary logs in virus scan

### 6.3.6 (2018/09/21)

* \[fix] Fix a bug in user defined role
* \[fix] Editable share link can be edited by anonymous user

### 6.3.5 (2018/09/18)

* \[fix, security] Fix a security issue in Shibboleth authentication
* \[fix] Fix sometimes Web UI will not autoload a >100 item directory view
* \[fix] Fix sending notification emails in backend node
* Showing user's name instead of email in web interface
* \[fix] Fix desktop client can't login if using ADFS

New features

* Add a new sharing link permission "can edit" for docx/excel. Any login users can edit the file via share link.
* \[multi-tenancy] Support department and department owned library
* Add system traffic statistics (showing the daily web download/web upload/sync traffic)

### 6.3.4 (2018/08/16)

* \[fix] Fix a bug in creating group-owned library

### 6.3.3 (2018/08/15)

* \[fix] Fix some bugs in sharing group-owned libraries
* \[fix] Fix a bug in setting folder permission
* Update Django to 1.11.11
* Support login via contact email
* Support sharing a sub-folder in a group-owned library

### 6.3.2 (2018/07/30)

* \[fix] Fix sometimes get group listing will cause ccnet-server crash
* \[fix] Fix built in office file preview can't works
* Redirect '/shib-login' to '/sso'
* Other small fixes

### 6.3.1 (2018/07/25)

* Add generating of internal links
* Lock office files when editing via online office suite
* Support setting organization quota, delete an organization via Web API
* Support Swift storage backend Identity v3.0 API
* Improve markdown editor
* Several fixes

### 6.3.0 Beta (2018/06/28)

* Support nested group and group-owned libraries
* Keep sharing link when file or folder moved or renamed
* Update Django to 1.11, remove fast-cgi support
* Update jQuery to version 3.3.1
* Update pdf.js, use pdf.js for preview pdf files
* Docx files are converted to PDFs and preview via pdf.js in builtin preview
* Support multiple storage backend to be used in a single server
* \[fix] Fix some bugs with OnlyOffice and CollaboraOffice
* \[fix] Use mobile version of OnlyOffice if viewed via mobile devices
* Shared sub-folders can be searched
* Show terms and condition link if terms and condition is enabled
* Remove login log after delete a user
* \[admin] Support customize site title, site name, CSS via Web UI
* \[fix] Fix a bug that causing seaf-fsck crash
* \[fix] Cancel Zip download task at the server side when user close zip download dialog
* \[fix] Fix crash when seaf-fsck, seaf-gc receive wrong arguments
* \[fix] Fix a few bugs in realtime backup server
* \[beta] Wiki, users can create public wikis
* Some other UI improvements

## 6.2

From 6.2, It is recommended to use proxy mode for communication between Seahub and Nginx/Apache. Two steps are needed if you'd like to switch to WSGI mode:

1. Change the config file of Nginx/Apache.
2. Restart Seahub with `./seahub.sh start` instead of `./seahub.sh start-fastcgi`

The configuration of Nginx is as following:

```
location / {
         proxy_pass         http://127.0.0.1:8000;
         proxy_set_header   Host $host;
         proxy_set_header   X-Real-IP $remote_addr;
         proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Host $server_name;
         proxy_read_timeout  1200s;

         # used for view/edit office file via Office Online Server
         client_max_body_size 0;

         access_log      /var/log/nginx/seahub.access.log;
         error_log       /var/log/nginx/seahub.error.log;
    }

```

The configuration of Apache is as following:

```
    # seahub
    SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1
    ProxyPass / http://127.0.0.1:8000/
    ProxyPassReverse / http://127.0.0.1:8000/

```

### 6.2.13 (2018.5.18)

* \[new] Support only return files or folders when search file via api.
* \[fix] Fix notification display behavior bug on some page.
* \[fix] Recreate folder when failed because of `file already exists` error for the first time.
* \[fix] Fix bug of saving file via onlyoffice.
* \[fix] Fix bug when set user’s reference id to ‘’ via admin api.
* \[fix] Fix bug of group info page display in organization admin panel.
* \[improve] Disable full email search if current user is a guest user.
* \[improve] Return library type when search file via api.
* \[improve] Add user auth info to cookie when login via OAuth.
* \[improve] Return timestamp instead of time string when get user clean up library trash event via api.
* \[improve] Check quota when copy/move file/folder.
* \[improve] Distinguish file or folder when send library/folder share notice/email.
* \[improve] Sort by parent folder’s name when get file/folder recursively.
* \[improve] Remove unused Python imports in ADFS module.
* \[improve] Optimizate library udpate event.
* \[improve] Remove seahub gunicorn access log.

### 6.2.12 (2018.4.20)

* \[fix] Fix a bug in seafevents

### 6.2.11 (2018.4.19)

* Update multi storage backend feature, add STORAGE_CLASS_MAPPING_POLICY setting.
* \[fix] Fix bug when search file by path.
* \[fix] A user that can't create a library can sync a sub-folder of a library now.
* Add title when view file via OOS.
* Check if enable LIBRARY_TEMPLATES feature when creating library.
* \[api] Enable return all files recursively under a folder.
* Preserve share links when admin transfer a library from a user to another user.
* Add setting to disable user change password.
* Add setting to disable group dissussion.
* Add setting to disable file comment.
* Restart both ccnet-server and seaf-server if seaf-server is down.
* Fix a bug that some cases elasticsearch be started repeatly.
* Don’t start seafile if failed to mount http-temp dir.
* Don’t deactive user if failed to get users from ldap server.
* \[fix] Fix online preview can't work in background node caused by wrong Python path.

### 6.2.10 (2018.3.20)

* Improve performance of file search
* \[fix] Fix a bug in daily active user statistics
* \[fix] Fix copy files larger than 2GB via seaf-fuse
* Show 403 error when visit share link if share link creator no longer has access permission to library.
* \[api] Add api for uploading file via upload share link.
* \[api] Support search file/folder in a specific library and folder via api.
* \[fix] Fix bug in folder renaming operation list on activities page.
* \[fix] Fix bug when creating personal/group wiki.
* \[fix] Fix bug when searching specific extension file.
* \[fix] Fix a bug in Two-Factor Authentication.
* \[fix] Fix bug when getting encrypted library history.
* \[fix] Fix UI bug of "New Library" and "More" buttons.
* \[fix] Fix bug of using truncated image file as avatar.
* Change value of `per_page` parameter to 10 when search file via api.
* Support indexing files in background after file uploading via API
* Add user clean library trash event to activities
* Use inner fileserver url to save file when edit office via OOS.

### 6.2.9 (2018.02.10)

* \[fix] Support setting region for Swift backend
* \[fix] Notify the admin when an invited people registered
* \[new, api] Add API for cleaning trash
* \[fix, api] Fix permission check in search API
* \[fix] Remove redundant warning message in seahub.log
* \[fix] Add API for upload files via upload link
* \[fix] Fix inconsistency in showing user's space usage in multi-tenancy mode
* \[new] Add online preview for SVG files

### 6.2.8 (2018.02.02)

* \[fix] Fix command pro/pro.py --test
* All logs that went to seahub_django_request.log go to seahub.log
* Print gunicorn error to runtime/error.log
* \[fix] Don't allow to generate share links via API for encrypted libraries
* \[new] Support online preview for tiff and eps files
* \[new, api] Add api to allow admin to copy files between libraries
* \[new] Allow system admin to share a library as "admin" to another user in admin panel
* Other UI fixes and improvements

### 6.2.7 (2018.01.22)

* \[fix, important] Fix a performance bug in search index
* \[fix, important] Fix a memory leak in listing folder with locked files
* \[fix] Fix creating of demo account
* \[new] Notify the inviter when a guest register
* \[new] Add the feature "remember this device" after two-factor authentication
* \[new] Don't allow to move, delete or rename a file when a file is locked
* \[new] Add option to notify the admin after new user registration (NOTIFY_ADMIN_AFTER_REGISTRATION)
* \[new, ui] Support inviting multiple guests at once
* \[new] Support customize the list of groups that a user can see when sharing a library
* \[new, api] Support search files in my libraries, shared libraries, shared to all libraries
* \[fix] Fix OAuth bug
* \[fix] Fix a bug that file preview can't work in Debian 9
* \[fix, multi-tenancy] Fix permission of a shared sub-folder can't be changed
* \[fix] Fix a bug in modify permission for a shared sub-folder
* \[fix] Improve performance in checking folder permission and file lock
* \[fix] Improve the performance of returning a user's all group libraries
* \[fix] Fix support for uploading 500+ files via web interface (caused by API rate throttle)
* \[fix] Fix API get_shared_repo_by_path()
* \[fix] Add more log when failed to zip a file
* Don't use memcache when read object in the Python part
* Update license file check
* \[multi-tenancy, api] Return origin_repo_name when listing libraries
* Add cancel zip download API
* \[fix] Fix some configuration bugs in seafevents module

### 6.2.5, 6.2.6 (deprecated)

### 6.2.4 (2017.12.20)

* \[fix] Fix a bug in file search index clearing command

### 6.2.3 (2017.12.19)

* \[fix] Fix a bug in file search indexing.
* \[fix, admin] Fix a bug of statistic module in a cluster.
* \[new, admin] Support search share link.
* \[improve, ui] Add transition to show/hide of feedback messages.
* Other small UI improvements.

### 6.2.2 (2017.12.12)

* \[improve] Improve performance of file history page.
* \[improve] show be shared folders when copy/move file/folder to “Other Libraries”.
* \[improve] Remove the white edge of webpage when previewing file via OnlyOffice.
* \[improve] Show two file history records at least.
* \[multi-tenancy] fix bug when listing libraries/folders shared to group.
* \[multi-tenancy] fix bug when deleting an organization.
* \[fix] fix bug when previewing excel file with “&” character in its name.
* \[fix] Don’t check if user exists when deleting a group memeber in admin panel.
* \[oauth] Don’t overwrite public registration settings when login an unexisted user.
* \[audit] Recording file access/update log when preview/edit a file via OnlyOffice.

### 6.2.1 beta (2017.11.22)

* \[new] Support OAuth.
* \[new] Support Swift v1 protocol.
* \[new, admin] Add option to turn on statistic module
* \[new] Enable publish library update events to message queue (like Redis)
* \[improve, ui] Add "click to select" feature for download/upload links.
* \[improve, ui] improved accessibility for some form elements, such as login inputs, and etc.
* \[improve, api] Add `repo_owner` field to library search web api.
* \[improve, admin] Show/edit contact email in admin panel.
* \[improve, admin] Show upload links in admin panel.
* \[improve, admin] Improve license display.
* \[improve, admin] Share with admin permission recorded in audit log.
* \[improve, admin] Add permission audit log when remove library from group.
* \[improve, search] Set timeout for extracting contents from doc/pdf.
* \[improve, search] Search indexing no longer depend on Seafile service. It reads information from database directly.
* \[fix] Fix Shibboleth login redirection issue, see <https://forum.seafile.com/t/shared-links-via-shibboleth/4067/19>
* \[fix] In some case failed to unshare a folder.
* \[fix] LDAP search issue.
* \[fix] Fix Safari downloaded file names are encoded like 'test-%2F%4B.doc' if it contains special characters.
* \[fix] Disable client encrypt library creation when creating encrypt library is disabled on server.
* \[fix] Failed to get snapshot labels when libraries are deleted.

### 6.2.0 beta (2017.10.16)

* Add report charts for daily active users, daily file operations, and usage space
* Add "admin" permision when sharing a library to another user/group
* Redesign login page, adding a background image.
* Clean the list of languages
* Add the ability of tagging a snapshot of a library (Use `ENABLE_REPO_SNAPSHOT_LABEL = True` to turn the feature on)
* \[admin] Add an option to enable users to share a library to any groups in the system.
* Use WSGI as the default mode for deploying Seahub.
* Add a field Reference ID to support changing users primary ID in Shibboleth or LDAP
* Improved performance of loading library list
* Use multi-threads in search indexing
* \[fix] Fix a bug when indexing a PDF larger than 10MB
* Support adding a custom user search function
  (<https://github.com/haiwen/seafile-docs/commit/115f5d85cdab7dc272da81bcc8e8c9b91d85506e>)
* Other small UI improvements
* \[fix] Fix ADFS support

## 6.1

You can follow the document on minor [upgrade](../upgrade/upgrade.md).

### 6.1.9 （2017.09.28）

* \[fix] Fix some bugs in realtime backup server
* Add option to set up Seafile HTTP server thread number
* \[fix] Fix create new file API when create a file with a same name with exist file
* \[fix] Fix a bug in permission check in file syncing
* Add more detailed log information when permission check error
* \[fix] Add log to the size of queue of library size calculation
* \[fix] Use customized logo when sending email notifications

### 6.1.8 (2017.08.18)

* \[fix] Fix license checking

### 6.1.7 (2017.08.17)

* \[fix] Fix a bug when concurrent uploading/creating files (in the old version, when a user uploading/deleting multiple files in cloud file browser, it had a high chance to get “internal server error” message)
* \[fix] Fix thumbnails for some images that 90 degrees rotated
* \[fix] Fix support for resumable file upload
* \[fix] Fix MySQL connection pool in Ccnet
* \[fix] Use original GIF file when view GIF files
* \[fix, api] Check if name is valid when creating folder/file
* Remove deleted libraries in search index
* Use 30MB as the default value of THUMBNAIL_IMAGE_SIZE_LIMIT
* \[api] Improve performance when move or copy multiple files/folders
* \[admin] Support syncing user role from AD/LDAP attribute ([ldap role sync](../deploy_pro/ldap_role_sync.md))
* \[admin] Support deleting all outdated invitations at once
* \[admin] Improve access log
* \[admin] Support upload seafile-license.txt via web interface (only for single machine deployment)
* \[admin] Admin can cancel two-factor authentication of a user
* \[admin, role] Show user’s role in LDAP(Imported) table
* \[admin, role] Add wildcard support in role mapping for Shibboleth login
* \[admin] Improve performance in getting total file number, used space and total number of devices
* \[admin] Admin can add users to an institution via Web UI
* \[admin] Admin can choose a user’s role when creating a user

### 6.1.4 (2017.07.11)

* \[api] Improve performance of getting unread notifications.
* Delete deleted libraries in search index
* Use user's languange as lang setting for OnlyOffice

### 6.1.3 (2017.07.06)

* Add context menu "details" to libraries and folders, so you can get how many files in a library or a folder.
* Improve search result accuracy
* \[fix] Fix a bug in zip downloading an empty folder
* Improve performance of multiple file copy and move
* Admin can delete out-dated guest invitations
* \[fix] Fix a bug in seafile-gc "dry run" option
* Users can restore deleted libraries by their own
* Change default block size for files uploaded via web browser to 8MB.

### 6.1.2 (deprecated)

### 6.1.1 (2017.06.19)

* Add "online preview only" option to share links
* Enable setting favicon and logo via admin panel

### 6.1.0 beta (2017.06.06)

Web UI Improvement:

1. Add thumbnail for video files (turn off by default)
2. Improved image file view, using thumbnail to view pictures
3. Move items by drap & drop
4. Add create docx/xlsx/pptx in web interface
5. Add OnlyOffice integration
6. Show which client modify a file in history, this will help to find which client accidentally modified a file or deleted a file.

Improvement for admins:

1. Admin can set default quota for each role
2. Admin can set user’s quote, delete users in bulk in admin panel
3. Support using admin panel in mobile platform
4. Add translation for settings page
5. Add admin operation logs
6. Admin can change users' login_id in web interface
7. Admin can create libraries in admin panel
8. Admin can set logo and favicon in admin panel

System changes:

1. Remove wiki by default  (to turn it on, set `ENABLE_WIKI = True` in seahub_settings.py)
2. Upgrade Django to 1.8.18
3. Clean Ajax API
4. Increase share link token length to 20 characters
5. Upgrade jstree to latest version
6. Update ElasticSearch to 2.4.5

## 6.0

You can follow the document on minor [upgrade](../upgrade/upgrade.md).

Special note for upgrading a cluster:

In version 6.0, the folder download mechanism has been updated. This requires that, in a cluster deployment, seafile-data/httptemp folder must be in an NFS share. You can make this folder a symlink to the NFS share.

```
cd /data/haiwen/
ln -s /nfs-share/seafile-httptemp seafile-data/httptemp

```

The httptemp folder only contains temp files for downloading/uploading file on web UI. So there is no reliability requirement for the NFS share. You can export it from any node in the cluster.

### 6.0.13 (2017.05.08)

* \[fix] Fix in file moving/copying dialog, self-owned libraries are not listed
* \[fix] Fix files in self-owned libraries are not listed when searching files in all libraries
* Update timestamp in about dialog

### 6.0.12 (2017.04.17)

* Improve performance when checking group shared library permission
* \[fix] Fix image popup in favourite page
* \[fix] Fix generating sharing link with expiring time in file detailed view page
* \[fix] Don't allow to create library with '/' in name
* \[fix] Fix two-factor authentication
* Add script to migrate between different storage backend

### 6.0.11 (Deprecated)

### 6.0.10 (2017.04.07)

* \[fix] Fix a bug in listing libraries in admin panel

### 6.0.9 (2017.04.01)

* Show user' name instead of user's email in notifications sent out by email
* Add config items for setting favicon, disable wiki feature
* Add css id to easily hide user password reset and delete account button
* \[fix] Fix UI bug in restoring a file from snapshot
* \[fix] Fix after renaming a file, the old versions before file rename can't be downloaded
* \[security] Fix XSS problem of the "go back" button in history page and snapshot view page
* \[fix] Fix crash problem of seaf-import
* Add API to create/delete/modify an account in Org
* \[ad/ldap sync] Support import posix group
* \[fix] Fix Office Web App co-authoring problems when opening file in a shared sub-folder
* \[fix] Fix "IE 9 not supported" popup message not showing

### 6.0.8 (2017.02.23)

Improvement for admin

* Admin can add/delete group members
* Admin can create group in admin panel
* Force users to change password if imported via csv
* Support set user's quota, name when import user via csv
* Set user's quota in user list page
* Add search group by group name
* Use ajax when deleting a user's library in admin panel
* Support logrotate for controller.log
* Add a log when a user can't be find in LDAP during login, so that the system admin can know whether it is caused by password error or the user can't be find
* Delete shared libraries information when deleting a user
* Add admin API to create default library for a user
* \[ldap-sync]  Support syncing users from AD/LDAP as inactive user

Other

* \[fix] Fix user search when global address book is disabled in CLOUD_MODE
* \[fix] Avoid timeout in some cases when showing a library trash
* Show "the account is inactive" when an inactive account try to login
* \[security] Remove viewer.js to show open document files (ods, odt) because viewer.js is not actively maintained and may have potential security bugs
* \[fix] Exclude virtual libraries from storage size statistics
* \[fix] Fix mysql gone away problem in seafevents
* Add region config option for Swift storage backend
* \[anti-virus] Send notification to the library owner if a virus is found

### 6.0.7 (2017.01.18)

* Set users role from Shibboleth affiliation attribute ([shibboleth config](../deploy/shibboleth_config.md), search "Affiliation and user role")
* \[fix] Uploading files with special names lets seaf-server crash
* \[fix] Fix reading database connection pool setting from ccnet.conf and seafile.conf
* \[fix] Fix total storage integer overflow, which is shown at the info page of admin panel)
* \[fix] Fix the password reset email gets send to the primary account email instead of the contact email of the profile.
* \[fix] Do not check path existence when delete user/group folder permission
* Support ADFS
* \[fix] Invitation email subject does not get translated

### 6.0.6 (2017.01.11)

* Guest invitation: Prevent the same address can be invited multiple times by the same inviter and by multiple inviters
* Guest invitation: Add an regex to prevent certain email addresses be invited (see [roles permissions](../config/roles_permissions.md#more-about-guest-invitation-feature))
* Office online: support co-authoring
* Admin can set users' department and name when creating users
* Show total number of files and storage in admin info page
* Show total number of devices and recently connected devices in admin info page
* Delete shared libraries information when deleting a user
* Upgrade Django to 1.8.17
* Admin can create group in admin panel
* \[fix] Fix quota check: users can't upload a file if the quota will be exceeded after uploading the file
* \[fix] Fix quota check when copy file from one library to another
* Add `# -*- coding: utf-8 -*-` to seahub_settings.py, so that admin can use non-ascii characters in the file.
* \[fix] Prevent admin from access group's wiki
* \[fix] Prevent transfering libraries to guest account
* \[fix] Prevent guest accout to create share link via API v2
* Add a log when a user can't be find in LDAP during login, so that the system admin can know whether it is caused by password error or the user can't be find
* Ingore white space character in the end of lines in ccnet.conf

### 6.0.5 (2016.12.19)

* \[fix] Fix generating of password protected link in file view page
* \[fix] Fix .jpg/.JPG image display in IE10
* Export quota usage in export Excel in user list admin page
* \[fix] Fix admin can't delete broken libraries
* Add "back to previous page" link in trash page, history page
* \[fix] Fix file encoding for text file editing online
* \[fix] Don't show operation buttons for broken libraries in normal users page
* \[fix] Support both `[Audit]` and `[AUDIT]` in seafevent.conf
* \[fix] Support utf-8 characters in filename when preview in MSOffice WebApp
* Support Collabora Online 2.0

### 6.0.4 (2016.11.29)

* \[fix] Fix list_inner_pub_repos error in cloud mode
* \[fix] Improve logo show in About dialog
* \[fix] Fix file/folder upload in Firefox 50
* \[fix] Fix groups not shown in admin panel when there are more than 100 groups

### 6.0.3 (2016.11.17)

* \[fix] Fix the shared folder link in the notification message when a user share a folder to another user
* \[fix] Update Django version from 1.8.10 to 1.8.16
* \[fix] Fix the shared folder name is not changed after removing the old share, renaming the folder and re-sharing the folder
* \[fix] Fix sub-folder accidentially show the files in parent folder when the parent folder contains more than 100 files
* \[fix] Fix image preview navigation when there are more than 100 entries in a folder
* \[fix] Fix jpeg image display in IE10
* \[fix] Fix bug when admin searching unexisting user
* Add support for online view of mov video files
* Make web access token expiring time configurable
* Add an option on server to control block size for web upload files
* \[fix] Failed to cache (set/get) WOPI_ACCESS_TOKEN_EXPIRATION due to memcached key length limit
* \[fix] Not allow user to set the permissions onto unshared folder. Because it is useless.
* \[fix] Fix condition check when display share icon for guest user
* Support full-text search and audit log by default
* \[fix] Fix permission dialog bug when the corresponding user/group deleted

### 6.0.2 (2016.10.20)

* \[fix] Virus scan fails when the keystone token has expired <https://github.com/haiwen/seafile/issues/1737>
* \[fix] If you share a sub-folder to a group, the sub-folder will appear as a library in that group page. Don't show "permission" menu item for such a shared sub-folder on the group page, because setting permissions on this shared sub-folder not work. The user should set permissions on the original library directly.
* \[fix] Fix API for uploading file by blocks (Used by iOS client when uploading a large file)
* \[fix] Fix a database connection problem in ccnet-server
* \[fix] Fix moved files are still present in local folder until refresh
* \[fix] Fix admin panel can't show deleted libraries

### 6.0.1 beta

* Enable create a library from a template
* Enable office preview by default in installation script
* \[fix] Fix not able to move files via WebDAV interface
* Check whether the quota will exceed before saving the uploaded file to Seafile via Web UI or API
* \[fix] Fix owner can't restore a deleted file or folder in snapshot
* \[fix] Fix UI of personal profile page
* \[fix] Fix in some cases mobile devices can't be unlinked
* \[fix] Fix connection problem for the latest MariaDB in initialisation script
* Make maxNumberOfFiles configurable
* \[fix] Remember the sorting of libraries
* Add Finnish translation
* Video + audio no longer be limited by max preview size

### 6.0.0 beta

* Add full screen Web UI
* Add file comment
* Improve zip downloading by adding zip progress
* Change of navigation labels
* Support Seafile Drive client
* \[admin] Add group transfer function in admin panel
* \[admin] Admin can set library permissions in admin panel
* Improve checking the user running Seafile must be the owner of seafile-data. If seafile-data is symbolic link, check the destination folder instead of the symbolic link.
* \[ui] Improve rename operation
* Show name/contact email in admin panel and enable search user by name/contact email
* Add printing style for markdown and doc/pdf
* The “Seafile” in "Welcome to Seafile" message can be customised by SITE_NAME
* Improve sorting of files with numbers
* \[api] Add admin API to only return LDAP imported user list
* Code clean and update Web APIs
* Remove number of synced libraries in devices page for simplify the interface and concept
* Update help pages
* \[online preview] The online preview size limit setting FILE_PREVIEW_MAX_SIZE will not affect videos and audio files. So videos and audio with any size can be previewed online.
* \[online preview] Add printing style for markdown

Pro only features

* Support LibreOffice online/Collabora Office online
* Add two-factor authentication
* Remote wipe (need desktop client 6.0.0)
* \[anti-virus] Support parallel scan
* \[anti-virus] Add option to only scan a file with size less than xx MB
* \[anti-virus] Add option to specific which file types to scan
* \[anti-virus] Add scanning virus instantly when user upload files via upload link
* \[online preivew] Add printing style for doc/pdf
* \[online preivew] Warn user if online preview only show 50 pages for doc/pdf with more than 50 pages
* \[fix] Fix search only work on the first page of search result pages



## 4.4

Note: Two new options are added in version 4.4, both are in seahub_settings.py

* SHOW_TRAFFIC: default is True, set to False if you what to hide public link traffic in profile
* SHARE_LINK_PASSWORD_MIN_LENGTH: default is 8

This version contains no database table change.

### 4.4.9 (2016.02.29)

* \[fix] Show “out of quota” instead of “DERP” in the case of out of quota when uploading files via web interface

### 4.4.8 (2015.12.17)

* \[security] Fix password check for visiting a file in folder sharing link

### 4.4.7 (2015.11.20)

* \[fix] Fix viewing PDF files via Office Web App
* \[fix, virus scan] Do not scanning deleted libraries in virus scan
* \[fix, virus scan] Fix showing the virus scan page when libraries containing scanned items are deleted
* \[virus scan] Add more debug information for virus scan
* \[fix] Clean cache when set users' name from web API
* \[fix] Fix a performance problem for generating picture thumbnails from folder sharing link

### 4.4.6 (2015.11.09)

* \[security] Fix a XSS problem in raw sharing link
* \[fix] Delete sharing links when deleting a library
* \[fix] Clean Seafile tables when deleting a library
* \[fix] Add <a> tag to the link in upload folder email notification
* \[fix] Fix a bug in creating a library (after submit a wrong password, the submit button is no longer clickable)
* \[fix, pro] Fix a bug in listing FileUpdate audit log
* \[security, pro] Don't online preview for office files in encrypted libraries

### 4.4.5 (2015.10.30)

* \[fix] Fix a bug in deleting sharing link in sharing dialog.

### 4.4.4 (2015.10.29)

* \[fix] Fix support for syncing old formatted libraries
* Remove commit and fs objects in GC for deleted libraries
* Add "transfer" operation to library list in "admin panel->a single user"
* \[fix] Fix the showing of the folder name for upload link generated from the root of a library
* \[fix] Add access log for online file preview
* \[fix] Fix permission settings for a sub-folder of a shared sub-folder

LDAP improvements and fixes

* Only import LDAP users to Seafile internal database upon login
* Only list imported LDAP users in "organization->members"
* Add option to not import users via LDAP Sync (Only update information for already imported users). The option name is IMPORT_NEW_USER. See document <http://manual.seafile.com/deploy/ldap_user_sync.html> (url might deprecated)

### 4.4.3 (2015.10.20)

* \[fix] Remove regenerate secret key in update script

### 4.4.2 (2015.10.19)

* \[security] Check validity of file object id to avoid a potential attack
* \[fix] Check the validity of system default library template, if it is broken, recreate a new one.
* \[fix] After transfer a library, remove original sharing information
* \[security] Fix possibility to bypass Captcha check
* \[security] More security fixes.
* \[pro] Enable syncing a sub-sub-folder of a shared sub-folder (For example, if you share library-A/sub-folder-B to a group, other group members can selectively sync sub-folder-B/sub-sub-folder-C)
* \[fix, office preview] Handle the case that "/tmp/seafile-office-output"is removed by operating system

### 4.4.1 beta (2015.09.24)

* \[fix] Fix a bug in setting an user's language
* \[fix] Show detailed failed information when sharing libraries failed
* \[api] Add API to list folders in a folder recursively
* \[api] Add API to list only folders in a folder

### 4.4.0 beta (2015.09.21)

New features:

* Allow group names with spaces
* Enable generating random password when adding an user
* Add option SHARE_LINK_PASSWORD_MIN_LENGTH
* Add sorting in share link management page
* Other UI improvements

Pro only:

* Integrate Office Web Apps server
* Integrate virus scan
* Support resumable upload (turn off by default)
* Add option to hide public link traffic in profile (SHOW_TRAFFIC)

Fixes:

* \[fix] Fix a bug that causing duplications in table LDAPImport
* set locale when Seahub start to avoid can't start Seahub problem in a few environments.

## 4.3

Note: this version contains no database table change from v4.2. But the old search index will be deleted and regenerated.

Note when upgrading from v4.2 and using cluster, a new option `COMPRESS_CACHE_BACKEND = 'locmem://'` should be added to seahub_settings.py

### 4.3.4 (2015.09.14)

* \[fix] Fix a bug in file locking
* \[fix] Fix sub-folder permission check for file rename/move
* \[fix] Fix a bug in active number of users checking
* Show total/active number of users in admin panel
* Counts all downloads into traffic statistics
* \[security] Use POST request to handle password reset request to avoid CSRF attack
* Don't show password reset link for LDAP users
* \[ui] Small improvements

### 4.3.3 (2015.08.21)

* \[fix, important] Bug-fix and improvements for seaf-fsck
* \[fix, important] Improve I/O error handling for file operations on web interface
* Update shared information when a sub-folder is renamed
* \[fix] Fix bug of list file revisions
* \[fix] Fix syncing sub-folder of encrypted library
* Update translations
* \[ui] Small improvements
* \[fix] Fix modification operations for system default library by admin

### 4.3.2 (2015.08.12)

* Update translations
* \[fix] Fix bug in showing German translation
* \[fix] Fix bug when remove shared link at library settings page
* \[fix] Fix api error in opCopy/opMove
* Old library page (used by admin in admin panel): removed 'thumbnail' & 'preview' for image files

### 4.3.1 (2015.07.31)

* \[fix] Fix generating image thumbnail
* \[ui] Improve UI for sharing link page, login page, file upload link page
* \[security] Clean web sessions when reset an user's password
* Delete the user's libraries when deleting an user
* Show link expiring date in sharing link management page
* \[admin] In a user's admin page, showing libraries' size and last modify time
* \[fix, api] Fix star file API
* \[pro, beta] Add "Open via Client" to enable calling local program to open a file at the web

About "Open via Client": The web interface will call Seafile desktop client via "seafile://" protocol to use local program to open a file. If the file is already synced, the local file will be opened. Otherwise it is downloaded and uploaded after modification. Need client version 4.3.0+

### 4.3.0 (2015.07.25)

Usability improvements

* \[ui] Improve ui for file view page
* \[ui] Improve ui for sorting files and libraries
* Redesign sharing dialog
* Enable generating random password for sharing link
* Remove direct file sharing between users (You can use sharing link instead)

Pro only features:

* Add file locking
* \[fix] Fix file name search for Chinese and other Asia language
* \[fix] Support special password for MySQL database in seafevents

Others

* \[security] Improve permission check in image thumbnail
* \[security] Regenerate Seahub secret key, the old secret key lack enough randomness
* Remove the support of ".seaf" format
* \[api] Add API for generating sharing link with password and expiration
* \[api] Add API for generating uploading link
* \[api] Add API for link files in sharing link
* Don't listen on 10001 and 12001 by default.
* Change the setting of THUMBNAIL_DEFAULT_SIZE from string to number, i.e., use `THUMBNAIL_DEFAULT_SIZE = 24`, instead of `THUMBNAIL_DEFAULT_SIZE = '24'`

## 4.2

Note: because Seafile has changed the way how office preview work in version 4.2.2,
you need to clean the old generated files using the command:

```
rm -rf /tmp/seafile-office-output/html/

```

### 4.2.4 (2015.07.08)

* More fix on showing share link management page
* Fix a bug on doc/ppt preview
* Fix a bug in reading last login time

### 4.2.3 (2015.07.07)

* Fix translation problem for German and other language
* Remove "open locally" feature. It needs more testing
* Fix a problem in showing share link management page

### 4.2.2 (2015.07.03)

* \[fix] Fix file uploading link
* Add LDAP user sync
* Improve preview for office files (doc/docx/ppt/pptx)

In the old way, the whole file is converted to HTML5 before returning to the client. By converting an office file to HTML5 page by page, the first page will be displayed faster. By displaying each page in a separate frame, the quality for some files is improved too.

### 4.2.1 (2015.06.30)

Improved account management

* Add global address book and remove the contacts module (You can disable it if you use CLOUD_MODE by adding ENABLE_GLOBAL_ADDRESSBOOK = False in seahub_settings.py)
* List users imported from LDAP
* \[guest] Enable guest user by default
* \[guest] Guest user can't generate share link
* Don't count inactive users as licensed users

Important

* \[fix] Fix viewing sub-folders for password protected sharing
* \[fix] Fix viewing starred files
* \[fix] Fix support of uploading multiple files in clients' cloud file browser
* Improve security of password resetting link
* Remove user private message feature

New features

* Enable syncing any folder for an encrypted library
* Add open file locally (open file via desktop client)

Others

* \[fix] Fix permission checking for sub-folder permissions
* Change "quit" to "Leave group"
* Clean inline CSS
* Use image gallery module in sharing link for folders containing images
* \[api] Update file details api, fix error
* Enable share link file download token available for multiple downloads
* \[fix] Fix visiting share link whose original path is deleted
* Hide enable sub-library option since it is not meaningless for Pro edition

### 4.2.0 (2015.05.29)

Pro only updates

* \[new] Support set permission on every sub-folder
* \[search] Support partial match like "com" matching "communication" in file name
* \[search] The search result page is much clean

Usability

* Add direct file download link
* Remove showing of library description
* Don't require library description
* Keep left navigation bar when navigate into a library
* Generate share link for the root of a library
* Add loading tip in picture preview page

Security Improvement

* Remove access tokens (all clients will log out) when a users password changed
* Temporary file access tokens can only be used once
* sudo mode: confirm password before doing sysadmin work

Platform

* Use HTTP/HTTPS sync only, no longer use TCP sync protocol
* Support byte-range requests
* Automatically clean of trashed libraries
* \[ldap] Save user information into local DB after login via LDAP

## 4.1

### 4.1.2 (2015.05.07)

* \[fix] Fix bug in syncing LDAP groups
* \[fix] Fix bug in viewing PDF/Doc
* \[fix] Fix crash bug when memcache is full

### 4.1.1 (2015.04.16)

* \[fix] Fix Webdav's port can't be changed to non default port (8082)
* \[fix, searching] Fix handling invalid path name when indexing
* \[fix] Fix seaf-fsck for swift/s3/ceph backend
* Do not show "this type of file can't be viewed online"
* \[fix] Fix showing of activity feed in mobile device
* \[fix] Fix viewing sharing link for deleted directories
* Log email sending in background task to seahub_email_sender.log
* Improve shibboleth login by supporting "next" parameter in URL

### 4.1.0 (2015.04.01)

Pro only updates

* Support syncing any sub-folder in the desktop client
* Add audit log, see <http://manual.seafile.com/security/auditing.html> (url might deprecated). This feature is turned off by default. To turn it on, see <http://manual.seafile.com/deploy_pro/configurable_options.html> (url might deprecated)
* Syncing LDAP groups
* Add permission setting for a sub-folder (beta)

Updates in community edition too

* \[fix] Fix image thumbnail in sharing link
* Show detailed time when mouse over a relative time
* Add trashed libraries (deleted libraries will first be put into trashed libraries where system admin can restore)
* Improve seaf-gc.sh
* Redesign fsck.
* Add API to support logout/login an account in the desktop client
* Add API to generate thumbnails for images files
* Clean syncing tokens after deleting an account
* Change permission of seahub_settings.py, ccnet.conf, seafile.conf to 0600
* Update Django to v1.5.12

## 4.0

### 4.0.6 (2015.03.06)

* \[fix] Fix the seafevents not shutdown by seafile.sh problem
* Improved shibboleth support
* \[fix] Fix uploading a directory if the top directory only contains sub-folders (no files)
* Improve thumbnail API

### 4.0.5 (2015.02.13)

* \[fix] Fix a crash problem when a client tries to upload corrupted data
* Add image thumbnails

### 4.0.4 (2015.02.05)

Important

* \[fix] Fix transfer library error in sysadmin page
* \[fix] Fix showing of space used in sysadmin page for LDAP users
* \[fix] Fix preview office files in file share links and private share
* Improved trash listing performance

Small

* \[webdav] list organisation public libraries
* Disable non-shibboleth login for shibboleth users
* \[fix] Fix wrong timestamp in file view page for files in sub-library
* Add Web API for thumbnail
* Add languages for Thai and Turkish, update a few translations
* \[ldap] Following referrals

### 4.0.3 (2015.01.15)

* \[fix] Fix memory leak in HTTP syncing
* Repo owner can restore folders/files from library snapshot
* Update translations
* \[ldap] Make the "page result" support turn off by default to be compatible with community edition.
* Only repo owner can restore a library to a snapshot
* \[fix] Remote redundant logs in seaf-server
* \[fix] Raise 404 when visiting an non-existing folder
* \[fix] Enable add admin when LDAP is enabled
* Add API to get server features information (what features are supported by this server)
* \[fix] Fix throttle for /api2/ping

### 4.0.2 (2015.01.06)

* \[fix] Fix syncing sub-library with HTTP protocol

### 4.0.1 (2014.12.29)

* Add Shibboleth support (beta)
* Improve libraries page loading speed by adding cache for library
* \[fix] Fix performance problem of FUSE when using ceph/swift backend
* \[fix] Fix folder upload by drap&drop
* \[fix] Fix version check for pro edition
* \[fix] Fix performance problem in listing files API
* \[fix] Fix listing files of a large folder
* \[fix] Fix folder sharing link with password protection
* \[fix] Fix deleting broken libraries in the system admin panel

### 4.0.0 (2014.12.13)

* Add HTTP syncing support
* Merge FileServer into seaf-server
* \[web] New upload file dialog
* \[search] Improve the speed of search by removing in-efficient code in calculating file modification time in the search result page.

## 3.1

### 3.1.13 (2014.11.25)

* Add WMV video file preview on web
* Support office documents online preview in cluster deployment
* \[fix] Fix file private sharing bug when file name contains &

### 3.1.12 (2014.11.17)

* Update ElasticSearch to v1.4
* Limit content search of txt file to 100KB.
* Fix "out of memory" problem.

### 3.1.11 (2014.11.03)

* \[fix] Fixed ./seaf-gc.sh to run online GC
* \[fix] Fixed showing libraries with same name in WebDAV extension in some specific Python version
* \[fix] Fixed event timestamp for library creation and library deleting events
* \[fix] Don't allow setting an encrypted library as default library
* \[fix] Don't list unregistered contacts in sharing dialog
* Don't list inactive users in "organization->members"
* \[multi-tenancy] Add webdav support
* Autoupload files when added in web interface

### 3.1.10 (2014.10.27)

* Online GC: you don't need to shutdown Seafile server to perform GC
* \[fix] Fixed performance problem in WebDAV extension
* \[fix] Fixed quota check in WebDAV extension
* \[fix] Fixed showing libraries with same name in WebDAV extension
* Add "clear" button in a library's trash
* \[fix] Fix small errors when upload files via Web interface
* \[fix] Fix moving/coping files when the select all file checkbox is checked
* \[multi-tenancy] Listing libraries of an organization
* \[multi-tenancy] Enable rename an organization
* \[multi-tenancy] Prevent the deleting of creator account of an organisation

### 3.1.9 (2014.10.13)

* \[ldap] split LDAP and Database in organization -> pubuser
* \[ldap] Support pagination for loading users from LDAP
* \[multi-tenancy] fix quota related bugs
* \[office preview] Fix seafevents not start bug when using Python v2.6

### 3.1.7, 3.1.8

* Add support for multi-tenancy

### 3.1.6 (2014.09.16)

* Add access.log for file download
* \[fix, api] Fix bug in group creation

### 3.1.5 (2014.09.13)

* Add multi-tenancy support

### 3.1.4 (2014.09.11)

* \[fix] Fix bug in uploading >1GB files via Web
* \[fix] Remove assert in Ccnet to avoid denial-of-service attack
* \[fix] Add the missing ./seaf-gc.sh
* Support two modes of license, life-time and subscription

### 3.1.3 (2014.08.29)

* \[fix] Fix multi-file upload in upload link and library page
* \[fix] Fix libreoffice file online view
* Add 'back to top' for pdf file view.
* \[fix] Fix "create sub-library" button under some language
* \[fix popup] Fix bug in set single notice as read.
* Add message content to notification email

### 3.1.2 (2014.08.27)

* \[fix] Fix support for guest account
* \[fix, security] Fix permission check for PDF full screen view
* \[fix] Fix copy/move multiple files in web
* Improve UI for group reply notification
* Improve seaf-fsck, seaf-fsck now can fix commit missing problem
* \[security improve] Access token generated by FileServer can only be used once.

### 3.1.1 (2014.08.18)

* \[fix] Fix memory leak
* \[fix] Fix a memory not initialized problem which may cause sync problem under heavy load.
* \[fix, search] Closing database connection first before indexing

### 3.1.0 (2014.08.15)

Pro edition only:

* \[search] Enable searching directories
* \[search] Enable search groups in organization tab
* \[search] Enable encrypted libraries (filename only)
* \[search, fix] Fix a bug when indexing a large library
* \[preview,fix] Fix document preview for Excel files in sharing links
* \[user] Enable add users as guests. Guests are only able to use libraries shared to him/her.
* \[user] Enable set users password strength requirement
* \[sharing link] Enable set expiring time for sharing links
* \[sharing link] Library owner can manage all share links from this library

Syncing

* Improve performance: easily syncing 10k+ files in a library.
* Don't need to download files if they are moved to another directory.

Platform

* Rename HttpServer to FileServer to remove confusing.
* Support log rotate
* Use unix domain socket in ccnet to listen for local connections. This isolates the access to ccnet daemon for different users.
* Delete old PID files when stop Seafile
* Remove simplejson dependency
* \[fix] fix listing libraries when some libraries are broken
* Add a bash wrapper for seafile-gc

Web

* Enable deleting of personal messages
* Improved notification
* Upgrade pdf.js
* Password protection for sharing links
* \[admin] Create multi-users by uploading a CSV file
* Sort libraries by name/date
* Enable users to put an additional message when sending a sharing link
* Expiring time for sharing links
* \[fix] Send notification to all users participating a group discussion
* Redesigned file viewing page
* Remove simplejson dependency
* Disable the ability to make a group public by default (admin can turn it on in settings)
* Add "Back to Top" button in file view page
* Improve page refreshing after uploading files

## 3.0

### 3.0.7

* Add support for logrotate
* \[fix] Fix script for migrating from community edition

### 3.0.6

* Fix seahub failing to start problem when Ceph backend is used

### 3.0.5

* Add option to enable highlight search keyword in the file view
* \[fix] Fix "Save to My Library" in file sharing
* \[fix] Fix API for renaming files containing non-ASCII characters from mobile clients

### 3.0.4

* Add support for MariaDB Cluster

### 3.0.3

Web

* Show a notice when one tries to reset/change the password of a LDAP user
* Improve the initial size of pdf/office documents online preview
* Handle languages more gracefully in search
* Highlight the keywords in the search results
* \[fix] Fixed a web page display problem for French language

Platform

* Improve the speed when saving objects to disks
* Show error messages when seahub.sh script failed to start

### 3.0.2

* Added Ceph storage backend support
* Use random ID as avatar file name instead of the file name uploaded by the user

### 3.0.1

* \[fix] Fix an UI bug in selecting multiple contacts in sending message
* Library browser page: Loading contacts asynchronously to improve initial loading speed

### 3.0.0

Web

* Redesigned UI
* \[admin] Add login log
* \[admin] Add share link traffic statistics
* \[fix] Handle loading avatar exceptions to avoid 500 error
* Fixed a few api errors
* Improve page loading speed
* \[fix] Fix UI problem when selecting contacts in personal message send form
* \[fix] Add nickname check and escape nickname to prevent XSS attack
* \[fix] Check validity of library name (only allow a valid directory name).

Platform

* Separate the storage of libraries
* Record files' last modification time directly
* Keep file timestamp during syncing
* Allow changing password of an encrypted library
* Allow config httpserver bind address
* Improved device (desktop and mobile clients) management

Misc

* \[fix] Fix API for uploading files from iOS in an encrypted library.
* \[fix] Fix API for getting groups messages containing multiple file attachments
* \[fix] Fix bug in HttpServer when file block is missing
* \[fix] Fix login error for some kind of Android

## 2.2

### 2.2.1

* Add more checking for the validity of users' Email
* Use random salt and PBKDF2 algorithm to store users' password.

## 2.1

### 2.1.5

* Add correct mime types for mp4 files when downloading
* \[important] set correct file mode bit after uploading a file from web.
* Show meaningful message instead of "auto merged by system" for file merges
* Improve file history calculation for files which were renamed

WebDAV

* Return last modified time of files

### 2.1.4-1

* \[fix] fixed the `pro.py search --clear` command
* \[fix] fixed full text search for office/pdf files

### 2.1.4

* Improved Microsoft Excel files online preview
* \[fix] Fixed file share link download issue on some browsers.
* \[wiki] Enable create index for wiki.
* Hide email address in avatar.
* Show "create library" button on Organization page.
* \[fix] Further improve markdown filter to avoid XSS attack.

### 2.1.3

* Fixed a problem of Seafile WebDAV server

### 2.1.2

* Fixed a problem of requiring python boto library even if it's not needed.

### 2.1.1

Platform

* Added FUSE support, currently read-only
* Added WebDAV support
* A default library would be created for new users on first login to seahub
* Upgrade scripts support MySQL databases now

Web

* Redesigned Web UI
* Redesigned notification module
* Uploadable share links
* \[login] Added captcha to prevent brute force attack
* \[login] Allow the user to choose the expiration of the session when login
* \[login] Change default session expiration age to 1 day
* \[fix] Fixed a bug of "trembling" when scrolling file lists
* \[sub-library] User can choose whether to enable sub-library
* Improved error messages when upload fails
* Set default browser file upload size limit to unlimited

Web for Admin

* Improved admin UI
* More flexible customization options
* Support specify the width of height of custom LOGO
* Online help is now bundled within Seahub

## 2.0

### 2.0.5

* Support S3-compatible storage backends like Swift
* Support use existing elasticsearch server

### 2.0.4

* \[fix] set the utf8 charset when connecting to database
* Use users from both database and LDAP
* \[admin] List database and LDAP users in sysadmin

### 2.0.3

* \[fix] Speed up file syncing when there are lots of small files

### 2.0.1

* \[fix] Elasticsearch now would not be started if search is not enabled
* \[fix] Fix CIFS support.
* \[fix] Support special characters like '@' in MySQL password
* \[fix] Fix create library from desktop client when deploy Seafile with Apache.
* \[fix] Fix sql syntax error in ccnet.log, issue #400 (<https://github.com/haiwen/seafile/issues/400>).
* \[fix] Return organization libraries to the client.
* Update French, German and Portuguese (Brazil) languages.

### 2.0.0

Platform

* New crypto scheme for encrypted libraries
* A fsck utility for checking data integrity

Web

* Change owner of a library/group
* Move/delete/copy multiple files
* Automatically save draft during online editing  
* Add "clear format" to .seaf file online editing
* Support user delete its own account
* Hide Wiki module by default
* Remove the concept of sub-library

Web for Admin

* Change owner of a library
* Search user/library

API

* Add list/add/delete user API

## 1.8

### 1.8.3

* Improve seahub.sh
* Improve license checking

### 1.8.2

* fixed 'cannot enter space' bug for .seaf file online edit
* add paginating for repo files list
* fixed a bug for empty repo

### 1.8.1

* Remove redundant log messages

### 1.8.0

Web

* Improve online file browsing and uploading
  * Redesigned interface
  * Use ajax for file operations
  * Support selecting of multiple files in uploading
  * Support drag/drop in uploading
* Improve file syncing and sharing
  * Syncing and sharing a sub-directory of an existing library.
  * Directly sharing files between two users (instead of generating public links)
  * User can save shared files to one's own library
* \[wiki] Add frame and max-width to images
* Use 127.0.0.1 to read files (markdown, txt, pdf) in file preview
* \[bugfix] Fix pagination in library snapshot page
* Set the max length of message reply from 128 characters to 2000 characters.

API

* Add creating/deleting library API

Platform

* Improve HTTPS support, now HTTPS reverse proxy is the recommend way.
* Add LDAP filter and multiple DN
* Case insensitive login
* Move log files to a single directory
* \[security] Add salt when saving user's password
* \[bugfix] Fix a bug in handling client connection
* Add a script to automate setup seafile with MySQL

## 1.7

### 1.7.0.4

* Fixed a bug in file activities module

### 1.7.0

* First release of Seafile Professional Server

# Seafile Professional Server Changelog (old)

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

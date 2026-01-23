# Seafile Professional Server Changelog

> You can check Seafile release table to find the lifetime of each release and current supported OS: <https://cloud.seatable.io/dtable/external-links/a85d4221e41344c19566/?tid=0000&vid=0000>


## 13.0

**Upgrade**

Please check our document for how to upgrade to [13.0](../upgrade/upgrade_notes_for_13.0.x.md)


### 13.0.16 (2026-01-23)

* [fix] Fix a security bug in guest invitation
* Improve error handing in metadata server when initializing metadata feature for a library
* fsck and gc should not use cache
* [fix] Fix performance issues of thumbnail-server based on a real-world heavy usage scenary


### 13.0.15 (2025-12-23)

* [fix] Do not print error message when using memcached as cache server
* Other UI fixes and improvements


### 13.0.14 (2025-11-28)

* Preview PDF files by the default viewer and after user clicking edit button, the PDF file will be edited in OnlyOffice
* Support generating thumbnails for SVG files
* Accessibility improvement
* [fix] Fix fsck crash when head commit is corrupt
* [fix] 1000 files upload limit doesn't get flushed when upload finishes
* [fix] Safari race condition prevents PDF preview
* [fix] Fix SeaSearch can’t search the content of PDF files
* Other UI fixes and improvements


### 13.0.12 beta (2025-10-24)

* SeaDoc: SeaDoc is now version 2.0
* Thumbnail server: A new thumbnail server component is added to improve performance for thumbnail generating and support thumbnail for videos
* Metadata server: A new metadata server component is available to manage extended file properties
* Notification server: The web interface now support real-time update when other people add or remove files if notification-server is enabled
* Database and memcache configurations are added to `.env`, it is recommended to use environment variables to config database and memcache
* Redis is recommended to be used as memcache server
* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The old file tags feature can no longer be used, the interface provide an upgrade notice for migrate the data to the new file tags feature


## 12.0

**Upgrade**

Please check our document for how to upgrade to [12.0](../upgrade/upgrade_notes_for_12.0.x.md)

### 12.0.19 (2025-12-03)

* [fix] Fix backgrand tasks are started at the front-end node in clustering environment.

### 12.0.18 (2025-11-17)

* Preview PDF files by the default viewer and after user clicking edit button, the PDF file will be edited in OnlyOffice.
* [fix] Update bundled Django version to 4.2.26 in Docker image
* [fix] Fix tranfering a library to another user in system admin panel

### 12.0.17 (2025-10-14)

* [fix] Fix a XSS issue for SVG file view in sharing link if golang file server is used
* [fix] Support line wrap for text file view
* [fix] Fix PDF view does not work when sharing a library with Online Read-Only

### 12.0.16 (2025-08-29)

* [fix] Fix a XSS issue in upload link
* [fix] Fix a permission check issue for "shared with all" libraries in mutli-tenancy mode

### 12.0.15 (2025-08-15)

* [fix] Fix OCM support
* [fix] Fix sending anti-virus email to system admin using contract email
* [fix] Fix expiring check for upload link
* [fix] Fix smart-link accessing for shared folders in multi-tenancy mode

### 12.0.14 (2025-05-28)

* [fix] Fix two stored XSS issues (In rendering terms and conditions and in institution admin page)
* [fix] Do not close the search popover when click a result

### 12.0.13 (2025-05-09)

* Add S/MIME support for emails

### 12.0.12 (2025-04-21)

* [fix] Fix a UI bug in "share admin -> share links"
* [fix] Fix a bug in rendering "system admin -> users"
* Update translations

### 12.0.11 (2025-03-20)

* [fix] Fix a stored XSS issue
* [fix] Do not show Wiki libraries in clients and WebDAV
* Add library name in "share admin -> folders"
* [fix] Fix set of library history keep days
* [fix] Fix support for enforcing Two-Factor Authentication
* Update support for working with SeaSearch 0.9.1

### 12.0.10 (2025-03-05)

* [fix] Fix seaf-fuse support
* [fix] Fix "save to" button in external link
* [fix] Search library text in system admin page is incorrect
* [fix] Fix library path displays issue in read-only shared
* Improve icons for creating Wiki and inviting links
* [fix] Fix a bug in Collabora integration: Interface in English despite Seafile interface in French
* Delete temp files if zip download failed
* Create a record in social_auth table when user login via SSO even if SSO_LDAP_USE_SAME_UID enabled
* [fix] Cannot create a share link with the “cloud edit” permission for OpenDocument (odt, ods, odp, odg)


### 12.0.9 beta (2025-02-12)

* [fix] Fix a bug related to smart-link in mutli-tenancy mode
* Improve consistency of format of logs
* DISABLE_ADFS_USER_PWD_LOGIN now work for OAuth too
* [fix] Fix a bug in search indexing with SeaSearch backend
* [fix] Thumbnail server does not preserve ICC profiles, resulting in washed out colors
* [fix] A few small UI fixes and improvements

### 12.0.8 beta (2025-01-17)

* A redesigned Web UI
* SeaDoc is now stable, providing online notes and documents feature
* A new wiki module
* A new trash mechanism, that deleted files will be recorded in database for fast listing
* The password strength level is now calculated by algorithm. The old USER_PASSWORD_MIN_LENGTH, USER_PASSWORD_STRENGTH_LEVEL is removed. Only USER_STRONG_PASSWORD_REQUIRED is still used.
* ADDITIONAL_APP_BOTTOM_LINKS is removed. Because there is no buttom bar in the navigation side bar now.
* SERVICE_URL and FILE_SERVER_ROOT are removed. SERVICE_URL will be calculated from SEAFILE_SERVER_PROTOCOL and SEAFILE_SERVER_HOSTNAME in `.env` file.
* `ccnet.conf` is removed. Some of its configuration items are moved from `.env` file, others are read from items in `seafile.conf` with same name.
* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The current file tags feature is deprecated. We will re-implement a new one in version 13.0 with a new general metadata management module.
* For ElasticSearch based search, full text search of doc/xls/ppt file types are no longer supported. This enable us to remove Java dependency in Seafile side.



## 11.0

**Upgrade**

Please check our document for how to upgrade to [11.0](../upgrade/upgrade_notes_for_11.0.x.md)

### 11.0.19 (2025-03-21)

* [fix] Fix a stored XSS issue
* SSO_LDAP_USE_SAME_UID option now support Shibboleth login method
* [fix] Fix a bug when a user view a shared file belong to a deleted user
* Improve SAML error message when exceed number of user limit of license

### 11.0.18 (2025-01-20）

* [fix] Fix license check in SAML mode
* [fix] Do not change a user's role if it is manully set in Shibboleth login
* Support using different office suites for different roles

### 11.0.17 (2025-01-04)

* [fix] Fix a few issues in golang file server related to permission check
* [fix] Fix a bug in golang file server related to online GC


### 11.0.16 (2024-11-04)

* The storage migration script now does not allow migration to the original bucket
* [Security] Do not allow .. as a file directory name
* [fix] Search results now show the first 20 entries and the user can click more to jump to the page dedicated to search
* [fix] Fixed SSE_C support
* Added an option USE_LDAP_SYNC_ONLY to meet the case that using LDAP to sync users to Seafile and let users to login via SSO only
* [fix] Hide the print button when opening with office online server for preview only the folder share
* [fix] Do not send file lock notifications to notification server if notification server is not configured for golang fileserver
* [fix] Sending Links with Passwords has no HTML escape
* [fix] Fix preview support for TIFF images

### 11.0.15 (2024-10-17)

* [fix] Check the length of email in login form, preventing too long input
* [fix] Use user name instead of user ID in email content
* [fix] auth-token API also prevent brute force attack
* [fix] Fix invite people in multi-tenancy mode
* [fix] Add option SSO_LDAP_USE_SAME_UID


### 11.0.14 (2024-08-22)

* [fix] Fix a bug that system admin can not share a library in admin panel
* [fix] Fix a bug when syncing user role in LDAP sync
* [fix] Fix S3 support configuration
* [fix] Add redis package in Docker image
* [fix] Improve client side SSO via local browser

### 11.0.13 (2024-08-14)

* Update translations

### 11.0.12 (2024-08-07)

* [fix] [important] Fix a security bug in WebDAV
* [fix] Fix S3 backend with V4 protocal and path_style_request
* [fix] Use user's name in reset password email instead of internal ID
* [fix] Fix invited guest cannot be revoke
* [fix] Fix keyerror when using backup code in two-factor auth
* [fix] Do not print warning in seaf-server.log when a LDAP user login

### 11.0.11 (2024-07-24)

* Remove unnecessary warning in seahub_email_sender.log 
* [fix] Fix a performance issue in sending file activities notification via email
* Remove REPLACE_FROM_EMAIL setting as most email server does not support it
* [fix] Fix a bug in LDAP login with multiple OU


### 11.0.10 (2024-07-09)

* [fix] Fix system admin users page when institution feature is enabled
* Improving logging of search index
* [fix] Support using contact email in OCM sharing

### 11.0.9 (2024-06-25)

* [fix] Fix a crash problem in golang file server introduced in version 11.0.8
* Add a new role permission "can_share_repo"
* Add rate control for password reset for a user

### 11.0.8 (2024-06-20)

* support named groups in SAML claim
* [fix] Fix CollaboraOnline integration for read-only shares and share links
* [fix] Fix display issue for ADDITIONAL_SHARE_DIALOG_NOTE
* [fix] Fix buckets check for ceph and swift backend
* [fix] Use contact_email in user freeze notifications for system admins


### 11.0.7 (2024-06-03)

Seafile

* Improve accessibility
* Support open ODG files with LibreOffice (Collabora Online)
* Support showing last modified time for folders in WebDAV
* [fix] Fix "remember me" in 2FA
* Enable transfering a library to department in system admin panel
* [fix] Fix a bug in SAML single logout


SDoc editor 0.8

* Support automatically adjusting table width to fit page width
* Improve comments feature
* Improve documents shown on mobile
* More UI fixes and improvements

### 11.0.6 beta (2024-04-19)

Seafile

* Support log rotate for golang file server and notification server
* Update UI for upload link
* Support OnlyOffice version feature
* Show files' original path in the trash
* Fix traffic statistics
* Fix an error in LDAP user sync
* Add an option DISABLE_ADFS_USER_PWD_LOGIN to prevent SAML users login via email/password

SDoc editor 0.7

* Improve file comment feature
* Improve file diff showing
* Support print a document
* Improve table editing

### 11.0.5 beta (2024-03-20)

* Forbid generating share links for a library if the user has invisible/cloud-read-only permission on the library
* [fix] Fix a configuration error for Ceph storage (if you don't use S3 interface)
* [fix] Fix a bug in traffic statistic in golang file server
* Support use different index names for ElasticSearch
* Fix column view is limited to 100 items
* Fix LDAP user login for WebDAV
* Remove the configuration item "ENABLE_FILE_COMMENT" as it is no longer needed
* Enable copy/move files between encrypted and non-encrypted libraries
* Forbid creating libraries with Emoji in name
* Fix some letters in the file name do not fit in height in some dialogs
* Fix a performance issue in sending file updates report
* Some other UI fixes and improvements

SDoc editor 0.6

* Support convert docx file to sdoc file
* Support Markdown format in comments
* Support drag rows/columns in table element and other improvements for table elements
* Other UI fixes and improvements

### 11.0.4 beta and SDoc editor 0.5 (2024-02-01)

Major changes

* Use a virtual ID to identify a user
* LDAP login update
* SAML/Shibboleth/OAuth login update
* Update Django to version 4.2
* Update SQLAlchemy to version 2.x
* Add SeaDoc
  
UI Improvements

* Improve UI of PDF view page
* Update folder icon
* The activities page support filter records based on modifiers
* Add indicator for folders that has been shared out
* Use file type icon as favicon for file preview pages
* Support preview of JFIF image format

Pro edition only changes

* Support S3 SSE-C encryption
* Support a new invisible sub-folder permission
* Update of online read-write permission, online read-write permission now support the shared user to update/rename/delete files online, making it consistent with normal read-write permission

Other changes

* Remove file comment features as they are used very little (except for SeaDoc)
* Add move dir/file, copy dir/file, delete dir/file, rename dir/file APIs for library token based API
* Use user's current language when create Office files in OnlyOffice

## 10.0

**Upgrade**

Please check our document for how to upgrade to [10.0](../upgrade/upgrade_notes_for_10.0.x.md).

**Note**

If you upgrade to version 10.0.18+ from 10.0.16 or below, you need to upgrade the sqlalchemy to version 1.4.44+ if you use binary based installation. Otherwise "activities" page will not work.


### 10.0.18 (2024-11-01)

* [fix] Prevent the creating of files with name ".."

### 10.0.17 (2024-10-23)

This release is for Docker image only

* [fix] Update the version of sqlalchemy to make "activities" page work. The bug was introduced in v10.0.16.

### 10.0.16 (2024-06-21)

* [fix] Fix CollaboraOnline integration for read-only shares and share links

### 10.0.15 (2024-03-21)

* [Fix] Fix a bug in seaf-gc for FS object

### 10.0.14 (2024-02-27)

* Update some translations
* [Fix] Fix a bug in OnlyOffice desktop editor integration
* [Fix] Fix a bug in moving file dialog

### 10.0.13 (2024-02-05)

* [security] Upgrade pillow dependency from 9.0 to 10.0.

Note, after upgrading to this version, you need to upgrade the Python libraries in your server "pillow==10.2.\* captcha==0.5.\* django_simple_captcha==0.5.20" 

### 10.0.12 (2024-01-16)

* Improved WOPI-integration of Collabora Online
* Fix "Share Admin->Links->Share Links" crash when shared link file does not exist anymore


### 10.0.11 (2023-11-09)

* [fix] Improve error message in SAML login when the IdP have a connection problem
* [fix] Fix a bug that go fileserver causing client to generate empty commit
* [fix] Add missing max number of files for a library when uploading via WebDAV
* [fix] Show which users cannot be imported when importing users to group

### 10.0.10 (2023-10-17)

* [fix] Fix a bug in golang file server that cannot handle sharing permission correctly for departments
* [fix] Fix a bug Share Link Email Verification cannot work for Italy language
* [fix] Fix notification server support in golang file server
* [fix] Fix a bug in search library by ID in admin panel

### 10.0.9 (2023-08-25)

* Add an option (library_file_limit in seafile.conf) to support setting the maximum number of files in a single library
* [fix] Support for virus scan in golang file server when uploading files via upload links
* Some UI fixes and improvements
* Improve script clear_invalid_repo_data.py

### 10.0.8 (2023-08-01)

* [fix] Fix a bug in worker pool management in golang file server
* Improve error message when a user log in via SAML in multi-tenancy mode
* [fix] Fix a bug that causing fsck crash
* Improve the way how cluster_shared folder is cleaned up

### 10.0.7 (2023-07-25)

* [fix] Fix a memory leak in golang file server

### 10.0.6 (2023-06-27)

* [fix] Fix "all notifications" page link broken when notification server is used
* [fix] Fix UI bug of notifications dialog
* [fix] Fix a bug in listing shared out libraries/folders in multi-tenancy mode
* [fix] Fix a bug in sending emails to admin when finding virus

### 10.0.5 (2023-06-12)

* [fix] Fix display of tags in the file details side bar
* [fix] Fix a file name encoding bug in golang file server
* [fix] Fix a UI bug in setting expiration time for a sharing link
* Update included POI java library which is used to extracting contents of doc/docx files in indexing

### 10.0.4 (2023-05-17)

* Add "Undo" action in the notification toast after deleting files and folders
* Improve UI of system admin -> department page
* Support online preview of more audio file formats
* Support TLS connection to MySQL/MariaDB server
* [fix] Fix a few bugs in notification server
* Some other UI improvements

### 10.0.3 beta (2023-04-12)

* [fix] Fix a performance issue when displaying many share links for a single file

### 10.0.2 beta (2023-04-12)

* Support generating multiple share links for a file and a folder
* [fix] Fix a bug in golang file server when zip-downloading a folder in encrypted library
* [fix] Fix a bug in upgrading script when there is no configuration for Nginx
* Video player support changing playback speed
* [fix] Fix a few bugs in notification server
* [multi-tenancy] Support org admin to changing logo for each organization

### 10.0.0 beta (2023-04-12)

* Update Python dependencies and support Ubuntu 22.04 and Debian 11
* Update ElasticSearch to 8.0
* [new] Add a new notification server (document will be provided later)
* [new] Support downloading/uploading rate limit for a user
* [new] Watch and get notifications for libraries
* [new] Support each organization to have its own SAML login in multi-tenancy mode
* Update WebDAV password to use one-way hash
* Remove SQL sub queries to improve SQL query speed in seaf-server
* Show number of shared users/groups if any when deleting a folder
* Support online playing of .wav files

## 9.0

**Upgrade**

Please check our document for how to upgrade to [9.0](../upgrade/upgrade_notes_for_9.0.x.md).

### 9.0.16 (2023-03-22)

* [fix] Fix a bug in clear_invalid_repo_data with virtual repos 

### 9.0.15 (2023-03-01)

* [fix] Fix a bug in seaf-gc for fs object
* [fix] Fix some bugs in golang fileserver

### 9.0.14 (2023-01-06)

* [fix] Fix some bugs in golang fileserver

### 9.0.13 (2022-11-11)

* [multi-tenancy] Add device management for organization admin
* [multi-tenancy] Add statistics for organization admin
* [multi-tenancy] Support import users from xlsx
* [fix] Prevent system admin creating libraries with invalid name in admin panel
* Add "create" permission in custome sharing permission
* Improve performance in golang file server


### 9.0.12 (2022-11-04)

* Enable 'zoom in/out by pinch' for mobile in pdf file view page
* [fix] Fix recording device information for desktop clients login with SSO

### 9.0.11 (2022-10-27)

* [fix] Fix file accessed by seadrive cannot be correctly logged in access log
* [fix] Fix "document convertion failed” error visiting a shared document with preview only
* [fix] Fix memory leak when block cache is enabled
* [fix] Add unique index to repo_id_file_path_md5 in table onlyoffice_onlyofficedockey
* [fix] Fix the default created ElasticSearch(v7.x) index has only one shard
* [fix] Fix search in move files dialog not working


### 9.0.10 (2022-10-12)

* Admin list all users API now return last_login and last_access_time
* [fix] Fix a bug in displaying markdown file in sharing link
* [fix] Fix notification mails are sent to inactive users
* [fix] Fix viewing a file in an old snapshot leads to server hickup
* [fix] Fix an HTTP/500 "Internal server error" when the user sets password containing non-latin characters for sharing links


### 9.0.9 (2022-09-22)

* [fix] Fix a memory leak problem
* [fix] Fix a bug that will lead to seaf-fsck crash
* [fix] Fix a stored XSS problem for library names
* [fix] Disable open a file in OnlyOffice for encrypted libraries when open from trash
* [fix] Fix library template feature cannot work for department libraries
* [fix] Fix file locking display on client for shared sub-folder
* [fix] Fix a memcached problem in go fileserver


### 9.0.8 (2022-09-09)

* [fix] Fix a UI bug in sending sharing link by email
* [fix] Markdown editor does not properly filter javscript URIs from the href attribute, which results in stored XSS
* [fix] Fix a bug in OCM sharing
* [fix] Fix a bug in un-linking a device in admin panel
* [fix] Adding URL security check in /accounts/login redirect by ?next= parameter
* Improve Onlyoffice document info cache handling
* [fix] Fix a performance problem in go fileserver
* When a Custom Sharing Permissions is deleted, removing corresponding shares
* [fix] Don't show auto-deletion menu item when the feature is not enabled
* [fix] Fix a bug in reading a role's quota when a user login with SSO



### 9.0.7 (2022/08/11)

Note: included lxml library is removed for some compatiblity reason. The library is used in published libraries feature and WebDAV feature. You need to install lxml manually after upgrade to 9.0.7. Use command `pip3 install lxml` to install it.

* A page in published libraries is rendered at the server side to improve loading speed.
* Upgrade Django from 3.2.6 to 3.2.14
* Fix a bug in collaboration notice sending via email to users' contact email
* Support OnlyOffice oform/docxf files
* Improve user search when sharing a library
* Admin panel support searching a library via ID prefix
* [fix] Fix preview PSD images
* [fix] Fix a bug that office files can't be opened in sharing links via OnlyOffice
* [fix] Go fileserver: Folder or File is not deletable when there is a spurious utf-8 char inside the filename
* [fix] Fix file moving in WebDAV
* ElasticSearch now support https
* Support advanced permissions like cloud-preview only, cloud read-write only when shareing a department library
* [fix] Fix a bug in get library sharing info in multi-tenancy mode
* [fix] Fix a bug in library list cache used by syncing client


### 9.0.6 (2022/07/06)

* Support using custom permission when shareing a department library
* [fix] Fix a bug in go file-server when working with online GC
* Add cache for getting locked files and getting folder permission (reduce server load caused by sycing client)
* Show table of contents in Markdown sharing link
* Check if quota exceeded before file uploading in upload sharing link
* Support import group member via contact email
* [fix] Fix a bug that sometimes a shared subfolder is unshared automatically by database access error
* [fix] Fix a bug in work with Python 3.10+
* [fix] Fix a bug in smart link redirect to the file page
* [fix] Fix a UI bug when drag and drop a file
* Improve UI of file comments
* [fix] Fix permission check in deleting/editing a file comment
* Support editing of expire time for sharing links
* Show ISO date and time in file history page instead of showing relative time
* Add "Visit related snapshot" in the dropdown menu of an entry in file history

### 9.0.5 (2022/03/21)

* Remove unused "related files" feature
* [fix] Fix zip downloading a folder not having .zip suffix when using golang file server
* UI improvement of file label feature
* Show file labels in folder sharing links
* Improve performance when deleting virtual repos when original repo is deleted
* [fix, security] Fix permission check in deleting/editing a file comment

### 9.0.4 (2022/01/24)

* Users can save files or folders in shared folder link to their own libraries
* [fix] Fix markdown file print

### 9.0.3 beta (2021/12/28)

* Upgrade ElasticSearch to version 7.x
* Improve UI of file moving/copying dialog to show folders with long names
* Expand to the current folder when open file moving/copying dialog
* [fix] Fix a bug in golang file server log rotate support
* [fix] Fix a bug in folder download-link and try to download files/folders as zip using golang file server
* Preserve keyword when expanding search dialog to a separate search page

### 9.0.2 beta (2021/12/15)

* Upgrade Django to 3.2
* Enable showing password for encrypted sharing links
* Rewrite HTTP service in seaf-server with golang and move it to a separate component (turn off by default)
* Upgrade PDFjs to new version, support viewing of password protected PDF
* Use database to store OnlyOffice cache keys
* Supporting converting files like doc to docx using OnlyOffice for online editing
* In sharing link with edit permission, anonymous users can set his/her name in OnlyOffice editing
* Move SERVICE_URL configuration from ccnet.conf to seahub_settings.py

The new file-server written in golang serves HTTP requests to upload/download/sync files. It provides three advantages:

* The performance is better in a high-concurrency environment and it can handle long requests. Now you can sync libraries with large number of files.
* Now file zipping and downloading can be done simutaneously. When zip downloading a folder, you don't need to wait until zip is done.
* Support rate control for file uploading and downloading.

You can turn golang file-server on by adding following configuration in seafile.conf

```
[fileserver]
use_go_fileserver = true
```

### 9.0.1

Deprecated

### 9.0.0

Deprecated

## 8.0

**Upgrade**

Please check our document for how to upgrade to [8.0](../upgrade/upgrade_notes_for_8.0.x.md).

### 8.0.17 (2022/01/10)

* [fix] Remove JndiManager.class, JmsAppender.class and SmtpAppender.class from log4j jar in bundled ElasticSearch
* [fix] Fix a bug in insert file from library in Markdown editor
* [fix] Fix a crash bug in real-time backup service

### 8.0.16 (2021/12/28)

* [fix] Remove JndiLookup.class from log4j jar in bundled ElasticSearch
* [fix] Fix a memory leak in seaf-server
* Use contact email and name in guest invitation revoking email
* Upgrade bundled mariadb connector c to 3.2.5

### 8.0.15 (2021/12/06)

* If a custom admin role is not found in admin role list, a role with minimal permissions ("audit_admin") will be assigned to the user
* [fix] Fix a security issue in token check in file syncing

### 8.0.14 (2021/11/17)

* [fix] Fix hanlding of user disconnect and connect messages from OnlyOffice 
* [fix] Fix OnlyOffice editing support for anonymous users in sharing links

### 8.0.12 (2021/11/03)

* Improve the way to download scan code for sharing links
* Group admins can search group members now

### 8.0.11 (2021/09/26)

* [fix] Fix a bug in LDAP group sync when using OpenLDAP

### 8.0.10 (2021/09/09)

* [fix] Fix a bug in LDAP sync

### 8.0.9 (2021/08/26)

* Improve title of guest invitation email
* [fix] Fix a bug that page "admin panel -> logs -> permissions" can't be displayed
* [fix] Fix a bug in admin search users

### 8.0.8 (2021/08/06)

* [multi-tenancy] Support system Admin to add additional admins to a specific org
* [fix] Fix zip downloading for large files in cluster
* [fix] Fix online editing for  files with very long names
* Improve performance for listing deleted files in trash
* [fix] Update expire date for new guest invitation if there is an old expired invitation
* [fix] Fix FORCE_PASSWORD_CHANGE does not force the new user to change their password if the user is added by admin
* [fix] Fix setting a webdav password when 2FA enabled

### 8.0.7 (2021/07/19)

* Add missing accessibility labels for some links and buttons in file details page
* [fix] Fix a bug in file zip download when the size of files exceed limit
* [fix] Fix long WebDAV Secret Yields 500 Error

### 8.0.6 (2021/07/15)

* [fix] Fix a cache problem in OnlyOffice integration when automatically saving is used
* [fix] Once a user quota have been set, I can not set it back to 0 (unlimited)
* [fix] Fix collabora integration
* User's can manage his/her Web API Auth Token in profile page
* A group admin can now leave a group
* [fix] Fix Lazy loading / pagination breaks image viewer (https://forum.seafile.com/t/lazy-loading-pagination-breaks-image-viewer/14655)
* seaf-gc can now clean fs object
* Update included libradios to version 16

### 8.0.5 (2021/06/25)

* Add compatibility with IE11
* [fix] Fix a bug in seaf-gc for libraries with sub-libraies
* Enable deleting devices in admin panel
* Enable setting a user's quota back to 0 (unlimited)
* Users can now manage its own Web API auth token in profile page
* Enable a group admin leave a group
* [fix] Disable editing via sharing link when a file is locked
* [fileserver] Add block cache option when downloading file from web or API


### 8.0.4 (2021/05/20)

* [fix] Add back virus scan support in uploading link
* [fix] Fix a bug in seaf-gc
* [fix] Fix a bug in library list cache
* [fix] Fix a bug that a libary can't be synced immidiately after creating
* [fix] Do not show watermark when editing files with Office Online Server

### 8.0.3 (2021/04/27)

* [fix] Fix SAML2 authentication
* [fix] Fix file locking
* [fix] Fix anothoer bug in upload files to a sharing link with upload permission

Potential breaking change in Seafile Pro 8.0.3: You can set the maximum number of files contained in a library that can be synced by the Seafile client. The default is 100000. When you download a repo, Seafile client will request fs id list, and you can control the timeout period of this request through `fs_id_list_request_timeout` configuration, which defaults to 5 minutes. These two options are added to prevent long fs-id-list requests from overloading the server. If you have large libraries on the server, this can cause "internal server error" returned to the client. You have to set a large enough limit for these two options.

```
[fileserver]
max_sync_file_count = 100000
fs_id_list_request_timeout = 300
```

### 8.0.2 (2021/04/21)

* [fix] Fix upload files to sub-folders in a sharing link with upload permission
* [fix] Enable sending collabration notification emails by default
* [fix] Recreate a department if it is deleted in LDAP syncing
* [fix] Fix compatibility with old MariaDB in upgrading SQL statements from version 7.1 to 8.0 
* [fix] Fix deleting libraries without owner in admin panel
* Add an API to change a user's email
* [fix] Fix a bug in storage migration script
* [fix] Fix a bug that will cause fsck crash
* [fix] Fix a XSS problem in notification

### 8.0.1 (2021/04/07)

* Users can set whether to receive email notifications in the setting page
* [fix] Fix a bug that sometimes traffic statistics are not correct
* Improve file locking handling for OnlyOffice and Office Online Server integration
* [fix] Fix a bug in seaf-gc
* [fix] Fix wrong links of files in library history details dialog
* Add "Open via Client" button in file view page
* Add an admin API to change a user's email

### 8.0.0 beta (2021/03/02)

* Add open cloud mesh feature
* Upgrade Django to 2.2 version
* Remove ccnet-server component
* Users can use secret key to access WebDAV after enabling two-factor authentication
* Add QR code for sharing links
* Rewrite upload link page to use React technology
* Improve GC performance
* Update help page
* Release v4 encrypted library format to enhance security for v3 encrypted format


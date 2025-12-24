# Seafile Server Changelog

> You can check Seafile release table to find the lifetime of each release and current supported OS: <https://cloud.seatable.io/dtable/external-links/a85d4221e41344c19566/?tid=0000&vid=0000>


## 13.0

**Upgrade**

Please check our document for how to upgrade to [13.0](../upgrade/upgrade_notes_for_13.0.x.md)


### 13.0.15 (2025-12-23)

* [fix] Do not print error message when using memcached as cache server
* Preview PDF files by the default viewer and after user clicking edit button, the PDF file will be edited in OnlyOffice
* Support generating thumbnails for SVG files
* Accessibility improvement
* [fix] Fix fsck crash when head commit is corrupt
* [fix] 1000 files upload limit doesn't get flushed when upload finishes
* [fix] Safari race condition prevents PDF preview
* Other UI fixes and improvements

### 13.0.12 (2025-10-24)

* [fix] Add missing is_department_owner field in database table to make sure community edition and pro edition have same database schema
* [fix] Fix LDAP and LDAP(Imported) page in system admin panel
* [fix] Fix if ENABLE_WIKI set to false, wiki module still be shown
* [fix] Fix a XSS issue for SVG file view in sharing link if golang file server is used (We'd like to thank [Jose Alfredo Bukit](https://github.com/x0root) for reporting the issue to us
* Support open docxf file type with OnlyOffice
* Other UI fixes and consistency improvements


### 13.0.11 beta (2025-09-22)

* [metadata] Add a new view type "Statistics"
* [metadata] Some UI fixes
* Support realtime comments update for file types like PDF, Markdown and so on
* Collabora: Fix clipboard issue
* Add access log for sdoc-server
* Some other UI fixes
* [sdoc] Fix images are lost after restoring a sdoc file from trash


### 13.0.9 beta (2025-08-28)

* [metadata] Edit and add location information for photos
* [metadata] Videos cannot be displayed directly in detail panel
* [metadata] UI improvement for table view
* [UI] Polishing the dark mode
* Add Excalidraw
* Enable editing of SeaDoc or Markdown Documents via Sharing Link
* Support OnlyOffice Form building
* Update Django to version 5.2
* Fix reading MySQL environment variables in go fileserver
* Fix an error in database upgrade script
* Fix seadoc reports an error when accessing history
* Fix a XSS issue in upload link


### 13.0.8 beta (2025-07-30)

* Add basic support for dark mode, it will be polished in a later version
* Support set order for folders/files in navigation panel
* Improve image view page by supporting dragging view position and zoom in/zoom out
* Fix login with WebDAV password
* Support searching in trash bin
* Fix docker image of thumbnail server
* Some other UI fixes

### 13.0.7 beta (2025-07-14)

Deploying Seafile with binary package is no longer supported for community edition. We recommend you to migrate your existing Seafile deployment to docker based.

* SeaDoc: SeaDoc is now version 2.0
* Thumbnail server: A new thumbnail server component is added to improve performance for thumbnail generating and support thumbnail for videos
* Metadata server: A new metadata server component is available to manage extended file properties
* Notification server: The web interface now support real-time update when other people add or remove files if notification-server is enabled
* Database and memcache configurations are added to `.env`, it is recommended to use environment variables to config database and memcache
* Redis is recommended to be used as memcache server
* For security reason, WebDAV no longer support login with LDAP account, the user with LDAP account must generate a WebDAV token at the profile page
* [File tags] The old file tags feature can no longer be used, the interface provide an upgrade notice for migrate the data to the new file tags feature
* Some UI updated and fixes


## 12.0

**Upgrade**

Please check our document for how to upgrade to [12.0](../upgrade/upgrade_notes_for_12.0.x.md)

### 12.0.14 (2025-05-29)

* [fix] Fix two stored XSS issues (In rendering terms and conditions and in institution admin page)
* Add S/MIME support for emails
* [fix] Fix a UI bug in "share admin -> share links"
* [fix] Fix a bug in rendering "system admin -> users"
* Update translations

### 12.0.11 (2025-03-19)

* [fix] Fix a stored XSS issue
* [fix] Do not show Wiki libraries in clients and WebDAV
* Add library name in "share admin -> folders"
* [fix] Fix set of library history keep days
* [fix] Fix support for enforcing Two-Factor Authentication


### 12.0.10 (2025-03-03)

* [fix] Fix seaf-fuse support
* [fix] Fix "save to" button in external link
* [fix] Search library text in system admin page is incorrect  
* [fix] Fix library path displays issue in read-only shared
* Improve icons for creating Wiki and inviting links
* [fix] Fix a bug in Collabora integration: Interface in English despite Seafile interface in French

### 12.0.9 (2025-02-14)

* Improve consistency of format of logs
* [fix] Thumbnail server does not preserve ICC profiles, resulting in washed out colors
* [fix] A few small UI fixes and improvements


### 12.0.7 (2025-01-08)

* [fix] Some UI improvements and fixes
* [Wiki] Some UI improvements and fixes
* Clean inconsistent format in logs
* [fix] Fix WebDAV upload "0 Byte Files" issue

### 12.0.6 beta (2024-12-19)

* [fix] Fix seafevents not started
* Update translation
* Some UI fixes

### 12.0.4 beta (2024-11-21)

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
* Support online GC 


## 11.0

**Upgrade**

Please check our document for how to upgrade to [11.0](../upgrade/upgrade_notes_for_11.0.x.md)


### 11.0.12 (2024-08-14)

* Update translations

### 11.0.11 (2024-08-07)

* [fix] [important] Fix a security bug in WebDAV


### 11.0.10 (2024-08-06)

Seafile

* [fix] Use user's name in reset password email instead of internal ID
* [fix] Fix SeaDoc incompatible with go fileserver
* [fix] Fix invited guest cannot be revoke
* [fix] Fix keyerror when using backup code in two-factor auth
* [fix] Do not print warning in seaf-server.log when a LDAP user login


### 11.0.9 (2024-05-30)

Seafile

* Improve accessibility
* Support open ODG files with LibreOffice (Collabora Online)
* Support showing last modified time for folders in WebDAV
* [fix] Fix "remember me" in 2FA

SDoc editor 0.8

* Support automatically adjusting table width to fit page width
* Improve comments feature
* Improve documents shown on mobile
* More UI fixes and improvements


### 11.0.8 (2024-04-22)

* Fix a bug in generating sharing links

### 11.0.7 (2024-04-18)

Seafile

* Support log rotate for golang file server and notification server
* Update UI for upload link
* Support OnlyOffice version feature
* Show files' original path in the trash

SDoc editor 0.7

* Improve file comment feature
* Improve file diff showing
* Support print a document
* Improve table editing


### 11.0.6 (2024-03-14)

Seafile

* Fix column view is limited to 100 items
* Fix LDAP user login for WebDAV
* Remove the configuration item "ENABLE_FILE_COMMENT" as it is no longer needed
* Enable copy/move files between encrypted and non-encrypted libraries
* Forbid creating libraries with Emoji in name
* Fix some letters in the file name do not fit in height in some dialogs
* Some other UI fixes and improvements
* Fix a performance issue in sending file updates report

SDoc editor 0.6

* Support convert docx file to sdoc file
* Support Markdown format in comments
* Support drag rows/columns in table element and other improvements for table elements
* Other UI fixes and improvements

### 11.0.5 (2024-01-31)

Seafile

* Fix captcha showing issue


### 11.0.4 (2024-01-26)

Seafile

* Add move dir/file, copy dir/file, delete dir/file, rename dir/file APIs for library token based API
* Support preview of JFIF image format
* Use user's current language when create Office files in OnlyOffice
* More UI fixes and improvements

SDoc editor 0.5

* Support convert sdoc to docx format
* Improve UX for internal document linking
* Support icons in callout element
* Add Search/Replace feature
* More UI fixes and improvements

### 11.0.3 (2023-12-19)

Seafile

* Use file type icon as favicon for file preview pages
* More UI fixes and improvements
* [fix] seafdav.conf workers parameters does not to be used

SDoc editor 0.4

* Add templates with predefined stypes for tables
* Support combining table cells
* Add callout element
* Support drag and drop elements
* Improve file comments
* Improve file history display by grouping history items
* More UI fixes and improvements


### 11.0.2 (2023-11-20)

Seafile

* Update folder icon
* The activities page support filter records based on modifiers
* Add indicator for folders that has been shared out
* Some small UI fixes
* [fix] Fix some small bugs in golang file server
* [fix] Fix LDAP users cannot login via desktop client
* Add login ID field when exporting users in admin panel

SDoc editor 0.3

* Improved file comment feature
* Improved revision and review feature
* Support file tags
* Better support editing list/table/code/image element
* Support getting link for header element


### 11.0.1 beta (2023-10-18)

Seafile

* Improve UI of notifications dialog
* Improve UI of dropdown menus for libraries and files
* Improve UI for file tags
* Remove file comment features as they are used very little

SDoc editor 0.2

* All major elements like tables, lists are now supported
* The editor is basically stable to use. Everyone is welcome to try it out.

### 11.0.0 beta (cancelled)

* Use a virtual ID to identify a user
* LDAP login update
* SAML/Shibboleth/OAuth login update
* Update Django to version 4.2
* Update SQLAlchemy to version 2.x
* Improve UI of PDF view page
* Add seafevents component


## 10.0

**Upgrade**

Please check our document for how to upgrade to [10.0](../upgrade/upgrade_notes_for_10.0.x.md).

### 10.0.1 (2023-04-11)

* Support generating multiple share links for a file and a folder
* [fix] Fix a bug in golang file server when zip-downloading a folder in encrypted library
* [fix] Fix a bug in upgrading script when there is no configuration for Nginx
* Video player support changing playback speed
* [fix] Fix a few bugs in notification server


### 10.0.0 beta (2023-02-22)

* Update Python dependencies and support Ubuntu 22.04 and Debian 11
* Add a new notification server (document will be provided later)
* Update WebDAV password to use one-way hash
* Remove SQL sub queries to improve SQL query speed in seaf-server
* Show number of shared users/groups if any when deleting a folder
* Support online playing of .wav files


## 9.0

### 9.0.10 (2022-12-07)

* Admin list all users API now return last_login and last_access_time
* [fix] Fix a bug in displaying markdown file in sharing link
* [fix] Fix notification mails are sent to inactive users
* [fix] Fix viewing a file in an old snapshot leads to server hickup
* [fix] Fix an HTTP/500 "Internal server error" when the user sets password containing non-latin characters for sharing links
* [fix] Fix "document convertion failed” error visiting a shared document with preview only
* [fix] Fix memory leak when block cache is enabled
* Enable 'zoom in/out by pinch' for mobile in pdf file view page
* [fix] Prevent system admin creating libraries with invalid name in admin panel
* Improve performance in golang file server

### 9.0.9 (2022-09-22)

* [fix] Fix a memory leak problem
* [fix] Fix a bug that will lead to seaf-fsck crash
* [fix] Fix a stored XSS problem for library names
* [fix] Disable open a file in OnlyOffice for encrypted libraries when open from trash

### 9.0.8 (2022-09-07)

* [fix] Fix a UI bug in sending sharing link by email
* [fix] Markdown editor does not properly filter javscript URIs from the href attribute, which results in stored XSS
* [fix] Fix a bug in OCM sharing
* [fix] Fix a bug in un-linking a device in admin panel
* [fix] Adding URL security check in `/accounts/login` redirect by `?next=` parameter


### 9.0.7 (2022-08-10)

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


### 9.0.6 (2022-06-22)

* Show table of contents in Markdown sharing link
* Check if quota exceeded before file uploading in upload sharing link
* Support import group member via contact email


### 9.0.5 (2022-05-13)

* [fix] Fix a bug that sometimes a shared subfolder is unshared automatically by database access error
* [fix] Fix a bug in work with Python 3.10+
* [fix] Fix a bug in smart link redict to the file page
* [fix] Fix a UI bug when drag and drop a file
* [fix] Fix zip downloading a folder not having .zip suffix when using golang file server
* Improve UI for file tags
* Show file tags in sharing links
* Improve UI of file comments
* [fix] Fix permission check in deleting/editing a file comment
* Remove the feature of related files as it is not used
* Support editing of expire time for sharing links
* Improve SQL performance when deleting a library
* Show ISO date and time in file history page instead of showing relative time
* Add "Visit related snapshot" in the dropdown menu of an entry in file history

### 9.0.4 (2022-02-21)

* [fix] Fix a UI bug in file moving/copying dialog
* Support admin enforcing a strong password in WebDAV secret
* [fix] Fix WebDAV error while filename contains special chars

### 9.0.3 (2022-02-15)

* Enable deleting fs objects in GC
* Users can save files or folders in shared folder link to their own libraries
* [fix] Fix language in calendar UI component used when picking date in sharing dialog
* [fix] Fix markdown file print
* Improve UI of file moving/copying dialog to show folders with long names
* Expand to the current folder when open file moving/copying dialog
* [fix] Fix a bug in golang file server log rotate support
* [fix] Fix a bug in folder download-link and try to download files/folders as zip using golang file server
* Show current number of shared users and groups when deleting a library
* [fix] Fix support for customizing of favicon
* [fix] Fix printing support of Markdown file
* [fix] Fix zip-downloading in sharing links when golang file server is used

### 9.0.2 (2021-12-10)

* Fix OnlyOffice/Collabora integration when golang http server
* Enable showing password for encrypted sharing links

### 9.0.1 beta (2021-11-20)

* Fix OnlyOffice integration

### 9.0.0 beta (2021-11-11)

* Upgrade Django to 3.2
* Rewrite HTTP service in seaf-server with golang and move it to a separate component (turn off by default)
* Upgrade PDFjs to new version, support viewing of password protected PDF
* Use database to store OnlyOffice cache keys
* Supporting converting files like doc to docx using OnlyOffice for online editing
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


## 8.0

Please check our document for how to upgrade to [8.0](../upgrade/upgrade_notes_for_8.0.x.md).

### 8.0.8 (2021/12/06)

* [fix] Fix a security issue in token check in file syncing
* [fix] Fix URL encoding problem when view a file's history for files with special characters in file name.

### 8.0.7 (2021/08/09)

* Improve performance for listing deleted files in trash
* [fix] Fix FORCE_PASSWORD_CHANGE does not force the new user to change the password if the user is added by admin
* [fix] Fix setting a webdav password when 2FA enabled
* [fix] Fix search in a shared sub-folder
* [fix] Remove watermark shown in Collabora integration

### 8.0.6 (2021/07/14)

* [fix] Fix a cache problem in OnlyOffice integration when automatically saving is used
* Admin can delete devices in the admin panel
* [fix] Once a user quota have been set, I can not set it back to 0 (unlimited)
* [fix] Fix collabora integration
* User's can manage his/her Web API Auth Token in profile page
* A group admin can now leave a group
* [fix] Fix Lazy loading / pagination breaks image viewer (https://forum.seafile.com/t/lazy-loading-pagination-breaks-image-viewer/14655)

### 8.0.5 (2021/05/14)

* Add "Open via Client" button in file view page
* Add an admin API to change a user's email
* [fix] Fix a bug in seaf-gc
* [fix] Fix wrong links of files in library history details dialog
* [fix] Fix deleting libraries without owner in admin panel
* [fix] Fix a XSS problem in notification
* [fix] Fix JWT token support in OnlyOffice integration
* [fix] Fix sometimes webdav cache files are not cleaned

### 8.0.4 (2021/03/25)

* [fix] Fix a permission denial problem in OCM, if a library is shared to more than two users in another server
* [fix] Fix a bug in password protected upload link
* [fix] Fix running seafile-controller with "seafile-controller -t" 
* [fix] Fix user search in "Transfering a library" dialog
* Add "Open via Client" button in file view page
* Add an admin API to change a user's email

### 8.0.3 (2021/01/27)

* Users can use secret key to access WebDAV after enabling two-factor authentication
* Fix fuse
* Fix navigation side panel in public library on mobile
* Improve UI of file search
* Add QR code for sharing links
* Fix OnlyOffice integration when JWT is enabled

### 8.0.2 (2021/01/04)

* Fix LDAP problem
* Fix upgrade script

### 8.0.1 beta (2021/01/04)

* Update translations for help pages
* Add missing upgrade script
* Add open cloud mesh feature

### 8.0.0 beta (2020/11/27)

* Support searching file in a library
* Rewrite upload link page to use React technology
* Improve GC performance
* Upgrade Django to 2.2 version
* Remove ccnet-server component
* Update help page
* Release v4 encrypted library format to enhance security for v3 encrypted format



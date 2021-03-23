# SeaDrive Client Changelog

### 2.0.13 (2021/3/23)

* \[Win] Fix crash issue when multiple accounts with the same name are used
* \[Win] Improve download speed for large files
* \[Win] Improvement and bug fixes for context menu
* \[Win] A few UI fixes
* \[Win] Support preconfigure cache folder location
* \[Mac] Fix bug for cleaning cached file/folder

### 2.0.12 (2021/1/29)

* \[Win] Fix crash issue when repeatedly download and cancel download some files
* \[Win] Fix some cases for creating unexpected conflict files
* \[Win] Automatically download new files for pinned folders
* Don't create commits for read-only libraries. Avoid unexpected permission errors.
* \[Win] Add user names to the shortcut in File Explorer
* \[Win] Pop notifications when files are created in a category folder
* \[Win] Make the columns in transfer progress dialog resizable

### 2.0.10 (2020/12/29)

* \[Win] Add context menu
* \[Mac] Support Apple Silicon M1 CPU
* \[Linux] Unmount on exit

### 2.0.9 (2020/11/20)

* \[Mac] Fix failure to load kernel extension on macOS 11 Big Sur

### 2.0.8 (2020/11/14)

* \[Mac] Support macOS 11
* \[Win] Fix moving multiple files/folders across different folders

### 2.0.7 (2020/10/31)

* \[Win] Avoid unintended file deletions when removing seafile account
* \[Mac] Fix some application compatibility issues caused by extended file attributes handling

### 2.0.6 (2020/09/24)

* \[Win] Remove invalid characters from sync root folder name
* \[Win] Increase request timeout for rename library, delete library, create library, move folders
* \[Win] Avoid creating redundant sync root folders on restart
* \[Win] Support pre-configuration registry keys

### 1.0.12 (2020/08/25)

* Fix occasional "permission denied" error when syncing a library

### 2.0.5 (2020/07/30)

* Fix occasional "permission denied" error when syncing a library
* \[Win] Remove explorer shortcut when uninstall SeaDrive or change cache folder location

### 2.0.4 (2020/07/13)

* \[Win] Use username for cache folder name instead of a hash value
* \[Win] Retry download files when pinning a folder
* \[Win] Retry rename category folder when switching language
* \[Win] Only allow install on Windows 10 1709 or later
* \[Mac] Disable "search in Finder" option
* Fix tray icon sync error status

### 2.0.3 (2020/06/17)

* \[Win] Fix crash on Windows 10 1709 - 1803
* \[Win] Show SeaDrive shortcut when opening files in 32-bit applications (e.g. Word)
* \[Win] Avoid creating unnecessary conflict files
* \[Win] Improve error message of opening placeholder files when SeaDrive is not running
* \[Win] Support removing account information when uninstall

### 2.0.2 (2020/05/23)

* \[Mac] Support syncing encrypted libraries
* \[Win] Support change cache location
* \[Win] Improve account switching behaviors
* \[Win] Other bug fixes

### 2.0.1 for Windows (2020/04/13)

* Fix issues when switching languages
* Fix issues for legacy Windows "8.3 format" paths
* Improve speed of creating placeholders
* Don't add SeaDrive cache folder to Windows search index
* Use short hash instead of "servername_account" for cache folder name
* Prevent the old Explorer extension from calling new SeaDrive (avoiding high CPU usage)
* Fix small issues in encrypted library support
* Change installation location from "Seafile Ltd" to "Seafile"
* Add SeaDrive entry to Windows start menu
* Change "seadrive" to "SeaDrive" in Explorer navigation pane
* Fix SSO re-login failure

### 2.0.0 for Windows (2020/03/20)

* Use Windows 10 native API to implement the virtual drive
* Support syncing encrypted libraries

### 1.0.11 (2020/02/07)

* Fix a bug that logout and login will lead to file deletion
* \[mac] Fix a bug in SSO

### 1.0.10 (2019/12/23)

* Fix a bug that sometimes SeaDrive is empty when network unavailable
* Fix generating too many tokens when library downloading failed
* Fix sometimes files should be ignored are uploaded
* Automatically re-sync a library if local metadata is broken
* \[mac] Add support for MacOS 10.15
* \[mac] Drop support for MacOS 10.12

### 1.0.8 (2019/11/05)

* Support French and Germany language for top level folder name
* Fix a compatible issue with Excel
* Fix a problem in cleaning local cache
* Support delete library in category My Libraries
* Ignore .fuse_hidden file in Mac
* Rotate seadrive.log

### 1.0.7 (2019/08/21)

* \[mac] Improve finder extension

### 1.0.6 (2019/07/01)

* \[fix, win] Fix a problem when uninstall or upgrade the drive client when the client is running.
* \[fix] Fix a crash problem when file path containing invalid character

### 1.0.5 (2019/06/11)

* \[fix] Fix lots of "Creating partial commit after adding" in the log
* \[fix] Fix permission at the client is wrong when a library shared to different groups with different permissions
* \[fix] Don't show libraries with online preview or online read-write permission
* \[mac] Add Mac Finder preview plugin to prevent automatically downloading of files

### 1.0.4 (2019/04/23)

* \[fix] Fix file locking
* \[fix] Fix support of detecting pro edition when first time login
* Support Kerberos authentication

### 1.0.3 (2019/03/18)

* \[fix] Fix copy folders with properties into SeaDrive
* \[fix] Fix a possible crash bug when listing libraries

### 1.0.1 (2019/01/14)

* Update included Dokany drive
* Improve notification when user try to delete a library in the client
* \[fix] Fix getting internal link for folders
* \[fix] Fix problem after changing the cache directory
* \[fix] Fix support for guest users that have no storage capacity
* \[fix] Fix timeout when loading a library with a lot of files

### 1.0.0 (2018/11/19)

* \[fix] Allow a guest user to copy files into shared library
* Support pause sync
* \[win] Add option to only allow current user to view the virtual disk
* \[win] Don't let the Windows to search into the internal cache folder
* \[win] Install the explorer extension to system path to allow multiple users to use the extension
* \[mac] Add option to allow search in Finder (disabled by default)
* \[mac] Update kernel drive to support Mac Mojave
* \[mac] Support office file automatically lock

### 0.9.5 (2018/09/10)

* \[fix, win] Fix support for some SSL CA
* Redirect to https if user accidentally input server's address with http but the server is actually use http
* \[fix, win] Show a tooltip that the Windows system maybe rebooted during upgrading drive client
* \[fix, mac] Fix permission problems during installation on Mac 10.13+

### 0.9.4 (2018/08/18)

* \[win] No longer depends on .Net framework
* \[mac] Support file search in Finder
* \[win] Fix loading of HTTPS certifications

### 0.9.3 (2018/06/19)

* \[win] Show syncing status at the top level folders
* \[fix] Fix sometimes logout/login lead to empty drive folder
* Support change cache folder
* Add "open file/open folder" in search window
* Set automatically login to true in SSO mode
* \[mac] Fix compatibility with AirDrop

### 0.9.2 (2018/05/05)

* Fix a bug that causing SeaDrive crash

### 0.9.1 (2018/04/24)

* Fix a bug that causing crash when file search menu is clicked

### 0.9.0 (2018/04/24)

* Libraries are displayed under three folders "My Libraries", "Group Libraries", "Shared libraries"
* \[fix] Fix a bug in cleaning cache
* \[win] Update the kernel drive
* Improve syncing notification messages
* \[mac] Include the kernel drive with the SeaDrive package
* \[mac] Add Finder sidebar shortcut
* Add file search

### 0.8.6 (2018/03/19)

* \[fix] Fix compatibility with Visio and other applications by implementing a missing system API

### 0.8.5 (2018/01/03)

* \[fix] Fix SeaDrive over RDP in Windows 10/7
* \[fix] Fix SeaDrive shell extension memory leak
* \[fix] Fix duplicated folder/files shown in Finder.app (macOS)
* \[fix] Fix file cache status icon for MacOS

### 0.8.4 (2017/12/01)

* \[fix] Fix Word/Excel files can't be saved in Windows 10
* Add "download" context menu to explicitly download a file
* Change "Shibboleth" to "Single Sign On"

### 0.8.3 (2017/11/24)

* \[fix] Fix deleted folder recreated issue
* Improve UI of downloading/uploading list dialog

### 0.8.1 (2017/11/03)

* Use "REMOVABLE" when mount the drive disk
* Prevent creating "System Volume Information"
* Some UI fixes

### 0.8.0 (2017/09/16)

* \[fix] Reuse old drive letter after SeaDrive crash
* \[fix] Fix rename library back to old name when it is changed in the server
* \[fix] Fix sometimes network can not reconnected after network down
* Change default block size to 8MB
* Make auto-login as default
* Remount SeaDrive when it is unmounted after Windows hibernate

### 0.7.1 (2017/06/23)

* \[fix] Fix a bug that causing client crash

### 0.7.0 (2017/06/07)

* Add support for multi-users using SeaDrive on a single desktop. But different users must choose different drive letters.
* Improve write performance
* \[fix] When a non-cached file is locked in the server, the "lock" icon will be shown instead of the "cloud" icon.
* Add "automatically login" option in login dialog
* Add file transfer status dialog.

### 0.6.2 (2017/04/22)

* \[fix] Fix after moving a file to a newly created sub folder, the file reappear when logout and login
* Refresh current folder and the destination folder after moving files from one library to another library
* \[fix] Fix file locking not work
* \[fix] Fix sometimes files can't be saved

### 0.6.1 (2017/03/27)

* \[fix] Don't show a popup notification to state that a file can't be created in `S:` because a few programs will automatically try to create files in `S:`

### 0.6.0 (2017/03/25)

* Improve syncing status icons
* Show error in the interface when there are syncing errors
* Don't show rorate icon when downloading/uploading metadata
* \[fix] Don't download files when the network is not connected

### 0.5.2 (2017/03/09)

* \[fix] Rename a non-cached folder or file will lead to sync error.

### 0.5.1 (2017/02/16)

* \[fix] Fix copying exe files to SeaDrive on Win 7 will freeze the explorer
* The mounted drive is only visible to the current user
* Add popup notification when syncing is done
* \[fix] Fix any change in the settings leads to a drive letter change

### 0.5.0 (2017/01/18)

* Improve stability
* Support file locking
* Support sub-folder permission
* \[fix] Fix 1TB limitation
* User can choose disk letter in settings dialog
* Support remote wipe
* \[fix] Use proxy server when login
* Click system tray icon open SeaDrive folder
* Support application auto-upgrade

### 0.4.2 (2016/12/16)

* \[fix] Fix SeaDrive initialization error during Windows startup

### 0.4.1 (2016/11/07)

* \[fix] Fix a bug that lead to empty S: drive after installation.

### 0.4.0 (2016/11/05)

* \[fix] Fix a bug that leads to generation of conflict files when editing
* Add translations
* Update included Dokany library to 1.0
* Don't show encrypted libraries even in command line
* Show permission error when copy a file to the root
* Show permission error when try to modify a read-only folder
* Show permission error when try to delete a folder in the root folder

### 0.3.1 (2016/10/22)

* Fix link for license terms
* Use new system tray icon
* Add notification for cross-libraries file move

### 0.3.0 (2016/10/14)

* Support selecting Drive letter
* Don't create folders like msiS50.tmp on Windows
* \[fix] Fix cache size limit settings
* Correctly show the storage space if the space is unlimited on the server side.

### 0.2.0 (2016/09/15)

* Add shibboleth support
* Show a dialog notify the client is downloading file list from the server during initialisation
* Show transfer rate
* \[fix] Fix a bug that lead to the file modification time to be empty
* \[fix] Fix a bug that lead to files not be uploaded

### 0.1.0 (2016/09/02)

* Initial release

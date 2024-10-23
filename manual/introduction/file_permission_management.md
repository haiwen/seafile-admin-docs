# File permission management

Seafile manages files using libraries. Every library has an owner, who can share the library to other users or share it with groups. The sharing can be read-only or read-write.

## Read-only syncing

Read-only libraries can be synced to local desktop. The modifications at the client will not be synced back. If a user has modified some file contents, he can use "resync" to revert the modifications.


## Cascading permission/Sub-folder permissions (Pro edition)

Sharing controls whether a user or group can see a library, while sub-folder permissions are used to modify permissions on specific folders.

Supposing you share a library as read-only to a group and then want specific sub-folders to be read-write for a few users, you can set read-write permissions on sub-folders for some users and groups.

Note:

* Setting sub-folder permission for a user without sharing the folder or parent folder to that user will have no effect.
* Sharing a library read-only to a user and then sharing a sub-folder read-write to that user will lead to two shared items for that user. This is going to cause confusion. Use sub-folder permissions instead.

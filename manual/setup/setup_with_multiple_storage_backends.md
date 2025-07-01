# Multiple Storage Backend

There are some use cases that supporting multiple storage backends in Seafile server is needed. Such as:

1. Store different types of files into different storage backends:
    - Normal files can be stored in primary storage (e.g., local disks)
    - Archived files can be stored in cold storage (tapes or other backup systems)

2. Combine multiple storage backends to extend storage scalability:
    - A single NFS volume may be limited by size
    - A single S3 bucket of Ceph RGW may suffer performance decrease when the number of objects become very large.

!!! note "About data of library"
    - The library data in Seafile server are spreaded into multiple storage backends in the unit of libraries. 
    - All the data in a library will be located in the same storage backend. 
    - The mapping from library to its storage backend is stored in a database table. 
    - Different mapping policies can be chosen based on the use case.

## How to engage multiple storage backend

To use this feature, you need to:

1. Set `SEAF_SERVER_STORAGE_TYPE=multiple` in `.env`.
2. Define [storage classes](#exmaple-of-storage-classes-file) in `seafile.conf`.
3. Enable multiple backend feature in *Seahub* and choose a mapping policy.

## Seafile Configuration

As Seafile server before 6.3 version doesn't support multiple storage classes, you have to explicitly enable this new feature and define storage classes with a different syntax than how we define storage backend before.

By default, Seafile dose not enable multiple storage classes. So, you have to create a configuration file for storage classes and specify it and enable the feature in `seafile.conf`:

1. Create the storage classes file:

    ```sh
    nano /opt/seafile-date/seafile/conf
    ```

    For the example of this file, please refer [next section](#exmaple-of-storage-classes-file)

2. Modify `seafile.conf`

    ```conf
    [storage]
    enable_storage_classes = true
    storage_classes_file = /shared/conf/seafile_storage_classes.json
    ```

    * `enable_storage_classes` ：If this is set to true, the storage class feature is enabled. You must define the storage classes in a **JSON** file provided in the next configuration option.
    * `storage_classes_file：Specifies` the path for the **JSON** file that contains the storage class definition.

    !!! tip 
        - Make sure you have added [memory cache configurations](../config/seafile-conf.md#cache-pro-edition-only) to `seafile.conf`
        - Due to the *Docker persistence strategy*, the path of `storage_classes_file` **in the *Seafile container*** is different from the host usually, so we suggest you put this file in to the Seafile's configurations directory, and use `/shared/conf` instead of `/opt/seafile-date/seafile/conf`. Otherwise you have to add another persistent volume mapping strategy in `seafile-server.yml`. If your Seafile server is not deployed with Docker, we still suggest you put this file into the Seafile configurations file directory.

## Exmaple of storage classes file

The storage classes JSON file is about **an array consist of objects**, for each defines a *storage class*. The fields in the definition corresponds to the information we need to specify for a ***storage class***:

| Variables | Descriptions |
|---|---|
| `storage_id` | A unique internal string ID used to identify the storage class. It is not visible to users. For example, "primary storage". |
| `name` | A user-visible name for the storage class. |
| `is_default` | Indicates whether this storage class is the default one. |
| `commits` | The storage used for storing commit objects for this class. |
| `fs` | The storage used for storing fs objects for this class. |
| `blocks` | The storage used for storing block objects for this class.  |

!!! note
    - `is_default` is effective in two cases: 
        1. When a user does not choose a mapping policy and can use this storage class for a library; 
        2. For other mapping policies, this option only takes effect when you have existing libraries before enabling the multiple storage backend feature, which will be automatically mapped to the default storage backend.
    - `commit`, `fs`, and `blocks` can be stored in different storages. This provides the most flexible way to define storage classes (e.g., a file system, *Ceph*, or *S3*.)

Here is an example, which uses local file system, S3 (default), Swift and Ceph at the same time.

```json
[
  {
    "storage_id": "hot_storage",
    "name": "Hot Storage",
    "is_default": true,
    "commits": {
      "backend": "s3",
      "bucket": "seafile-commits",
      "key": "<your key>",
      "key_id": "<your key id>"
    },
    "fs": {
      "backend": "s3",
      "bucket": "seafile-fs",
      "key": "<your key>",
      "key_id": "<your key id>"
    },
    "blocks": {
      "backend": "s3",
      "bucket": "seafile-blocks",
      "key": "<your key>",
      "key_id": "<your key id>"
    }
  },
  {
    "storage_id": "cold_storage",
    "name": "Cold Storage",
    "is_default": false,
    "fs": {
      "backend": "fs",
      "dir": "/share/seafile/seafile-data" // /opt/seafile/seafile-data for binary-install Seafile
    },
    "commits": {
      "backend": "fs",
      "dir": "/share/seafile/seafile-data"
    },
    "blocks": {
      "backend": "fs",
      "dir": "/share/seafile/seafile-data"
    }
  },
  {
    "storage_id": "swift_storage",
    "name": "Swift Storage",
    "fs": {
      "backend": "swift",
      "tenant": "<your tenant>",
      "user_name": "<your username>",
      "password": "<your password>",
      "container": "seafile-commits",
      "auth_host": "<Swift auth host>:<port, default 5000>",
      "auth_ver": "v2.0"
    },
    "commits": {
      "backend": "swift",
      "tenant": "<your tenant>",
      "user_name": "<your username>",
      "password": "<your password>",
      "container": "seafile-commits",
      "auth_host": "<Swift auth host>:<port, default 5000>",
      "auth_ver": "v2.0"
    },
    "blocks": {
      "backend": "swift",
      "tenant": "<your tenant>",
      "user_name": "<your username>",
      "password": "<your password>",
      "container": "seafile-commits",
      "auth_host": "<Swift auth host>:<port, default 5000>",
      "auth_ver": "v2.0",
      "region": "RegionTwo"
    }
  },
  {
    "storage_id": "ceph_storage",
    "name": "ceph Storage",
    "fs": {
      "backend": "ceph",
      "ceph_config": "/etc/ceph/ceph.conf",
      "pool": "seafile-fs"
    },
    "commits": {
      "backend": "ceph",
      "ceph_config": "/etc/ceph/ceph.conf",
      "pool": "seafile-commits"
    },
    "blocks": {
      "backend": "ceph",
      "ceph_config": "/etc/ceph/ceph.conf",
      "pool": "seafile-blocks"
    }
  }
]
```

!!! tip
    - As you may have seen, the `commits`, `fs` and `blocks` information syntax is similar to what is used in `[commit_object_backend]`, `[fs_object_backend]` and `[block_backend]` section of `seafile.conf` for a single backend storage. You can refer to the detailed syntax in the documentation for the storage you use (e.g., [S3 Storage](setup_with_s3.md) for S3).

    - If you use file system as storage for `fs`, `commits` or `blocks`, you must explicitly provide the path for the `seafile-data` directory. The objects will be stored in `storage/commits`, `storage/fs`, `storage/blocks` under this path. 

## Library Mapping Policies

Library mapping policies decide the storage class a library uses. Currently we provide 3 policies for 3 different use cases:

- ***User Chosen***
- ***Role-based Mapping***
- ***Library ID Based Mapping***


The storage class of a library is decided on creation and stored in a database table. The storage class of a library won't change if the mapping policy is changed later.

Before choosing your mapping policy, you need to enable the storage classes feature in seahub_settings.py:

```py
ENABLE_STORAGE_CLASSES = True
```

### User Chosen

This policy lets the users choose which storage class to use when creating a new library. The users can select any storage class that's been defined in the JSON file.

To use this policy, add following options in seahub_settings.py:

```py
STORAGE_CLASS_MAPPING_POLICY = 'USER_SELECT'
```

If you enable storage class support but don't explicitly set `STORAGE_CLASS_MAPPING_POLIICY` in seahub_settings.py, this policy is used by default.

### Role-based Mapping

Due to storage cost or management considerations, sometimes a system admin wants to make different type of users use different storage backends (or classes). You can configure a user's storage classes based on their roles.

A new option `storage_ids` is added to the role configuration in `seahub_settings.py` to assign storage classes to each role. If only one storage class is assigned to a role, the users with this role cannot choose storage class for libraries; otherwise, the users can choose a storage class if more than one class are assigned. If no storage class is assigned to a role, the default class specified in the JSON file will be used. 

Here are the sample options in seahub_settings.py to use this policy:

```py
ENABLE_STORAGE_CLASSES = True
STORAGE_CLASS_MAPPING_POLICY = 'ROLE_BASED'

ENABLED_ROLE_PERMISSIONS = {
    'default': {
        'can_add_repo': True,
        'can_add_group': True,
        'can_view_org': True,
        'can_use_global_address_book': True,
        'can_generate_share_link': True,
        'can_generate_upload_link': True,
        'can_invite_guest': True,
        'can_connect_with_android_clients': True,
        'can_connect_with_ios_clients': True,
        'can_connect_with_desktop_clients': True,
        'storage_ids': ['old_version_id', 'hot_storage', 'cold_storage', 'a_storage'],
    },
    'guest': {
        'can_add_repo': True,
        'can_add_group': False,
        'can_view_org': False,
        'can_use_global_address_book': False,
        'can_generate_share_link': False,
        'can_generate_upload_link': False,
        'can_invite_guest': False,
        'can_connect_with_android_clients': False,
        'can_connect_with_ios_clients': False,
        'can_connect_with_desktop_clients': False,
        'storage_ids': ['hot_storage', 'cold_storage'],
    },
}

```

### Library ID Based Mapping

This policy maps libraries to storage classes based on its library ID. The ID of a library is an UUID. In this way, the data in the system can be evenly distributed among the storage classes.

!!! note 
    This policy is not a designed to be a complete distributed storage solution. It doesn't handle automatic migration of library data between storage classes. If you need to add more storage classes to the configuration, existing libraries will stay in their original storage classes. New libraries can be distributed among the new storage classes (backends). You still have to plan about the total storage capacity of your system at the beginning.

To use this policy, you first add following options in seahub_settings.py:

```py
STORAGE_CLASS_MAPPING_POLICY = 'REPO_ID_MAPPING'
```

Then you can add option `for_new_library` to the backends which are expected to store new libraries in json file:

```json
[
    {
        "storage_id": "new_backend",
        "name": "New store",
        "for_new_library": true,
        "is_default": false,
        "fs": {
            "backend": "fs", 
            "dir": "/storage/seafile/new-data"
        },
        "commits": {
            "backend": "fs", 
            "dir": "/storage/seafile/new-data"
        },
        "blocks": {
            "backend": "fs", 
            "dir": "/storage/seafile/new-data"
        }
    }
]

```

## Multiple Storage Backend Data Migration

!!! warning "Migration from S3"

    Since version 11, when you migrate from S3 to other storage servers, you have to use V4 authentication protocol. This is because version 11 upgrades to Boto3 library, which fails to list objects from S3 when it's configured to use V2 authentication protocol.

Run the `migrate-repo.sh` script to migrate library data between different storage backends.

```sh
./migrate-repo.sh [repo_id] origin_storage_id destination_storage_id
```

* repo_id: migrated library id
* origin_storage_id: migrated origin storage id
* destination_storage_id: migrated destination storage id

repo_id is optional, if not specified, **all libraries will be migrated**.

!!! tip "Specify a path prefix"
    You can set the `OBJECT_LIST_FILE_PATH` environment variable to **specify a path prefix** to store the migrated object list **before** running the migration script

    For example:

    ```sh
    export OBJECT_LIST_FILE_PATH=/opt/test
    ```

    This will create three files in the specified path (/opt): 
    
    - `test_4c731e5c-f589-4eaa-889f-14c00d4893cb.fs`
    - `test_4c731e5c-f589-4eaa-889f-14c00d4893cb.commits` 
    - `test_4c731e5c-f589-4eaa-889f-14c00d4893cb.blocks`

    Setting the `OBJECT_LIST_FILE_PATH` environment variable has two purposes:

    1. If the migrated library is very large, you need to run the migration script multiple times. Setting this environment variable can skip the previously migrated objects.
    2. After the migration is complete, if you need to delete the objects in the origin storage, you must set this environment variable.

### Delete All Objects In a Library In The Specified Storage Backend

Run the `remove-objs.sh` script (before migration, you need to set the OBJECT_LIST_FILE_PATH environment variable) to delete all objects in a library in the specified storage backend.

```sh
./remove-objs.sh repo_id storage_id
```

# Roles and Permissions Support

You can add/edit roles and permission for users. A role is just a group of users with some pre-defined permissions, you can toggle user roles in user list page at admin panel. For most permissions, the meaning can be easily obtained from the variable name. The following is a further detailed introduction to some variables.

- `role_quota` is used to set quota for a certain role of users. For example, we can set the quota of employee to 100G by adding `'role_quota': '100g'`, and leave other role of users to the default quota.

    !!! tip "After set `role_quote`, it will take affect once a user with such a role loggin into Seafile. You can also manually change `seafile-db.RoleQuota`, if you want to see the effect immediately.

- `can_add_public_repo` is to set whether a role can create a public library, default is `False`. 

    !!! tip "Since version 11.0.9 pro, `can_share_repo` is added to limit users' ability to share a library"

    !!! warning "The `can_add_public_repo` option will not take effect if you configure global `CLOUD_MODE = True`"

- `storage_ids` permission is used for assigning storage backends to users with specific role. More details can be found in [multiple storage backends](../setup/setup_with_multiple_storage_backends.md).

- `upload_rate_limit` and `download_rate_limit` are added to limit upload and download speed for users with different roles.

    !!! note
        After configured the rate limit, run the following command in the `seafile-server-latest` directory to make the configuration take effect:

        ```sh
        ./seahub.sh python-env python3 seahub/manage.py set_user_role_upload_download_rate_limit
        ```

- `can_drag_drop_folder_to_sync`: allow or deny user to sync folder by draging and droping

- `can_export_files_via_mobile_client`: allow or deny user to export files in using mobile client

Seafile comes with two build-in roles `default` and `guest`, a default user is a normal user with permissions as followings:

```py
    'default': {
        'can_add_repo': True,
        'can_share_repo': True,
        'can_add_group': True,
        'can_view_org': True,
        'can_add_public_repo': False,
        'can_use_global_address_book': True,
        'can_generate_share_link': True,
        'can_generate_upload_link': True,
        'can_send_share_link_mail': True,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': True,
        'can_connect_with_android_clients': True,
        'can_connect_with_ios_clients': True,
        'can_connect_with_desktop_clients': True,
        'can_export_files_via_mobile_client': True,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': True,
        'upload_rate_limit': 0,  # unit: kb/s
        'download_rate_limit': 0,
    },
```

While a guest user can only read files/folders in the system, here are the permissions for a guest user:

```py
    'guest': {
        'can_add_repo': False,
        'can_share_repo': False,
        'can_add_group': False,
        'can_view_org': False,
        'can_add_public_repo': False,
        'can_use_global_address_book': False,
        'can_generate_share_link': False,
        'can_generate_upload_link': False,
        'can_send_share_link_mail': False,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': False,
        'can_connect_with_android_clients': False,
        'can_connect_with_ios_clients': False,
        'can_connect_with_desktop_clients': False,
        'can_export_files_via_mobile_client': False,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': False,
        'upload_rate_limit': 0,
        'download_rate_limit': 0,
    },
```

## Edit build-in roles

If you want to edit the permissions of build-in roles, e.g. default users can invite guest, guest users can view repos in organization, you can add following lines to `seahub_settings.py` with corresponding permissions set to `True`.

```py
ENABLED_ROLE_PERMISSIONS = {
    'default': {
        'can_add_repo': True,
        'can_share_repo': True,
        'can_add_group': True,
        'can_view_org': True,
        'can_add_public_repo': False,
        'can_use_global_address_book': True,
        'can_generate_share_link': True,
        'can_generate_upload_link': True,
        'can_send_share_link_mail': True,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': True,
        'can_connect_with_android_clients': True,
        'can_connect_with_ios_clients': True,
        'can_connect_with_desktop_clients': True,
        'can_export_files_via_mobile_client': True,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': True,
        'upload_rate_limit': 2000,  # unit: kb/s
        'download_rate_limit': 4000,
    },
    'guest': {
        'can_add_repo': False,
        'can_share_repo': False,
        'can_add_group': False,
        'can_view_org': False,
        'can_add_public_repo': False,
        'can_use_global_address_book': False,
        'can_generate_share_link': False,
        'can_generate_upload_link': False,
        'can_send_share_link_mail': False,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': False,
        'can_connect_with_android_clients': False,
        'can_connect_with_ios_clients': False,
        'can_connect_with_desktop_clients': False,
        'can_export_files_via_mobile_client': False,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': False,
        'upload_rate_limit': 100,
        'download_rate_limit': 200,
    }
}
```

### More about guest invitation feature

An user who has `can_invite_guest` permission can invite people outside of the organization as guest.

In order to use this feature, in addition to granting `can_invite_guest` permission to the user, add the  following line to `seahub_settings.py`,

```
ENABLE_GUEST_INVITATION = True

# invitation expire time
INVITATIONS_TOKEN_AGE = 72 # hours
```

After restarting, users who have `can_invite_guest` permission will see "Invite People" section at sidebar of home page.

Users can invite a guest user by providing his/her email address, system will email the invite link to the user.

!!! tip

    If you want to block certain email addresses for the invitation, you can define a blacklist, e.g.

    ```
    INVITATION_ACCEPTER_BLACKLIST = ["a@a.com", "*@a-a-a.com", r".*@(foo|bar).com", ]
    ```

    After that, email address "a@a.com", any email address ends with "@a-a-a.com" and any email address ends with "@foo.com" or "@bar.com" will not be allowed.


## Add custom roles

If you want to add a new role and assign some users with this role, e.g. new role `employee` can invite guest and can create public library and have all other permissions a default user has, you can add following lines to `seahub_settings.py`

```py
ENABLED_ROLE_PERMISSIONS = {
    'default': {
        'can_add_repo': True,
        'can_share_repo': True,
        'can_add_group': True,
        'can_view_org': True,
        'can_add_public_repo': False,
        'can_use_global_address_book': True,
        'can_generate_share_link': True,
        'can_generate_upload_link': True,
        'can_send_share_link_mail': True,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': True,
        'can_connect_with_android_clients': True,
        'can_connect_with_ios_clients': True,
        'can_connect_with_desktop_clients': True,
        'can_export_files_via_mobile_client': True,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': True,
        'upload_rate_limit': 2000,  # unit: kb/s
        'download_rate_limit': 4000,
    },
    'guest': {
        'can_add_repo': False,
        'can_share_repo': False,
        'can_add_group': False,
        'can_view_org': False,
        'can_add_public_repo': False,
        'can_use_global_address_book': False,
        'can_generate_share_link': False,
        'can_generate_upload_link': False,
        'can_send_share_link_mail': False,
        'can_invite_guest': False,
        'can_drag_drop_folder_to_sync': False,
        'can_connect_with_android_clients': False,
        'can_connect_with_ios_clients': False,
        'can_connect_with_desktop_clients': False,
        'can_export_files_via_mobile_client': False,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': False,
        'upload_rate_limit': 100,
        'download_rate_limit': 200,
    },
    'employee': {
        'can_add_repo': True,
        'can_share_repo': True,
        'can_add_group': True,
        'can_view_org': True,
        'can_add_public_repo': True,
        'can_use_global_address_book': True,
        'can_generate_share_link': True,
        'can_generate_upload_link': True,
        'can_send_share_link_mail': True,
        'can_invite_guest': True,
        'can_drag_drop_folder_to_sync': True,
        'can_connect_with_android_clients': True,
        'can_connect_with_ios_clients': True,
        'can_connect_with_desktop_clients': True,
        'can_export_files_via_mobile_client': True,
        'storage_ids': [],
        'role_quota': '',
        'can_publish_repo': True,
        'upload_rate_limit': 500,
        'download_rate_limit': 800,
    },
}
```

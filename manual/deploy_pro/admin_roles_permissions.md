# Roles and Permissions Support

Starting from version 6.2.2, you can add/edit roles and permission for administrators. Seafile has four build-in admin roles:

 1. default_admin, has all permissions.

 1. system_admin, can only view system info and config system.

 1. daily_admin, can only view system info, view statistic, manage library/user/group, view user log.

 1. audit_admin, can only view system info and admin log.

All administrators will have `default_admin` role with all permissions by default. If you set an administrator to some other admin role, the administrator will **only have the permissions you configured to `True`**.

Seafile supports eight permissions for now,  its configuration is very like common user role, you can custom it by adding the following settings to `seahub_settings.py`.

```
ENABLED_ADMIN_ROLE_PERMISSIONS = {
    'system_admin': {
        'can_view_system_info': True,
        'can_config_system': True,
    },
    'daily_admin': {
        'can_view_system_info': True,
        'can_view_statistic': True,
        'can_manage_library': True,
        'can_manage_user': True,
        'can_manage_group': True,
        'can_view_user_log': True,
    },
    'audit_admin': {
        'can_view_system_info': True,
        'can_view_admin_log': True,
    },
    'custom_admin': {
        'can_view_system_info': True,
        'can_config_system': True,
        'can_view_statistic': True,
        'can_manage_library': True,
        'can_manage_user': True,
        'can_manage_group': True,
        'can_view_user_log': True,
        'can_view_admin_log': True,
    },
}
```

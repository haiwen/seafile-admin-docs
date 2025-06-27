# Multiple Organization/Institution User Management

Starting from version 5.1, you can add institutions into Seafile and assign users into institutions. Each institution can have one or more administrators. This feature is to ease user administration when multiple organizations (universities) share a single Seafile instance. Unlike multi-tenancy, the users are not-isolated. A user from one institution can share files with another institution.

## Turn on the feature

In `seahub_settings.py`, add `MULTI_INSTITUTION = True` to enable multi-institution feature, and add

```py
    EXTRA_MIDDLEWARE += (
        'seahub.institutions.middleware.InstitutionMiddleware',
    )
```

!!! tip "Please replease `+=` to `=` if `EXTRA_MIDDLEWARE` is not defined"

## Add institutions and institution admins

After restarting Seafile, a system admin can add institutions by adding institution name in admin panel. He can also click into an institution, which will list all users whose `profile.institution` match the name.

## Assign users to institutions

If you are using Shibboleth, you can map a Shibboleth attribute into institution. For example, the following configuration maps organization attribute to institution.

```
SHIBBOLETH_ATTRIBUTE_MAP = {
    "givenname": (False, "givenname"),
    "sn": (False, "surname"),
    "mail": (False, "contact_email"),
    "organization": (False, "institution"),
}
```

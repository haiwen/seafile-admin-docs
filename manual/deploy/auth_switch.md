# Switch authentication type

Seafile Server supports the following external authentication types:

* [LDAP (Auth and Sync)](./ldap_in_11.0.md)
* [OAuth](./oauth.md)
* [Shibboleth](./shibboleth_config_v6.3.md)
* [SAML](../deploy_pro/saml2_in_10.0.md)
* [CAS](../deploy_pro/cas.md)

Since 11.0 version, switching between the types is possible, but any switch requires modifications of Seafile's databases.

!!! note

    Before manually manipulating your database, make a database backup, so you can restore your system if anything goes wrong!

See more about [make a database backup](../maintain/backup_recovery.md).

## Migrating from local user database to external authentication

As an organisation grows and its IT infrastructure matures, the migration from local authentication to external authentication like LDAP, SAML, OAUTH is common requirement. Fortunately, the switch is comparatively simple. 

### General procedure

1. Configure and test the desired external authentication. Note the name of the `provider` you use in the config file. The user to be migrated should already be able to log in with this new authentication type, but he will be created as a new user with a new unique identifier, so he will not have access to his existing libraries. Note the `uid` from the `social_auth_usersocialauth` table. Delete this new, still empty user again.

2. Determine the `xxx@auth.local` address of the user to be migrated.

3. Replace the password hash with an exclamation mark.

4. Create a new entry in `social_auth_usersocialauth` with the `xxx@auth.local`, your `provider` and the `uid`.

The login with the password stored in the local database is not possible anymore. After logging in via external authentication, the user has access to all his previous libraries.

### Example

This example shows how to migrate the user with the username `12ae56789f1e4c8d8e1c31415867317c@auth.local` from local database authentication to OAuth. The OAuth authentication is configured in `seahub_settings.py` with the provider name `authentik-oauth`. The `uid` of the user inside the Identity Provider is `HR12345`.

This is what the database looks like before these commands must be executed:

```
mysql> select email,left(passwd,25) from EmailUser where email = '12ae56789f1e4c8d8e1c31415867317c@auth.local';
+---------------------------------------------+------------------------------+
| email                                       | left(passwd,25)              |
+---------------------------------------------+------------------------------+
| 12ae56789f1e4c8d8e1c31415867317c@auth.local | PBKDF2SHA256$10000$4cdda6... |
+---------------------------------------------+------------------------------+

mysql> update EmailUser set passwd = '!' where email = '12ae56789f1e4c8d8e1c31415867317c@auth.local';

mysql> insert into `social_auth_usersocialauth` (`username`, `provider`, `uid`, `extra_data`) values ('12ae56789f1e4c8d8e1c31415867317c@auth.local', 'authentik-oauth', 'HR12345', '');
```

__Note__: The `extra_data` field store user's information returned from the provider. For example, when integrating WeChat (a very common single sign-on method in China), some necessary information needs to be stored; for other providers, the `extra_data` field is usually an empty character. Since version 11.0.3-Pro, the default value of the `extra_data` field is `NULL`.

Afterwards the databases should look like this:

```
mysql> select email,passwd from EmailUser where email = '12ae56789f1e4c8d8e1c31415867317c@auth.local';
+---------------------------------------------+------- +
| email                                       | passwd |
+---------------------------------------------+--------+
| 12ae56789f1e4c8d8e1c31415867317c@auth.local | !      |
+---------------------------------------------+--------+

mysql> select username,provider,uid from social_auth_usersocialauth where username = '12ae56789f1e4c8d8e1c31415867317c@auth.local';
+---------------------------------------------+-----------------+---------+
| username                                    | provider        | uid     |
+---------------------------------------------+-----------------+---------+
| 12ae56789f1e4c8d8e1c31415867317c@auth.local | authentik-oauth | HR12345 |
+---------------------------------------------+-----------------+---------+
```

## Migrating from one external authentication to another

First configure the two external authentications and test them with a dummy user. Then, to migrate all the existing users you only need to make changes to the `social_auth_usersocialauth` table. No entries need to be deleted or created. You only need to modify the existing ones. The `xxx@auth.local` remains the same, you only need to replace the `provider` and the `uid`.

## Migrating from external authentication to local user database

First, delete the entry in the `social_auth_usersocialauth` table that belongs to the particular user.

Then you can reset the user's password, e.g. via the web interface. The user will be assigned a local password and from now on the authentication against the local database of Seafile will be done. 

More details about this option will follow soon.

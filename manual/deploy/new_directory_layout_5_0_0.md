# Config files location change in Seafile Server 5.0.0

Seafile server has various components, each of them has its own config files. These files used to be in different directories, which is inconvenient to manage.

This is the layout before Seafile Server 5.0.0:

```sh
└── seahub_settings.py
└── ccnet/
    └── ccnet.conf
└── seafile/
    └── seafile.conf
└── conf/
    └── seafdav.conf
└── pro-data/
    └── seafevents.conf # (professional edition only)
└── seafile-server-latest/
```

Since Seafile Server 5.0.0, all config files are moved to the **conf** folder:

```sh
└── conf/
    └── ccnet.conf
    └── seafile.conf
    └── seafdav.conf
    └── seahub_settings.py
    └── seafevents.conf # (professional edition only)
└── ccnet/
└── seafile/
└── pro-data/
```

This way, it's much easier to manage the configurations since all files can be found in the same place.

When you upgrading to seafile 5.0.0, the upgrade script would move these files to the central **conf/** folder for you.

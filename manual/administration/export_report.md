# Export Report

Since version 7.0.8 pro, Seafile provides commands to export reports via command line.

## Export User Traffic Report

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python seahub/manage.py export_user_traffic_report --date 201906

```

## Export User Storage Report

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python seahub/manage.py export_user_storage_report

```

## Export File Access Log

```
cd <install-path>/seafile-server-latest
./seahub.sh python-env python seahub/manage.py export_file_access_log --start-date 2019-06-01 --end-date 2019-07-01

```



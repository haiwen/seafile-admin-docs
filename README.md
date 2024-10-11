# Seafile Admin Docs

Manual for Seafile server

The web site: https://haiwen.github.io/seafile-admin-docs/

## Serve docs locally

These docs are built using 'mkdocs'.  Install the tooling by running:

```
pip3 install mkdocs-material mkdocs-awesome-pages-plugin mkdocs-material-extensions
```

Start up the development server by running `mkdocs serve` in the project root directory.  Browse at `http://127.0.0.1:8000/seafile-admin-docs/`.

## Publish version

Install `mike`

```shell
pip3 install mike
```

Publish a new version

```shell
mike deploy --push --update-aliases <version> latest
```

Set `latest` as default page

```shell
mike set-default --push latest
```

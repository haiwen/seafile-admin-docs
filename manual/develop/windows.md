# Windows

## Environment Setup

The following setups are required for building and packaging Sync Client on Windows:

* Visual Studio 2019
    * Desktop development with C++
        * MSVC v142
        * Windows 10 SDK (10.0.19041.0) (installed by default, not used)
        * Windows 10 SDK (10.0.18362.0)
    * Universal Windows Platform development
        * Windows 10 SDK (10.0.18362.0)
* Qt 6.5
    * MSVC 2019 64-bit
    * Qt 5 Compatibility Module
    * Qt Positioning
    * Qt Serial Port
    * Qt WebChannel
    * Qt WebEngine
* Qt VS Tools
* vcpkg (it is recommended to update to the latest version)
    * Run `vcpkg.exe integrate install` to integrates vcpkg with projects.
    * Note: Dependencies will be automatically downloaded and compiled when building VS projects.

## Building Sync Client

Following directory structures are expected when building Sync Client:

```
seafile-workspace/
seafile-workspace/libsearpc/
seafile-workspace/seafile/
seafile-workspace/seafile-client/
seafile-workspace/seafile-shell-ext/
```

The source code of these projects can be downloaded at [github.com/haiwen/libsearpc](https://github.com/haiwen/libsearpc), [github.com/haiwen/seafile](https://github.com/haiwen/seafile), [github.com/haiwen/seafile-client](https://github.com/haiwen/seafile-client), and [github.com/haiwen/seafile-shell-ext](https://github.com/haiwen/seafile-shell-ext).

### Building

Note: these commands are run in "x64 Native Tools Command Prompt for VS 2019". The "Debug|x64" configuration is simplified to build, which does not include breakpad and other dependencies.

To build libsearpc:

```
$ cd seafile-workspace/libsearpc/
$ devenv libsearpc.sln /build "Debug|x64"
```

To build seafile

```
$ cd seafile-workspace/seafile/
$ devenv seafile.sln /build "Debug|x64"
$ devenv msi/custom/seafile_custom.sln /build "Debug|x64"
```

To build seafile-client

```
$ cd seafile-workspace/seafile-client/
$ devenv third_party/quazip/quazip.sln /build "Debug|x64"
$ devenv seafile-client.sln /build "Debug|x64"
```

To build seafile-shell-ext

```
$ cd seafile-workspace/seafile-shell-ext/
$ devenv extensions/seafile_ext.sln /build "Debug|x64"
$ devenv seadrive-thumbnail-ext/seadrive_thumbnail_ext.sln /build "Debug|x64"
```

### Packaging

Additional setups are required for packaging:

* Python 3.7
* [wix](https://github.com/wixtoolset/wix3/releases/tag/wix3111rtm)
    * install to C:\wix
* [Paraffin](https://github.com/Wintellect/Paraffin/releases)
    * copy Paraffin.exe to C:\wix\bin
* Breakpad
* Certificates
    * install to C:\certs

1. Update the CERTFILE configure in __seafile-workspace/seafile/scripts/build/build-msi-vs.py__ .
2. Run commands:


        $ cd seafile-workspace/seafile-client/third_party/quazip
        $ devenv quazip.sln /build Release|x64
        $ cd seafile-workspace/seafile/scripts/build
        $ python build-msi-vs.py 1.0.0

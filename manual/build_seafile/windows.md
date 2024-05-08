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
* vcpkg
    * curl\[openssl\]:x64-windows
    * getopt:x64-windows
    * glib:x64-windows
    * jansson:x64-windows
    * libevent:x64-windows
    * libwebsockets:x64-windows
    * openssl:x64-windows
    * pthreads:x64-windows
    * sqlite3:x64-windows
    * zlib:x64-windows
* Python 3.7
* [wix](https://github.com/wixtoolset/wix3/releases/tag/wix3111rtm)
    * install to C:\wix
* [Paraffin](https://github.com/Wintellect/Paraffin/releases)
    * copy Paraffin.exe to C:\wix\bin
* Breakpad
* Certificates
    * install to C:\certs

### Breakpad

Support for Breakpad can be added by running following steps:

* install gyp tool

        $ git clone --depth=1 git@github.com:chromium/gyp.git
        $ python setup.py install

* compile breakpad

        $ git clone --depth=1 git@github.com:google/breakpad.git
        $ cd breakpad
        $ git clone https://github.com/google/googletest.git testing
        $ cd ..
        # create vs solution, this may throw an error "module collections.abc has no attribute OrderedDict", you should open the msvs.py and replace 'collections.abc' with 'collections'.
        $ gyp –-no-circular-check breakpad\src\client\windows\breakpad_client.gyp

    * open breakpad_client.sln and configure C++ Language Standard to C++17 and C/C++ ---> Code Generation ---> Runtime Library to Multi-threaded DLL (/MD)
    * build breakpad

* compile dump_syms tool

    create vs solution

        gyp –-no-circular-check breakpad\src\tools\windows\tools_windows.gyp

    * open tools_windows.sln and build tools_windows
    * Insert #include in the source file about unique_ptr compilation error and recompile.
    * build dump_syms
    * Copy C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\Remote Debugger\x64\msdia140.dll to breakpad\src\tools\windows\Release.

* copy VC merge modules

        copy C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\v142\MergeModules\MergeModules\Microsoft_VC142_CRT_x64.msm C:\packagelib

## Building Sync Client

Following directory structures are expected when building Sync Client:

```
seafile-workspace/
seafile-workspace/libsearpc/
seafile-workspace/seafile/
seafile-workspace/seafile-client/
seafile-workspace/seafile-shell-ext/
```

### Building

Note: the building commands have been included in the packaging script, you can skip building commands while packaging.

To build libsearpc:

```
$ cd seafile-workspace/libsearpc/
$ devenv libsearpc.sln /build "Release|x64"
```

To build seafile

```
$ cd seafile-workspace/seafile/
$ devenv seafile.sln /build "Release|x64"
$ devenv msi/custom/seafile_custom.sln /build "Release|x64"
```

To build seafile-client

```
$ cd seafile-workspace/seafile-client/
$ devenv third_party/quazip/quazip.sln /build "Release|x64"
$ devenv seafile-client.sln /build "Release|x64"
```

To build seafile-shell-ext

```
$ cd seafile-workspace/seafile-shell-ext/
$ devenv extensions/seafile_ext.sln /build "Release|x64"
$ devenv seadrive-thumbnail-ext/seadrive_thumbnail_ext.sln /build "Release|x64"
```

### Packaging

1. Update the CERTFILE configure in __seafile-workspace/seafile/scripts/build/build-msi-vs.py__ .
2. Run commands:


        $ cd seafile-workspace/seafile-client/third_party/quazip
        $ devenv quazip.sln /build Release|x64
        $ cd seafile-workspace/seafile/scripts/build
        $ python build-msi-vs.py 1.0.0

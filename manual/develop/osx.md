# macOS

## Environment Setup

The following setups are required for building and packaging Sync Client on macOS:

* XCode 13.2 (or later)
    * After installing XCode, you can start XCode once so that it automatically installs the rest of the components.
* Qt 6.2
* MacPorts
    * Modify __/opt/local/etc/macports/macports.conf__ to add configuration `universal_archs arm64 x86_64`. Specifies the architecture on which MapPorts is compiled.
    * Modify __/opt/local/etc/macports/variants.conf__ to add configuration `+universal`. MacPorts installs universal versions of all ports.
    * Install other dependencies: `sudo port install autoconf automake pkgconfig libtool glib2 libevent vala openssl git jansson cmake libwebsockets argon2`.
* Certificates
    * Create certificate signing requests for certification, see [https://developer.apple.com/help/account/create-certificates/create-a-certificate-signing-request]().
    * Create a _Developer ID Application_ certificate and a _Developer ID Installer_ certificate, see [https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates](). Install them to the login keychain.
    * Install the Developer ID Intermediate Certificate (Developer ID - G2), from [https://www.apple.com/certificateauthority/]()
* dropDMG
* bash environments
    * add following lines to the __~/.bash_profile__ file:

            export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/local/lib/pkgconfig:/usr/local/lib/pkgconfig
            export PATH=/opt/local/bin:/usr/local/bin:/opt/local/Library/Frameworks/Python.framework/Versions/3.10/bin:$PATH
            export LDFLAGS="-L/opt/local/lib -L/usr/local/lib"
            export CFLAGS="-I/opt/local/include -I/usr/local/include"
            export CPPFLAGS="-I/opt/local/include -I/usr/local/include"
            export LD_LIBRARY_PATH=/opt/lib:/usr/local/lib:/opt/local/lib/:/usr/local/lib/:$LD_LIBRARY_PATH

            QT_BASE=$HOME/Qt/6.2.4/macos
            export PATH=$QT_BASE/bin:$PATH
            export PKG_CONFIG_PATH=$QT_BASE/lib/pkgconfig:$PKG_CONFIG_PATH
            export NOTARIZE_APPLE_ID="Your notarize account"
            export NOTARIZE_PASSWORD="Your notarize password"
            export NOTARIZE_TEAM_ID="Your notarize team id"

## Building Sync Client

Following directory structures are expected when building Sync Client:

```
seafile-workspace/
seafile-workspace/libsearpc/
seafile-workspace/seafile/
seafile-workspace/seafile-client/
```

The source code of these projects can be downloaded at [github.com/haiwen/libsearpc](https://github.com/haiwen/libsearpc), [github.com/haiwen/seafile](https://github.com/haiwen/seafile), and [github.com/haiwen/seafile-client](https://github.com/haiwen/seafile-client).

### Building

Note: the building commands have been included in the packaging script, you can skip building commands while packaging.

To build libsearpc:

```
$ cd seafile-workspace/libsearpc/
$ ./autogen.sh
$ ./configure --disable-compile-demo --enable-compile-universal=yes
$ make
$ make install
```

To build seafile:

```
$ cd seafile-workspace/seafile/
$ ./autogen.sh
$ ./configure --disable-fuse --enable-compile-universal=yes
$ make
$ make install
```

To build seafile-client:

```
$ cd seafile-workspace/seafile-client/
$ cmake -GXcode -B. -S.
$ xcodebuild -target seafile-applet -configuration Release
```

### Packaging

1. Update the CERT_ID in __seafile-workspace/seafile/scripts/build/build-mac-local-py3.py__ to the ID of _Developer ID Application_.
2. Run the packaging script: `python3 build-mac-local-py3.py --brand="" --version=1.0.0 --nostrip --universal`

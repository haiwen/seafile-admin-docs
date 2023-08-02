# Mac OS X

## Requirements

The following software packages are required for building Seafile client on macOS:

* XCode (10.2 or later)

    Newer versions of XCode may work, but not tested. Some tweaks may be applied to the build scripts in order to compile or package the application.

* Qt 5.15 (official package)
* MacPorts
* Other dependencies

    The following packages are required to be installed via MacPorts:

        $ sudo port install autoconf automake pkgconfig libtool glib2 libevent vala openssl git jansson cmake curl libwebsockets

Also, add following lines to the *~/.bash_profile* file:

```bash
export PKG_CONFIG_PATH=/opt/local/lib/pkgconfig:/usr/local/lib/pkgconfig
export LIBTOOL=glibtool
export LIBTOOLIZE=glibtoolize
export CPPFLAGS="-I/opt/local/include"
export LDFLAGS="-L/opt/local/lib -L/usr/local/lib -Wl,-headerpad_max_install_names"

QT_BASE=$HOME/Qt5.15.2/5.15.2/clang_64
export PATH=$QT_BASE/bin:$PATH
export PKG_CONFIG_PATH=$QT_BASE/lib/pkgconfig:$PKG_CONFIG_PATH

```

## Compile & Run

### Clone Source Code

We assume the workspace is located at *~/seafile-workspace*. Then, run following commands in a shell:

```bash
$ cd ~/seafile-workspace
$ git clone https://github.com/haiwen/libsearpc.git
$ git clone https://github.com/haiwen/seafile.git
$ git clone https://github.com/haiwen/seafile-client.git

```

### Compile libsearpc

```bash
$ cd ~/seafile-workspace/libsearpc

$ ./autogen.sh
$ ./configure
$ make
$ sudo make install

```

In order to compile universal, you can specify the following option through configure:
```
$ ./configure --enable-compile-universal=yes
```

### Compile seafile

```bash
$ cd ~/seafile-workspace/seafile

$ ./autogen.sh
$ ./configure
$ make
$ sudo make install

```

In order to compile universal, you can specify the following option through configure:
```
$ ./configure --enable-compile-universal=yes
```

### Compile seafile-client

```bash
$ cd ~/seafile-workspace/seafile-client

cmake -G "Unix Makefiles" -B build -S .
cmake --build build --target seafile-applet

```

In order to compile universal, you can specify the following option through cmake to generate makefiles:
```
cmake -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -G "Unix Makefiles" -B build -S .
```

### Run seafile-applet

```bash
$ cd ~/seafile-workspace/seafile-client/build
$ ./seafile-applet

```

## Package Application

Additonal setups are required for packing Seafile client on macOS:

* dropDMG
* certifications
* notarization username and password

### Code Signing

A mac application must be distribution-signed before shipping. More technical details can be found from the [post](https://developer.apple.com/forums/thread/701514#701514021) at developer forums.

Before signing, please make sure to import the distribution certification. Then, the permission of imported key should be changed: right click the imported key in Keychain Access -> select "Get Info" -> select "Access Control" -> choose "Allow all applications to access this item".

Now, executables and frameworks inside the bundle can be signed with the `codesign` command. See the *seafile/scripts/build/build_mac_local.py* script for actual signing commands.

### Notarization

Notarization is the final step before shipping a DMG installer. The `notarytool` command can be used to submit or staple the installer. See the *seafile/scripts/build/notarize.sh* script for actual notarizing commands.

### Run Packaging Script

Some changes need to be applied to the *seafile/scripts/build/build_mac_local.py* script before running it.

* change `'BUILD_SPARKLE_SUPPORT': 'ON',` to `'BUILD_SPARKLE_SUPPORT': 'OFF',`
* comment out sparkle related lines:

        # for fn in _glob('Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app/Contents/MacOS/*'):
        #     do_sign(fn, preserve_entitlemenets=False)

        # for fn in (
        #         'Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app',
        #         'Contents/Frameworks/Sparkle.framework/Versions/A/Sparkle',
        # ):
        #    do_sign(join(appdir, fn))

        # copy_sparkle_framework()

* Update altool path in *seafile/scripts/build/notarize.sh*:

        _altool() {
            xcrun altool "$@"
        }

Then, run following commands in a shell:

```bash
$ cd ~/seafile-workspace/seafile/scripts/build
$ python build-mac-local.py --brand="" --version=1.0.0 --nostrip

```

In order to build an universal package, you can specify the following option through python script:

```
# This script depends on python3
$ python build-mac-local-py3.py --brand="" --version=1.0.0 --nostrip --universal
```

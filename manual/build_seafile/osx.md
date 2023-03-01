# Mac OS X

## Requirements

The following software packages are required for building Seafile client on macOS:

* XCode
* Qt 5.15 (official package)
* MacPorts
* libraries and tools

    `sudo port autoconf automake pkgconfig libtool glib2 libevent vala openssl git jansson cmake libwebsockets`

Configuration for environment variables are also needed:

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

## Compiling Sources

### libsearpc

```
git clone https://github.com/haiwen/libsearpc.git

cd ./libsearpc
./autogen.sh
./configure
make
sudo make install
```

### seafile

```
git clone https://github.com/haiwen/seafile.git

cd ./seafile
./autogen.sh
./configure
make
sudo make install
```

### seafile-client

```
git clone https://github.com/haiwen/seafile-client.git

cd ./seafile-client
cmake -G "Unix Makefiles" -S . -B build
cmake --build build --target seafile-applet
```

then run seafile-applet as `./build/seafile-applet`.

## Packing Application

### Environment

In addition to basic setup from compiling requirements, packing a client application will also need following setup:

* install dropDMG
* import certifications for code signing
* register notarizing username and password to Keychain Access

#### Code Signing

A mac application must be distribution-signed before shipping. More technical details can be found from the [post](https://developer.apple.com/forums/thread/701514#701514021) at developer forums.

Before signing, please make sure to import the distribution certification. Then, the permission of imported key should be changed: right click the imported key in Keychain Access -> select "Get Info" -> select "Access Control" -> choose "Allow all applications to access this item".

Now, executables and frameworks inside the bundle can be signed with the `codesign` command. See the *seafile/scripts/build/build_mac_local.py* script for actual signing commands.

#### Notarization

Notarization is the final step before shipping a DMG installer. The `notarytool` command can be used to submit or staple the installer. See the *seafile/scripts/build/notarize.sh* script for actual notarizing commands.

### Run packing script

Assuming the layout of folders is similar to:

```
seafile-workspace/
|- libsearpc/
|- seafile/
|- seafile-client/
```

Then, run following commands in a shell:

```
cd seafile-workspace/seafile/scripts/build
python build-mac-local.py --brand="" --version=1.0.0 --nostrip

```

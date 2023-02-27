# macOS

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
* register username and password to Keychain Access

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

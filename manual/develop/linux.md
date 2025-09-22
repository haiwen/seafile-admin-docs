# Linux

#### Preparation

The following list is what you need to install on your development machine. **You should install all of them before you build Seafile**.

Package names are according to Ubuntu 24.04. For other Linux distros, please find their corresponding names yourself.

* autotools-dev
* libevent-dev ( 2.0 or later )
* libcurl4-openssl-dev  (1.0.0 or later)
* libgtk2.0-dev ( 2.24 or later)
* uuid-dev
* intltool (0.40 or later)
* libsqlite3-dev (3.7 or later)
* libjansson-dev
* valac
* git
* cmake
* libtool
* python-simplejson (for seaf-cli)
* libssl-dev
* libargon2-dev
* libglib2.0-dev
* libwebsockets-dev
* qtwebengine5-dev
* libqt5webkit5-dev
* qtbase5-dev
* qtchooser
* qttools5-dev
* qttools5-dev-tools
* qtwayland5

##### Ubuntu

```bash
sudo apt-get install build-essential autotools-dev libtool libevent-dev libcurl4-openssl-dev libgtk2.0-dev uuid-dev intltool libsqlite3-dev valac git libjansson-dev cmake libwebsockets-dev qtchooser qtbase5-dev libqt5webkit5-dev qttools5-dev qttools5-dev-tools libssl-dev libargon2-dev libglib2.0-dev qtwebengine5-dev qtwayland5
```

#### Building

First you should get the latest source of libsearpc/seafile/seafile-client:

Download the source code of the latest tag from

* <https://github.com/haiwen/libsearpc> (use v3.2-latest)
* <https://github.com/haiwen/seafile>
* <https://github.com/haiwen/seafile-client>

For example, if the latest released seafile client is 9.0.15, then just use the **v9.0.15** tags of the three projects.

```sh
git clone --branch v3.2-latest https://github.com/haiwen/libsearpc.git
git clone --branch v9.0.15 https://github.com/haiwen/seafile.git
git clone --branch v9.0.15 https://github.com/haiwen/seafile-client.git
```

To build Seafile client, you need first build **libsearpc** and **seafile**.

##### set paths

```bash
export PREFIX=/usr
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$PREFIX/bin:$PATH"

```

##### libsearpc

```bash
cd libsearpc
./autogen.sh
./configure --prefix=$PREFIX
make
sudo make install
cd ..

```

##### seafile

```bash
cd seafile
./autogen.sh
./configure --prefix=$PREFIX --enable-ws=yes
make
sudo make install
cd ..

```

If you don't need notification server, you can set `--enable-ws=no` to disable notification server.

#### seafile-client

```bash
cd seafile-client
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX .
make
sudo make install
cd ..

```

#### custom prefix

when installing to a custom `$PREFIX`, i.e. `/opt`, you may need a script to set the path variables correctly

```bash
cat >$PREFIX/bin/seafile-applet.sh <<END
#!/bin/bash
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export PATH="$PREFIX/bin:$PATH"
exec seafile-applet $@
END
cat >$PREFIX/bin/seaf-cli.sh <<'END'
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export PATH="$PREFIX/bin:$PATH"
export PYTHONPATH=$PREFIX/lib/python3.12/site-packages
exec seaf-cli "$@"
END
chmod +x $PREFIX/bin/seafile-applet.sh $PREFIX/bin/seaf-cli.sh

```

you can now start the client with `$PREFIX/bin/seafile-applet.sh`.

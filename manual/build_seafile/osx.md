# Mac OS X

### Install QT 5.15.1:

* Download it from <https://download.qt.io/official_releases/online_installers/qt-unified-mac-x64-online.dmg>
* Double click the downloaded dmg file to start the installer, and install it to its default location.

## Install Macports

\###Setup macports environment

1. Install xcode

* Download Xcode from [website](https://developer.apple.com/xcode/downloads/) or
  [App Store](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)

1. Install macports

* Quick start <https://www.macports.org/install.php>

> visit <https://www.macports.org/> for more

1. Install following libraries and tools using `port`

```
sudo port install autoconf automake pkgconfig libtool glib2 \
libevent vala openssl git jansson cmake

```

2. Install python

```
sudo port install python27
sudo port select --set python python27

sudo port install py27-pip
sudo port select --set pip pip27

```

3. Set pkg config environment

```
export PKG_CONFIG_PATH=/opt/local/lib/pkgconfig:/usr/local/lib/pkgconfig
export LIBTOOL=glibtool
export LIBTOOLIZE=glibtoolize
export CPPFLAGS="-I/opt/local/include"
export LDFLAGS="-L/opt/local/lib -L/usr/local/lib -Wl,-headerpad_max_install_names"

QT_BASE=$HOME/Qt5.15.1/5.15.1/clang_64
export PATH=$QT_BASE/bin:$PATH
export PKG_CONFIG_PATH=$QT_BASE/lib/pkgconfig:$PKG_CONFIG_PATH

```

## Compiling libsearpc

Download [libsearpc](https://github.com/haiwen/libsearpc), then:

```
./autogen.sh
./configure
make
sudo make install

```

## Compiling seafile

1. Download [seafile](https://github.com/haiwen/seafile)
2. Compile

```
./autogen.sh
./configure
make
sudo make install

```

## Compiling seafile-client

1. Download [seafile-client](https://github.com/haiwen/seafile-client)
2. Compile

```
cmake .
make

```

3. Run the seafile client executable

```
./seafile-applet

```

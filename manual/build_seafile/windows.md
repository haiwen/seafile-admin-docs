# Build Seafile Client for Windows

The following compilation steps are only valid for versions 8.0 and above.

## The development environment

Before compiling and developing, you need to install and configure the development environment

1. Microsoft Visual Studio 2019

2. Package manager tools: [vcpkg](https://docs.microsoft.com/en-us/cpp/build/vcpkg?view=vs-2019)

3. Install wix[wix](https://github.com/wixtoolset/wix3/releases/tag/wix3111rtm)

4. Install paraffin [paraffin](https://github.com/Wintellect/Paraffin/releases)

## Installing third-party libraries

```bash
glib, curl, openssl, libevent, jansson, sqlite3, pthreads, getopt-win32
Install curl：`vcpkg.exe install curl[core,openssl]:x64-windows`
```

Install and configure Qt:

1. Search and install Qt Visual Studio tools in the Visual Studio plugin repository
2. Install Qt, choose qt-opensource-windows-x86-5.13.1.exe ([QT download link](http://download.qt.io/archive/qt/)).
3. Set Qt Visual Studio Tools. The setting is to tell Visual Studio 2019 Qt installation directory. Set Qt Version in Extension->Qt VS Tools-> Qt Options in Visual Studio 2019. Here you need to select the bin directory of Qt. The path of the parent directory. After configuring the Qt installation directory, you also need to set the Qt version used in the project properties of seafile-client. Select properties in the right-click menu of the project, and then select "Qt Project Settings" in the properties dialog box, and select the Version name set in Qt VS Tools just now for Qt Installation.

## How to make msi
For example, if you want to compile seafile 8.0.0, you can package it like this.

First clone the libsearpc seafile seafile-client code to a directory.

```bash
git clone git@github.com:haiwen/libsearpc.git
git clone git@github.com:haiwen/seafile.git
git clone git@github.com:haiwen/seafile-client.git
```

Then pull the code of the specified tag and build.

```bash
cd libsearpc
git pull origin master:master
git reset v8.0.0 --hard

cd ../seafile-client
git pull origin master:master
git reset v8.0.0 --hard

cd ../seafile
git pull origin master:master
git reset v8.0.0 --hard


cd scripts/build
python build-msi-vs.py 8.0.0
```

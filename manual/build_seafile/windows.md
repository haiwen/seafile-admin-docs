# Build Seafile Client for Windows

The following compilation steps are only valid for versions 8.0 and above.

## The development environment

Before compiling and developing, you need to install and configure the development environment

1. Microsoft Visual Studio 2019 (Windows SDK 10.0.18362.0)
2. Package manager tools: [vcpkg](https://docs.microsoft.com/en-us/cpp/build/vcpkg?view=vs-2019)
3. Install wix[wix](https://github.com/wixtoolset/wix3/releases/tag/wix3111rtm) to c:/wix
4. Install paraffin [paraffin](https://github.com/Wintellect/Paraffin/releases) and copy Paraffin.exe to c:/wix/bin
5. Prepare signing certificate seafile.pfx to c:/certs
6. Create a workspace folder such as c:/workspace, all souce code will be downloaded to this folder.

## Installing third-party libraries

Third-party libraries include:glib, curl, openssl(version1.1.1d), openssl-windows(version1.1.1d-1), libevent, jansson, sqlite3, pthreads, getopt-win32

```
Install example：`vcpkg.exe install curl[core,openssl]:x64-windows`

```

Install and configure Qt:

1. Search and install Qt Visual Studio tools in the Visual Studio plugin repository
2. Install Qt5.15.1 ([QT download link](http://download.qt.io/archive/qt/)).
3. Configure Qt Visual Studio Tools. This will tell VS about Qt installation path. In VS menu, open Extension -> Qt VS -> Qt Options. Here you can setup Qt versions and the corresponding installation paths. You should set the path to the parent folder of Qt "bin" folder.Configure Qt Visual Studio Tools. This will tell VS about Qt installation path. In VS menu, open Extension -> Qt VS -> Qt Options. Here you can setup Qt versions and the corresponding installation paths. You should set the path to the parent folder of Qt "bin" folder.
4. Choose Qt version to be used in your project. In VS navigation pane, right click on seafile-client project and choose "Properties". Then click "Qt Project Settings" in the properties dialog. You should select the Qt version you just setup in the last step.Choose Qt version to be used in your project. In VS navigation pane, right click on seafile-client project and choose "Properties". Then click "Qt Project Settings" in the properties dialog. You should select the Qt version you just setup in the last step.

## Install and configure breakpad:

### Install gyp tool

Clone gyp

```
git clone --depth=1 git@github.com:chromium/gyp.git

```

Install gyp 

```
python setup.py install

```

### Compile breakpad

```bash
#clone breakpad
git clone --depth=1 git@github.com:google/breakpad.git
cd breakpad
git clone <https://github.com/google/googletest.git> testing
cd ..
#create vs solution, this may throw an error "module collections.abc has no attribute OrderedDict",
#you should open the msvs.py and replace 'collections.abc' with 'collections'.
gyp –-no-circular-check breakpad\\src\\client\\windows\\breakpad_client.gyp

```

1. open breakpad_client.sln and configure C++ Language Standard to C++17 and C/C++ ---> Code Generation ---> Runtime Library to  Multi-threaded DLL (/MD)
2. build breakpad

### Compile dump_syms tool

create vs solution

```
gyp –-no-circular-check breakpad\\src\\tools\\windows\\tools_windows.gyp

```

1. open tools_windows.sln and build tools_windows
2. Insert #include\<memory> in the source file about unique_ptr compilation error and recompile.
3. build dump_syms
4. Copy C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\Common7\\IDE\\Remote Debugger\\x64\\msdia140.dll to breakpad\\src\\tools\\windows\\Release.

### Copy VC merge modules

```
copy C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Redist\\MSVC\\v142\\MergeModules\\MergeModules\\Microsoft_VC142_CRT_x64.msm C:\\packagelib

```

## How to make msi

For example, if you want to compile seafile 8.0.0, you can package it like this.

First clone the libsearpc seafile seafile-client code to a directory.

```bash
git clone git@github.com:haiwen/libsearpc.git
git clone git@github.com:haiwen/seafile.git
git clone git@github.com:haiwen/seafile-client.git
git clone git@github.com:haiwen/seafile-shell-ext.git

```

Modify build scripts:

1. open seafile/scripts/build/build-msi-vs.py and modify QT_DIR to your directory of qt.
2. replace generator_fragment_cmd with generator_fragment_cmd="%s/Paraffin.exe -dir bin -alias bin -gn group_bin fragment.wxs" %(WIX_BIN).
3. replace new_line = re.sub(r'file_bin\_\[\\d]+', 'seafileapplet.exe', line) with new_line = re.sub(r'file\_\[\\w]+', 'seafileapplet.exe',  line)

Then pull the code of the specified tag and build.

```bash
cd libsearpc
git pull origin master:master
git reset v3.2-latest --hard

cd ../seafile-client
git pull origin master:master
git reset v8.0.0 --hard

cd ../seafile-shell-ext
git pull origin master:master
git reset v8.0.0 --hard

cd ../seafile
git pull origin master:master
git reset v8.0.0 --hard

cd scripts/build
python build-msi-vs.py 8.0.0

```



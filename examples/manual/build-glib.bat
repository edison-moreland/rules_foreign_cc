cd pcre2-10.37
mkdir build
cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\pcre2-install  ..
cmake --build .
cmake --install .

cd ..\..\

cd zlib-1.2.12
@REM need to apply cmamke_dont_build_more_than_needed.patch from vpckg so that output lib is zlib.lib not zlibstatic.lib, as glib expects zlib.lib
@REM actually also had to remove the if(UNIX) so that on windows it is called z.lib
@REM  actually modifications to zlib may not be necessary if using cmake_prefix_path to find zlib instead
mkdir build
cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\zlib-install ..
cmake --build .
cmake --install .

cd ..\..\

cd libffi-meson-3.2.9999.3
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py --prefix=%cd%\libffi-install builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py compile -C builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py install -C builddir
cd ..\..\

cd proxy-libintl-0.4
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py --prefix=%cd%\proxy-libintl-install builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py compile -C builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py install -C builddir
cd ..\..\

cd gettext-0.21
@REM  see build-gettext.sh

@REM set PKG_CONFIG_PATH=%cd%\pcre2-10.37\pcre2-install\lib\pkgconfig;%cd%\zlib-1.2.12\zlib-install\share\pkgconfig;%cd%\libffi-meson-3.2.9999.3\libffi-install/lib\pkgconfig
set PKG_CONFIG_PATH=%cd%\pcre2-10.37\pcre2-install\lib\pkgconfig;%cd%\libffi-meson-3.2.9999.3\libffi-install/lib\pkgconfig

@REM note that pkg-config and gettext binaries were fetched from https://stackoverflow.com/a/22363820
set CMAKE_PREFIX_PATH=%cd%\zlib-1.2.12\zlib-install
@REM set PATH=%cd%\bin;%PATH%
set PATH=%cd%\bin;%cd%\gettext-runtime\bin;%PATH%
set INCLUDE=%INCLUDE%;%cd%\gettext\include
set LIB=%LIB%;%cd%\gettext\lib

@REM got 64 bit gettext from https://download.gnome.org/binaries/win64/dependencies/gettext-runtime-dev_0.18.1.1-2_win64.zip or http://ftp.acc.umu.se/pub/gnome/binaries/win64/dependencies/gettext-runtime-dev_0.18.1.1-2_win64.zip
cd glib-2.73.2
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py --prefix=%cd%\glib-install -Dtests=false builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py compile -C builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py install -C builddir
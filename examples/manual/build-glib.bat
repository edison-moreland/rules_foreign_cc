@REM cd pcre2-10.40
@REM mkdir build
@REM cd build
@REM cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..\pcre2-install ..
@REM cmake --build .
@REM cmake --install .

@REM cd ..\..\

cd zlib-1.2.12
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

set PKG_CONFIG_PATH=%cd%\pcre2-10.40\pcre2-install\lib\pkgconfig;%cd%\zlib-1.2.12\zlib-install\share\pkgconfig;%cd%\libffi-meson-3.2.9999.3\libffi-install/lib\pkgconfig
set PATH=%cd%\bin;%PATH%
set INCLUDE=%INCLUDE%;%cd%\proxy-libintl-0.4\proxy-libintl-install\include
set LIB=%LIB%;%cd%\proxy-libintl-0.4\proxy-libintl-install\lib
cd glib-2.73.2
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py --prefix=%cd%\glib-install builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py compile -C builddir
C:\Users\jheaffey\AppData\Local\Programs\Python\Python310\python.exe ..\meson-0.63.0/meson.py install -C builddir
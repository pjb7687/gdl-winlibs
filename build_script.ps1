$env:PATH="$env:MINGWW64_ROOT\bin;$env:PATH"
$DOWNLOAD_DIR="$env:PROJECT_ROOT\downloads"
New-Item -ItemType Directory -Force -Path "$DOWNLOAD_DIR"
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT"
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT\bin"
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT\lib"
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT\include"
$env:CMAKE_INCLUDE_PATH="$env:LIB_ROOT\include"
$env:CMAKE_LIBRARY_PATH="$env:LIB_ROOT\lib"

# Versions
$WXWIDGETS_VERSION="3.0.4"
$BSDXDR_VERSION="1.0.0"
$PLPLOT_VERSION="5.13.0"
$EIGEN_VERSION="3.3.4"
$EIGEN_COMMIT="5a0156e40feb"
$GSL_VERSION="2.4"
$FFTW_VERSION="3.3.7"
$PSLIB_VERSION="0.4.5"
$ZLIB_VERSION="1.2.11"
$LIBPNG_VERSION="1.6.34"
$PCRE_VERSION="8.42"
$WINEDITLINE_VERSION="2.205"
$BZIP2_VERSION="1.0.6"
$FREETYPE_VERSION="2.9"
$JBIGKIT_VERSION="2.1"
$LIBJPEG_VERSION="9c"
$LIBTIFF_VERSION="4.0.9"
$LIBWMF_VERSION="0.2.8.4"
$LIBXZ_VERSION="5.2.3"
$GRAPHICSMAGICK_VERSION="1.3.28"

# Downloads
Set-Location $DOWNLOAD_DIR
appveyor DownloadFile "https://github.com/wxWidgets/wxWidgets/releases/download/v$WXWIDGETS_VERSION/wxWidgets-$WXWIDGETS_VERSION.7z"
appveyor DownloadFile "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/bsd-xdr/bsd-xdr-$BSDXDR_VERSION.tar.gz"
appveyor DownloadFile "http://downloads.sourceforge.net/project/plplot/plplot/$PLPLOT_VERSION%20Source/plplot-$PLPLOT_VERSION.tar.gz"
appveyor DownloadFile "https://bitbucket.org/eigen/eigen/get/$EIGEN_VERSION.tar.bz2"
Move-Item "$EIGEN_VERSION.tar.bz2" "eigen-eigen-$EIGEN_COMMIT.tar.bz2"
appveyor DownloadFile "http://ftpmirror.gnu.org/gsl/gsl-$GSL_VERSION.tar.gz"
appveyor DownloadFile "http://www.fftw.org/fftw-$FFTW_VERSION.tar.gz"
appveyor DownloadFile "https://downloads.sourceforge.net/project/pslib/pslib/$PSLIB_VERSION/pslib-$PSLIB_VERSION.tar.gz"
appveyor DownloadFile "https://zlib.net/zlib-$ZLIB_VERSION.tar.xz"
appveyor DownloadFile "https://download.sourceforge.net/libpng/libpng-$LIBPNG_VERSION.tar.xz"
appveyor DownloadFile "https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.bz2"
appveyor DownloadFile "https://downloads.sourceforge.net/project/mingweditline/wineditline-$WINEDITLINE_VERSION.zip"
appveyor DownloadFile "http://www.bzip.org/$BZIP2_VERSION/bzip2-$BZIP2_VERSION.tar.gz"
appveyor DownLoadFile "https://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VERSION.tar.gz"
appveyor DownLoadFile "http://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-$JBIGKIT_VERSION.tar.gz"
appveyor DownLoadFile "http://www.ijg.org/files/jpegsrc.v$LIBJPEG_VERSION.tar.gz"
appveyor DownLoadFile "ftp://download.osgeo.org/libtiff/tiff-$LIBTIFF_VERSION.tar.gz"
appveyor DownLoadFile "https://downloads.sourceforge.net/project/wvware/libwmf/$LIBWMF_VERSION/libwmf-$LIBWMF_VERSION.tar.gz"
appveyor DownLoadFile "https://kent.dl.sourceforge.net/project/lzmautils/xz-$LIBXZ_VERSION.tar.xz"
appveyor DownloadFile "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/$GRAPHICSMAGICK_VERSION/GraphicsMagick-$GRAPHICSMAGICK_VERSION.tar.xz"

function prepare_build_path() {
    Param (
        [string]$cfile,
        [Parameter(Mandatory=$false)][string]$cdirname
    )
    $csplitted=$cfile.Split(".")
    if ($csplitted[-2] -eq "tar") {
        $cprefix=$csplitted[0..($csplitted.Length-3)] -join "."
        #tar xf $cfile 
        7z e "$cfile" -y
        7z x "$cprefix.tar" -y
    } else {
        $cprefix=$csplitted[0..($csplitted.Length-2)] -join "."
        7z x $cfile -y
    }
    if ($PSBoundParameters.ContainsKey('cdirname')) {
        $cprefix="$cdirname"
    }
    New-Item -ItemType Directory -Force -Path "$cprefix/build"
    Set-Location "$cprefix/build"
}

function configure_cmake() {
    Invoke-Expression "cmake .. -G 'MinGW Makefiles' -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE='-O3 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=$env:LIB_ROOT $args"
}

function build_cmake() {
    configure_cmake @args
    mingw32-make -j4
    mingw32-make install
}

function build_configure() {
    $MINGW64_UNIXPATH=& "$env:MSYS_ROOT\usr\bin\cygpath.exe" -u "$env:MINGWW64_ROOT"
    $LIBROOT_UNIXPATH=& "$env:MSYS_ROOT\usr\bin\cygpath.exe" -u "$env:LIB_ROOT"
    & "$env:MSYS_ROOT\usr\bin\bash.exe" -c "export PATH=/usr/bin:$MINGW64_UNIXPATH/bin && export LDFLAGS='-L$LIBROOT_UNIXPATH/lib -L$MINGW64_UNIXPATH/$env:host/lib' && export CPPFLAGS='-I$MINGW64_UNIXPATH/$env:host/include -I$LIBROOT_UNIXPATH/include' && ../configure --enable-shared --build=$env:host --host=$env:host --prefix=$LIBROOT_UNIXPATH && make -j4 && make install"
}

# WxWidgets
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION"
Set-Location "$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION"
7z x "$DOWNLOAD_DIR\wxWidgets-$WXWIDGETS_VERSION.7z" -y
Set-Location "build\msw"
mingw32-make SHELL=cmd -f makefile.gcc setup_h BUILD=release SHARED=1 USE_GUI=1 USE_XRC=0 USE_HTML=0 USE_WEBVIEW=0 USE_MEDIA=0 USE_AUI=0 USE_RIBBON=0 USE_PROPGRID=0 USE_RICHTEXT=0 USE_STC=0 USE_OPENGL=0 VENDOR=gdl DEBUG_FLAG=1
sed -i "s/#   define wxUSE_GRAPHICS_CONTEXT 0/#   define wxUSE_GRAPHICS_CONTEXT 1/g" "$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION\lib\gcc_dll\mswu\wx\setup.h"
mingw32-make SHELL=cmd -f makefile.gcc -j4 BUILD=release SHARED=1 USE_GUI=1 USE_XRC=0 USE_HTML=0 USE_WEBVIEW=0 USE_MEDIA=0 USE_AUI=0 USE_RIBBON=0 USE_PROPGRID=0 USE_RICHTEXT=0 USE_STC=0 USE_OPENGL=0 VENDOR=gdl DEBUG_FLAG=1
# Below 2 lines are required for wxWidgets-3.0.4, don't know why
Copy-Item "$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION\build\msw\gcc_mswudll\coredll_headerctrlg.o" "$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION\build\msw\gcc_mswudll\coredll_headerctrlgo"
mingw32-make SHELL=cmd -f makefile.gcc -j4 BUILD=release SHARED=1 USE_GUI=1 USE_XRC=0 USE_HTML=0 USE_WEBVIEW=0 USE_MEDIA=0 USE_AUI=0 USE_RIBBON=0 USE_PROPGRID=0 USE_RICHTEXT=0 USE_STC=0 USE_OPENGL=0 VENDOR=gdl DEBUG_FLAG=1
$env:WXWIDGETS_ROOT="$env:LIB_ROOT\wxWidgets-$WXWIDGETS_VERSION"

# BSD-XDR
Set-Location "$DOWNLOAD_DIR"
tar xf "bsd-xdr-$BSDXDR_VERSION.tar.gz"
Set-Location "bsd-xdr-$BSDXDR_VERSION"
#sed -i 's/%hh/%/g' src\test\test_data.c
New-Item -ItemType Directory -Force -Path mingw
New-Item -ItemType Directory -Force -Path mingw\lib
mingw32-make -f Makefile -j4 PLATFORM=mingw STAMP=clean TEST_PROGS="" top_srcdir="$DOWNLOAD_DIR\bsd-xdr-$BSDXDR_VERSION" recursive-all
Move-Item mingw\libxdr.dll.a "$env:LIB_ROOT\lib"
Move-Item rpc "$env:LIB_ROOT\include"
Move-Item mingw\mgwxdr-0.dll "$env:LIB_ROOT\bin"

# Zlib
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("zlib-$ZLIB_VERSION.tar.xz")
build_cmake
Copy-Item "$env:LIB_ROOT\lib\libzlib.dll.a" "$env:LIB_ROOT\lib\libz.dll.a"

# libbz2
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("bzip2-$BZIP2_VERSION.tar.gz")
$srcs=@("blocksort","huffman","crctable","randtable","compress","decompress","bzlib")
$objs=""
foreach ($src in $srcs) {
    gcc -fpic -fPIC -Wall -Winline -O3 -D_FILE_OFFSET_BITS=64 -c ..\${src}.c
    $objs="$src.o $objs"
}
Invoke-Expression "gcc -shared -o libbz2.dll $objs `"-Wl,--out-implib,libbz2.dll.a`""
Move-Item libbz2.dll.a "$env:LIB_ROOT\lib"
Move-Item libbz2.dll "$env:LIB_ROOT\bin"
Copy-Item ..\bzlib.h "$env:LIB_ROOT\include"

# Freetype
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("freetype-$FREETYPE_VERSION.tar.gz")
build_cmake("-DBUILD_SHARED_LIBS=ON -DZLIB_ROOT=$env:LIB_ROOT -D_BZIP2_PATHS=$env:LIB_ROOT")
Move-Item "$env:LIB_ROOT\include\freetype2\freetype" "$env:LIB_ROOT\include"
Move-Item "$env:LIB_ROOT\include\freetype2\ft2build.h" "$env:LIB_ROOT\include"
Remove-Item "$env:LIB_ROOT\include\freetype2"

# PLplot
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("plplot-$PLPLOT_VERSION.tar.gz")
build_cmake("-DwxWidgets_ROOT_DIR=$env:WXWIDGETS_ROOT -DFREETYPE_DIR=$env:LIB_ROOT -DENABLE_DYNDRIVERS=OFF")

# Eigen
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("eigen-eigen-$EIGEN_COMMIT.tar.bz2")
build_cmake

# GSL
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("gsl-$GSL_VERSION.tar.gz")
build_configure

# FFTW
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("fftw-$FFTW_VERSION.tar.gz")
configure_cmake("-DENABLE_FLOAT=ON")
sed -i "s:/\* #undef WITH_OUR_MALLOC \*/:#define WITH_OUR_MALLOC 1:g" config.h
mingw32-make -j4
mingw32-make install

# PSLIB
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("pslib-$PSLIB_VERSION.tar.gz")
sed -i "1s/^/#define max(X,Y) (((X) > (Y)) ? (X) : (Y))/" ../src/ps_strbuf.c
configure_cmake
mingw32-make
Move-Item libpslib.dll "$env:LIB_ROOT\bin"
Move-Item libpslib.dll.a "$env:LIB_ROOT\lib"

# libPNG
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("libpng-$LIBPNG_VERSION.tar.xz")
build_cmake("-DZLIB_ROOT=$env:LIB_ROOT")

# WinEditLine
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("wineditline-$WINEDITLINE_VERSION.zip")
build_cmake
if ($env:host -eq "i686-w64-mingw32") {
    Move-Item "$DOWNLOAD_DIR\wineditline-$WINEDITLINE_VERSION\bin32\*.dll" "$env:LIB_ROOT\bin"
    Move-Item "$DOWNLOAD_DIR\wineditline-$WINEDITLINE_VERSION\bin32\*.a" "$env:LIB_ROOT\lib"
} else {
    Move-Item "$DOWNLOAD_DIR\wineditline-$WINEDITLINE_VERSION\bin64\*.dll" "$env:LIB_ROOT\bin"
    Move-Item "$DOWNLOAD_DIR\wineditline-$WINEDITLINE_VERSION\bin64\*.a" "$env:LIB_ROOT\lib"
}
New-Item -ItemType Directory -Force -Path "$env:LIB_ROOT\include\readline"
Move-Item "$DOWNLOAD_DIR\wineditline-$WINEDITLINE_VERSION\include\editline\*.h" "$env:LIB_ROOT\include\readline"

# PCRE
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("pcre-$PCRE_VERSION.tar.bz2")
build_cmake("-DEDITLINE_INCLUDE_DIR=$env:LIB_ROOT\include -DPCRE_SUPPORT_LIBEDIT=ON -DBUILD_SHARED_LIBS=ON -DZLIB_ROOT=$env:LIB_ROOT -D_BZIP2_PATHS=$env:LIB_ROOT")

# libJBIG
Set-Location "$DOWNLOAD_DIR"
prepare_build_path("jbigkit-$JBIGKIT_VERSION.tar.gz")
$srcs=@("jbig","jbig_ar")
$objs=""
foreach ($src in $srcs) {
    gcc -O3 -W -Wall -ansi -pedantic -c ..\libjbig\${src}.c
    $objs="$src.o $objs"
}
Invoke-Expression "gcc -shared -o libjbig.dll $objs `"-Wl,--out-implib,libjbig.dll.a`""
Move-Item libjbig.dll.a "$env:LIB_ROOT\lib"
Move-Item libjbig.dll "$env:LIB_ROOT\bin"
Copy-Item ..\libjbig\jbig.h "$env:LIB_ROOT\include"
Copy-Item ..\libjbig\jbig_ar.h "$env:LIB_ROOT\include"

# libjpeg
Set-Location "$DOWNLOAD_DIR"
prepare_build_path "jpegsrc.v$LIBJPEG_VERSION.tar.gz" "jpeg-$LIBJPEG_VERSION"
build_configure

# libtiff
Set-Location "$DOWNLOAD_DIR"
prepare_build_path "tiff-$LIBTIFF_VERSION.tar.gz"
build_cmake

# libwmf
Set-Location "$DOWNLOAD_DIR"
prepare_build_path "libwmf-$LIBWMF_VERSION.tar.gz"
build_configure

# libxz
Set-Location "$DOWNLOAD_DIR"
prepare_build_path "xz-$LIBXZ_VERSION.tar.xz"
build_configure

# GraphicsMagicK
Set-Location "$DOWNLOAD_DIR"
prepare_build_path "GraphicsMagick-$GRAPHICSMAGICK_VERSION.tar.xz"
build_configure
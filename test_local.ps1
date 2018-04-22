$env:LIB_ROOT="D:\GDL\gdl-winlibs\win32libs"
$env:PROJECT_ROOT="D:\GDL\gdl-winlibs"
$env:MINGWW64_ROOT="D:\i686-6.3.0-release-posix-dwarf-rt_v5-rev1\mingw32"
$env:MSYS_ROOT="D:\msys64"
$env:PYTHON_ROOT="C:\Python27"
$env:host="i686-w64-mingw32"

function appveyor ([string]$cmd, [string]$arg1) {
    & "$env:MSYS_ROOT/usr/bin/wget.exe" "$arg1"
}

& .\build_script.ps1

. $env:GITHUB_WORKSPACE\actions\windows\Invoke-CmdScript.ps1
. $env:Qt5_Dir\bin\qtenv2.bat
cd $env:GITHUB_WORKSPACE
Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64
. $env:Qt5_Dir\bin\qmake.exe -spec win32-msvc
cd Main
nmake
# & {
#     # https://stackoverflow.com/a/12538601
#     $ErrorActionPreference = 'SilentlyContinue'
#     # D:\Qt\Tools\QtCreator\bin\jom.exe 2>&1
#     nmake 2>&1
# }
# tree "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\bin"
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
. $env:Qt5_Dir\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item Anthem -Destination D:\Anthem

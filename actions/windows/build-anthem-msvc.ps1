Write-Host "`nBuild script started.`n`n"
Write-Host "`nInstalling Invoke-CmdScript...`n`n"
. $env:GITHUB_WORKSPACE\actions\windows\Invoke-CmdScript.ps1

cd $env:GITHUB_WORKSPACE\src
Write-Host "`nSetting up MSVC build environment...`n`n"
Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64

# ls "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise" "cl.exe" -Recurse -File
# cmake . -DCMAKE_BUILD_TYPE:STRING="Release" -DCMAKE_C_COMPILER:STRING="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.27.29110\bin\HostX86\x64\cl.exe" -DCMAKE_PREFIX_PATH:STRING="C:\Qt\5.15.1\msvc2019_64" -DQT_QMAKE_EXECUTABLE:STRING="C:\Qt\5.15.1\msvc2019_64\bin\qmake.exe"
Write-Host "`nRunning CMake...`n`n"
cmake . -DCMAKE_BUILD_TYPE:STRING="Release" -DCMAKE_C_COMPILER:STRING="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.27.29110\bin\HostX64\x64\cl.exe" -DCMAKE_PREFIX_PATH:STRING=$env:Qt5_Dir\msvc2019_64 -DQT_QMAKE_EXECUTABLE:STRING=$env:Qt5_Dir\msvc2019_64\bin\qmake.exe
Get-ChildItem -Recurse
Write-Host "`nBuilding...`n`n"
msbuild Anthem.sln
# & {
#     # https://stackoverflow.com/a/12538601
#     $ErrorActionPreference = 'Continue'
#     nmake
# }
mkdir AnthemBuild
Copy-Item release\Anthem.exe -Destination AnthemBuild
cd AnthemBuild
Write-Host "`nPackaging...`n`n"
. $env:Qt5_Dir\bin\windeployqt.exe Anthem.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item AnthemBuild -Destination D:\Anthem

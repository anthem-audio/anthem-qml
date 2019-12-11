. $env:GITHUB_WORKSPACE\actions\windows\Invoke-CmdScript.ps1
D:\Qt\5.13.2\msvc2017_64\bin\qtenv2.bat
cd $env:GITHUB_WORKSPACE
Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64
D:\Qt\5.13.2\msvc2017_64\bin\qmake.exe
& {
    # https://stackoverflow.com/a/12538601
    $ErrorActionPreference = 'SilentlyContinue'
    D:\Qt\Tools\QtCreator\bin\jom.exe 2>&1
}
cd Main\release
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
D:\Qt\5.13.2\msvc2017_64\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item Anthem -Destination D:\Anthem

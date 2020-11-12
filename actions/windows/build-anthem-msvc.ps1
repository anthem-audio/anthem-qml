. $env:GITHUB_WORKSPACE\actions\windows\Invoke-CmdScript.ps1
cd $env:GITHUB_WORKSPACE
Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64
cd src
. $env:Qt5_Dir\bin\qmake.exe
& {
    # https://stackoverflow.com/a/12538601
    $ErrorActionPreference = 'Continue'
    nmake
}
mkdir AnthemBuild
Copy-Item release\Anthem.exe -Destination AnthemBuild
cd AnthemBuild
. $env:Qt5_Dir\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item AnthemBuild -Destination D:\Anthem

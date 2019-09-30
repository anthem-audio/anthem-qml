D:\Qt\5.13.1\mingw73_64\bin\qtenv2.bat
cd $env:GITHUB_WORKSPACE
D:\Qt\5.13.1\mingw73_64\bin\qmake
Write-Host "Main folder after qmake:"
dir $env:GITHUB_WORKSPACE\Main
Write-Host "Folder above workspace after qmake:"
cd ..
dir
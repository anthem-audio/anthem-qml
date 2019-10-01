D:\Qt\5.13.1\mingw73_64\bin\qtenv2.bat
cd $env:GITHUB_WORKSPACE
D:\Qt\5.13.1\mingw73_64\bin\qmake
D:\Qt\Tools\mingw730_64\bin\mingw32-make.exe
cd Main\release
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
D:\Qt\5.13.1\mingw73_64\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
7z a Anthem.zip Anthem
Move-Item Anthem.zip D:\
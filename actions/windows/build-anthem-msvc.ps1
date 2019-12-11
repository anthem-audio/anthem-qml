cd $env:GITHUB_WORKSPACE
D:\Qt\5.13.2\msvc2017_64\bin\qmake
D:\Qt\5.13.2\msvc2017_64\bin\jom
cd Main\release
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
D:\Qt\5.13.2\msvc2017_64\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item Anthem -Destination D:\Anthem

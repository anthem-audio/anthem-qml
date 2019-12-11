D:\Qt\5.13.2\msvc2017_64\bin\qtenv2.bat
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
cd $env:GITHUB_WORKSPACE
D:\Qt\5.13.2\msvc2017_64\bin\qmake.exe
D:\Qt\5.13.2\msvc2017_64\bin\jom.exe
cd Main\release
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
D:\Qt\5.13.2\msvc2017_64\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
cd ..
Move-Item Anthem -Destination D:\Anthem

tree $env:Qt5_Dir

Invoke-Expression $env:Qt5_Dir\bin\qtenv2.bat
cd $env:GITHUB_WORKSPACE
Invoke-Expression $env:Qt5_Dir\bin\qmake
Invoke-Expression $env:Qt5_Dir\..\..\Tools\mingw730_64\bin\mingw32-make.exe
cd Main\release
mkdir Anthem
Copy-Item Main.exe -Destination Anthem
cd Anthem
Invoke-Expression $env:Qt5_Dir\bin\windeployqt.exe Main.exe --qmldir $env:GITHUB_WORKSPACE\Main
# Copy some extra DLLs that windeployqt missed (dlls might be because mingw wasn't run properly??)
Copy-Item "$env:Qt5_Dir\bin\libgcc_s_seh-1.dll" -Destination "libgcc_s_seh-1.dll"
Copy-Item "$env:Qt5_Dir\bin\libwinpthread-1.dll" -Destination "libwinpthread-1.dll"
Copy-Item "$env:Qt5_Dir\bin\libstdc++-6.dll" -Destination "libstdc++-6.dll"
cd ..
Move-Item Anthem -Destination D:\Anthem
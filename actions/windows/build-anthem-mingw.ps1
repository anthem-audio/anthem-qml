Write-Host "Build script started."

cd $env:GITHUB_WORKSPACE\src

Write-Host "Running CMake...`n`n"
cmake . -G "MinGW Makefiles"

Get-ChildItem -Recurse

Write-Host "`nBuilding Anthem...`n`n"
C:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\bin\mingw32-make.exe

mkdir AnthemBuild
Copy-Item Anthem.exe -Destination AnthemBuild
cd AnthemBuild
. $env:Qt5_Dir\bin\windeployqt.exe Anthem.exe --qmldir $env:GITHUB_WORKSPACE\src

# Copy some extra DLLs that windeployqt missed (dlls might be because mingw wasn't run properly??)
Copy-Item "$env:Qt5_Dir\bin\libgcc_s_seh-1.dll" -Destination "libgcc_s_seh-1.dll"
Copy-Item "$env:Qt5_Dir\bin\libwinpthread-1.dll" -Destination "libwinpthread-1.dll"
Copy-Item "$env:Qt5_Dir\bin\libstdc++-6.dll" -Destination "libstdc++-6.dll"

cd ..
Move-Item AnthemBuild -Destination D:\Anthem
Write-Host "Build script started."
Write-Host "Installing Invoke-CmdScript..."
. $env:GITHUB_WORKSPACE\actions\windows\Invoke-CmdScript.ps1

cd $env:GITHUB_WORKSPACE\src
Write-Host "Setting up MSVC build environment..."
Invoke-CmdScript "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64

Write-Host "Running CMake...`n`n"
cmake .

Write-Host "`nBuilding...`n`n"
msbuild Anthem.sln /property:Configuration=Release
mkdir AnthemBuild
Copy-Item Release\Anthem.exe -Destination AnthemBuild
cd AnthemBuild
Write-Host "`nPackaging...`n`n"
. $env:Qt5_Dir\bin\windeployqt.exe Anthem.exe --qmldir $env:GITHUB_WORKSPACE\src
cd ..
Move-Item AnthemBuild -Destination D:\Anthem
Write-Host "Echo test 1"
D:\Qt\5.13.1\mingw73_64\bin\qtenv2.bat
Write-Host "Echo test 2"
cd $env:GITHUB_WORKSPACE
Write-Host "Echo test 3"
qmake
Write-Host "Echo test 4"
dir $env:GITHUB_WORKSPACE
Write-Host "Echo test 5"
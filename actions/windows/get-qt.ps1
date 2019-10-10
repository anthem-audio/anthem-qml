# $env:GITHUB_WORKSPACE = 'C:\Users\qbgee\Documents\Code\Aurora\Prototyping'

Set-Location $env:GITHUB_WORKSPACE
Invoke-WebRequest -Uri $installer_url -OutFile "qt-install.exe"
$installer_url = 'https://download.qt.io/archive/online_installers/3.1/qt-unified-windows-x86-3.1.1-online.exe'
# .\qt-install.exe --script .\actions\installer-noninteractive-windows.qs --verbose
# $env:GITHUB_WORKSPACE = 'C:\Users\qbgee\Documents\Code\Aurora\Prototyping'

Set-Location $env:GITHUB_WORKSPACE
# choco install curl -y
$installer_url = 'http://download.qt.io/official_releases/qt/5.14/5.14.0/qt-opensource-windows-x86-5.14.0.exe'
# Invoke-WebRequest -Uri $installer_url -OutFile "qt-install.exe"
C:\Windows\System32\curl.exe -L $installer_url --output "$env:GITHUB_WORKSPACE\qt-install.exe"
# .\qt-install.exe --script .\actions\installer-noninteractive-windows.qs --verbose
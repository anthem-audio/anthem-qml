$env:GITHUB_WORKSPACE = 'C:\Users\qbgee\Documents\Code\Aurora\Prototyping'

$installer_url = 'https://download.qt.io/archive/online_installers/3.1/qt-unified-windows-x86-3.1.1-online.exe'
Invoke-WebRequest -Uri $installer_url -OutFile "${env:GITHUB_WORKSPACE}\qt-install.exe"

echo %GITHUB_WORKSPACE%
powershell %GITHUB_WORKSPACE%\actions\windows\download-qt-installer.ps1
%GITHUB_WORKSPACE%\qt-install.exe --script %GITHUB_WORKSPACE%\actions\installer-noninteractive.qs --platform minimal --verbose
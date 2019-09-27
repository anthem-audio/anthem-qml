Write-Output $Env:GITHUB_WORKSPACE
(new-object System.Net.WebClient).DownloadFile('http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/qt-opensource-windows-x86-5.13.1.exe',$Env:GITHUB_WORKSPACE + '/qt-install.exe')
Start-Process -FilePath $Env:GITHUB_WORKSPACE -ArgumentList "--script", $Env:GITHUB_WORKSPACE + "/actions/installer-noninteractive.qs", "--platform minimal" -RedirectStandardOutput output.txt
Get-Content output.txt | ForEach-Object {Write-Output $_}
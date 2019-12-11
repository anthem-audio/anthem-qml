D:\Qt\5.13.2\msvc2017_64\bin\qtenv2.bat
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" amd64
pwsh -Command "& {ls env: | Select-Object -Property Key, Value | ConvertTo-Csv}"

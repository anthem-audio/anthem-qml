D:\Qt\5.13.2\msvc2017_64\bin\qtenv2.bat
"%VCVARSALL%" amd64
pwsh -Command "& {ls env: | Select-Object -Property Key, Value | ConvertTo-Csv}"

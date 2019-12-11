"%VCVARSALL%" amd64
pwsh -Command "& {ls env: | Select-Object -Property Key, Value | ConvertTo-Csv}"

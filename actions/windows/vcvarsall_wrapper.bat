"%VCVARSALL%"
pwsh -Command "& {ls env: | Select-Object -Property Key, Value | ConvertTo-Csv}"

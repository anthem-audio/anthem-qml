$env:VCVARSALL amd64
ls env: | Select-Object -Property Key, Value | ConvertTo-Csv

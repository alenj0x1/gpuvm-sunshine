# GpuVM: builds this Sunshine fork with MSYS2 UCRT64 (C:\msys64). Output in build\.
$env:MSYSTEM = 'UCRT64'; $env:CHERE_INVOKING = '1'; $env:MSYS2_PATH_TYPE = 'inherit'
& C:\msys64\usr\bin\bash.exe -lc "./build-gpuvm.sh" 2>&1 | Tee-Object (Join-Path $PSScriptRoot 'build-gpuvm.log')

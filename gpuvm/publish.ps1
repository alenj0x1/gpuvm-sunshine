# Copies the files GpuVM ships from this fork's build into GpuVM's repo (..\gpu-vm\sunshine, git-ignored there):
# sunshine.exe, tools\sunshine_wgc_capture.exe and VERSION (upstream tag + this fork's commit).
param([string]$GpuVM = (Join-Path $PSScriptRoot '..\..\gpu-vm'))
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$out = Join-Path (Resolve-Path $GpuVM) 'sunshine'
New-Item -ItemType Directory -Force (Join-Path $out 'tools') | Out-Null
Copy-Item (Join-Path $root 'build\sunshine.exe') $out -Force
Copy-Item (Join-Path $root 'build\tools\sunshine_wgc_capture.exe') (Join-Path $out 'tools') -Force
$commit = (git -C $root rev-parse --short HEAD).Trim()
$dirty = if (git -C $root status --porcelain -- src tools cmake) { '-dirty' } else { '' }
Set-Content (Join-Path $out 'VERSION') "v2026.914.233613+gpuvm.$commit$dirty" -Encoding ASCII
Get-ChildItem $out -Recurse -File | ForEach-Object { '{0}  {1}' -f (Get-FileHash $_.FullName).Hash.Substring(0, 12), $_.FullName.Substring($out.Length + 1) }

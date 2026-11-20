# GpuVM Sunshine

GpuVM's Sunshine is a fork of [Sunshine](https://github.com/LizardByte/Sunshine) (GPL-3.0) at `v2026.914.233613`.
GpuVM still installs upstream's MSI in every VM; on agent machines it adds two files from this fork. Everything
else stays as upstream wrote it.

## Why

On Hyper-V GPU-P machines with a virtual display, Desktop Duplication loses access after every frame (GpuVM lab 055),
so the viewer stays black. Windows.Graphics.Capture works, but only for the console session's own user: Sunshine
running as SYSTEM can't use it, and running Sunshine as that user would hand it Sunshine's keys. This fork lets the
SYSTEM service capture with WGC through a small helper that runs as the signed-in user and holds nothing secret.

## What changes from upstream

| File | Change |
|---|---|
| `tools/sunshine_wgc_capture.cpp` | The capture helper, from [Vibeshine](https://github.com/Nonary/vibeshine) (GPL-3.0, commit `95254e2`). Captures with WGC and publishes frames in a keyed-mutex shared texture. |
| `src/platform/windows/ipc/*`, `wgc_capture_policy.h` | Vibeshine's IPC (pipes, process launcher, session). The launcher only ever uses the console user's non-elevated token: Vibeshine's SYSTEM fallback is removed. |
| `src/platform/windows/display.h`, `display_wgc.cpp`, `display_vram.cpp` | `display_wgc_*_t` pick their frame source at init: the helper as SYSTEM, WGC in-process otherwise. |
| `tools/CMakeLists.txt`, `cmake/compile_definitions/windows.cmake` | Build the helper and the IPC. |
| `cmake/packaging/windows.cmake` | `GPUVM_SKIP_WIX` (GpuVM doesn't use the MSI). |
| `build-gpuvm.*`, `build-target.sh` | Build in MSYS2 UCRT64: no docs, tests or tray (no UI of a SYSTEM process on the user's desktop). |

The first commit after the upstream tag imports Vibeshine's files unmodified; the following ones show every change.

## Build (Windows)

Requirements: MSYS2 in `C:\msys64` with the UCRT64 packages in `docs/building.md` plus `libtiff` and
`nlohmann-json`, and Node.js on the PATH (web UI).

```powershell
git submodule update --init --recursive
.\build-gpuvm.ps1
.\gpuvm\publish.ps1   # copies the two files GpuVM ships into ..\gpu-vm\sunshine
```

## Following upstream

```powershell
git fetch upstream --tags
git rebase --onto vX.Y.Z v2026.914.233613 gpuvm
```

Then update `streaming/components.json` in GpuVM to the same upstream version (the fork's `sunshine.exe` replaces
the MSI's), build, and run GpuVM lab 055 (`open.ps1` on an agent copy) before shipping.

## License

GPL-3.0, like Sunshine and Vibeshine. The source of every build GpuVM ships is published. GpuVM itself (MIT) is a
separate program.

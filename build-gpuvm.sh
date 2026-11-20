#!/usr/bin/env bash
# GpuVM: builds Sunshine in MSYS2 UCRT64 (run through build-gpuvm.ps1). Docs, tests and the tray off (no Qt; no UI of a SYSTEM process on the desktop); the web UI needs the
# host's native Node.js on PATH (MSYS2_PATH_TYPE=inherit).
set -e
cd "$(dirname "$0")"
cmake -B build -G Ninja -S . -DBUILD_DOCS=OFF -DBUILD_TESTS=OFF -DSUNSHINE_ENABLE_TRAY=OFF -DCMAKE_BUILD_TYPE=Release
ninja -C build
echo BUILD-OK

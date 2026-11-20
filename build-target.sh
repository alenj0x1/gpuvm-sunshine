#!/usr/bin/env bash
# GpuVM: configure (as build-gpuvm.sh) and build one target; full log in build-target.log, errors on stdout.
cd "$(dirname "$0")"
{ cmake -B build -G Ninja -S . -DBUILD_DOCS=OFF -DBUILD_TESTS=OFF -DSUNSHINE_ENABLE_TRAY=OFF -DGPUVM_SKIP_WIX=ON -DCMAKE_BUILD_TYPE=Release && ninja -C build "$@"; echo "EXIT $?"; } > build-target.log 2>&1
grep -E -A6 "CMake Error|error:|FAILED:" build-target.log | grep -v -E "cmake_install.cmake|c\+\+\.exe " | head -60
tail -1 build-target.log

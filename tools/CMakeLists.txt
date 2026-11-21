cmake_minimum_required(VERSION 3.20)

project(sunshine_tools)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 17)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

include_directories(
        "${CMAKE_SOURCE_DIR}"
        "${FFMPEG_INCLUDE_DIRS}"  # this is included only for logging
)

set(TOOL_SOURCES
        "${CMAKE_SOURCE_DIR}/src/logging.cpp"
        "${CMAKE_SOURCE_DIR}/src/platform/windows/utf_utils.cpp"
)

add_executable(dxgi-info dxgi.cpp ${TOOL_SOURCES})
target_link_libraries(dxgi-info
        ${Boost_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT}
        ${FFMPEG_LIBRARIES}  # this is included only for logging
        dxgi
        libdisplaydevice::display_device  # this is included only for logging
        ${PLATFORM_LIBRARIES}
)
target_compile_options(dxgi-info PRIVATE ${SUNSHINE_COMPILE_OPTIONS})

add_executable(audio-info audio.cpp ${TOOL_SOURCES})
target_link_libraries(audio-info
        ${Boost_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT}
        ${FFMPEG_LIBRARIES}  # this is included only for logging
        libdisplaydevice::display_device  # this is included only for logging
        ksuser
        ${PLATFORM_LIBRARIES}
)
target_compile_options(audio-info PRIVATE ${SUNSHINE_COMPILE_OPTIONS})

add_executable(sunshinesvc sunshinesvc.cpp)
target_link_libraries(sunshinesvc
        ${CMAKE_THREAD_LIBS_INIT}
        wtsapi32
        ${PLATFORM_LIBRARIES})
target_compile_options(sunshinesvc PRIVATE ${SUNSHINE_COMPILE_OPTIONS})

# GpuVM: Windows.Graphics.Capture helper (from Vibeshine). Sunshine, running as SYSTEM, starts it in the console
# session with the signed-in user's token and reads its frames from a keyed-mutex shared texture.
add_executable(sunshine_wgc_capture sunshine_wgc_capture.cpp
        "${CMAKE_SOURCE_DIR}/src/platform/windows/ipc/pipes.cpp"
        "${CMAKE_SOURCE_DIR}/src/platform/windows/ipc/misc_utils.cpp"
        ${TOOL_SOURCES})
target_link_libraries(sunshine_wgc_capture
        ${Boost_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT}
        ${FFMPEG_LIBRARIES}  # this is included only for logging
        libdisplaydevice::display_device  # this is included only for logging
        d3d11 dxgi ole32 user32 gdi32 windowsapp avrt shcore wtsapi32 userenv advapi32
        ${PLATFORM_LIBRARIES})
target_compile_options(sunshine_wgc_capture PRIVATE ${SUNSHINE_COMPILE_OPTIONS})

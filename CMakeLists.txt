
cmake_minimum_required(VERSION 3.20)
project(NecroMachZgpu LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/libs/dawn" EXCLUDE_FROM_ALL)
set_target_properties(dawn_native PROPERTIES EXCLUDE_FROM_ALL FALSE)
set_target_properties(dawn_proc PROPERTIES EXCLUDE_FROM_ALL FALSE)

if (WIN32)
    add_library(mingw_helpers STATIC "src/dawn/mingw_helpers.cpp")
    target_link_libraries(dawn_native PRIVATE mingw_helpers)
endif()

# As a last resort, after trying everything else, some files must be patched.
# Doing that from here for now rather than maintaining forks of these giant libs

if (WIN32)
    # Disable Abseil’s WinRT globalization path by emptying its source
    set(_tz_cc
        "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/third_party/abseil-cpp/absl/time/internal/cctz/src/time_zone_lookup.cc"
    )
    if (EXISTS "${_tz_cc}")
        file(WRITE "${_tz_cc}" "// stubbed out by toolchain: no WinRT globalization\n")
        message(STATUS "Stubbed out time_zone_lookup.cc (empty file)")
    else()
        message(WARNING "time_zone_lookup.cc not found to stub out")
    endif()
endif()

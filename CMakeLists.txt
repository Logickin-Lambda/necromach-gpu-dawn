
cmake_minimum_required(VERSION 3.20)
project(NecroMachZgpu LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/libs/dawn" EXCLUDE_FROM_ALL)
set_target_properties(webgpu_dawn PROPERTIES EXCLUDE_FROM_ALL FALSE)

if (WIN32)
    add_library(mingw_helpers STATIC "src/dawn/mingw_helpers.cpp")
    target_link_libraries(webgpu_dawn PRIVATE mingw_helpers)
endif()

# As a last resort, after trying everything else, some files must be patched.
# Doing that from here for now rather than maintaining forks of these giant libs

if (WIN32)
    # Disable Abseil’s WinRT globalization path by patching its source
    set(_tz_cc
        "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/third_party/abseil-cpp/absl/time/internal/cctz/src/time_zone_lookup.cc"
    )
    if (EXISTS "${_tz_cc}")
        file(READ "${_tz_cc}" _orig_tz)
        string(REPLACE
            "    (_WIN32_WINNT >= _WIN32_WINNT_WINXP)"
            "    (_WIN32_WINNT >= _WIN32_WINNT_WINXP) && false // necromach change - eat it, microshaft"
            _patched_tz
            "${_orig_tz}"
        )
        file(WRITE "${_tz_cc}" "${_patched_tz}")
        message(STATUS "Patched time_zone_lookup.cc")
    else()
        message(WARNING "time_zone_lookup.cc not found to patch")
    endif()
endif()

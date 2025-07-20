
cmake_minimum_required(VERSION 3.20)

# include("${CMAKE_CURRENT_LIST_DIR}/zig-toolchain.cmake")

project(NecroMachZgpu LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/libs/dawn" EXCLUDE_FROM_ALL)
set_target_properties(dawn_native PROPERTIES EXCLUDE_FROM_ALL FALSE)


# set(_shim "${CMAKE_CURRENT_LIST_DIR}/windows_shims.h")
# get_target_property(_srcs dawn_native SOURCES)
# foreach(_src IN LISTS _srcs)
#   if(_src MATCHES "third_party/dxc/lib/MSSupport/MSFileSystemImpl\\.cpp$")
#     set_source_files_properties(
#       "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/${_src}"
#       PROPERTIES
#         COMPILE_OPTIONS "-include;${_shim}"
#     )
#     message(STATUS "→ Shimmed: ${_src}")
#   endif()
# endforeach()


# find_library(DXGUID_LIB dxguid HINTS "${_WINSDK_ROOT}/Lib/${_WINSDK_VER}/um/x64")
# find_library(UUID_LIB uuid HINTS "${_WINSDK_ROOT}/Lib/${_WINSDK_VER}/um/x64")
# find_library(OLE32_LIB ole32 HINTS "${_WINSDK_ROOT}/Lib/${_WINSDK_VER}/um/x64")
# target_link_libraries(dawn_native PRIVATE ${DXGUID_LIB} ${UUID_LIB} ${OLE32_LIB})


# set(_SHIMS_H "${CMAKE_CURRENT_LIST_DIR}/src/shims.h")
# set(_msfs_impl
#     "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/third_party/dxc/lib/MSSupport/MSFileSystemImpl.cpp")
# if (EXISTS "${_msfs_impl}")
# message(STATUS "Inserting shim.h for MSFileSystemImpl.cpp")
# set_source_files_properties(${_msfs_impl}
#     PROPERTIES
#     COMPILE_FLAGS "-include ${_SHIMS_H}"
# )
# endif()


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

# if (WIN32)
#     file(READ
#     "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/third_party/abseil-cpp/absl/time/internal/cctz/src/time_zone_lookup.cc"
#     _txt
#     )
#     string(REGEX REPLACE
#     "(#if \\(\\(defined\\(_WIN32_WINNT_WIN10\\)[\\s\\S]*?\\#endif\\s*)"
#     "/* WinRT globalization stubbed out */\n#if 0\n\\1#endif\n"
#     _newtxt
#     "${_txt}"
#     )
#     file(WRITE
#     "${CMAKE_CURRENT_LIST_DIR}/libs/dawn/third_party/abseil-cpp/absl/time/internal/cctz/src/time_zone_lookup.cc"
#     "${_newtxt}"
#     )
#     message(STATUS "Patched CCTZ time_zone_lookup.cc to remove WinRT globalization")
# endif()
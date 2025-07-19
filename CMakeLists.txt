
cmake_minimum_required(VERSION 3.20)

include("${CMAKE_CURRENT_LIST_DIR}/zig-toolchain.cmake")

project(NecroMachZgpu LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/libs/dawn")


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

if (WIN32)
    add_library(mingw_helpers STATIC "src/dawn/mingw_helpers.cpp")
    target_link_libraries(dawn_native PRIVATE mingw_helpers)
endif()

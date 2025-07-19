# zig-project-patch.cmake
# This gets loaded right after the top-level project() in Dawn’s CMakeLists.txt

if (WIN32)
    # message(STATUS "››› Patching LLVMMSSupport to #define _MSC_VER for WinIncludes.h")
    # target_compile_definitions(LLVMMSSupport PRIVATE _MSC_VER=1920)

    if(TARGET dawn_native)
        target_compile_options(dawn_native PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-include${CMAKE_SOURCE_DIR}/src/dawn/common/windows_with_undefs.h>)
    endif()

    if(TARGET dawn_native_objects)
        target_compile_options(dawn_native_objects PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-include${CMAKE_SOURCE_DIR}/src/dawn/common/windows_with_undefs.h>)
    endif()
    
endif()
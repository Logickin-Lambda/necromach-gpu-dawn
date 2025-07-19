# zig-project-patch.cmake
# This gets loaded right after the top-level project() in Dawn’s CMakeLists.txt

if (WIN32)
    # message(STATUS "››› Patching LLVMMSSupport to #define _MSC_VER for WinIncludes.h")
    # target_compile_definitions(LLVMMSSupport PRIVATE _MSC_VER=1920)

    # if(TARGET dawn_native)
    #     target_compile_options(dawn_native PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-include${CMAKE_SOURCE_DIR}/src/dawn/common/windows_with_undefs.h>)
    # endif()

    # if(TARGET dawn_native_objects)
    #     target_compile_options(dawn_native_objects PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-include${CMAKE_SOURCE_DIR}/src/dawn/common/windows_with_undefs.h>)
    # endif()




    # set(_mss_impl
    # "${CMAKE_SOURCE_DIR}/third_party/dxc/lib/MSSupport/MSFileSystemImpl.cpp"
    # )
    # if (EXISTS "${_mss_impl}")
    # message(STATUS "Defining _MSC_VER=1920 only for MSFileSystemImpl.cpp")
    # set_source_files_properties(${_mss_impl}
    #     PROPERTIES
    #     COMPILE_OPTIONS "-D_MSC_VER=1920"
    # )
    # else()
    #     message(FATAL "Can't Find ${_mss_impl}")
    # endif()



    # set(_tzl_impl
    #     "${CMAKE_SOURCE_DIR}/third_party/abseil-cpp/absl/time/internal/cctz/src/time_zone_lookup.cc")
    # if (EXISTS "${_tzl_impl}")
    # message(STATUS "Inserting shim.h for time_zone_lookup.cc")
    # set_source_files_properties(${_tzl_impl}
    #     PROPERTIES
    #     COMPILE_FLAGS "-include ${_SHIMS_H}"
    # )
    # endif()





    # set(_MINGW_GUIDS_CPP
    #     "${CMAKE_CURRENT_LIST_DIR}/src/dawn/mingw_helpers.cpp"
    # )
    # if (EXISTS "${_MINGW_GUIDS_CPP}")
    #     message(STATUS "Adding MinGW GUID impl: ${_MINGW_GUIDS_CPP}")
    #     if (TARGET webgpu_dawn)
    #         target_sources(webgpu_dawn PRIVATE "${_MINGW_GUIDS_CPP}")
    #     endif()
    # else()
    #     message(WARN
    #     "Can't find ${_MINGW_GUIDS_CPP}")
    # endif()




    
endif()
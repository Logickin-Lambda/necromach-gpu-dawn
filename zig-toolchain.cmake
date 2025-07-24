# zig-toolchain.cmake

# One of these may be passed on the CLI:
#   -DTARGET=x86_64-linux-gnu
#   -DTARGET=x86_64-windows-gnu
#   -DTARGET=aarch64-apple-darwin

# Grab host info (already populated by CMake) e.g. Linux, Darwin, or Windows
message(STATUS "Host system: ${CMAKE_HOST_SYSTEM_NAME}/${CMAKE_HOST_SYSTEM_PROCESSOR}")

find_program(ZIG_EXECUTABLE zig REQUIRED
    DOC "Zig compiler driver"
)

# Only set TARGET if the user didn't supply -DTARGET=…
if(NOT DEFINED TARGET)
    # Lowercase the host OS for a triple suffix
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(_os linux-gnu)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(_os apple-darwin)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(_os windows-gnu)
    else()
        message(FATAL_ERROR "Unsupported host: ${CMAKE_HOST_SYSTEM_NAME}")
    endif()

    # Lowercase the CPU
    string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" _host_arch_lc)

    # Normalize CPU to Zig’s preferred names
    if(_host_arch_lc MATCHES "^(amd64|x86_64)$")
        set(_arch x86_64)
    elseif(_host_arch_lc MATCHES "^(arm64|aarch64)$")
        set(_arch aarch64)
    else()
        message(FATAL_ERROR
                "Unrecognized host CPU: ${CMAKE_HOST_SYSTEM_PROCESSOR}. "
                "Please pass -DTARGET=<triple> explicitly."
        )
    endif()

    # Build and cache the default triple
    set(TARGET "${_arch}-${_os}"
            CACHE STRING "Target triple for Zig (user may override with -DTARGET=…)" )
    message(STATUS "Defaulting TARGET to ${TARGET}")
endif()

# Parse the triple to pick the CMake SYSTEM
string(REGEX MATCH "windows" _is_win "${TARGET}")
string(REGEX MATCH "darwin|apple" _is_mac "${TARGET}")
if(_is_win)
    set(CMAKE_SYSTEM_NAME Windows CACHE INTERNAL "")
elseif(_is_mac)
    set(CMAKE_SYSTEM_NAME Darwin CACHE INTERNAL "")
else()
    set(CMAKE_SYSTEM_NAME Linux CACHE INTERNAL "")
endif()

# Always set the target CPU from the triple prefix (could parse "${TARGET}" further to get arm vs. x86)
if(${TARGET} MATCHES "^aarch64")
    set(CMAKE_SYSTEM_PROCESSOR aarch64 CACHE INTERNAL "")
else()
    set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE INTERNAL "")
endif()

# Set C compiler to zig cc
if (WIN32)
    # Create executable wrapper for `zig cc` which can be called as a single argument for poor inept Windows
    set(_zig_c_wrapper "${CMAKE_BINARY_DIR}/zig-c.bat")
    file(WRITE "${_zig_c_wrapper}"
        "@echo off\r\n"
        "REM Auto‑generated wrapper to call zig cc from CMake\r\n"
        "\"${ZIG_EXECUTABLE}\" cc %*\r\n"
    )
    set(CMAKE_C_COMPILER "${_zig_c_wrapper}" CACHE FILEPATH "C compiler (Zig cc)" FORCE)
else()
    # Otherwise just do the sane thing for real operating systems
    set(CMAKE_C_COMPILER ${ZIG_EXECUTABLE} cc CACHE FILEPATH "C compiler (Zig cc)" FORCE)
endif()

# Set C++ compiler to zig c++
if (WIN32)
    # Create executable wrapper for `zig c++` which can be called as a single argument for poor inept Windows
    set(_zig_cpp_wrapper "${CMAKE_BINARY_DIR}/zig-cpp.bat")
    file(WRITE "${_zig_cpp_wrapper}"
        "@echo off\r\n"
        "REM Auto‑generated wrapper to call zig c++ from CMake\r\n"
        "\"${ZIG_EXECUTABLE}\" c++ %*\r\n"
    )
    set(CMAKE_CXX_COMPILER "${_zig_cpp_wrapper}" CACHE FILEPATH "C++ compiler (Zig c++)" FORCE)
else()
    # Otherwise just do the sane thing for real operating systems
    set(CMAKE_CXX_COMPILER ${ZIG_EXECUTABLE} c++ CACHE FILEPATH "C++ compiler (Zig c++)" FORCE)
endif()

# Set archiver/ranlib to zig ar
if (WIN32)
    # Create executable wrapper for `zig ar` which can be called as a single argument for poor inept Windows
    set(_zig_ar_wrapper "${CMAKE_BINARY_DIR}/zig-ar.bat")
    file(WRITE "${_zig_ar_wrapper}"
        "@echo off\r\n"
        "REM Auto‑generated wrapper to call zig ar from CMake\r\n"
        "if \"%~1\"==\"qc\" (\r\n"
        "  REM archive step: qc <archive> <objs...>\r\n"
        "  \"${ZIG_EXECUTABLE}\" ar %*\r\n"
        ") else (\r\n"
        "  REM ranlib step: only <archive> passed -> index it\r\n"
        "  \"${ZIG_EXECUTABLE}\" ar s %1\r\n"
        ")\r\n"
    )
    set(CMAKE_AR "${_zig_ar_wrapper}" CACHE FILEPATH "Archiver (zig ar)" FORCE)
    set(CMAKE_RANLIB "${_zig_ar_wrapper}" CACHE FILEPATH "Ranlib (zig ar)" FORCE)
else()
    # Otherwise just do the sane thing for real operating systems
    set(CMAKE_AR ${ZIG_EXECUTABLE} ar CACHE FILEPATH "Archiver (zig ar)" FORCE)
    set(CMAKE_RANLIB ${ZIG_EXECUTABLE} ar s CACHE FILEPATH "Ranlib (zig ar)" FORCE)
endif()

if (WIN32)
    find_program(RC_PROG windres 
        HINTS ENV PATH 
        DOC "Resource compiler (windres) from GNU binutils")
    if (RC_PROG)
        set(CMAKE_RC_COMPILER "${RC_PROG}"
            CACHE FILEPATH "Resource compiler (windres)" FORCE)
    else()
        message(STATUS "No windres found; stubbing CMAKE_RC_COMPILER to zig")
        set(CMAKE_RC_COMPILER "${ZIG_EXECUTABLE}"
            CACHE FILEPATH "Resource compiler (stubbed to zig)" FORCE)
    endif()
endif()

# Tell Zig which triple to emit
set(CMAKE_C_COMPILER_TARGET ${TARGET} CACHE INTERNAL "")
set(CMAKE_CXX_COMPILER_TARGET ${TARGET} CACHE INTERNAL "")

# Set the flags passed to zig cc and zig c++ (and linker) in release mode
# set(CMAKE_C_FLAGS_RELEASE "-O3 -g0 -DNDEBUG -fno-exceptions -fno-rtti" CACHE INTERNAL "")
# set(CMAKE_CXX_FLAGS_RELEASE "-O3 -g0 -DNDEBUG -fno-exceptions -fno-rtti" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE "-O3 -g0 -DNDEBUG -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -g0 -DNDEBUG -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections" CACHE INTERNAL "")

# Static libs only, assuming any targets actually listen
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# Cross-compile mode tweaks
set(CMAKE_CROSSCOMPILING TRUE CACHE INTERNAL "")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY CACHE INTERNAL "")

# Setting options that make sense for a Zig build
set(DAWN_ENABLE_D3D11 OFF CACHE BOOL "Enable compilation of the D3D11 backend")
set(DAWN_ENABLE_DESKTOP_GL OFF CACHE BOOL "Enable compilation of the OpenGL backend")
set(DAWN_ENABLE_OPENGLES OFF CACHE BOOL "Enable compilation of the OpenGL ES backend")

set(DAWN_USE_WINDOWS_UI OFF CACHE BOOL "Enable support for Windows UI surface")
set(DAWN_FETCH_DEPENDENCIES ON CACHE BOOL "Use fetch_dawn_dependencies.py as an alternative to using depot_tools")
set(DAWN_BUILD_SAMPLES OFF CACHE BOOL "Enables building Dawn's samples")
set(DAWN_BUILD_TESTS OFF CACHE BOOL "Enables building Dawn's tests")
set(DAWN_BUILD_MONOLITHIC_LIBRARY ON CACHE BOOL "Bundle all dawn components into a single shared library.")
set(DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG OFF CACHE BOOL "Enable DXC asserts in non-debug builds")
set(DAWN_USE_BUILT_DXC ON CACHE BOOL "Enable building and using DXC by the D3D12 backend")

set(TINT_BUILD_CMD_TOOLS OFF CACHE BOOL "Build the Tint command line tools")
set(TINT_BUILD_TESTS OFF CACHE BOOL "Build tests")

set(HLSL_INCLUDE_TESTS OFF CACHE BOOL "Generate build targets for the HLSL unit tests.")
# set(HLSL_BUILD_DXILCONV OFF CACHE BOOL "Include DXBC to DXIL converter and tools.")

# # set(LLVM_INCLUDE_TOOLS OFF CACHE BOOL "Generate build targets for the LLVM tools.")
# set(LLVM_BUILD_TOOLS OFF CACHE BOOL "Build the LLVM tools. If OFF, just generate build targets.")
# set(LLVM_INCLUDE_UTILS OFF CACHE BOOL "Generate build targets for the LLVM utils.")
set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "Build the LLVM example programs. If OFF, just generate build targets.")
set(LLVM_BUILD_EXAMPLES OFF CACHE BOOL "Generate build targets for the LLVM examples")
set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "Generate build targets for the LLVM unit tests.")
set(LLVM_BUILD_TESTS OFF CACHE BOOL "Build LLVM unit tests. If OFF, just generate build targets.")
set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "Generate build targets for llvm documentation.")
set(LLVM_BUILD_DOCS OFF CACHE BOOL "Build the llvm documentation.")
set(LLVM_ENABLE_RTTI OFF CACHE BOOL "Enable run time type information")
set(LLVM_ENABLE_EH OFF CACHE BOOL "Enable Exception handling")

# set(LLVM_DISTRIBUTION_COMPONENTS "dxcompiler" CACHE STRING "")

if (WIN32)
    add_compile_definitions(
        _SH_DENYNO=0x40   # permit read+write sharing
        _S_IREAD=0x0100   # owner‐read permission
        _S_IWRITE=0x0080  # owner‐write permission
    )
    message(STATUS "Defining _SH_DENYNO, _S_IREAD, _S_IWRITE for Windows-gnu build")
endif()

if (WIN32)
    add_compile_definitions(
        HRESULT=long      # Please just die, Windows.
        _HRESULT_DEFINED  # No, really. Just die.
    )
    message(STATUS "Defining HRESULT, _HRESULT_DEFINED for Windows-gnu build")
endif()

if (WIN32)
    # Slim down windows.h and avoid min/max macros
    add_compile_definitions(WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)

    # Let D3D headers be included in any order
    add_compile_definitions(D3D10_ARBITRARY_HEADER_ORDERING)

    # Tell LLVM/Tint/DXC we really are on Win32 with PSAPI etc.
    add_compile_definitions(MSFT_SUPPORTS_CHILD_PROCESSES=1 HAVE_LIBPSAPI=1 HAVE_LIBSHELL32=1 LLVM_ON_WIN32=1)

    message(STATUS
    "Introducing a bunch more definitions/macros for Windows-gnu build:\n"
    "\tWIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS"
    "\tD3D10_ARBITRARY_HEADER_ORDERING"
    "\tMSFT_SUPPORTS_CHILD_PROCESSES=1 HAVE_LIBPSAPI=1 HAVE_LIBSHELL32=1 LLVM_ON_WIN32=1"
    )
endif()

if (WIN32)
    # Determine the SDK root:
    if (DEFINED ENV{WindowsSdkDir})
        set(_WINSDK_ROOT "$ENV{WindowsSdkDir}")
    else()
    # Try the two usual install locations
    set(_candidates
        "C:/Program Files (x86)/Windows Kits/10"
        "C:/Program Files/Windows Kits/10"
    )
    foreach(_cand IN LISTS _candidates)
        if (EXISTS "${_cand}")
            set(_WINSDK_ROOT "${_cand}")
            break()
        endif()
    endforeach()
    endif()

    if (NOT DEFINED _WINSDK_ROOT)
        message(FATAL_ERROR
        "Could not locate Windows 10 SDK.\n"
        "Please install the Windows 10 SDK or set the WindowsSdkDir env var."
        )
    endif()

    # Pick the highest‐versioned Include subfolder
    file(GLOB _inc_dirs LIST_DIRECTORIES true
        "${_WINSDK_ROOT}/Include/[0-9]*")
    list(SORT _inc_dirs)
    list(GET _inc_dirs -1 _LATEST)
    get_filename_component(_WINSDK_VER ${_LATEST} NAME)

    message(STATUS "Using Windows SDK ${_WINSDK_VER} at ${_WINSDK_ROOT}")

    # Inject the core SDK headers as SYSTEM includes
    include_directories(
        SYSTEM
        "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/um"
        "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/shared"
        "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/ucrt"
        "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/winrt"
    )
endif()

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
set(DAWN_BUILD_MONOLITHIC_LIBRARY OFF CACHE BOOL "Bundle all dawn components into a single shared library.")
set(DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG OFF CACHE BOOL "Enable DXC asserts in non-debug builds")
# set(DAWN_USE_BUILT_DXC ON CACHE BOOL "Enable building and using DXC by the D3D12 backend")

set(TINT_BUILD_CMD_TOOLS OFF CACHE BOOL "Build the Tint command line tools")
set(TINT_BUILD_TESTS OFF CACHE BOOL "Build tests")

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)




# Load the project patch file after Dawn's top level CMakeLists.txt
# set(CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/zig-patch-project.cmake" CACHE INTERNAL "")





set(_SHIMS_H "${CMAKE_CURRENT_LIST_DIR}/src/shims.h")
# add_compile_options(
#   $<$<COMPILE_LANGUAGE:C>:-include${_SHIMS_H}>
#   $<$<COMPILE_LANGUAGE:CXX>:-include${_SHIMS_H}>
# )
# message(STATUS "Will -include ${_SHIMS_H} in all TUs")





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










# if (WIN32)
#   set(_stub "${CMAKE_BINARY_DIR}/atlbase.h")
#   file(WRITE "${_stub}"
#   "  // build/atlbase.h (auto‑generated stub)\n"
#   "  #pragma once\n"
#   "  namespace ATL {\n"
#   "  template<typename T>\n"
#   "  class CComPtr {\n"
#   "  public:\n"
#   "      CComPtr() = default;\n"
#   "      CComPtr(T* p) : ptr_(p) {}\n"
#   "      ~CComPtr() { if (ptr_) ptr_->Release(); }\n"
#   "      T* operator->() const { return ptr_; }\n"
#   "      operator T*()    const { return ptr_; }\n"
#   "      T** operator&() { return &ptr_; }  // for &validator use\n"
#   "  private:\n"
#   "      T* ptr_ = nullptr;\n"
#   "      // disable copy to avoid double-Release\n"
#   "      CComPtr(const CComPtr&) = delete;\n"
#   "      CComPtr& operator=(const CComPtr&) = delete;\n"
#   "      // allow move\n"
#   "      CComPtr(CComPtr&& o) noexcept : ptr_(o.ptr_) { o.ptr_ = nullptr; }\n"
#   "      CComPtr& operator=(CComPtr&& o) noexcept {\n"
#   "      if (this != &o) { if (ptr_) ptr_->Release(); ptr_ = o.ptr_; o.ptr_ = nullptr; }\n"
#   "      return *this;\n"
#   "      }\n"
#   "  };\n"
#   "  }\n"
#   "  using ATL::CComPtr;\n"
#   )
#   include_directories( BEFORE "${CMAKE_BINARY_DIR}")
#   message(STATUS "Injecting stub atlbase.h so <atlbase.h> and CComPtr<T> exist")
# endif()










# if (WIN32)
#   set(_stub "${CMAKE_BINARY_DIR}/atlbase.h")
#   file(WRITE "${_stub}"
#     "// Auto‑generated stub of ATL for Clang-windows-gnu builds\n"
#     "#pragma once\n"
#     "namespace ATL {\n"
#     "    template <class T> class CComPtrBase {\n"
#     "    protected:\n"
#     "        CComPtrBase() throw() { p = NULL; }\n"
#     "        CComPtrBase(_Inout_opt_ T* lp) throw() { p = lp; if (p != NULL) p->AddRef(); }\n"
#     "        void Swap(CComPtrBase& other) { T* pTemp = p; p = other.p; other.p = pTemp; }\n"
#     "    public:\n"
#     "        typedef T _PtrClass;\n"
#     "        ~CComPtrBase() throw() { if (p) p->Release(); }\n"
#     "        operator T*() const throw() { return p; }\n"
#     "        T& operator*() const { return *p; }\n"
#     "        T** operator&() throw() { return &p; }\n"
#     "        _NoAddRefReleaseOnCComPtr<T>* operator->() const throw() { return (_NoAddRefReleaseOnCComPtr<T>*)p; }\n"
#     "        bool operator!() const throw() { return (p == NULL); }\n"
#     "        bool operator<(_In_opt_ T* pT) const throw() { return p < pT; }\n"
#     "        bool operator!=(_In_opt_ T* pT) const { return !operator==(pT); }\n"
#     "        bool operator==(_In_opt_ T* pT) const throw() { return p == pT; }\n"
#     "        bool operator==(const CComPtrBase& pT) const throw() { return p == pT; }\n"
#     "        void Release() throw() { T* pTemp = p; if (pTemp) { p = NULL; pTemp->Release(); } }\n"
#     "        inline bool IsEqualObject(_Inout_opt_ IUnknown* pOther) throw();\n"
#     "        T* p;\n"
#     "    };\n"
#     "    template <class T> class CComPtr : public CComPtrBase<T> {\n"
#     "    public:\n"
#     "        CComPtr() throw() {}\n"
#     "        CComPtr(_Inout_opt_ T* lp) throw() : CComPtrBase<T>(lp) {}\n"
#     "        CComPtr(_Inout_ const CComPtr<T>& lp) throw() : CComPtrBase<T>(lp.p) {}\n"
#     "        T* operator=(_Inout_opt_ T* lp) throw() { if(this->p!=lp) { CComPtr(lp).Swap(*this); } return *this; }\n"
#     "        template <typename Q> T* operator=(_Inout_ const CComPtr<Q>& lp) throw() { if(!this->IsEqualObject(lp) ) { AtlComQIPtrAssign2((IUnknown**)&this->p, lp, __uuidof(T)); } return *this; }\n"
#     "        T* operator=(_Inout_ const CComPtr<T>& lp) throw() { if(this->p!=lp.p) { CComPtr(lp).Swap(*this); } return *this; }\n"
#     "        CComPtr(_Inout_ CComPtr<T>&& lp) throw() : CComPtrBase<T>() { lp.Swap(*this); }\n"
#     "        T* operator=(_Inout_ CComPtr<T>&& lp) throw() { if (this->p!=lp.p) { CComPtr(static_cast<CComPtr&&>(lp)).Swap(*this); } return *this; }\n"
#     "    };\n"
#     "    template <class T> inline bool CComPtrBase<T>::IsEqualObject(_Inout_opt_ IUnknown* pOther) throw() {\n"
#     "        if (p == NULL && pOther == NULL) return true; // They are both NULL objects\n"
#     "        if (p == NULL || pOther == NULL) return false; // One is NULL the other is not\n"
#     "        CComPtr<IUnknown> punk1;\n"
#     "        CComPtr<IUnknown> punk2;\n"
#     "        p->QueryInterface(__uuidof(IUnknown), (void**)&punk1);\n"
#     "        pOther->QueryInterface(__uuidof(IUnknown), (void**)&punk2);\n"
#     "        return punk1 == punk2;\n"
#     "    }\n"
#     "}\n"
#     "using ATL::CComPtr;\n"
#   )
#   include_directories( BEFORE "${CMAKE_BINARY_DIR}")
#   message(STATUS "Injecting stub atlbase.h so <atlbase.h> and CComPtr<T> exist")
# endif()





# if (WIN32)
#     # Target Windows XP (or lower) so the Win10 branch never fires
#     add_compile_definitions(_WIN32_WINNT=0x0501)
#     message(STATUS "Forcing _WIN32_WINNT=0x0501 to disable windows.globalization.h path")
# endif()




## — only if we’re targeting Windows (native or cross-compile) —
#if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
#
#    # 1) Figure out where the Windows 10 SDK is installed.
#    #    If you’re in an MSVC env, Visual Studio sets this for you:
#    if(DEFINED ENV{WindowsSdkDir})
#        set(_WINSDK_ROOT "$ENV{WindowsSdkDir}")
#    else()
#        message(FATAL_ERROR
#                "WindowsSdkDir environment variable not set; please install the "
#                "Windows 10 SDK or set WindowsSdkDir yourself.")
#    endif()
#
#    # 2) Pick the highest-version subfolder under Include/
#    file(GLOB _win_inc_dirs "${_WINSDK_ROOT}/Include/*")
#    list(SORT _win_inc_dirs)
#    list(GET _win_inc_dirs -1 _LATEST_SDK_DIR)
#    get_filename_component(_WINSDK_VER ${_LATEST_SDK_DIR} NAME)
#    message(STATUS "Using Windows SDK ${_WINSDK_VER} from ${_WINSDK_ROOT}")
#
#    # 3) Globally add the SDK’s um, shared, winrt and ucrt folders
#    include_directories(
#            SYSTEM
#            "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/um"
#            "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/shared"
#            "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/winrt"
#            "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/ucrt"
#    )
#
#endif()



# Get some compiler details so that CMake can hopefully skip a bunch of tests that give non-fatal error output clutter
#find_program(ZIG_BIN zig)
#if(ZIG_BIN)
#    execute_process(COMMAND ${ZIG_BIN} c++ --version OUTPUT_VARIABLE _zig_cxx_out OUTPUT_STRIP_TRAILING_WHITESPACE)
#    string(REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" _clang_ver "${_zig_cxx_out}")
#    message(STATUS "Detected Clang version: ${_clang_ver}")
#    set(CMAKE_C_COMPILER_ID "Clang" CACHE STRING "" FORCE)
#    set(CMAKE_CXX_COMPILER_ID "Clang" CACHE STRING "" FORCE)
#    set(CMAKE_C_COMPILER_VERSION "${_clang_ver}" CACHE STRING "" FORCE)
#    set(CMAKE_CXX_COMPILER_VERSION "${_clang_ver}" CACHE STRING "" FORCE)
#    set(CMAKE_C_COMPILER_WORKS TRUE CACHE INTERNAL "" FORCE)
#    set(CMAKE_CXX_COMPILER_WORKS TRUE CACHE INTERNAL "" FORCE)
#
#    set(CMAKE_C_STANDARD_COMPUTED_DEFAULT      11    CACHE INTERNAL "" FORCE)
#    set(CMAKE_C_EXTENSIONS_COMPUTED_DEFAULT    ON    CACHE INTERNAL "" FORCE)
#    set(CMAKE_CXX_STANDARD_COMPUTED_DEFAULT    17    CACHE INTERNAL "" FORCE)
#    set(CMAKE_CXX_EXTENSIONS_COMPUTED_DEFAULT  ON    CACHE INTERNAL "" FORCE)
#
#    set(CMAKE_C_COMPILER_LOADED   TRUE CACHE INTERNAL "" FORCE)
#    set(CMAKE_CXX_COMPILER_LOADED TRUE CACHE INTERNAL "" FORCE)
#endif()



# if (WIN32)
#   message(STATUS ">>> Injecting Windows SDK include paths")

#   # Locate the SDK root (use the same registry lookup CMake does)
#   execute_process(
#     COMMAND "${CMAKE_COMMAND}" -E environment
#     OUTPUT_VARIABLE _cm_env_raw
#   )
#   # CMake on Windows will already have set WindowsSdkDir in that
#   # environment.  We pull it back out:
#   string(REGEX MATCH "WindowsSdkDir=([^\r\n]+)" _match "${_cm_env_raw}")
#   if(NOT _match)
#     message(FATAL_ERROR "Could not find WindowsSdkDir in CMake environment")
#   endif()
#   string(REGEX REPLACE "WindowsSdkDir=([^\r\n]+)" "\\1" _WINSDK_ROOT "${_match}")
#   message(STATUS ">>> WindowsSdkDir is ${_WINSDK_ROOT}")

#   # Pick the latest versioned include folder
#   file(GLOB _inc_dirs LIST_DIRECTORIES true "${_WINSDK_ROOT}/Include/*")
#   list(SORT _inc_dirs)
#   list(GET _inc_dirs -1 _LATEST)
#   get_filename_component(_WINSDK_VER ${_LATEST} NAME)
#   message(STATUS ">>> Using Windows SDK version ${_WINSDK_VER}")

#   # Inject the headers
#   include_directories(
#     SYSTEM
#       "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/um"
#       "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/shared"
#       "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/ucrt"
#       "${_WINSDK_ROOT}/Include/${_WINSDK_VER}/winrt"
#   )
# endif()

# if (WIN32)
#     # Tell Clang to pretend every TU starts with <windows.h>
#     add_compile_options(-include "windows.h")
#     message(STATUS "Forcing all files to be compiled with <windows.h> pre-included")
# endif()

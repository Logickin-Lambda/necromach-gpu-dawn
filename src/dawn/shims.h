// windows_shims.h
#pragma once

#ifdef _WIN32

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"

// #ifndef _SH_DENYNO
//   #define _SH_DENYNO 0
// #endif
// #ifndef _S_IREAD
//   #define _S_IREAD  0x0100
// #endif
// #ifndef _S_IWRITE
//   #define _S_IWRITE 0x0080
// #endif

// // #ifndef WIN32_LEAN_AND_MEAN
// //   #define WIN32_LEAN_AND_MEAN
// // #endif
// #ifndef NOMINMAX
//   #define NOMINMAX
// #endif
// #ifndef _CRT_SECURE_NO_WARNINGS
//   #define _CRT_SECURE_NO_WARNINGS
// #endif

// #ifndef _HRESULT_DEFINED
//   #define _HRESULT_DEFINED
//   typedef long HRESULT;
// #endif

// #ifndef __EMULATE_UUID
//   #define __EMULATE_UUID
// #endif

// #ifndef __EMULATE_UUID
//   #define __EMULATE_UUID
//   typedef struct _GUID {
//     unsigned long  Data1;
//     unsigned short Data2;
//     unsigned short Data3;
//     unsigned char  Data4[8];
//   } GUID;
// #endif

// #ifndef UNREFERENCED_PARAMETER
//   #define UNREFERENCED_PARAMETER(x) (void)(x)
// #endif

// #ifndef MSFT_SUPPORTS_CHILD_PROCESSES
//   #define MSFT_SUPPORTS_CHILD_PROCESSES 1
// #endif
// #ifndef HAVE_LIBPSAPI
//   #define HAVE_LIBPSAPI 1
// #endif
// #ifndef HAVE_LIBSHELL32
//   #define HAVE_LIBSHELL32 1
// #endif
// #ifndef LLVM_ON_WIN32
//   #define LLVM_ON_WIN32 1
// #endif

// #ifndef D3D10_ARBITRARY_HEADER_ORDERING
//   #define D3D10_ARBITRARY_HEADER_ORDERING
// #endif






/********************************************************************
 * STUFF THAT SHOULD HAVE COME FROM WinAdapter.h IF IT WEREN'T BROKEN
 ********************************************************************/
// #ifdef __cplusplus
// typedef bool BOOL;
// typedef uint32_t DWORD;
// typedef const wchar_t *LPCWSTR;
// typedef void *HANDLE;
// typedef struct _FILETIME {
//   DWORD dwLowDateTime;
//   DWORD dwHighDateTime;
// } FILETIME, *PFILETIME, *LPFILETIME;
// typedef struct _WIN32_FIND_DATAW {
//   DWORD dwFileAttributes;
//   FILETIME ftCreationTime;
//   FILETIME ftLastAccessTime;
//   FILETIME ftLastWriteTime;
//   DWORD nFileSizeHigh;
//   DWORD nFileSizeLow;
//   DWORD dwReserved0;
//   DWORD dwReserved1;
//   WCHAR cFileName[260];
//   WCHAR cAlternateFileName[14];
// } WIN32_FIND_DATAW, *PWIN32_FIND_DATAW, *LPWIN32_FIND_DATAW;
// #endif // __cplusplus






// // Speed up Windows.h & avoid min/max pollution
// #ifndef WIN32_LEAN_AND_MEAN
//   #define WIN32_LEAN_AND_MEAN
// #endif
// #ifndef NOMINMAX
//   #define NOMINMAX
// #endif

// // Bring in the real WinSDK headers for HANDLE/BOOL/etc.
// // (assumes your toolchain also adds the SDK um/shared/ucrt/winrt paths)
// #include <windows.h>

// // HRESULT stub if it wasn’t already pulled in
// #ifndef _HRESULT_DEFINED
//   #define _HRESULT_DEFINED
//   typedef long HRESULT;
// #endif

// // Emulate GUID<> so __uuidof<T>() yields inline GUIDs
// #ifndef __EMULATE_UUID
//   #define __EMULATE_UUID
//   typedef struct _GUID {
//     unsigned long  Data1;
//     unsigned short Data2;
//     unsigned short Data3;
//     unsigned char  Data4[8];
//   } GUID;
// #endif

// // Share‑mode & permission flags
// #ifndef _SH_DENYNO
//   #define _SH_DENYNO 0
// #endif
// #ifndef _S_IREAD
//   #define _S_IREAD  0x0100
// #endif
// #ifndef _S_IWRITE
//   #define _S_IWRITE 0x0080
// #endif

// // Stub out UNREFERENCED_PARAMETER
// #ifndef UNREFERENCED_PARAMETER
//   #define UNREFERENCED_PARAMETER(x) (void)(x)
// #endif

// // #ifdef __cplusplus
// // // A minimal CComPtr<T> so validate.cc’s CComPtr<IDxcValidator> compiles
// // namespace ATL {
// //   template<typename T>
// //   struct CComPtr {
// //     T* ptr_ = nullptr;
// //     CComPtr() = default;
// //     CComPtr(T* p) : ptr_(p) {}
// //     ~CComPtr() { if (ptr_) ptr_->Release(); }
// //     T* operator->() const { return ptr_; }
// //     operator T*()      const { return ptr_; }
// //     T** operator&()          { return &ptr_; }

// //     // disable copy, allow move
// //     CComPtr(const CComPtr&) = delete;
// //     CComPtr& operator=(const CComPtr&) = delete;
// //     CComPtr(CComPtr&& o) noexcept : ptr_(o.ptr_) { o.ptr_ = nullptr; }
// //     CComPtr& operator=(CComPtr&& o) noexcept {
// //       if (this != &o) {
// //         if (ptr_) ptr_->Release();
// //         ptr_ = o.ptr_;
// //         o.ptr_ = nullptr;
// //       }
// //       return *this;
// //     }
// //   };
// // }
// // using ATL::CComPtr;
// // #endif  // __cplusplus







#pragma clang diagnostic pop

#endif // _WIN32

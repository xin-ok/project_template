#pragma once

/**
 * @file shared_lib_export.h
 * @brief 共享库导入/导出符号宏定义。
 *
 * 根据编译平台与编译配置，将 @ref SHAREDLIB_API 定义为合适的符号可见性属性：
 * - Windows / Cygwin：使用 `__declspec(dllexport/dllimport)`；
 * - 其他平台（GCC/Clang 等）：使用 `__attribute__((visibility("default")))`；
 * - 静态链接或非共享库场景：定义为空，不影响普通编译。
 *
 * @note 依赖以下两个编译期宏进行配置：
 *       - @c SHAREDLIB_SHARED：表示当前目标为共享库（DLL / .so）。
 *       - @c SHAREDLIB_EXPORT：表示当前处于“导出”编译单元（库本身），
 *         否则视为“导入”编译单元（使用库的一方）。
 */

// clang-format off
#if defined(_WIN32) || defined(__CYGWIN__)
  #ifdef SHAREDLIB_SHARED
    #ifdef SHAREDLIB_EXPORT
      #define SHAREDLIB_API __declspec(dllexport)  ///< Windows：导出符号。
    #else
      #define SHAREDLIB_API __declspec(dllimport)  ///< Windows：导入符号。
    #endif
  #else
    #define SHAREDLIB_API  ///< Windows：静态链接，无需修饰。
  #endif
#else
  #if defined(SHAREDLIB_SHARED) && defined(SHAREDLIB_EXPORT)
    #define SHAREDLIB_API __attribute__((visibility("default")))  ///< 非 Windows：默认可见性导出。
  #else
    #define SHAREDLIB_API  ///< 非 Windows：非导出场景，无需修饰。
  #endif
#endif
// clang-format on
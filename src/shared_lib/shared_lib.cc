/**
 * @file shared_lib.cc
 * @brief 共享库实现文件。
 *
 * 包含共享库函数的实现，以及 Windows 平台下 DLL 的入口函数 DllMain。
 * 预编译头（pch.h）由 CMake 统一管理并自动包含，无需在此手动 include。
 */

// #include "pch.h"  // 通过 cmake 管理，可以不用手动包含预编译头

#include "shared_lib/shared_lib.h"

#ifdef _WIN32

/**
 * @brief Windows DLL 入口函数（DllMain）。
 *
 * 在 DLL 被加载、卸载以及线程创建、销毁时由系统调用，
 * 用于执行进程/线程级别的初始化与清理工作。
 *
 * @param hModule            当前 DLL 的模块句柄（未使用）。
 * @param ul_reason_for_call 调用原因，见下表：
 *        - @c DLL_PROCESS_ATTACH DLL 被加载到进程时调用；
 *        - @c DLL_THREAD_ATTACH  新线程被创建时调用（主线程除外）；
 *        - @c DLL_THREAD_DETACH  线程退出时调用；
 *        - @c DLL_PROCESS_DETACH DLL 从进程中卸载时调用。
 * @param lpReserved         保留参数（未使用）。
 *
 * @return 返回 @c TRUE 表示初始化成功。
 *
 * @warning 不要在此函数中调用 LoadLibrary，以避免加载器锁死锁。
 */
BOOL APIENTRY DllMain(HMODULE hModule,
                      DWORD ul_reason_for_call,
                      LPVOID lpReserved) {
  // 避免未使用参数的编译警告
  (void)hModule;
  (void)ul_reason_for_call;
  (void)lpReserved;

  switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
      // DLL 被加载到进程时调用
      // 适合做：初始化资源、创建全局对象等
      // 注意：不要在这里调用 LoadLibrary！
      std::cout << "DLL_PROCESS_ATTACH" << std::endl;  ///< DLL 加载到进程。
      break;

    case DLL_THREAD_ATTACH:
      // 新线程被创建时调用（主线程除外）
      // 可选，如果不需要可以带 DLL_THREAD_DETACH 一起禁用
      std::cout << "DLL_THREAD_ATTACH"
                << std::endl;  ///< 新线程创建（主线程除外）。
      break;

    case DLL_THREAD_DETACH:
      // 线程退出时调用
      std::cout << "DLL_THREAD_DETACH" << std::endl;  ///< 线程退出。
      break;

    case DLL_PROCESS_DETACH:
      // DLL 从进程中卸载时调用
      // 适合做：释放资源、清理全局对象等
      std::cout << "DLL_PROCESS_DETACH" << std::endl;  ///< DLL 从进程卸载。
      break;
  }
  return TRUE;  // 返回 TRUE 表示初始化成功
}
#endif

void shared_lib() { std::cout << "shared_lib" << std::endl; }
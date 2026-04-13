#pragma once

/**
 * @file shared_lib.h
 * @brief 共享库对外公开接口声明。
 *
 * 定义了共享库中由外部调用方使用的导出函数。
 * 导出符号通过 @ref SHAREDLIB_API 宏适配不同平台的可见性规则
 * （详见 shared_lib/shared_lib_export.h）。
 */
#include "shared_lib/shared_lib_export.h"

/**
 * @brief 共享库示例函数。
 *
 * 打印一条示例信息，用于演示共享库的导出与调用。
 *
 * @note 该函数被 @ref SHAREDLIB_API 修饰，因此会以平台相关的方式
 *       导出到共享库的符号表中。
 */
SHAREDLIB_API void shared_lib();
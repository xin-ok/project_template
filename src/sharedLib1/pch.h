#pragma once

// ============================================================
//  Precompiled Header - 集中放置不常修改的头文件
//  预编译后所有 .cc 复用，大幅加速编译
// ============================================================

// 标准库（几乎不修改，预编译收益大）
#include <iostream>
#include <memory>
#include <string>
#include <vector>

// Windows API（体积大、不常改，预编译效果最明显）
#ifdef _WIN32
#include <windows.h>
#endif
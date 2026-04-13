#include <iostream>

/**
 * @file print_hello.cc
 * @brief 演示在 C++ 中输出 UTF-8 编码的中文字符串。
 *
 * 该程序通过 __has_include 检测标准库是否提供 \<print\> 头文件：
 * - 若可用，则使用 C++23 的 std::println 输出；
 * - 否则回退到 std::cout。
 */

// clang-format off
#ifdef __has_include
  #if __has_include(<print>)
    #include <print>
    #define HAS_PRINT 1
  #endif
#endif
// clang-format on

/**
 * @brief 程序入口。
 *
 * 输出一个 UTF-8 编码的中文字符串（"中" 的 UTF-8 编码为 E4 B8 AD）。
 */
int main() {
#ifdef HAS_PRINT
  std::println("{}", "你好");
#else
  std::cout << "你好" << std::endl;
#endif
}
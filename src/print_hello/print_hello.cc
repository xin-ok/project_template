#include "print_hello/print_hello.h"

/**
 * @brief 程序入口。
 *
 * 输出一个 UTF-8 编码的中文字符串（"中" 的 UTF-8 编码为 E4 B8 AD）。
 */
int main() {
#ifdef HAS_PRINT
  std::println("{}", "你好");
#else
  std::cout << "你好\n";
#endif
}
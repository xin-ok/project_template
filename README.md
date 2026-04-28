# project_template

一个跨平台的 C++ CMake vscode 工程模板，支持 **Linux (GCC)** 和 **Windows (Visual Studio)** 双平台开发。

## 特性

- ✅ **跨平台构建** — 支持 Linux GCC + Ninja 和 Windows Visual Studio 2022
- ✅ **CMake Presets** — 使用 CMake Preset 一键配置、构建、测试、打包
- ✅ **多目标类型** — 可执行程序、静态库（`.a`/`.lib`）、动态库（`.so`/`.dll`）示例
- ✅ **CTest 集成** — 内置测试支持，`cmake --build` 后可直接 `ctest`
- ✅ **CPack 打包** — 一键打包为 `.tar.gz`（Linux）或 `.zip`（Windows）
- ✅ **Sanitizer 支持** — 可选启用 AddressSanitizer / UndefinedBehaviorSanitizer / ThreadSanitizer
- ✅ **代码格式化** — 内置 `.clang-format`（Google 风格）
- ✅ **调试友好** — Debug 模式下生成完整调试信息，禁用优化

## 项目结构

```
project_template/
├── CMakeLists.txt                  # 根 CMake 配置
├── CMakePresets.json               # CMake Preset 配置（核心）
├── .clang-format                   # Google 风格代码格式化配置
├── .gitignore                      # Git 忽略规则
├── clean_all.sh                    # Linux 清理脚本
├── clean_all.bat                   # Windows 清理脚本
├── cmake/
│   ├── GeneralPreset.cmake         # 通用编译选项（警告、调试、Sanitizer）
│   ├── CPackPreset.cmake           # CPack 打包配置
│   └── PrivatePreset.cmake         # 私有/项目特定编译选项
└── src/
    ├── project1/                   # 主可执行程序
    │   ├── CMakeLists.txt
    │   └── project1.cc
    ├── staticLib1/                 # 静态库示例
    │   ├── CMakeLists.txt
    │   ├── staticLib1.h
    │   └── staticLib1.cc
    ├── sharedLib1/                 # 动态库示例（含跨平台导出宏）
    │   ├── CMakeLists.txt
    │   ├── sharedLib1.h
    │   ├── sharedLib1.cc
    │   └── sharedLib1_export.h
    └── TestLib/                    # 测试程序（链接静态库 + 动态库）
        ├── CMakeLists.txt
        └── TestLib.cc
```

## 当前配置环境要求

| 平台 | 编译器 | 构建工具 | CMake 版本 |
|------|--------|----------|------------|
| Linux | GCC 14.2.0 | Ninja | ≥ 3.10 |
| Windows | Visual Studio 2022 | MSBuild | ≥ 3.10 |

以上配置可根据情况自行更改

## 快速开始

在 vscode 下安装 CMake Tools插件选择相应配置执行操作，包含

- 配置
- 生成
- 测试
- 打包
- 安装
- 工作流

## CMakePresets.json 详解

`CMakePresets.json` 是本项目的核心配置文件，它定义了完整的构建生命周期 Preset，包括 **配置 → 构建 → 测试 → 打包 → 工作流** 五个阶段。

### 配置 Preset（configurePresets）

配置 Preset 定义了 CMake 的配置参数，包括生成器、编译器、构建类型和输出目录。

| Preset 名称 | 平台 | 生成器 | 构建类型 | 编译器 | 二进制目录 |
|-------------|------|--------|----------|--------|-----------|
| `vs2022` | Windows | Visual Studio 17 2022 | 多配置（Debug/Release） | MSVC cl.exe | `build/vs2022/` |
| `gcc_14.2.0_debug` | Linux | Ninja | Debug | GCC 14.2.0 | `build/gcc_14.2.0_debug/` |
| `gcc_14.2.0_release` | Linux | Ninja | Release | GCC 14.2.0 | `build/gcc_14.2.0_release/` |

> **注意**: Windows 使用多配置生成器（Visual Studio），构建类型在构建时指定；Linux 使用单配置生成器（Ninja），构建类型在配置时通过 `CMAKE_BUILD_TYPE` 指定。

### 构建 Preset（buildPresets）

构建 Preset 关联到对应的配置 Preset，并指定构建配置（Debug/Release）。

| Preset 名称 | 关联配置 | 构建配置 | 说明 |
|-------------|----------|----------|------|
| `vs2022-debug` | vs2022 | Debug | Windows Debug 构建 |
| `vs2022-release` | vs2022 | Release | Windows Release 构建 |

> Linux 的构建 Preset 未单独定义，因为构建配置已包含在配置 Preset 中，直接使用 `cmake --build build/gcc_14.2.0_debug` 即可。

### 测试 Preset（testPresets）

测试 Preset 关联到对应的配置 Preset，用于运行 CTest。

| Preset 名称 | 关联配置 | 构建配置 | 说明 |
|-------------|----------|----------|------|
| `ctest-vs2022-debug` | vs2022 | Debug | Windows Debug 测试 |
| `ctest-vs2022-release` | vs2022 | Release | Windows Release 测试 |
| `ctest-gcc_14.2.0_debug` | gcc_14.2.0_debug | Debug | Linux Debug 测试 |
| `ctest-gcc_14.2.0_release` | gcc_14.2.0_release | Release | Linux Release 测试 |

### 打包 Preset（packagePresets）

打包 Preset 关联到对应的配置 Preset，用于 CPack 打包。

| Preset 名称 | 关联配置 | 打包格式 | 说明 |
|-------------|----------|----------|------|
| `cpack-vs2022` | vs2022 | ZIP | Windows ZIP 打包 |
| `cpack-gcc_14.2.0_debug` | gcc_14.2.0_debug | TGZ | Linux Debug TGZ 打包 |
| `cpack-gcc_14.2.0_release` | gcc_14.2.0_release | TGZ | Linux Release TGZ 打包 |

> 打包文件输出到 `packages/` 目录，文件名格式：`{项目名}-{版本}-{系统}-{构建类型}.{zip\|tar.gz}`

### 工作流 Preset（workflowPresets）

工作流 Preset 是 CMake Presets 的最高级抽象，它将 **配置 → 构建 → 测试 → 打包** 四个步骤串联成一个命令，实现一键完成整个构建生命周期。

| Preset 名称 | 步骤顺序 | 说明 |
|-------------|----------|------|
| `workflow-vs2022-debug` | configure(vs2022) → build(vs2022-debug) → test(ctest-vs2022-debug) → package(cpack-vs2022) | Windows Debug 完整工作流 |
| `workflow-vs2022-release` | configure(vs2022) → build(vs2022-release) → test(ctest-vs2022-release) → package(cpack-vs2022) | Windows Release 完整工作流 |
| `workflow-gcc_14.2.0_debug` | configure(gcc_14.2.0_debug) → build(gcc_14.2.0_debug) → test(ctest-gcc_14.2.0_debug) → package(cpack-gcc_14.2.0_debug) | Linux Debug 完整工作流 |
| `workflow-gcc_14.2.0_release` | configure(gcc_14.2.0_release) → build(gcc_14.2.0_release) → test(ctest-gcc_14.2.0_release) → package(cpack-gcc_14.2.0_release) | Linux Release 完整工作流 |


### Preset 层级关系图

```
CMakePresets.json
├── configurePresets          # 配置 Preset（定义编译器、生成器、构建类型）
│   ├── vs2022                # Windows: Visual Studio 2022
│   ├── gcc_14.2.0_debug      # Linux: GCC Debug
│   └── gcc_14.2.0_release    # Linux: GCC Release
│
├── buildPresets              # 构建 Preset（关联配置 Preset）
│   ├── vs2022-debug          # → vs2022 (Debug)
│   └── vs2022-release        # → vs2022 (Release)
│
├── testPresets               # 测试 Preset（关联配置 Preset）
│   ├── ctest-vs2022-debug    # → vs2022 (Debug)
│   ├── ctest-vs2022-release  # → vs2022 (Release)
│   ├── ctest-gcc_14.2.0_debug    # → gcc_14.2.0_debug
│   └── ctest-gcc_14.2.0_release  # → gcc_14.2.0_release
│
├── packagePresets            # 打包 Preset（关联配置 Preset）
│   ├── cpack-vs2022          # → vs2022
│   ├── cpack-gcc_14.2.0_debug    # → gcc_14.2.0_debug
│   └── cpack-gcc_14.2.0_release  # → gcc_14.2.0_release
│
└── workflowPresets           # 工作流 Preset（串联多个 Preset）
    ├── workflow-vs2022-debug       # configure → build → test → package
    ├── workflow-vs2022-release     # configure → build → test → package
    ├── workflow-gcc_14.2.0_debug   # configure → build → test → package
    └── workflow-gcc_14.2.0_release # configure → build → test → package
```

## 编译选项详解

### Debug 模式

- **调试信息**: `-g3`（GCC）/ `/Zi`（MSVC）— 最详细的调试信息
- **优化**: `-O0`（GCC）/ `/Od`（MSVC）— 禁用优化，方便调试
- **帧指针**: 保留帧指针，获得更好的堆栈回溯
- **后缀**: 可执行文件自动添加 `d` 后缀（如 `project1d`）

### Release 模式

- **优化**: 默认启用最高优化级别
- **可选**: 可通过 CMake 变量（ENABLE_RELEASE_DEBUG_INFO，DISABLE_RELEASE_OPTIMIZATION）开启 Release 模式的调试信息或禁用优化

### Sanitizer（可选）

在配置时通过 CMake 变量启用或者通过CMake Tools配置：

```bash
# 启用 AddressSanitizer（检测内存错误）
cmake --preset gcc_14.2.0_debug -DENABLE_FSANITIZE_ADDRESS=ON

# 启用 UndefinedBehaviorSanitizer（检测未定义行为）
cmake --preset gcc_14.2.0_debug -DENABLE_FSANITIZE_UNDEFINED=ON

# 启用 ThreadSanitizer（检测数据竞争）
cmake --preset gcc_14.2.0_debug -DENABLE_FSANITIZE_THREAD=ON
```
以上变量默认关闭

> **注意**: Sanitizer 有显著的性能开销，建议仅在 Debug 模式下使用。

## 代码格式化

项目使用 Google C++ 风格指南，配置文件为 `.clang-format`。

## 清理构建产物

```bash
# Linux
./clean_all.sh

# Windows
clean_all.bat

# 或使用 CMake 自定义目标
cmake --build build/gcc_14.2.0_debug --target clean_all_binary
```

## 许可证

本项目仅供学习和参考。

# project_template

一个跨平台的 C++ CMake 工程模板，支持 **Linux (GCC/Clang)** 和 **Windows (Visual Studio)** 双平台开发。

## 特性

- ✅ **跨平台构建** — 支持 Linux GCC/Clang + Ninja 和 Windows Visual Studio 2022
- ✅ **自动生成 Presets** — 一键检测环境，自动生成适配的 CMakePresets.json
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
├── CMakePresets.json               # CMake Preset 配置（由脚本自动生成）
├── .clang-format                   # Google 风格代码格式化配置
├── .gitignore                      # Git 忽略规则
├── clean_all.sh                    # Linux 清理脚本
├── clean_all.bat                   # Windows 清理脚本
├── cmake/
│   ├── GeneratePresets.cmake       # 🔧 自动检测环境并生成 CMakePresets.json
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

## 快速开始

### 第一步：生成 Presets

`CMakePresets.json` 包含了编译器路径等环境相关配置，不同机器上不同。首次使用项目时，先运行自动检测脚本：

```bash
cmake -P cmake/GeneratePresets.cmake
```

脚本会自动检测当前环境的：
- **操作系统** — Linux / Windows
- **编译器** — GCC、Clang、MSVC 及其版本号
- **构建工具** — Ninja、Unix Makefiles、Visual Studio

生成后即可查看可用的 Preset：

```bash
cmake --list-presets
```

### 第二步：配置与构建

```bash
# 配置并构建（以 GCC 14 Debug 为例，具体名称以 --list-presets 输出为准）
cmake --preset gcc_14_debug

# 生成
cmake --build --preset gcc_14_debug

# 运行
./bin/Debug/project1d
./bin/Debug/TestLibd

# 测试
ctest --preset ctest-gcc_14_debug

# 打包
cmake --build --preset gcc_14_debug --target package

# 安装
cmake --install build/gcc_14_debug --prefix install/gcc_14_debug

# 一键工作流
# 配置 → 构建 → 测试 → 打包，一条命令完成：

cmake --workflow --preset workflow-gcc_14_debug

```

以上操作都可以通过 CMake Tools 图形化界面完成

### 在 VS Code 中使用

安装 **CMake Tools** 插件后，插件会自动读取 `CMakePresets.json` 中的 Preset，你可以在 VS Code 底部的状态栏中选择：

- **Kit** — 选择编译器（对应 configurePreset）
- **Build** — 选择构建配置
- **Run CTest** — 运行测试
- **Package** — 打包

## CMakePresets.json 详解

`CMakePresets.json` 由 `cmake/GeneratePresets.cmake` 自动生成，定义了完整的构建生命周期 Preset，包括 **配置 → 构建 → 测试 → 打包 → 工作流** 五个阶段。

### Preset 命名规则

自动生成的 Preset 名称格式如下：

| 平台 | 配置 Preset 名称 | 说明 |
|------|-----------------|------|
| Linux GCC | `gcc_{版本}_debug` / `gcc_{版本}_release` | 如 `gcc_14_debug` |
| Linux Clang | `clang_{版本}_debug` / `clang_{版本}_release` | 如 `clang_20_debug` |
| Windows MSVC | `msvc` | 多配置，构建时指定 Debug/Release |

其他 Preset 类型（build、test、package、workflow）的命名均基于配置 Preset 名称派生：

| Preset 类型 | 命名格式 | 示例 |
|------------|---------|------|
| buildPreset | `{配置名称}` | `gcc_14_debug` |
| testPreset | `ctest-{配置名称}` | `ctest-gcc_14_debug` |
| packagePreset | `cpack-{配置名称}` | `cpack-gcc_14_debug` |
| workflowPreset | `workflow-{配置名称}` | `workflow-gcc_14_debug` |

### 配置 Preset（configurePresets）

配置 Preset 定义了 CMake 的配置参数，包括生成器、编译器、构建类型和输出目录。

- **Linux**: 单配置生成器（Ninja），Debug/Release 各一个 Preset，构建类型在配置时通过 `CMAKE_BUILD_TYPE` 指定
- **Windows**: 多配置生成器（Visual Studio），一个 Preset 包含 Debug/Release，构建类型在构建时指定

### 构建 Preset（buildPresets）

构建 Preset 关联到对应的配置 Preset。

- **Linux**: 直接引用配置 Preset 名称
- **Windows**: 需要为 Debug/Release 各生成一个（如 `msvc-debug`、`msvc-release`）

### 测试 Preset（testPresets）

测试 Preset 关联到对应的配置 Preset，用于运行 CTest。

### 打包 Preset（packagePresets）

打包 Preset 关联到对应的配置 Preset，用于 CPack 打包。

- **Linux**: 打包为 `.tar.gz`，输出到 `packages/` 目录
- **Windows**: 打包为 `.zip`，输出到 `packages/` 目录

### 工作流 Preset（workflowPresets）

工作流 Preset 将 **配置 → 构建 → 测试 → 打包** 四个步骤串联成一个命令：

```bash
cmake --workflow --preset workflow-gcc_14_debug
```

等价于依次执行：

```bash
cmake --preset gcc_14_debug
cmake --build --preset gcc_14_debug
ctest --preset ctest-gcc_14_debug
cmake --build --preset gcc_14_debug --target package
```

### Preset 层级关系图

```
CMakePresets.json
├── configurePresets          # 配置 Preset（定义编译器、生成器、构建类型）
│   ├── gcc_14_debug          # Linux: GCC 14 Debug
│   ├── gcc_14_release        # Linux: GCC 14 Release
│   ├── clang_20_debug        # Linux: Clang 20 Debug
│   ├── clang_20_release      # Linux: Clang 20 Release
│   └── msvc                  # Windows: MSVC（多配置）
│
├── buildPresets              # 构建 Preset（关联配置 Preset）
│   ├── gcc_14_debug          # → gcc_14_debug
│   ├── gcc_14_release        # → gcc_14_release
│   ├── clang_20_debug        # → clang_20_debug
│   ├── clang_20_release      # → clang_20_release
│   ├── msvc-debug            # → msvc (Debug)
│   └── msvc-release          # → msvc (Release)
│
├── testPresets               # 测试 Preset（关联配置 Preset）
│   ├── ctest-gcc_14_debug    # → gcc_14_debug
│   ├── ctest-gcc_14_release  # → gcc_14_release
│   ├── ctest-clang_20_debug  # → clang_20_debug
│   ├── ctest-clang_20_release# → clang_20_release
│   ├── ctest-msvc-debug      # → msvc (Debug)
│   └── ctest-msvc-release    # → msvc (Release)
│
├── packagePresets            # 打包 Preset（关联配置 Preset）
│   ├── cpack-gcc_14_debug    # → gcc_14_debug
│   ├── cpack-gcc_14_release  # → gcc_14_release
│   ├── cpack-clang_20_debug  # → clang_20_debug
│   ├── cpack-clang_20_release# → clang_20_release
│   └── cpack-msvc            # → msvc
│
└── workflowPresets           # 工作流 Preset（串联多个 Preset）
    ├── workflow-gcc_14_debug       # configure → build → test → package
    ├── workflow-gcc_14_release     # configure → build → test → package
    ├── workflow-clang_20_debug     # configure → build → test → package
    ├── workflow-clang_20_release   # configure → build → test → package
    ├── workflow-msvc-debug         # configure → build → test → package
    └── workflow-msvc-release       # configure → build → test → package
```

> 以上名称仅为示例，实际生成的名称取决于你环境中检测到的编译器类型和版本。

## 编译选项详解

### Debug 模式

- **调试信息**: `-g3`（GCC/Clang）/ `/Zi`（MSVC）— 最详细的调试信息
- **优化**: `-O0`（GCC/Clang）/ `/Od`（MSVC）— 禁用优化，方便调试
- **帧指针**: 保留帧指针，获得更好的堆栈回溯
- **后缀**: 可执行文件自动添加 `d` 后缀（如 `project1d`）

### Release 模式

- **优化**: 默认启用最高优化级别
- **可选**: 可通过 CMake 变量开启 Release 模式的调试信息或禁用优化

### Sanitizer（可选）

在配置时通过 CMake 变量启用：

```bash
# 启用 AddressSanitizer（检测内存错误）
cmake --preset gcc_14_debug -DENABLE_FSANITIZE_ADDRESS=ON

# 启用 UndefinedBehaviorSanitizer（检测未定义行为）
cmake --preset gcc_14_debug -DENABLE_FSANITIZE_UNDEFINED=ON

# 启用 ThreadSanitizer（检测数据竞争）
cmake --preset gcc_14_debug -DENABLE_FSANITIZE_THREAD=ON
```

以上变量默认关闭。

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
cmake --build build/gcc_14_debug --target clean_all_binary
```

## 许可证

本项目仅供学习和参考。

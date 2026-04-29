# project_template

一个跨平台的 C++ CMake 工程模板，支持 **Linux (GCC/Clang)** 和 **Windows (MSVC/Clang/MinGW)** 多平台开发。

## 特性

- ✅ **跨平台构建** — 支持 Linux GCC/Clang + Ninja 和 Windows MSVC/Clang/MinGW + Ninja/Visual Studio
- ✅ **自动生成 Presets** — 一键检测环境，自动生成适配的 CMakePresets.json
- ✅ **多目标类型** — 可执行程序、静态库（`.a`/`.lib`）、动态库（`.so`/`.dll`）示例
- ✅ **CTest 集成** — 内置测试支持，`cmake --build` 后可直接 `ctest`
- ✅ **CPack 打包** — 一键打包为 `.tar.gz`（Linux）或 `.zip`（Windows）
- ✅ **工作流 Preset** — 一条命令完成配置 → 构建 → 测试 → 打包全流程
- ✅ **Sanitizer 支持** — 可选启用 AddressSanitizer / UndefinedBehaviorSanitizer / ThreadSanitizer
- ✅ **代码格式化** — 内置 `.clang-format`（Google 风格）
- ✅ **调试友好** — Debug 模式下生成完整调试信息，禁用优化
- ✅ **预编译头** — 使用 CMake 3.16+ `target_precompile_headers` 自动注入，大幅加速编译
- ✅ **跨平台项目写法** — 展示了跨平台动态库、静态库、可执行文件的简单例子
- ✅ **多 VS 版本检测** — Windows 下自动检测所有已安装的 Visual Studio 版本（vswhere）
- ✅ **多编译器支持** — 同时检测 MSVC、Clang、MinGW GCC、GCC
- ✅ **跨平台统一体验** — Linux/Windows 使用同一套 Preset 生成脚本，行为一致
- ✅ **VS Code 深度集成** — 配合 CMake Tools 插件，自动识别 Preset，可视化选择编译器、构建、测试、打包、安装

## 项目结构

```
project_template/
├── CMakeLists.txt                  # 根 CMake 配置
├── .clang-format                   # Google 风格代码格式化配置
├── LICENSE                         # MIT 开源许可证
├── .gitignore                      # Git 忽略规则
├── generate_presets.sh             # Linux 生成 CMakePresets.json 脚本
├── generate_presets.bat            # Windows 生成 CMakePresets.json 脚本
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
    │   ├── pch.h
    │   ├── sharedLib1.h
    │   ├── sharedLib1.cc
    │   └── sharedLib1_export.h
    └── TestLib/                    # 测试程序（链接静态库 + 动态库）
        ├── CMakeLists.txt
        └── TestLib.cc
```

## 快速开始

### 第一步：自定义项目（可选）

使用模板前，建议先修改项目名和版本号以适配你的业务需求：

**`CMakeLists.txt`** — 修改项目名和版本号：
```cmake
project(你的项目名 VERSION 你的版本号)
```

**`cmake/CPackPreset.cmake`** — 修改打包描述和公司名：
```cmake
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "你的应用描述")
set(CPACK_PACKAGE_VENDOR "你的公司名")
```

> 子项目（`src/project1`、`src/staticLib1` 等）为示例模板，可按需增删改。

### 第二步：生成 Presets

`CMakePresets.json` 包含了编译器路径等环境相关配置，不同机器上不同。首次使用项目时，先运行自动检测脚本：

```bash
# Linux
./generate_presets.sh

# Windows
generate_presets.bat
```

脚本会自动检测当前环境的：
- **操作系统** — Linux / Windows
- **编译器** — GCC、Clang、MSVC 及其完整版本号（如 14.2.0）
- **构建工具** — Ninja、Unix Makefiles、Visual Studio

生成后即可查看可用的 Preset：

```bash
cmake --list-presets
```

### 第三步：配置与构建

以下命令都可以通过 VScode + CMake Tools 图形化界面操作完成

```bash
# 配置并构建（具体名称以 --list-presets 输出为准）
# Linux 示例：GCC 14.2.0 Debug
cmake --preset gcc_14.2.0-debug
cmake --build --preset gcc_14.2.0-debug

# Windows 示例：MSVC 17
cmake --preset msvc17
cmake --build --preset msvc17-debug

# Windows 示例：独立 Clang 20.1.0 Debug
cmake --preset clang_20.1.0-debug
cmake --build --preset clang_20.1.0-debug

# 运行（Linux）
./build/gcc_14.2.0-debug/bin/project1d
./build/gcc_14.2.0-debug/bin/TestLibd

# 运行（Windows）
build\msvc17\bin\Debug\project1d.exe
build\msvc17\bin\Debug\TestLibd.exe

# 测试
ctest --preset ctest-gcc_14.2.0-debug

# 打包
cpack --preset cpack-gcc_14.2.0-debug

# 安装
cmake --install build/gcc_14.2.0-debug --config Debug

# 一键工作流
# 配置 → 构建 → 测试 → 打包，一条命令完成：

cmake --workflow --preset workflow-gcc_14.2.0-debug

```

### 在 VS Code 中使用

安装 **CMake Tools** 插件后，插件会自动读取 `CMakePresets.json` 中的 Preset，你可以在 VS Code 底部的状态栏中选择：

- **Kit** — 选择编译器（对应 configurePreset）
- **Build** — 选择构建配置
- **Run CTest** — 运行测试
- **Package** — 打包

## CMakePresets.json 详解

`CMakePresets.json` 由 `cmake/GeneratePresets.cmake` 自动生成，定义了完整的构建生命周期 Preset，包括 **配置 → 构建 → 测试 → 打包 → 工作流** 五个阶段。

### Preset 命名规则

自动生成的 Preset 名称格式如下（GCC 使用 `-dumpfullversion` 获取完整版本号，如 `14.2.0`）：

| 平台 | 配置 Preset 名称 | 说明 |
|------|-----------------|------|
| Linux GCC | `gcc_{版本}-debug` / `gcc_{版本}-release` | 如 `gcc_14.2.0-debug` |
| Linux Clang | `clang_{版本}-debug` / `clang_{版本}-release` | 如 `clang_20.1.0-debug` |
| Windows MSVC | `msvc{主版本}` | 如 `msvc17`，多配置，构建时指定 Debug/Release |
| Windows Clang | `clang_{版本}-debug` / `clang_{版本}-release` | 如 `clang_20.1.0-debug`，独立安装的 Clang |
| Windows MinGW | `gcc_{版本}-debug` / `gcc_{版本}-release` | 如 `gcc_14.2.0-debug`，MinGW GCC |

其他 Preset 类型（build、test、package、workflow）的命名均基于配置 Preset 名称派生：

| Preset 类型 | 命名格式 | 示例 |
|------------|---------|------|
| buildPreset | `{配置名称}` | `gcc_14.2.0-debug` |
| testPreset | `ctest-{配置名称}` | `ctest-gcc_14.2.0-debug` |
| packagePreset | `cpack-{配置名称}` | `cpack-gcc_14.2.0-debug` |
| workflowPreset | `workflow-{配置名称}` | `workflow-gcc_14.2.0-debug` |

### 配置 Preset（configurePresets）

配置 Preset 定义了 CMake 的配置参数，包括生成器、编译器、构建类型和输出目录。

- **单配置生成器（Ninja / Unix Makefiles）**: 用于独立 Clang、GCC（跨平台），Debug/Release 各一个 Preset，构建类型在配置时通过 `CMAKE_BUILD_TYPE` 指定
- **多配置生成器（Visual Studio）**: 用于 MSVC、Clang-cl（仅 Windows），一个 Preset 包含 Debug/Release，构建类型在构建时指定

### 构建 Preset（buildPresets）

构建 Preset 关联到对应的配置 Preset。

- **单配置**: 直接引用配置 Preset 名称
- **多配置**: 需要为 Debug/Release 各生成一个（如 `msvc17-debug`、`msvc17-release`）

### 测试 Preset（testPresets）

测试 Preset 关联到对应的配置 Preset，用于运行 CTest。

### 打包 Preset（packagePresets）

打包 Preset 关联到对应的配置 Preset，用于 CPack 打包。

- **Linux**: 打包为 `.tar.gz`，输出到 `packages/` 目录
- **Windows**: 打包为 `.zip`，输出到 `packages/` 目录

### 工作流 Preset（workflowPresets）

工作流 Preset 将 **配置 → 构建 → 测试 → 打包** 四个步骤串联成一个命令：

```bash
cmake --workflow --preset workflow-gcc_14.2.0-debug
```

等价于依次执行：

```bash
cmake --preset gcc_14.2.0-debug
cmake --build --preset gcc_14.2.0-debug
ctest --preset ctest-gcc_14.2.0-debug
cpack --preset cpack-gcc_14.2.0-debug
```

### Preset 层级关系图

```
CMakePresets.json
├── configurePresets          # 配置 Preset（定义编译器、生成器、构建类型）
│   ├── gcc_14.2.0-debug      # Linux: GCC 14.2.0 Debug
│   ├── gcc_14.2.0-release    # Linux: GCC 14.2.0 Release
│   ├── clang_20.1.0-debug    # Linux/Windows: Clang 20.1.0 Debug
│   ├── clang_20.1.0-release  # Linux/Windows: Clang 20.1.0 Release
│   └── msvc17                # Windows: MSVC 17（多配置）
│
├── buildPresets              # 构建 Preset（关联配置 Preset）
│   ├── gcc_14.2.0-debug      # → gcc_14.2.0-debug
│   ├── gcc_14.2.0-release    # → gcc_14.2.0-release
│   ├── clang_20.1.0-debug    # → clang_20.1.0-debug
│   ├── clang_20.1.0-release  # → clang_20.1.0-release
│   ├── msvc17-debug          # → msvc17 (Debug)
│   └── msvc17-release        # → msvc17 (Release)
│
├── testPresets               # 测试 Preset（关联配置 Preset）
│   ├── ctest-gcc_14.2.0-debug    # → gcc_14.2.0-debug
│   ├── ctest-gcc_14.2.0-release  # → gcc_14.2.0-release
│   ├── ctest-clang_20.1.0-debug  # → clang_20.1.0-debug
│   ├── ctest-clang_20.1.0-release# → clang_20.1.0-release
│   ├── ctest-msvc17-debug        # → msvc17 (Debug)
│   └── ctest-msvc17-release      # → msvc17 (Release)
│
├── packagePresets            # 打包 Preset（关联配置 Preset）
│   ├── cpack-gcc_14.2.0-debug    # → gcc_14.2.0-debug
│   ├── cpack-gcc_14.2.0-release  # → gcc_14.2.0-release
│   ├── cpack-clang_20.1.0-debug  # → clang_20.1.0-debug
│   ├── cpack-clang_20.1.0-release# → clang_20.1.0-release
│   └── cpack-msvc17              # → msvc17
│
└── workflowPresets           # 工作流 Preset（串联多个 Preset）
    ├── workflow-gcc_14.2.0-debug       # configure → build → test → package
    ├── workflow-gcc_14.2.0-release     # configure → build → test → package
    ├── workflow-clang_20.1.0-debug     # configure → build → test → package
    ├── workflow-clang_20.1.0-release   # configure → build → test → package
    ├── workflow-msvc17-debug           # configure → build → test → package
    └── workflow-msvc17-release         # configure → build → test → package
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
cmake --preset gcc_14.2.0-debug -DENABLE_FSANITIZE_ADDRESS=ON

# 启用 UndefinedBehaviorSanitizer（检测未定义行为）
cmake --preset gcc_14.2.0-debug -DENABLE_FSANITIZE_UNDEFINED=ON

# 启用 ThreadSanitizer（检测数据竞争）
cmake --preset gcc_14.2.0-debug -DENABLE_FSANITIZE_THREAD=ON
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
cmake --build build/gcc_14.2.0-debug --target clean_all_binary
```

## 许可证

本项目基于 [MIT License](LICENSE) 开源。
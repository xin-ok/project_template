set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)

message(STATUS "Latest supported C++ standard: ${CMAKE_CXX_STANDARD_LATEST}")
set(CMAKE_CXX_STANDARD ${CMAKE_CXX_STANDARD_LATEST})
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_DEBUG_POSTFIX "d")
set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/bin/Release)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/bin/Debug)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/lib/Release)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/lib/Debug)

if(WIN32)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/bin/Release)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/bin/Debug)
    add_compile_options(
        # 警告和代码质量选项（所有配置都生效，无性能影响）
        /W4                       # 警告级别 4
        /WX                       # 将警告视为错误
        /permissive-              # 严格遵循标准，禁用非标准扩展
        /Zc:__cplusplus           # 使 __cplusplus 宏报告正确的 C++ 标准版本
        /Zc:preprocessor          # 使用符合标准的新预处理器
        /sdl                      # 启用安全开发生命周期检查（缓冲区溢出等）
        /utf-8                    # 跨平台开发时建议统一为 utf-8 编码格式

        # 有性能影响的选项：只在 Debug 模式下开启
        $<$<CONFIG:Debug>:/guard:cf>      # 启用控制流保护（CFG），有轻微运行时开销
        $<$<CONFIG:Debug>:/Zc:inline>     # 移除未使用的内联函数（影响编译/链接时间）
        $<$<CONFIG:Debug>:/Gy>            # 启用函数级链接（影响链接时间）
    )
else()
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/lib/Release)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/lib/Debug)
    add_compile_options(
        -Werror                   # 开启警告视为错误
        -Wall                     # 开启大部分常见警告
        -Wextra                   # 开启额外警告
        -Wpedantic                # 严格遵循C++标准，不使用GNU扩展
        -Wold-style-cast          # 警告C风格的强制类型转换
        -Woverloaded-virtual      # 警告虚函数重载问题 
        -Wpointer-arith           # 警告指针算术运算
        -Wshadow                  # 警告变量或函数被隐藏 
        -Wwrite-strings           # 警告不安全的字符串常量赋值 
        -Wno-unused-parameter     # 关闭未使用参数的警告，减少噪音 
        -march=native             # 为当前机器的CPU架构生成最优指令，但会牺牲可移植性
        -fPIC                     # 生成位置无关代码，对动态库 (.so) 是必需的
        $<$<CONFIG:Debug>:-g3>    # 生成最详细的调试信息（包括宏定义、局部变量等）
        $<$<CONFIG:Debug>:-fno-omit-frame-pointer>     # 保留帧指针，获得更好的堆栈跟踪
        $<$<CONFIG:Debug>:-fno-optimize-sibling-calls> # 禁用尾调用优化，保持完整堆栈
    )
endif()

message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

option(ENABLE_RELEASE_DEBUG_INFO "Enable debug info in Release mode" OFF)
option(DISABLE_RELEASE_OPTIMIZATION "Disable optimization in Release mode" OFF)
option(ENABLE_FSANITIZE_ADDRESS "Enable AddressSanitizer (memory error detection)" OFF)
if(MSVC)
    set(ENABLE_FSANITIZE_UNDEFINED OFF CACHE INTERNAL "Not supported on this platform")
    set(ENABLE_FSANITIZE_THREAD OFF CACHE INTERNAL "Not supported on this platform")
else()
    option(ENABLE_FSANITIZE_UNDEFINED "Enable UndefinedBehaviorSanitizer (UB detection)" OFF)
    option(ENABLE_FSANITIZE_THREAD "Enable ThreadSanitizer (data race detection)" OFF)
endif()

if(ENABLE_RELEASE_DEBUG_INFO)
    message(STATUS "# Enable debug info in Release mode")
    if(MSVC)
        add_compile_options(/Zi /UNDEBUG)
        add_link_options(/DEBUG)
    else()
        add_compile_options(
            -g3 
            -UNDEBUG 
            -fno-omit-frame-pointer
        )
    endif()
endif()

if(DISABLE_RELEASE_OPTIMIZATION)
    message(STATUS "# Disable optimization in Release mode")
    if(MSVC)
        add_compile_options(/Od /Ob0 /Oy-)
    else()
        add_compile_options(-O0)
    endif()
endif()

if(ENABLE_FSANITIZE_ADDRESS)
    message(STATUS "# AddressSanitizer is ENABLED (detects: buffer overflow, use-after-free, memory leaks)")
    message(STATUS "#   Performance impact: ~2x slower, ~2x memory usage")
    if(MSVC)
        add_compile_options(/fsanitize=address)
    else()
        add_compile_options(
            -fsanitize=address
            -fsanitize-address-use-after-scope  # 检测栈上的 use-after-scope
        )
        add_link_options(-fsanitize=address)
    endif()
endif()


if(ENABLE_FSANITIZE_UNDEFINED)
    message(STATUS "# UndefinedBehaviorSanitizer is ENABLED (detects: integer overflow, null pointer deref, alignment errors, etc.)")
    message(STATUS "#   Performance impact: ~1.2x slower")
    if(MSVC)
        message(WARNING "UndefinedBehaviorSanitizer is not supported by MSVC. "
                        "Use ClangCL or switch to Linux for this feature.")
    else()
        # Linux GCC/Clang 环境
        add_compile_options(
            -fsanitize=undefined
            -fsanitize=float-divide-by-zero     # 检测浮点数除零
            -fsanitize=null                     # 检测空指针解引用
            -fsanitize=return                   # 检测返回值错误
            -fsanitize=bool                     # 检测布尔值非法
            -fsanitize=enum                     # 检测枚举值非法
            -fsanitize=vptr                     # 检测虚函数指针错误（需要 -fno-rtti 禁用时无效）
        )
        add_link_options(-fsanitize=undefined)
        
        # 可选：将未定义行为转换为运行时陷阱（立即崩溃）
        # add_compile_options(-fsanitize-undefined-trap-on-error)
    endif()
endif()

# 注意：ThreadSanitizer 开启优化 (-O1 或 -O2) 可以获得更好的性能
if(ENABLE_FSANITIZE_THREAD)
    message(STATUS "# ThreadSanitizer is ENABLED (detects: data races, lock ordering issues)")
    message(STATUS "#   Performance impact: ~5-15x slower, ~5-10x memory usage")
    message(STATUS "#   Note: Only one thread-sanitized process should run at a time")
    message(STATUS "# ThreadSanitizer works better with optimization enabled (-O1 or -O2). ")

    
    if(MSVC)
        # MSVC 不支持 TSan，给出警告
        message(WARNING "ThreadSanitizer is not supported by MSVC. "
                        "Use ClangCL or switch to Linux for this feature.")
    else()
        # Linux GCC/Clang 环境
        add_compile_options(
            -fsanitize=thread
            # -fsanitize-ignorelist=${PROJECT_SOURCE_DIR}/tsan_ignorelist.txt  # 可选：忽略某些函数
        )
        add_link_options(-fsanitize=thread)
    endif()
endif()

include_directories(${PROJECT_SOURCE_DIR}/src)
find_package(Threads REQUIRED)

# Windows下，当文件被锁定或占用时，该目标生成会执行失败
add_custom_target(clean_all_binary
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${PROJECT_SOURCE_DIR}/bin"
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${PROJECT_SOURCE_DIR}/lib"
    COMMENT "Removing Bin and lib directories"
)

set(UTILITY_FILES
    ${PROJECT_SOURCE_DIR}/cmake/GeneralPreset.cmake
    ${PROJECT_SOURCE_DIR}/README.md
    ${PROJECT_SOURCE_DIR}/.clang-format
    ${PROJECT_SOURCE_DIR}/.gitignore
    ${PROJECT_SOURCE_DIR}/CMakeLists.txt
)

add_custom_target(Utilities
    COMMENT "Utility files and scripts"
)

target_sources(Utilities PRIVATE ${UTILITY_FILES})

set_target_properties(clean_all_binary Utilities PROPERTIES FOLDER "Tools")
# ============================================================================
#  GeneratePresets.cmake
#  自动检测当前环境并生成 CMakePresets.json
#
#  用法: cmake -P cmake/GeneratePresets.cmake
# ============================================================================

cmake_minimum_required(VERSION 3.10)

# ---- 辅助函数 ----

# 获取编译器版本号
function(get_compiler_version compiler_path var_name)
    if(compiler_path)
        execute_process(
            COMMAND ${compiler_path} -dumpversion
            OUTPUT_VARIABLE version_raw
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        # 只取主版本号.次版本号（如 14.2.0 → 14.2）
        string(REGEX MATCH "^[0-9]+\\.[0-9]+" version_short "${version_raw}")
        if(version_short)
            set(${var_name} "${version_short}" PARENT_SCOPE)
        else()
            set(${var_name} "${version_raw}" PARENT_SCOPE)
        endif()
    else()
        set(${var_name} "unknown" PARENT_SCOPE)
    endif()
endfunction()

# 获取 Ninja 路径
function(find_ninja var_name)
    find_program(NINJA_PATH ninja)
    if(NINJA_PATH)
        set(${var_name} "Ninja" PARENT_SCOPE)
    else()
        set(${var_name} "" PARENT_SCOPE)
    endif()
endfunction()

# 生成编译器标识字符串（用于 preset 名称）
function(make_compiler_id compiler_type compiler_path var_name)
    if(compiler_path)
        get_compiler_version("${compiler_path}" ver)
        string(TOLOWER "${compiler_type}" type_lower)
        set(${var_name} "${type_lower}_${ver}" PARENT_SCOPE)
    else()
        set(${var_name} "" PARENT_SCOPE)
    endif()
endfunction()

# ---- 检测环境 ----

message(STATUS "=== 检测环境 ===")

# 操作系统
string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" HOST_OS)
message(STATUS "操作系统: ${CMAKE_HOST_SYSTEM_NAME}")

# 检测构建工具
find_ninja(GENERATOR)
if(NOT GENERATOR)
    if(WIN32)
        set(GENERATOR "Visual Studio 17 2022")
    else()
        set(GENERATOR "Unix Makefiles")
    endif()
endif()
message(STATUS "构建工具: ${GENERATOR}")

# ---- 检测编译器 ----

set(COMPILERS "")  # 存储 {type, c_path, cxx_path, id} 的列表

if(WIN32)
    # Windows: 检测 MSVC
    find_program(MSVC_C_COMPILER cl)
    find_program(MSVC_CXX_COMPILER cl)
    if(MSVC_C_COMPILER)
        list(APPEND COMPILERS "msvc")
        list(APPEND COMPILERS "${MSVC_C_COMPILER}")
        list(APPEND COMPILERS "${MSVC_CXX_COMPILER}")
        list(APPEND COMPILERS "msvc")
        message(STATUS "  发现编译器: MSVC (${MSVC_C_COMPILER})")
    endif()
else()
    # Linux: 检测 GCC
    find_program(GCC_C_COMPILER gcc)
    find_program(GCC_CXX_COMPILER g++)
    if(GCC_C_COMPILER)
        make_compiler_id("gcc" "${GCC_C_COMPILER}" gcc_id)
        list(APPEND COMPILERS "gcc")
        list(APPEND COMPILERS "${GCC_C_COMPILER}")
        list(APPEND COMPILERS "${GCC_CXX_COMPILER}")
        list(APPEND COMPILERS "${gcc_id}")
        message(STATUS "  发现编译器: GCC (${GCC_C_COMPILER}) → ID: ${gcc_id}")
    endif()

    # Linux: 检测 Clang
    find_program(CLANG_C_COMPILER clang)
    find_program(CLANG_CXX_COMPILER clang++)
    if(CLANG_C_COMPILER)
        make_compiler_id("clang" "${CLANG_C_COMPILER}" clang_id)
        list(APPEND COMPILERS "clang")
        list(APPEND COMPILERS "${CLANG_C_COMPILER}")
        list(APPEND COMPILERS "${CLANG_CXX_COMPILER}")
        list(APPEND COMPILERS "${clang_id}")
        message(STATUS "  发现编译器: Clang (${CLANG_C_COMPILER}) → ID: ${clang_id}")
    endif()
endif()

if(NOT COMPILERS)
    message(FATAL_ERROR "未检测到任何支持的编译器！")
endif()

# ---- 生成 CMakePresets.json ----

message(STATUS "=== 生成 CMakePresets.json ===")

# 开始构建 JSON
set(JSON "{\n")
set(JSON "${JSON}    \"version\": 8,\n")

# ---- configurePresets ----
set(JSON "${JSON}    \"configurePresets\": [\n")

set(PRESET_NAMES "")       # 存储所有 preset 名称
set(BUILD_PRESET_NAMES "") # 存储需要 buildPreset 的名称（Windows 多配置需要）
set(has_first_config FALSE)

# 遍历每个编译器
set(idx 0)
list(LENGTH COMPILERS total_len)
while(idx LESS total_len)
    list(GET COMPILERS ${idx} comp_type)
    math(EXPR idx "${idx} + 1")
    list(GET COMPILERS ${idx} comp_c_path)
    math(EXPR idx "${idx} + 1")
    list(GET COMPILERS ${idx} comp_cxx_path)
    math(EXPR idx "${idx} + 1")
    list(GET COMPILERS ${idx} comp_id)
    math(EXPR idx "${idx} + 1")

    if(WIN32)
        # Windows: 多配置生成器，一个 preset 包含 Debug/Release
        if(has_first_config)
            set(JSON "${JSON},\n")
        endif()
        set(has_first_config TRUE)

        set(preset_name "msvc")
        set(JSON "${JSON}        {\n")
        set(JSON "${JSON}            \"name\": \"${preset_name}\",\n")
        set(JSON "${JSON}            \"displayName\": \"MSVC (Visual Studio 2022) - amd64\",\n")
        set(JSON "${JSON}            \"description\": \"Visual Studio 17 2022 (x64)\",\n")
        set(JSON "${JSON}            \"generator\": \"Visual Studio 17 2022\",\n")
        set(JSON "${JSON}            \"toolset\": \"host=x64\",\n")
        set(JSON "${JSON}            \"architecture\": \"x64\",\n")
        set(JSON "${JSON}            \"binaryDir\": \"\${sourceDir}/build/\${presetName}\",\n")
        set(JSON "${JSON}            \"cacheVariables\": {\n")
        set(JSON "${JSON}                \"CMAKE_INSTALL_PREFIX\": \"\${sourceDir}/install/\${presetName}\",\n")
        set(JSON "${JSON}                \"CMAKE_C_COMPILER\": \"${comp_c_path}\",\n")
        set(JSON "${JSON}                \"CMAKE_CXX_COMPILER\": \"${comp_cxx_path}\"\n")
        set(JSON "${JSON}            },\n")
        set(JSON "${JSON}            \"condition\": {\n")
        set(JSON "${JSON}                \"type\": \"equals\",\n")
        set(JSON "${JSON}                \"lhs\": \"\${hostSystemName}\",\n")
        set(JSON "${JSON}                \"rhs\": \"Windows\"\n")
        set(JSON "${JSON}            }\n")
        set(JSON "${JSON}        }")

        list(APPEND PRESET_NAMES "${preset_name}")
        list(APPEND BUILD_PRESET_NAMES "${preset_name}")
    else()
        # Linux: 单配置生成器，Debug/Release 各一个 preset
        foreach(build_type "Debug" "Release")
            if(has_first_config)
                set(JSON "${JSON},\n")
            endif()
            set(has_first_config TRUE)

            string(TOLOWER "${build_type}" build_type_lower)
            set(preset_name "${comp_id}_${build_type_lower}")

            if(build_type STREQUAL "Debug")
                set(display_name "${comp_type} ${comp_id} x86_64-linux-gnu Debug")
                set(desc "C = ${comp_c_path}, CXX = ${comp_cxx_path} (Debug)")
            else()
                set(display_name "${comp_type} ${comp_id} x86_64-linux-gnu Release")
                set(desc "C = ${comp_c_path}, CXX = ${comp_cxx_path} (Release)")
            endif()

            set(JSON "${JSON}        {\n")
            set(JSON "${JSON}            \"name\": \"${preset_name}\",\n")
            set(JSON "${JSON}            \"displayName\": \"${display_name}\",\n")
            set(JSON "${JSON}            \"description\": \"${desc}\",\n")
            set(JSON "${JSON}            \"generator\": \"${GENERATOR}\",\n")
            set(JSON "${JSON}            \"binaryDir\": \"\${sourceDir}/build/\${presetName}\",\n")
            set(JSON "${JSON}            \"cacheVariables\": {\n")
            set(JSON "${JSON}                \"CMAKE_INSTALL_PREFIX\": \"\${sourceDir}/install/\${presetName}\",\n")
            set(JSON "${JSON}                \"CMAKE_C_COMPILER\": \"${comp_c_path}\",\n")
            set(JSON "${JSON}                \"CMAKE_CXX_COMPILER\": \"${comp_cxx_path}\",\n")
            set(JSON "${JSON}                \"CMAKE_BUILD_TYPE\": \"${build_type}\"\n")
            set(JSON "${JSON}            },\n")
            set(JSON "${JSON}            \"condition\": {\n")
            set(JSON "${JSON}                \"type\": \"equals\",\n")
            set(JSON "${JSON}                \"lhs\": \"\${hostSystemName}\",\n")
            set(JSON "${JSON}                \"rhs\": \"Linux\"\n")
            set(JSON "${JSON}            }\n")
            set(JSON "${JSON}        }")

            list(APPEND PRESET_NAMES "${preset_name}")
        endforeach()
    endif()
endwhile()

set(JSON "${JSON}\n    ],\n")

# ---- buildPresets ----
set(JSON "${JSON}    \"buildPresets\": [\n")
set(has_first_build FALSE)

foreach(preset_name IN LISTS PRESET_NAMES)
    if(WIN32)
        # Windows 多配置：需要为 Debug/Release 各生成一个 buildPreset
        foreach(config "Debug" "Release")
            if(has_first_build)
                set(JSON "${JSON},\n")
            endif()
            set(has_first_build TRUE)
            string(TOLOWER "${config}" config_lower)
            set(JSON "${JSON}        {\n")
            set(JSON "${JSON}            \"name\": \"${preset_name}-${config_lower}\",\n")
            set(JSON "${JSON}            \"configurePreset\": \"${preset_name}\",\n")
            set(JSON "${JSON}            \"configuration\": \"${config}\"\n")
            set(JSON "${JSON}        }")
        endforeach()
    else()
        # Linux 单配置：直接引用 configurePreset
        if(has_first_build)
            set(JSON "${JSON},\n")
        endif()
        set(has_first_build TRUE)
        set(JSON "${JSON}        {\n")
        set(JSON "${JSON}            \"name\": \"${preset_name}\",\n")
        set(JSON "${JSON}            \"configurePreset\": \"${preset_name}\"\n")
        set(JSON "${JSON}        }")
    endif()
endforeach()

set(JSON "${JSON}\n    ],\n")

# ---- testPresets ----
set(JSON "${JSON}    \"testPresets\": [\n")
set(has_first_test FALSE)

foreach(preset_name IN LISTS PRESET_NAMES)
    if(WIN32)
        foreach(config "Debug" "Release")
            if(has_first_test)
                set(JSON "${JSON},\n")
            endif()
            set(has_first_test TRUE)
            string(TOLOWER "${config}" config_lower)
            set(JSON "${JSON}        {\n")
            set(JSON "${JSON}            \"name\": \"ctest-${preset_name}-${config_lower}\",\n")
            set(JSON "${JSON}            \"configurePreset\": \"${preset_name}\",\n")
            set(JSON "${JSON}            \"configuration\": \"${config}\"\n")
            set(JSON "${JSON}        }")
        endforeach()
    else()
        if(has_first_test)
            set(JSON "${JSON},\n")
        endif()
        set(has_first_test TRUE)
        set(JSON "${JSON}        {\n")
        set(JSON "${JSON}            \"name\": \"ctest-${preset_name}\",\n")
        set(JSON "${JSON}            \"configurePreset\": \"${preset_name}\"\n")
        set(JSON "${JSON}        }")
    endif()
endforeach()

set(JSON "${JSON}\n    ],\n")

# ---- packagePresets ----
set(JSON "${JSON}    \"packagePresets\": [\n")
set(has_first_pkg FALSE)

foreach(preset_name IN LISTS PRESET_NAMES)
    if(has_first_pkg)
        set(JSON "${JSON},\n")
    endif()
    set(has_first_pkg TRUE)
    set(JSON "${JSON}        {\n")
    set(JSON "${JSON}            \"name\": \"cpack-${preset_name}\",\n")
    set(JSON "${JSON}            \"configurePreset\": \"${preset_name}\"\n")
    set(JSON "${JSON}        }")
endforeach()

set(JSON "${JSON}\n    ],\n")

# ---- workflowPresets ----
set(JSON "${JSON}    \"workflowPresets\": [\n")
set(has_first_wf FALSE)

foreach(preset_name IN LISTS PRESET_NAMES)
    if(WIN32)
        foreach(config "Debug" "Release")
            if(has_first_wf)
                set(JSON "${JSON},\n")
            endif()
            set(has_first_wf TRUE)
            string(TOLOWER "${config}" config_lower)

            set(JSON "${JSON}        {\n")
            set(JSON "${JSON}            \"name\": \"workflow-${preset_name}-${config_lower}\",\n")
            set(JSON "${JSON}            \"steps\": [\n")
            set(JSON "${JSON}                { \"type\": \"configure\", \"name\": \"${preset_name}\" },\n")
            set(JSON "${JSON}                { \"type\": \"build\", \"name\": \"${preset_name}-${config_lower}\" },\n")
            set(JSON "${JSON}                { \"type\": \"test\", \"name\": \"ctest-${preset_name}-${config_lower}\" },\n")
            set(JSON "${JSON}                { \"type\": \"package\", \"name\": \"cpack-${preset_name}\" }\n")
            set(JSON "${JSON}            ]\n")
            set(JSON "${JSON}        }")
        endforeach()
    else()
        if(has_first_wf)
            set(JSON "${JSON},\n")
        endif()
        set(has_first_wf TRUE)
        set(JSON "${JSON}        {\n")
        set(JSON "${JSON}            \"name\": \"workflow-${preset_name}\",\n")
        set(JSON "${JSON}            \"steps\": [\n")
        set(JSON "${JSON}                { \"type\": \"configure\", \"name\": \"${preset_name}\" },\n")
        set(JSON "${JSON}                { \"type\": \"build\", \"name\": \"${preset_name}\" },\n")
        set(JSON "${JSON}                { \"type\": \"test\", \"name\": \"ctest-${preset_name}\" },\n")
        set(JSON "${JSON}                { \"type\": \"package\", \"name\": \"cpack-${preset_name}\" }\n")
        set(JSON "${JSON}            ]\n")
        set(JSON "${JSON}        }")
    endif()
endforeach()

set(JSON "${JSON}\n    ]\n")
set(JSON "${JSON}}\n")

# ---- 写入文件 ----

set(OUTPUT_FILE "${CMAKE_CURRENT_LIST_DIR}/../CMakePresets.json")
file(WRITE "${OUTPUT_FILE}" "${JSON}")
message(STATUS "✅ 已生成: ${OUTPUT_FILE}")
message(STATUS "")
message(STATUS "可用 Preset 列表:")

foreach(preset_name IN LISTS PRESET_NAMES)
    message(STATUS "  configure: cmake --preset ${preset_name}")
    if(WIN32)
        message(STATUS "  build:     cmake --build --preset ${preset_name}-debug")
        message(STATUS "  build:     cmake --build --preset ${preset_name}-release")
        message(STATUS "  workflow:  cmake --workflow --preset workflow-${preset_name}-debug")
    else()
        message(STATUS "  build:     cmake --build --preset ${preset_name}")
        message(STATUS "  workflow:  cmake --workflow --preset workflow-${preset_name}")
    endif()
    message(STATUS "")
endforeach()

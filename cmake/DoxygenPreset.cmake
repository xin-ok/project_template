find_package(Doxygen COMPONENTS dot)

if(DOXYGEN_FOUND)
    # 项目名
    set(DOXYGEN_PROJECT_NAME ${CMAKE_PROJECT_NAME})
    
    # 提取所有实体
    set(DOXYGEN_EXTRACT_ALL YES)
    
    # 不生成 LaTeX (PDF)
    set(DOXYGEN_GENERATE_LATEX NO)
    
    # 开启源码浏览
    set(DOXYGEN_SOURCE_BROWSER YES)

    if(NOT DOXYGEN_DOT_FOUND)
        find_program(USER_DOT_EXECUTABLE dot HINTS ${USER_DOT_PATH})
        if(USER_DOT_EXECUTABLE)
            set(DOXYGEN_DOT_FOUND TRUE)
            set(DOXYGEN_DOT_EXECUTABLE "${USER_DOT_EXECUTABLE}")
            message(STATUS "User specific Graphviz dot: ${DOXYGEN_DOT_EXECUTABLE}")
        endif()
    endif()

    if(DOXYGEN_DOT_FOUND)
        set(DOXYGEN_HAVE_DOT YES)             # 开启 dot 引擎
        # 常用图表开关（按需开启，全开会拖慢构建速度）
        set(DOXYGEN_CLASS_DIAGRAMS YES)       # 类图
        set(DOXYGEN_CLASS_GRAPH YES)          # 类继承/协作图
        set(DOXYGEN_INCLUDE_GRAPH YES)        # 头文件包含图
        set(DOXYGEN_INCLUDED_BY_GRAPH YES)    # 被包含图
        set(DOXYGEN_COLLABORATION_GRAPH YES)  # 类协作图
        set(DOXYGEN_GROUP_GRAPHS YES)         # 分组图 (针对你的 Topics)
        set(DOXYGEN_UML_LOOK YES)             # 启用 UML 风格（画出方框、加减号）

        # 控制在图里显示什么细节
        # NO (默认) = 只显示类名
        # YES = 显示所有（属性+函数+说明）
        # ATTR = 只显示属性（变量）
        # METHOD = 只显示函数（方法）
        set(DOXYGEN_DOT_UML_DETAILS YES)
        
        set(DOXYGEN_UML_LIMIT_NUM_FIELDS 15) # 防止类太大导致图表爆炸，限制最大显示的字段/函数数量
        
        # 如果你想要函数调用关系图（会比较慢）
        set(DOXYGEN_CALL_GRAPH YES)
        set(DOXYGEN_CALLER_GRAPH YES)
    else()
        message(WARNING "未找到 dot (Graphviz)，文档将不会包含可视化图表。")
    endif()
    
    # 读回 add_doxygen_macros() 在全局属性中累加的宏
    get_property(DOXYGEN_PREDEFINED_LIST GLOBAL PROPERTY DOXYGEN_PREDEFINED_LIST)

    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        list(APPEND DOXYGEN_PREDEFINED_LIST "_WIN32")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        list(APPEND DOXYGEN_PREDEFINED_LIST "__linux__")
    endif()
    
    set(DOXYGEN_PREDEFINED ${DOXYGEN_PREDEFINED_LIST})
    message(STATUS "DOXYGEN_PREDEFINED = ${DOXYGEN_PREDEFINED_LIST}")
    
    # 定义生成文档的 target
    doxygen_add_docs(
        build_docs
        ${PROJECT_SOURCE_DIR}/src
        COMMENT "正在使用 Doxygen 生成文档..."
    )

    set_target_properties(build_docs PROPERTIES FOLDER "tools")
else()
    message(WARNING "未找到 Doxygen，无法生成文档。请安装 Doxygen。")
endif()
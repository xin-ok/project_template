add_library(static_lib
STATIC
    static_lib.h
    static_lib.cc
)

target_include_directories(static_lib
PRIVATE
    ${PROJECT_SOURCE_DIR}/project_template
)

set_target_properties(static_lib PROPERTIES FOLDER "project_template")

install(TARGETS static_lib
    RUNTIME DESTINATION bin     
    LIBRARY DESTINATION lib     
    ARCHIVE DESTINATION lib
)

# windows 下 Debug 模式静态库不需要安装 PDB 文件，只有可执行文件和动态库才需要
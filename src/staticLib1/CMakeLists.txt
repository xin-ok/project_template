add_library(staticLib1
STATIC
    staticLib1.h
    staticLib1.cc
)

install(TARGETS staticLib1
        RUNTIME DESTINATION bin     
        LIBRARY DESTINATION lib     
        ARCHIVE DESTINATION lib
)

# windows 下 Debug 模式静态库不需要安装 PDB 文件，只有可执行文件和动态库才需要
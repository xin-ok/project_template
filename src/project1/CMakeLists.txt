add_executable(project1 project1.cc)

# 设置启动项目（仅对 Visual Studio 生成器有效）
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT project1)

# 设置调试时的工作目录为可执行文件所在目录
set_target_properties(project1 PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "$(TargetDir)"
    DEBUG_POSTFIX "d"
)

add_test(NAME project1 
         COMMAND project1
         WORKING_DIRECTORY $<TARGET_FILE_DIR:project1>
)

install(TARGETS project1
        RUNTIME DESTINATION bin     
        LIBRARY DESTINATION lib     
        ARCHIVE DESTINATION lib
) 

install(FILES $<TARGET_PDB_FILE:project1>
    DESTINATION bin
    CONFIGURATIONS Debug
    OPTIONAL
)
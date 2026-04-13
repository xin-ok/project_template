add_executable(TestLib TestLib.cc)

target_link_libraries(TestLib
PRIVATE
    sharedLib1    
    staticLib1
)

# 设置调试时的工作目录为可执行文件所在目录
set_target_properties(project1 PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "$(TargetDir)"
)
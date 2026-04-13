add_executable(project1 project1.cc)

# 设置启动项目（仅对 Visual Studio 生成器有效）
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT project1)

# 设置调试时的工作目录为可执行文件所在目录
set_target_properties(project1 PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "$(TargetDir)"
)
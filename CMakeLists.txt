cmake_minimum_required(VERSION 3.16)

# ============================================================
#  👇 自定义项目配置
#  修改项目名和版本号以适配你的业务需求
#  示例: project(my_app VERSION 2.0.0)
# ============================================================
project(project_template VERSION 1.1.0)
# ============================================================
include(cmake/GeneralPreset.cmake)
include(cmake/CPackPreset.cmake)
enable_testing()

add_subdirectory(src/project1)
add_subdirectory(src/staticLib1)
add_subdirectory(src/sharedLib1)
add_subdirectory(src/TestLib)
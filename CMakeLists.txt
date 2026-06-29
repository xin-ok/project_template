cmake_minimum_required(VERSION 3.16)
# ============================================================
#  👇 自定义项目配置
#  示例: project(my_app VERSION 2.0.0)
# ============================================================
project(project_template VERSION 1.0.0)
# ============================================================

include(cmake/PublicPreset.cmake)
include(cmake/PrivatePreset.cmake)
include(cmake/CPackPreset.cmake)
enable_testing()

add_subdirectory(project_template)

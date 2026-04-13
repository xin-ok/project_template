cmake_minimum_required(VERSION 3.10)
set(PROJECT_TEMPLATE_VERSION 1.0.0)
project(project_template VERSION ${PROJECT_TEMPLATE_VERSION})
include(cmake/GeneralPreset.cmake)

add_subdirectory(project1)
add_subdirectory(staticLib1)
add_subdirectory(sharedLib1)
add_subdirectory(TestLib)
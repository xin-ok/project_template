add_executable(project_lib_test project_lib_test.cc)

target_link_libraries(project_lib_test
PRIVATE
    shared_lib    
    static_lib
)

target_link_libraries(project_lib_test
PRIVATE
    shared_lib    
    static_lib
)

target_include_directories(project_lib_test
PRIVATE
    ${PROJECT_SOURCE_DIR}/project_template
)

set_target_properties(project_lib_test PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY ${MSVC_DEBUGGER_DIR} # "$(TargetDir)"
    DEBUG_POSTFIX "d"
)

set_target_properties(project_lib_test PROPERTIES FOLDER "project_template")

add_test(NAME project_lib_test
    COMMAND project_lib_test
    WORKING_DIRECTORY $<TARGET_FILE_DIR:project_lib_test>
)

install(TARGETS project_lib_test
    RUNTIME DESTINATION bin     
    LIBRARY DESTINATION lib     
    ARCHIVE DESTINATION lib
)

if(WIN32)
    install(FILES $<TARGET_PDB_FILE:project_lib_test>
        DESTINATION bin
        CONFIGURATIONS Debug
        OPTIONAL
    )
else()
    set_target_properties(project_lib_test PROPERTIES
        INSTALL_RPATH "$ORIGIN/../lib"
    )
endif()

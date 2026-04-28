add_executable(TestLib TestLib.cc)

target_link_libraries(TestLib
PRIVATE
    sharedLib1    
    staticLib1
)

set_target_properties(TestLib PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "$(TargetDir)"
    DEBUG_POSTFIX "d"
)

add_test(NAME TestLib 
         COMMAND TestLib
         WORKING_DIRECTORY $<TARGET_FILE_DIR:TestLib>
)

install(TARGETS TestLib
        RUNTIME DESTINATION bin     
        LIBRARY DESTINATION lib     
        ARCHIVE DESTINATION lib
)

if(WIN32)
    install(FILES $<TARGET_PDB_FILE:TestLib>
        DESTINATION bin
        CONFIGURATIONS Debug
        OPTIONAL
    )
endif()

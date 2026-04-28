add_library(sharedLib1
SHARED
    sharedLib1_export.h
    sharedLib1.h
    sharedLib1.cc
)

target_compile_definitions(sharedLib1
PRIVATE
    SHAREDLIB1_EXPORT
)

install(TARGETS sharedLib1
        RUNTIME DESTINATION bin     
        LIBRARY DESTINATION lib     
        ARCHIVE DESTINATION lib
)

install(FILES $<TARGET_PDB_FILE:sharedLib1>
    DESTINATION bin
    CONFIGURATIONS Debug
    OPTIONAL
)
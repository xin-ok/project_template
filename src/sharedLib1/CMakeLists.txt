add_library(sharedLib1
SHARED
    pch.h
    sharedLib1_export.h
    sharedLib1.h
    sharedLib1.cc
)

target_precompile_headers(sharedLib1 PRIVATE pch.h)

target_compile_definitions(sharedLib1
PRIVATE
    SHAREDLIB1_EXPORT
)

install(TARGETS sharedLib1
    RUNTIME DESTINATION bin     
    LIBRARY DESTINATION lib     
    ARCHIVE DESTINATION lib
)

if(WIN32)
    install(FILES $<TARGET_PDB_FILE:sharedLib1>
        DESTINATION bin
        CONFIGURATIONS Debug
        OPTIONAL
    )
endif()
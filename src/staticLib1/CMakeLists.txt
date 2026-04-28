add_library(staticLib1
STATIC
    staticLib1.h
    staticLib1.cc
)

install(TARGETS staticLib1
        RUNTIME DESTINATION bin     
        LIBRARY DESTINATION lib     
        ARCHIVE DESTINATION lib
)

if(WIN32)
    install(FILES $<TARGET_PDB_FILE:staticLib1>
        DESTINATION lib
        CONFIGURATIONS Debug
        OPTIONAL
    )
endif()
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

install(FILES $<TARGET_PDB_FILE:sharedLib1>
    DESTINATION lib
    CONFIGURATIONS Debug
    OPTIONAL
)
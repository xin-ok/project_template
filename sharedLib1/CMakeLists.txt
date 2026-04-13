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
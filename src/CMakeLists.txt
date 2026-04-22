# Additional CMake configuration file for building the xchange library from
# source
#
# To invoke simply configure the cmake build in the supernovas directory.
#
# Author: Attila Kovacs


FILE(GLOB C_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.c)

add_library(core ${C_SOURCES})
add_library(xchange::core ALIAS core)

set_target_properties(core PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    OUTPUT_NAME xchange
)

target_include_directories(core PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Link with math libs as necessary
target_link_libraries(core PUBLIC ${MATHLIB})

#set_property(TARGET core PROPERTY C_STANDARD 99)


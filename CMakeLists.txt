# CMake configuration file for the xchange library
#
# Authors: Attila Kovacs
#
# Usage: 
#   
#  To build under a 'build/' directory:
#
#    $ cmake -B build [OPTIONS]
#    $ cmake --build build
#  
#  And then to install, e.g. under '/usr/local':
#    $ [sudo ] cmake --install --prefix=/usr/local
#
#  You may install just a specific component via the --component option, such
#  as 'Runtime' or 'Development'.
#

cmake_minimum_required(VERSION 3.24...4.3)

if(NOT PACKAGE_NAME)
    set(PACKAGE_NAME xchange)
endif()

# Project definition
project(${PACKAGE_NAME}
    VERSION 1.1.2
    DESCRIPTION "Structured data exchange library for C/C++"
    HOMEPAGE_URL "https://sigmyne.github.io/xchange/"
    LANGUAGES C
)

# Include required modules
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(FeatureSummary)

# Build options
option(BUILD_SHARED_LIBS "Build as shared libraries instead of static" OFF)
option(BUILD_DOC "Build HTML documetation" OFF)
option(BUILD_TESTING "Build regression test suite" ON)
option(BUILD_EXAMPLES "Build example programs" OFF)

# Set feature descriptions for summary
add_feature_info(SharedLibs BUILD_SHARED_LIBS "Build as shared libraries")
add_feature_info(Documentation BUILD_DOC "Developer documentation (HTML)")
add_feature_info(Testing BUILD_TESTING "Run regression testing")
add_feature_info(Examples BUILD_EXAMPLES "Build and test example programs")

# ----------------------------------------------------------------------------
# pkg-config variables

# [.pc] Libs -- linker flags for apps
set(PC_LIBS "-lxchange ")

# [.pc] Libs.private -- linker flags for supernovas itself
set(PC_LIBS_PRIVATE "")

# ----------------------------------------------------------------------------
# Global build configuration

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Debug postfix for libraries
set(CMAKE_DEBUG_POSTFIX d)

# Build time locations for sub-configs
link_directories(${CMAKE_BINARY_DIR}/lib)
set(xchange_INCLUDE_DIRS ${PROJECT_SOURCE_DIR}/include)

if(WIN32)
    # Windows-specific settings
    message("Configuring for Windows...")
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

if(WIN32)
    set(MATHLIB "")
else()
    find_library(MATH_LIBRARY m REQUIRED)
    set(MATHLIB m)
    
    # [.pc] Link applications against math lib...
    string(APPEND PC_LIBS_PRIVATE -l${MATHLIB} " ")
endif()

# ----------------------------------------------------------------------------
# Build libraries from source

add_subdirectory(src)

# ----------------------------------------------------------------------------
# Testing, examples, and benchmarks...

# Run tests for the enabled options below...
enable_testing()

# Examples
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Testing
if(BUILD_TESTING)
    add_subdirectory(test)
endif()

# Examples
if(BUILD_DOC)
    add_subdirectory(doc)
endif()



# ----------------------------------------------------------------------------
# Install Runtime component

install(FILES include/xchange.h include/xjson.h
    TYPE INCLUDE
    COMPONENT Development
)

set(INSTALL_TARGETS core)
set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME Runtime)

install(TARGETS ${INSTALL_TARGETS} EXPORT xchangeTargets)

# Install markdown files
install(FILES CHANGELOG.md CONTRIBUTING.md
    TYPE DOC
    COMPONENT Development   
)

# For examples/ dir, list just the directory, not the individual files installed.
install(CODE "message(STATUS \"Installing: <prefix>/${CMAKE_INSTALL_DOCDIR}/examples/\")")
install(DIRECTORY ${PROJECT_SOURCE_DIR}/examples
    TYPE DOC
    MESSAGE_NEVER
    COMPONENT Development
)

install(EXPORT xchangeTargets
    COMPONENT Development
    FILE xchangeTargets.cmake
    NAMESPACE xchange::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/xchange
)


# ------------------------------------------------------------------------
# Package config

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/xchangeConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/xchangeConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/xchange
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/xchangeConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/xchangeConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/xchangeConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/xchange
    COMPONENT Development
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/xchange.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/xchange.pc
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/xchange.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    COMPONENT Development
)

# ----------------------------------------------------------------------------
# Uninstall target
if(NOT TARGET uninstall)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY
    )

    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
endif()

# ----------------------------------------------------------------------------
# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry)
export(PACKAGE xchange)


# ----------------------------------------------------------------------------
# Summary
feature_summary(WHAT ALL)

message(" - Compile flags added with CMAKE_BUILD_TYPE:")
message("   Debug:             ${CMAKE_C_FLAGS_DEBUG}")
message("   Release:           ${CMAKE_C_FLAGS_RELEASE}")
message("   RelWithDebInfo:    ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
message("   MinSizeRel:        ${CMAKE_C_FLAGS_MINSIZEREL}")
message("")

message(" - supernovas Configuration Summary:")
message("   Version:           ${PROJECT_VERSION}")
if(CMAKE_BUILD_TYPE)
    message("   Build type:        ${CMAKE_BUILD_TYPE}")
else()
    message("   Build type:        (default) -- external CFLAGS only")
endif()
message("   Install prefix:    ${CMAKE_INSTALL_PREFIX}")
message("   Compiler:          ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message("")



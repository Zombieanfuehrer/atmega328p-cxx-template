cmake_minimum_required(VERSION 3.28)

project( 
    ATmega328__T_
    VERSION 1.0.0
    LANGUAGES CXX)

# SET USER SPECIFIC VARIABLES 
set(CONAN_PROFILE_NAME "avr-mega328p" CACHE STRING "Name of the conan profile to use")

# GLOBAL VARIABLES
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# OPTIONS
option(ENABLE_WARNINGS "Enable to add warnings to a target." ON)
option(ENABLE_WARNINGS_AS_ERRORS "Enable to treat warnings as errors." OFF)

# PROJECT / LIBRARY NAMES
set(LIBRARY_NAME "ATmega328__T_LIB")
set(EXECUTABLE_NAME "ATmega328__T_")


# CMAKE MODULES
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/")

add_subdirectory(src)
add_subdirectory(app)

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/CMakeUserPresets.json")
    include(ConanInstall)

    set(CONAN_GENERATORS_FOLDER_PATH)
    run_conan_install(
        CONANFILE_PY_PATH
        "${PROJECT_SOURCE_DIR}/conanfile.py"
        CONAN_PROFILE
        ${CONAN_PROFILE_NAME}
        CONAN_GENERATORS_PATH  
        ${CONAN_GENERATORS_FOLDER_PATH}
    )
endif()
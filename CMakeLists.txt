cmake_minimum_required(VERSION 3.28)

project( 
    ATmega328__T_
    VERSION 1.0.0
    LANGUAGES CXX)

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

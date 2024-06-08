cmake_minimum_required(VERSION 3.28)

project( 
    ATmega328__T_
    VERSION 1.0.0
    LANGUAGES CXX)

# SET USER SPECIFIC VARIABLES 
set(CONAN_PROFILE_NAME "avr-mega328p_g" CACHE STRING "Name of the conan profile to use")
set(F_CPU "16000000")

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

include(ConanInstall)
set(CMAKE_USER_PRESET "${PROJECT_SOURCE_DIR}/CMakeUserPresets.json")

prepare_build_by_conan(
    PACKAGE_CONANFILE_PY_PATH
    "${PROJECT_SOURCE_DIR}/conanfile.py"
    CONAN_BUILD_PROFILE
    ${CONAN_PROFILE_NAME}
    CMAKE_USER_PRESET_PATH
    ${CMAKE_USER_PRESET}
)

if(NOT EXISTS ${CMAKE_USER_PRESET})
    set(CONAN_GENERATORS_FOLDER_PATH)
    run_conan_install(
        CONANFILE_PY_PATH
        "${PROJECT_SOURCE_DIR}/conanfile.py"
        CONAN_PROFILE
        ${CONAN_PROFILE_NAME}
        CONAN_GENERATORS_PATH  
        CONAN_GENERATORS_FOLDER_PATH
    )
    set_env_through_conanbuild_script(
        CONAN_GENERATORS_PATH
        ${CONAN_GENERATORS_FOLDER_PATH}
    )
endif()

set(CONAN_BUILD_PRESET)
find_conan_generator_preset(
    CMAKE_USER_PRESET_JSON_FILE_PATH 
    ${CMAKE_USER_PRESET}
    CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME
    CONAN_BUILD_PRESET
)

load_conan_generator_preset(
    CMAKE_BUILD_PRESET_NAME
    ${CONAN_BUILD_PRESET}
)
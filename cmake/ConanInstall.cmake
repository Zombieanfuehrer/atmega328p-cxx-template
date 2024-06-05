# Function to create a custom target for running the Conan install command
function(run_conan_install)
    set(oneValueArgs CONANFILE_PY_PATH CONAN_PROFILE CONAN_GENERATORS_PATH)
    cmake_parse_arguments(
        RUN_CONAN_INSTALL
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

        execute_process(
            COMMAND conan install ${RUN_CONAN_INSTALL_CONANFILE_PY_PATH} --build=missing -pr:h=${RUN_CONAN_INSTALL_CONAN_PROFILE}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE CONAN_INSTALL_STDOUT
            ERROR_VARIABLE CONAN_INSTALL_STDERR     # conan writes output in stderr instead stdout
            RESULT_VARIABLE CONAN_INSTALL_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(CONAN_INSTALL_RESULT)
            message(FATAL_ERROR "Conan install failed with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}!")
            return()
        else()
            message(STATUS "Conan install succeeded with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}.")
        endif()

        string(REGEX MATCH "Generators folder: .*$" CONAN_GENERATORS_FOLDER_LINE "${CONAN_INSTALL_STDERR}")
        if(CONAN_GENERATORS_FOLDER_LINE)
            string(REGEX REPLACE "Generators folder: " "" CONAN_GENERATORS_FOLDER_PATH "${CONAN_GENERATORS_FOLDER_LINE}")
            message(STATUS "Extracted generators folder path: ${CONAN_GENERATORS_FOLDER_PATH}")
            set(${RUN_CONAN_INSTALL_CONAN_GENERATORS_PATH} "${CONAN_GENERATORS_FOLDER_PATH}" PARENT_SCOPE)
        else()
            message(WARNING "Could not find 'Generators folder:' line in Conan output.")
        endif()
        message(STATUS "DEBUG_0: ${RUN_CONAN_INSTALL_CONAN_GENERATORS_PATH}")
endfunction(run_conan_install)

function(set_env_through_conanbuild_script)
    set(oneValueArgs CONAN_GENERATORS_PATH)
    cmake_parse_arguments(
        SET_ENV_THROUGH_CONANBUILD_SCRIPT
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})
        message(STATUS "DEBUG_2: ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}")
        string(APPEND ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH} "/conanbuild.sh")
        if(EXISTS ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH})
        message(STATUS "Build enviroment will set by ${CONANBUILD_SH}") 
        execute_process(
            COMMAND source ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
        else() 
            message(FATAL_ERROR "Could not find conanbuild.sh") 
        endif()
endfunction(set_env_through_conanbuild_script)

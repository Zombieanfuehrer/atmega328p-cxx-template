include(Utils)
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
            string(REGEX REPLACE "Generators folder: ([^\r\n]*).*$" "\\1" CONAN_GENERATORS_FOLDER_PATH "${CONAN_GENERATORS_FOLDER_LINE}")
            string(REGEX REPLACE "[^A-Za-z0-9_./\:-]+$" "" CONAN_GENERATORS_FOLDER_PATH "${CONAN_GENERATORS_FOLDER_PATH}")
            message(STATUS "Extracted generators folder path: ${CONAN_GENERATORS_FOLDER_PATH}")
            set(${RUN_CONAN_INSTALL_CONAN_GENERATORS_PATH} "${CONAN_GENERATORS_FOLDER_PATH}" PARENT_SCOPE)
        else()
            message(WARNING "Could not find 'Generators folder:' line in Conan output.")
        endif()
endfunction(run_conan_install)

function(set_env_through_conanbuild_script)
    set(oneValueArgs CONAN_GENERATORS_PATH)
    cmake_parse_arguments(
        SET_ENV_THROUGH_CONANBUILD_SCRIPT
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})
        message(STATUS "DEBUG_2: ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}")
        string(REGEX REPLACE "[^[:print:]]+$" "" CLEANED_STRING "${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}")
        set(CONANBUILD_ENV_SCRIPT "${CLEANED_STRING}/conanbuild.sh")
        message(STATUS "DEBUG_3: ${CONANBUILD_ENV_SCRIPT}")
        if(EXISTS "${CONANBUILD_ENV_SCRIPT}")
        message(STATUS "Build enviroment will set by ${CONANBUILD_SH}") 
        execute_process(
            COMMAND source ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
        else() 
            message(FATAL_ERROR "Could not find conanbuild.sh") 
        endif()
endfunction(set_env_through_conanbuild_script)

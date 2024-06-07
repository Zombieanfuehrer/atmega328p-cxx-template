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
            message(FATAL_ERROR "[run_conan_install] Conan install failed with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}!")
            return()
        else()
            message(STATUS "[run_conan_install] Conan install succeeded with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}.")
        endif()

        string(REGEX MATCH "Generators folder: .*$" CONAN_GENERATORS_FOLDER_LINE "${CONAN_INSTALL_STDERR}")
        if(CONAN_GENERATORS_FOLDER_LINE)
            string(REGEX REPLACE "Generators folder: ([^\r\n]*).*$" "\\1" CONAN_GENERATORS_FOLDER_PATH "${CONAN_GENERATORS_FOLDER_LINE}")
            string(REGEX REPLACE "[^A-Za-z0-9_./\:-]+$" "" CONAN_GENERATORS_FOLDER_PATH "${CONAN_GENERATORS_FOLDER_PATH}")
            message(STATUS "[run_conan_install] Extracted generators folder path: ${CONAN_GENERATORS_FOLDER_PATH}")
            set(${RUN_CONAN_INSTALL_CONAN_GENERATORS_PATH} "${CONAN_GENERATORS_FOLDER_PATH}" PARENT_SCOPE)
        else()
            message(WARNING "[run_conan_install] Could not find 'Generators folder:' line in Conan output.")
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
        set(CONANBUILD_ENV_SCRIPT "${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}/conanbuild.sh")
        message(STATUS "[set_env_through_conanbuild_script] Search for: ${CONANBUILD_ENV_SCRIPT}")
        if(EXISTS "${CONANBUILD_ENV_SCRIPT}")
        message(STATUS "[set_env_through_conanbuild_script] Build enviroment will set by ${CONANBUILD_ENV_SCRIPT}") 
        execute_process(
            COMMAND source ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
        else() 
            message(FATAL_ERROR "[set_env_through_conanbuild_script] Could not find conanbuild.sh") 
        endif()
endfunction(set_env_through_conanbuild_script)

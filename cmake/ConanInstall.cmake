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
        COMMAND conan install ${RUN_CONAN_INSTALL_CONANFILE_PY_PATH} --build=missing
                -pr:h=${RUN_CONAN_INSTALL_CONAN_PROFILE}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE CONAN_INSTALL_STDOUT
        ERROR_VARIABLE CONAN_INSTALL_STDERR # conan writes output in stderr instead stdout
        RESULT_VARIABLE CONAN_INSTALL_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(CONAN_INSTALL_RESULT)
        message(STATUS "[run_conan_install] Conan error is '${CONAN_INSTALL_STDERR}'")
        message(FATAL_ERROR "[run_conan_install] Conan install failed with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}!")
        return()
    else()
        message(STATUS "[run_conan_install] Conan install succeeded with profile ${RUN_CONAN_INSTALL_CONAN_PROFILE}.")
    endif()

    string(
        REGEX MATCH
              "Generators folder: .*$"
              CONAN_GENERATORS_FOLDER_LINE
              "${CONAN_INSTALL_STDERR}")
    if(CONAN_GENERATORS_FOLDER_LINE)
        string(
            REGEX
            REPLACE "Generators folder: ([^\r\n]*).*$"
                    "\\1"
                    CONAN_GENERATORS_FOLDER_PATH
                    "${CONAN_GENERATORS_FOLDER_LINE}")
        string(
            REGEX
            REPLACE "[^A-Za-z0-9_./\:-]+$"
                    ""
                    CONAN_GENERATORS_FOLDER_PATH
                    "${CONAN_GENERATORS_FOLDER_PATH}")
        message(STATUS "[run_conan_install] Extracted generators folder path: ${CONAN_GENERATORS_FOLDER_PATH}")
        set(${RUN_CONAN_INSTALL_CONAN_GENERATORS_PATH}
            "${CONAN_GENERATORS_FOLDER_PATH}"
            PARENT_SCOPE)
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
        execute_process(COMMAND source ${SET_ENV_THROUGH_CONANBUILD_SCRIPT_CONAN_GENERATORS_PATH}
                        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    else()
        message(FATAL_ERROR "[set_env_through_conanbuild_script] Could not find: ${CONANBUILD_ENV_SCRIPT}")
    endif()
endfunction(set_env_through_conanbuild_script)

function(find_conan_generator_preset)
    set(oneValueArgs CMAKE_USER_PRESET_JSON_FILE_PATH CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME)
    cmake_parse_arguments(
        FIND_CONAN_GENERATOR_PRESET
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    if(EXISTS ${FIND_CONAN_GENERATOR_PRESET_CMAKE_USER_PRESET_JSON_FILE_PATH})
        file(READ ${FIND_CONAN_GENERATOR_PRESET_CMAKE_USER_PRESET_JSON_FILE_PATH} CMAKE_USER_PRESET_JSON)
        string(
            JSON
            CONAN_GENERATED_CMAKE_PRESET_PATH
            GET
            ${CMAKE_USER_PRESET_JSON}
            "include"
            0)
        if(${CONAN_GENERATED_CMAKE_PRESET_PATH} EQUAL "NOTFOUND")
            message(
                WARNING
                    "[find_conan_generator_preset] In ${CMAKE_USER_PRESET}, has non member 'include',  so it is not clear which CMake preset should be loaded!"
            )
            return()
        else()
            file(READ ${CONAN_GENERATED_CMAKE_PRESET_PATH} CONAN_GENERATED_CMAKE_PRESET_JSON)
            string(
                JSON
                CONAN_GENERATED_CMAKE_BUILD_PRESETS_JSON_STR
                GET
                ${CONAN_GENERATED_CMAKE_PRESET_JSON}
                "buildPresets"
                0)
            string(
                JSON
                CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME
                GET
                ${CONAN_GENERATED_CMAKE_BUILD_PRESETS_JSON_STR}
                "name")
            message(
                STATUS "[find_conan_generator_preset] Found CMake Preset : ${CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME}")
        endif()
        set(${FIND_CONAN_GENERATOR_PRESET_CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME}
            "${CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME}"
            PARENT_SCOPE)
    endif()
endfunction(find_conan_generator_preset)

function(create_target_load_cmake_preset)
    set(oneValueArgs CMAKE_BUILD_PRESET_NAME)
    cmake_parse_arguments(
        LOAD_CONAN_GENERATOR_PRESET
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    message(
        STATUS "[create_target_load_cmake_preset] load preset : ${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}")
    add_custom_target(load_preset_${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}
                      COMMENT "Setting CMake Preset: ${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}")

    add_custom_command(
        TARGET load_preset_${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}
        COMMAND ${CMAKE_COMMAND} --preset ${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Set Preset: ${LOAD_CONAN_GENERATOR_PRESET_CMAKE_BUILD_PRESET_NAME}"
        VERBATIM)
endfunction(create_target_load_cmake_preset)

function(prepare_build_presets_by_conan)
    set(oneValueArgs
        PACKAGE_CONANFILE_PY_PATH
        CONAN_BUILD_PROFILE
        CMAKE_USER_PRESET_PATH
        CONAN_BUILD_PRESET)
    cmake_parse_arguments(
        PREPARE_BUILD_BY_CONAN
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    if(NOT EXISTS ${PREPARE_BUILD_BY_CONAN_CMAKE_USER_PRESET_PATH})
        set(CONAN_GENERATORS_FOLDER_PATH)
        run_conan_install(
            CONANFILE_PY_PATH
            "${PREPARE_BUILD_BY_CONAN_PACKAGE_CONANFILE_PY_PATH}"
            CONAN_PROFILE
            ${PREPARE_BUILD_BY_CONAN_CONAN_BUILD_PROFILE}
            CONAN_GENERATORS_PATH
            CONAN_GENERATORS_FOLDER_PATH)
        set_env_through_conanbuild_script(CONAN_GENERATORS_PATH ${CONAN_GENERATORS_FOLDER_PATH})
    endif()

    find_conan_generator_preset(
        CMAKE_USER_PRESET_JSON_FILE_PATH
        ${PREPARE_BUILD_BY_CONAN_CMAKE_USER_PRESET_PATH}
        CONAN_GENERATED_CMAKE_BUILD_PRESET_NAME
        CONAN_BUILDED_CMAKE_PRESET)
    set(${PREPARE_BUILD_BY_CONAN_CONAN_BUILD_PRESET}
        "${CONAN_BUILDED_CMAKE_PRESET}"
        PARENT_SCOPE)
endfunction(prepare_build_presets_by_conan)

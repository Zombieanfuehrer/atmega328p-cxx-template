set(CPPLINT_CONFIG
"verbose"
"output"
"filter"
"counting"
"repository"
"root"
"linelength"
"recursive"
"exclude"
"extensions"
"headers")

function(get_build_filter)
    set(oneValueArgs CPPLINT_CFG_JSON_CONTENT FILTER_LIST)
    cmake_parse_arguments(
        GET_BUILD_FILTER
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    string(
        JSON
        VALUE
        GET
        ${GET_BUILD_FILTER_CPPLINT_CFG_JSON_CONTENT}
        "filter")

    set(CURRENT_FILTER_LIST ${GET_BUILD_FILTER_FILTER_LIST})

    if (NOT "${VALUE}" STREQUAL "")
        string(FIND "${VALUE}" "\"build\": [" start_index)
        string(FIND "${VALUE}" "]," end_index)

        math(EXPR content_start "${start_index} +19") # 19 Chars inkl. build\": [ bis zum ersten array eintrag
        math(EXPR content_length "${end_index} - ${content_start}")
        string(SUBSTRING "${VALUE}" ${content_start} ${content_length} BUILD_CONTENT)
        string(REPLACE "\n" "" BUILD_CONTENT "${BUILD_CONTENT}")
        string(REPLACE " " "" BUILD_CONTENT "${BUILD_CONTENT}")
        string(REPLACE "\"" "" BUILD_CONTENT "${BUILD_CONTENT}")
        list(APPEND CURRENT_FILTER_LIST ${BUILD_CONTENT})
        set(${GET_BUILD_FILTER_FILTER_LIST} "${CURRENT_FILTER_LIST}" PARENT_SCOPE)
    endif()
endfunction(get_build_filter)

function(parse_cpplint_config)
    set(oneValueArgs CPPLINT_CONFIG_JSON_PATH)
    cmake_parse_arguments(
        PARSE_CPPLINT_CONFIG
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

        message(
            STATUS "[parse_cpplint_config] search for cpplint configuration at : ${PARSE_CPPLINT_CONFIG_CPPLINT_CONFIG_JSON_PATH}")
        file(READ "${PARSE_CPPLINT_CONFIG_CPPLINT_CONFIG_JSON_PATH}" CPPLINT_CONFIG_JSON_CONTENT)
    
        foreach(CPP_CONFIGURATION_OPTION IN LISTS CPPLINT_CONFIG)
            # Handle filter arrays specially
            if (CPP_CONFIGURATION_OPTION MATCHES "^filter")
                get_build_filter(
                    CPPLINT_CFG_JSON_CONTENT
                    ${CPPLINT_CONFIG_JSON_CONTENT}
                    FILTER_LIST
                    UPDATED_CPPLINT_CONFIG
                )
            else()
            # General case for other configuration options
            string(
                JSON
                VALUE
                GET
                ${CPPLINT_CONFIG_JSON_CONTENT}
                ${CPP_CONFIGURATION_OPTION})

            if (NOT "${VALUE}" STREQUAL "")
                list(APPEND UPDATED_CPPLINT_CONFIG "${CPP_CONFIGURATION_OPTION}=${VALUE}")
            else()
                message(STATUS "[parse_cpplint_config] ${CPP_CONFIGURATION_OPTION}: No valid value found!")
            endif()
        endif()
    endforeach()

        
        foreach(IT IN LISTS UPDATED_CPPLINT_CONFIG)
            message(STATUS "DEBUG: ${IT}")  
        endforeach()
endfunction(parse_cpplint_config)

function(add_cpplint_dependancy)
    find_program(CPPLINT "cpplint")
    if(NOT CPPLINT)
        message(FATAL_ERROR "[add_cpplint_dependancy] cpplint not found! Please install to use this option")
    else()
        set(CMAKE_CXX_CPPLINT ${CPPLINT})
    endif()
   
    set(CPPLINT_CONFIG_JSON "${PROJECT_SOURCE_DIR}/style/cpplint_config.json")
    
    parse_cpplint_config(
        CPPLINT_CONFIG_JSON_PATH
        ${CPPLINT_CONFIG_JSON}  
    )

    file(GLOB_RECURSE CXX_FILES "${CMAKE_SOURCE_DIR}/*.cpp" "${CMAKE_SOURCE_DIR}/*.cc" "${CMAKE_SOURCE_DIR}/*.cxx")
    list(
        FILTER
        CXX_FILES
        EXCLUDE
        REGEX
        "${CMAKE_SOURCE_DIR}/(build|external|.venv|CMakeFiles)/.*")

    message(STATUS "[add_cpplint_dependancy] add c++ files to cpplint analysis")
    foreach(CXX_FILE_CPPLINT_CMD ${CXX_FILES})
        message(STATUS "[add_cpplint_dependancy] add '${CXX_FILE_CPPLINT_CMD}' to cpplint static code analyse")    
    endforeach()
    set(CPPLINT_CFG "${CMAKE_SOURCE_DIR}/style/CPPLINT.cfg")
    add_custom_target(run_cpplint ALL
    COMMAND ${CPPLINT}
    --config=${CPPLINT_CFG}
    ${CXX_FILES}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "run cpplint on cpp source install_files"
    VERBATIM
    )
    
endfunction(add_cpplint_dependancy)

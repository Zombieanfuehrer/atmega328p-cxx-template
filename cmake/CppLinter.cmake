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

set(CPPLINT_FILTER_TYPES
"build"
"legal"
"readability"
"runtime"
"whitespace"
)

function(get_linter_filter_array)
    set(oneValueArgs CPPLINT_CFG_JSON_CONTENT ARRAY_TYPENAME FILTER_LIST)
    cmake_parse_arguments(
        GET_LINTER_FILTER_ARRAY
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    message(STATUS "[get_linter_filter_array] search for cpplint filter type: ${GET_LINTER_FILTER_ARRAY_ARRAY_TYPENAME} and extract appropriate options: \n")
    string(
        JSON
        VALUE
        GET
        ${GET_LINTER_FILTER_ARRAY_CPPLINT_CFG_JSON_CONTENT}
        "filter")

    set(CURRENT_FILTER_LIST)
    if (NOT "${VALUE}" STREQUAL "")
        set(SEARCH_FOR_FILTER_ARRAY_ENTRYS_REGEX "[+-]${GET_LINTER_FILTER_ARRAY_ARRAY_TYPENAME}\/[a-zA-Z0-9_+]+")
        string(REGEX MATCHALL "${SEARCH_FOR_FILTER_ARRAY_ENTRYS_REGEX}" CPPLINT_CONFIG_FILTER_ENTRIES ${VALUE})
        list(APPEND CURRENT_FILTER_LIST ${CPPLINT_CONFIG_FILTER_ENTRIES})
        set(${GET_LINTER_FILTER_ARRAY_FILTER_LIST} "${CURRENT_FILTER_LIST}" PARENT_SCOPE)
    else()
        message(STATUS "[get_linter_filter_array] no valid 'filter' found in cpplint-config.json file!")
    endif()
endfunction(get_linter_filter_array)

function(parse_cpplint_config)
    set(oneValueArgs CPPLINT_CONFIG_JSON_PATH)
    cmake_parse_arguments(
        PARSE_CPPLINT_CONFIG
        ""
        "${oneValueArgs}"
        ""
        ${ARGN})

    message(STATUS "[parse_cpplint_config] search for cpplint configuration at : ${PARSE_CPPLINT_CONFIG_CPPLINT_CONFIG_JSON_PATH}")
    file(READ "${PARSE_CPPLINT_CONFIG_CPPLINT_CONFIG_JSON_PATH}" CPPLINT_CONFIG_JSON_CONTENT)
    
    set(UPDATED_CPPLINT_CONFIG)
    foreach(CPP_CONFIGURATION_OPTION IN LISTS CPPLINT_CONFIG)
        # Handle filter arrays specially
        if (CPP_CONFIGURATION_OPTION MATCHES "^filter")
            foreach(CPP_LINTER_FILTER_ARRAY IN LISTS CPPLINT_FILTER_TYPES)
                set(UPDATED_CPPLINT_CONFIG_TMP "")
                get_linter_filter_array(
                    CPPLINT_CFG_JSON_CONTENT
                    ${CPPLINT_CONFIG_JSON_CONTENT}
                    ARRAY_TYPENAME
                    ${CPP_LINTER_FILTER_ARRAY}
                    FILTER_LIST
                    UPDATED_CPPLINT_CONFIG_TMP
                )
                list(APPEND UPDATED_CPPLINT_CONFIG "${UPDATED_CPPLINT_CONFIG_TMP}")
            endforeach()
        else()
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

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
    

        string(
        JSON
        CPPLINT_VERBOSITY
        GET
        ${CPPLINT_CONFIG_JSON_CONTENT}
        "verbose")
    
        message(
            STATUS "[parse_cpplint_config] cpplint verbose : ${CPPLINT_VERBOSITY}")
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

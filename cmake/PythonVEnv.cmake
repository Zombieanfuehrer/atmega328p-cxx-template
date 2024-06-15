function(set_python_virtual_enviroment)
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
    if (Python3_FOUND)
        message(STATUS "[set_python_virtual_enviroment] Found Python 3 Version: ${Python3_VERSION}")
    else()
        message(FATAL_ERROR "[set_python_virtual_enviroment] Python 3 missing, but is a requirement for this project!")
    endif()

    if(EXISTS "${CMAKE_SOURCE_DIR}/requirements.txt" AND NOT EXISTS "${CMAKE_SOURCE_DIR}/.venv/")
        message(STATUS "[set_python_virtual_enviroment] setup virtual python enviroment for this project") 

        execute_process(
            COMMAND ${Python_EXECUTABLE} -m venv .venv
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    endif()

    if(EXISTS "${CMAKE_SOURCE_DIR}/requirements.txt" AND EXISTS "${CMAKE_SOURCE_DIR}/.venv/") 
        message(STATUS "[set_python_virtual_enviroment] load virtual python enviroment for this project")
        execute_process(
            COMMAND source activate
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/.venv/bin
        )

        # change python3 from $PATH to virtual enviroment
        set (ENV{VIRTUAL_ENV} "${CMAKE_SOURCE_DIR}/.venv")
        set (Python3_FIND_VIRTUALENV FIRST)
        unset (Python3_EXECUTABLE)
        find_package (Python3 COMPONENTS Interpreter REQUIRED)

        execute_process(
            COMMAND ${Python_EXECUTABLE} -m pip install -r requirements.txt
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE PIP_INSTALL_STDOUT
            ERROR_VARIABLE PIP_INSTALL_STDERR
            RESULT_VARIABLE PIP_INSTALL_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(PIP_INSTALL_RESULT)
            message(STATUS "[set_python_virtual_enviroment] pip install error is '${PIP_INSTALL_STDOUT}'")
        else()
            message(STATUS "[set_python_virtual_enviroment] pip install succeeded: '${PIP_INSTALL_STDOUT}'")
        endif()

    endif()

endfunction(set_python_virtual_enviroment)

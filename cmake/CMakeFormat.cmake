function(add_cmake_format_target)
    # Definieren der Haupt-CMake-Datei und das Rekursive Suchen nach CMake-Dateien
    set(ROOT_CMAKE_FILES "${CMAKE_SOURCE_DIR}/CMakeLists.txt")
    file(GLOB_RECURSE CMAKE_FILES_TXT "*/CMakeLists.txt")
    file(GLOB_RECURSE CMAKE_FILES_C "cmake/*.cmake")

    # Filtern der Dateien, um bestimmte Verzeichnisse auszuschließen
    list(
        FILTER
        CMAKE_FILES_TXT
        EXCLUDE
        REGEX
        "${CMAKE_SOURCE_DIR}/(build|external|.venv)/.*")
    set(CMAKE_FILES ${ROOT_CMAKE_FILES} ${CMAKE_FILES_TXT} ${CMAKE_FILES_C})

    # Suchen des cmake-format Programms
    find_program(CMAKE_FORMAT cmake-format)
    if(CMAKE_FORMAT)
        message(STATUS "[add_cmake_format_target] Added Cmake Format")

        # Erstellen der Liste von Formatierungsbefehlen
        set(FORMATTING_COMMANDS)
        foreach(cmake_file ${CMAKE_FILES})
            list(
                APPEND
                FORMATTING_COMMANDS
                COMMAND
                cmake-format
                -c
                ${CMAKE_SOURCE_DIR}/.cmake-format.yaml
                -i
                ${cmake_file})
        endforeach()

        # Definieren des custom Targets zum Ausführen der Formatierung
        add_custom_target(
            run_cmake_format
            COMMAND ${FORMATTING_COMMANDS}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMENT "Running cmake-format")
    else()
        message(WARNING "[add_cmake_format_target] CMAKE_FORMAT NOT FOUND")
    endif()
endfunction()

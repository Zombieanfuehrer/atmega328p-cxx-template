function(remove_newlines string_input string_output)
    string(
        REGEX MATCH
              "\n"
              NEWLINE_IN
              "${string_input}")
    if(NEWLINE_IN)
        message(STATUS "Input string contains newlines. Removing them...")
        string(
            REPLACE "\n"
                    ""
                    cleaned_string
                    "${input}")
        set(${output}
            "${cleaned_string}"
            PARENT_SCOPE)
    else()
        message(STATUS "Input string does not contain newlines.")
        set(${output}
            "${input}"
            PARENT_SCOPE)
    endif()
endfunction()

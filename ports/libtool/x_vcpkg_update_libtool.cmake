if(Z_VCPKG_UPDATE_LIBTOOL_GUARD)
    return()
endif()
set(Z_VCPKG_UPDATE_LIBTOOL_GUARD ON CACHE INTERNAL "guard variable")

function(x_vcpkg_update_libtool)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "RECURSE"
        "SOURCE_PATH"
        ""
    )
    if(NOT DEFINED arg_SOURCE_PATH OR arg_SOURCE_PATH STREQUAL "")
        message(FATAL_ERROR "x_vcpkg_update_libtool requires parameter SOURCE_PATH!")
    endif()

    if(arg_RECURSE)
        file(GLOB_RECURSE files "${arg_SOURCE_PATH}/ltmain.sh")
    else()
        set(files "${arg_SOURCE_PATH}/build-aux/ltmain.sh")
    endif()
    foreach(file IN LISTS files)
        configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/@PORT@/libtool/build-aux/ltmain.sh" "${file}" COPYONLY)
    endforeach()
endfunction()

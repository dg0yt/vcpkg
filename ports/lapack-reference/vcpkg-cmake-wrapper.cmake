message(STATUS "Using VCPKG FindLAPACK from package 'lapack-reference'")
set(LAPACK_PREV_MODULE_PATH "${CMAKE_MODULE_PATH}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE")

include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
    enable_language(Fortran) # needed for lapack-reference/mingw
endif()

_find_package(${ARGS})

set(CMAKE_MODULE_PATH "${LAPACK_PREV_MODULE_PATH}")
unset(LAPACK_PREV_MODULE_PATH)
cmake_minimum_required(VERSION 3.7)

project(skia-example)

set(CMAKE_CXX_STANDARD 17)

add_executable(main WIN32 convert-to-nia.cpp)

find_package(unofficial-skia CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::skia::skia)

set(PRINT_VARS "" CACHE STRING "Variables to print at the end of configuration")
foreach(var IN LISTS PRINT_VARS)
    message(STATUS "${var}:=${${var}}")
endforeach()

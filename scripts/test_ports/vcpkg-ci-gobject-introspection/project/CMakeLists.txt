cmake_minimum_required(VERSION 3.30)
project(gobject-introspection-test C)

set(CMAKE_SKIP_RPATH FALSE)

find_package(PkgConfig REQUIRED)
pkg_check_modules(gobject-introspection_pc gobject-introspection-1.0 REQUIRED IMPORTED_TARGET)

add_executable(main-pkgconfig main.c)
target_link_libraries(main-pkgconfig PRIVATE
    PkgConfig::gobject-introspection_pc
)

OPTION(RUN_TEST "Run the test program")
if(RUN_TEST)
    # NB: Building with gobject-introspection implies being able to run binaries.
    add_custom_target(run-test ALL main-pkgconfig)
endif()
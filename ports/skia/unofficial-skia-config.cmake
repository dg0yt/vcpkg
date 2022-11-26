# Compute the installation prefix relative to this file.
get_filename_component(vcpkg_root "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(vcpkg_root "${vcpkg_root}" PATH)
get_filename_component(vcpkg_root "${vcpkg_root}" PATH)
if(vcpkg_root STREQUAL "/")
    set(vcpkg_root "")
endif()

find_library(SKIA_LIB_REL NAMES skia skia.dll PATHS "${vcpkg_root}/lib" NO_DEFAULT_PATH)
find_library(SKIA_LIB_DBG NAMES skia skia.dll PATHS "${vcpkg_root}/debug/lib" NO_DEFAULT_PATH)

if(NOT TARGET unofficial::skia::skia)
    add_library(unofficial::skia::skia UNKNOWN IMPORTED)
    set_target_properties(unofficial::skia::skia PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${vcpkg_root}/include/skia;${vcpkg_root}/include/skia/include"
    )

    if(SKIA_LIB_REL)
        set_property(TARGET unofficial::skia::skia APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE
        )
        set_target_properties(unofficial::skia::skia PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
            IMPORTED_LOCATION_RELEASE "${SKIA_LIB_REL}"
        )
        set_property(TARGET unofficial::skia::skia APPEND PROPERTY
            INTERFACE_COMPILE_DEFINITIONS "$<$<CONFIG:Release>:@SKIA_DEFINITIONS_REL@>"
        )
    endif()

    if(SKIA_LIB_DBG)
        set_property(TARGET unofficial::skia::skia APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(unofficial::skia::skia PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
            IMPORTED_LOCATION_DEBUG "${SKIA_LIB_DBG}"
        )
        set_property(TARGET unofficial::skia::skia APPEND PROPERTY
            INTERFACE_COMPILE_DEFINITIONS "$<$<NOT:$<CONFIG:Release>>:@SKIA_DEFINITIONS_DBG@>"
        )
    endif()

    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        include(CMakeFindDependencyMacro)
        find_dependency(Fontconfig) # CMake 3.14
        find_dependency(Freetype)
        set(link_libs Fontconfig::Fontconfig Freetype::Freetype)
        set(skia_features "@FEATURES@")
        if("gl" IN_LIST skia_features)
            find_dependency(OpenGL)
            if(TARGET OpenGL::GLX)
                list(APPEND link_libs OpenGL::GLX)
            endif()
        endif()
        set_property(TARGET unofficial::skia::skia APPEND PROPERTY INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:${link_libs}>")
    endif()

    function(set_dependencies config path libraries)
        set(libs "")
        set(trailing_libs "")
        foreach(lib IN LISTS libraries)
            if(TARGET "${lib}")
                list(APPEND libs "${lib}")
            elseif(lib MATCHES "^/")
                if(WIN32)
                    string(SUBSTRING "${lib}" 1 -1 lib)
                endif()
                list(APPEND libs "${lib}")
            elseif(lib MATCHES [[^(dl|m|pthread)$]])
                list(APPEND trailing_libs "${lib}")
            elseif(lib MATCHES [[([a-zA-Z0-9][a-zA-Z0-9]*)[.]framework$]])
                list(APPEND trailing_libs "-framework ${CMAKE_MATCH_1}")
            else()
                string(MAKE_C_IDENTIFIER "z_vcpkg_skia_${lib}${config}" lib_var)
                find_library(${lib_var} NAMES "${lib}" PATH "${path}")
                mark_as_advanced(${lib_var})
                if("${${lib_var}}")
                    list(APPEND libs "${${lib_var}}")
                else()
                    message(STATUS "Omitting '${lib}' from link libraries.")
                endif()
            endif()
        endforeach()
        list(APPEND libs "${trailing_libs}")
        if(libs)
            set_property(TARGET unofficial::skia::skia APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                "$<LINK_ONLY:$<${config}:${libs}>>")
        endif()
    endfunction()

    # @SKIA_DEP_REL@
    set_dependencies(
        [[$<NOT:$<CONFIG:Release>>]]
        "${vcpkg_root}/debug/lib"
        "@SKIA_DEP_DBG@"
    )
    # @SKIA_DEP_DBG@
    set_dependencies(
        [[$<CONFIG:Release>]]
        "${vcpkg_root}/lib"
        "@SKIA_DEP_REL@"
    )
endif()

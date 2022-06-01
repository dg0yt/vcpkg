set(OSG_VER 3.6.5)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO openscenegraph/OpenSceneGraph
	REF OpenSceneGraph-${OSG_VER}
	SHA512 7002fa30a3bcf6551d2e1050b4ca75a3736013fd190e4f50953717406864da1952deb09f530bc8c5ddf6e4b90204baec7dbc283f497829846d46d561f66feb4b
	HEAD_REF master
    PATCHES
        collada.patch
        fix-sdl.patch
        fix-example-application.patch
        disable-present3d-staticview-in-linux.patch #Due to some link error we cannot solve yet, disable them in linux.
        fix-curl.patch
        remove-prefix.patch # Remove this patch when cmake fix Findosg_functions.cmake
        use-boost-asio.patch
        osgdb_zip_nozip.patch # This is fix symbol clashes with other libs when built in static-lib mode
)

file(REMOVE "${SOURCE_PATH}/CMakeModules/FindSDL2.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OSG_DYNAMIC)

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -DOSG_USE_UTF8_FILENAME=ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       BUILD_OSG_APPLICATIONS
        examples    BUILD_OSG_EXAMPLES
        plugins     BUILD_OSG_PLUGINS
        packages    BUILD_OSG_PACKAGES
        docs        BUILD_DOCUMENTATION
        docs        BUILD_REF_DOCS_SEARCHENGINE
        docs        BUILD_REF_DOCS_TAGFILE
        fontconfig  OSG_TEXT_USE_FONTCONFIG
        collada     BUILD_OSG_PLUGIN_DAE
        nvtt        BUILD_OSG_PLUGIN_NVTT
        rest-http-device BUILD_OSG_PLUGIN_RESTHTTPDEVICE
)

set(plugin_vars "")
file(STRINGS "${SOURCE_PATH}/src/osgPlugins/CMakeLists.txt" plugin_lines REGEX "ADD_PLUGIN_DIRECTORY")
foreach(line IN LISTS plugin_lines)
    if(NOT line MATCHES "ADD_PLUGIN_DIRECTORY\\(([^)]*)" OR NOT EXISTS "${SOURCE_PATH}/src/osgPlugins/${CMAKE_MATCH_1}/CMakeLists.txt")
        continue()
    endif()
    string(TOUPPER "${CMAKE_MATCH_1}" plugin_upper)
    list(APPEND plugin_vars "BUILD_OSG_PLUGIN_${plugin_upper}")
endforeach()

# The package osg can be configured to use different OpenGL profiles via a custom triplet file:
# Possible values are GLCORE, GL2, GL3, GLES1, GLES2, GLES3, and GLES2+GLES3
if(NOT DEFINED osg_OPENGL_PROFILE)
    set(osg_OPENGL_PROFILE "GL3")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDYNAMIC_OPENSCENEGRAPH=${OSG_DYNAMIC}
        -DDYNAMIC_OPENTHREADS=${OSG_DYNAMIC}
        -DBUILD_OSG_PLUGIN_DICOM=OFF
        -DBUILD_OSG_PLUGIN_DIRECTSHOW=OFF
        -DBUILD_OSG_PLUGIN_FBX=OFF
        -DBUILD_OSG_PLUGIN_FFMPEG=OFF
        -DBUILD_OSG_PLUGIN_GSTREAMER=OFF
        -DBUILD_OSG_PLUGIN_INVENTOR=OFF
        -DBUILD_OSG_PLUGIN_LAS=OFF
        -DBUILD_OSG_PLUGIN_LUA=OFF
        -DBUILD_OSG_PLUGIN_OPENCASCADE=OFF
        -DBUILD_OSG_PLUGIN_QTKIT=OFF
        -DBUILD_OSG_PLUGIN_SVG=OFF
        -DBUILD_OSG_PLUGIN_VNC=OFF
        -DOPENGL_PROFILE=${osg_OPENGL_PROFILE}
        -DBUILD_OSG_PLUGIN_ZEROCONFDEVICE=OFF
        -DBUILD_DASHBOARD_REPORTS=OFF
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_DISABLE_FIND_PACKAGE_Inventor=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SDL=ON
        ${OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUILD_REF_DOCS_SEARCHENGINE
        BUILD_REF_DOCS_TAGFILE
        ${plugin_vars}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# handle osg tools and plugins
set(OSG_TOOL_PATH "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(GLOB OSG_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
if (OSG_TOOLS)
    file(INSTALL ${OSG_TOOLS} DESTINATION "${OSG_TOOL_PATH}" USE_SOURCE_PERMISSIONS)
    file(REMOVE_RECURSE ${OSG_TOOLS})
    file(GLOB OSG_TOOLS_DBG "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(REMOVE_RECURSE ${OSG_TOOLS_DBG})
endif()
file(GLOB OSG_TOOLS "${CURRENT_PACKAGES_DIR}/share/OpenSceneGraph/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
if (OSG_TOOLS)
    file(INSTALL ${OSG_TOOLS} DESTINATION "${OSG_TOOL_PATH}" USE_SOURCE_PERMISSIONS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/OpenSceneGraph")
endif()

file(GLOB OSG_PLUGINS_DBG "${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/*")
if (OSG_PLUGINS_DBG)
    file(INSTALL ${OSG_PLUGINS_DBG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER}")
endif()

file(GLOB OSG_PLUGINS_REL "${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/*")
if (OSG_PLUGINS_REL)
    file(INSTALL ${OSG_PLUGINS_REL} DESTINATION "${OSG_TOOL_PATH}/osgPlugins-${OSG_VER}")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}"
    "${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

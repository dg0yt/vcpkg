string(REGEX MATCH "^([0-9]*[.][0-9]*)" Gi_MAJOR_MINOR "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gobject-introspection/${GI_MAJOR_MINOR}/gobject-introspection-${VERSION}.tar.xz"
    FILENAME "gobject-introspection-${VERSION}.tar.xz"
    SHA512 b8fba2bd12e93776c55228acf3487bef36ee40b1abdc7f681b827780ac94a8bfa1f59b0c30d60fa5a1fea2f610de78b9e52029f411128067808f17eb6374cdc5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        ##0002-cross-build.patch
        0003-fix-paths.patch
        #python.patch
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/python3")
if(VCPKG_CROSSCOMPILING)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")
endif()

vcpkg_list(SET OPTIONS_RELEASE)
if("libs" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS_RELEASE -Dbuild_introspection_data=true)
else()
    # only tools
    set(VCPKG_BUILD_TYPE "release") 
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild_introspection_data=false
        -Dcairo=disabled # only used for tests
        -Ddoctool=disabled
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        g-ir-annotation-tool='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-annotation-tool'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner'
)

vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()

set(GI_TOOLS
        g-ir-compiler
        g-ir-generate
        g-ir-inspect
)
set(GI_SCRIPTS
        g-ir-annotation-tool
        g-ir-scanner
)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN LISTS GI_SCRIPTS)
    file(READ "${CURRENT_PACKAGES_DIR}/bin/${script}" _contents)
    string(REPLACE "#!/usr/bin/env ${PYTHON3}" "#!/usr/bin/env python3" _contents "${_contents}")
    string(REPLACE "datadir = \"${CURRENT_PACKAGES_DIR}/share\"" "raise Exception('could not find right path') " _contents "${_contents}")
    string(REPLACE "pylibdir = os.path.join('${CURRENT_PACKAGES_DIR}/lib', 'gobject-introspection')" "raise Exception('could not find right path') " _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/bin/${script}" "${_contents}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()
vcpkg_copy_tools(TOOL_NAMES ${GI_TOOLS} AUTO_CLEAN)
if(NOT VCPKG_TARGET_IS_WINDOWS)
endif()

if("libs" IN_LIST FEATURES)
    vcpkg_fixup_pkgconfig()
else()
    file(GLOB unix_runtime LIST_DIRECTORIES false
        "${CURRENT_PACKAGES_DIR}/lib/lib*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}*"
        "${CURRENT_PACKAGES_DIR}/lib/lib*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}*"
    )
    if(unix_runtime)
        file(COPY ${unix_runtime} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
    file(GLOB devel LIST_DIRECTORIES true
        "${CURRENT_PACKAGES_DIR}/include"
        "${CURRENT_PACKAGES_DIR}/lib/*"
    )
    list(FILTER devel EXCLUDE REGEX "/gobject-introspection\$")
    file(REMOVE_RECURSE ${devel})
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pyd_lib_files "${CURRENT_PACKAGES_DIR}/lib/gobject-introspection/giscanner/_giscanner.*.lib")
    file(REMOVE ${_pyd_lib_files})
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

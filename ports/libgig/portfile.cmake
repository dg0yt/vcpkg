vcpkg_download_distfile(ARCHIVE
    URLS "https://download.linuxsampler.org/packages/libgig-${VERSION}.tar.bz2"
    FILENAME "libgig-${VERSION}.tar.bz2"
    SHA512 921bddf06b572d7336cb0055a62b6509901bc07156ea487b0941ae84a86ae545c54772ef113f34be40bd17894a1364480f4e5e1b93ef2635ed2b430f052d789e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        cmakelists.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBGIG_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools LIBGIG_BUILD_TOOLS
        tests LIBGIG_ENABLE_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBGIG_BUILD_SHARED=${LIBGIG_BUILD_SHARED}
        -DVERSION=${VERSION}
    OPTIONS_DEBUG
        -DLIBGIG_BUILD_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_OSX AND NOT VCPKG_TARGET_IS_WINDOWS)
    file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/libgig-config.cmake" cmake_config)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/libgig-config.cmake" "include(CMakeFindDependencyMacro)\nfind_dependency(unofficial-libuuid)\n\n${cmake_config}")
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES dlsdump gigdump gigmerge korg2gig korgdump rifftree sf2dump
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

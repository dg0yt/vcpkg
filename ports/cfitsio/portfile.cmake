vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.1.0.tar.gz"
    FILENAME "cfitsio-4.1.0.tar.gz"
    SHA512 bbbe10e890e74a30a9806dd2bbf711b3b1f15502b210b222d2d57cc083495c3b66b44927e4680f989045187fb7075f7187e2805ddcb4753ce53c68c3442cc813
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-fix-dependencies-and-export-cmake-targets.patch
        0002-add-Wno-error-implicit-funciton-declaration-to-cmake.patch
        0003-fix-LNK2019-of-strtok_r-in-pthreads-feature.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl        USE_CURL
        curl        CMAKE_REQUIRE_FIND_PACKAGE_CURL
        pthreads    USE_PTHREADS
        tools       UTILS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DUTILS=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_CURL
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-cfitsio)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES FPack Funpack Fitscopy
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
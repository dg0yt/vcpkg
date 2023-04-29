set(VCPKG_BUILD_TYPE "release")
set(7ZIP_VERSION "2201")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z${7ZIP_VERSION}-src.7z"
    FILENAME "7z${7ZIP_VERSION}-src.7z"
    SHA512 c37cede4b7253b8dc4372e9e011ef0fee0c1cd53cf9705bf106672a455e7ce1e5a0a288c763d73d3c28b2a41fb860c9bacb702b01d9192eed810787c7da1e0d8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

if("cmake" IN_LIST FEATURES)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tool"  BUILD_TOOL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DASM_TARGET=${VCPKG_TARGET_ARCHITECTURE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

else()
    message(STATUS "** ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    z_vcpkg_get_cmake_vars(for_cache)
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    file(INSTALL "${SOURCE_PATH}/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    vcpkg_build_make(
        SUBPATH "CPP/7zip/Bundles/Format7zF"
        MAKEFILE "makefile.gcc"
        OPTIONS _o COMPL_STATIC=1
    )
endif()

file(
    INSTALL "${SOURCE_PATH}/DOC/License.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

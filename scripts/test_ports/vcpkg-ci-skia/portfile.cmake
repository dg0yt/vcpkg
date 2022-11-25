set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/skia/example"
    OPTIONS
        "-DPRINT_VARS=SKIA_LIB_REL;SKIA_LIB_DBG"
)
vcpkg_cmake_build()

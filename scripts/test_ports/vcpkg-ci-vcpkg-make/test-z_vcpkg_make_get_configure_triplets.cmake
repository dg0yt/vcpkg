block(SCOPE_FOR VARIABLES  PROPAGATE build_opt)
    z_vcpkg_make_get_configure_triplets(configure_triplets)
    if(configure_triplets STREQUAL "")
        # Initially empty configure_triplets is okay.
        # Force non-empty configure_triplets via VCPKG_MAKE_BUILD_TRIPLET.
        set(VCPKG_MAKE_BUILD_TRIPLET "--host=vcpkg")
        z_vcpkg_make_get_configure_triplets(configure_triplets)
    endif()
    string(REGEX MATCH "--host=[^;]*" host_opt "${configure_triplets};")
    unit_test_check_variable_not_equal(
        [[ # match --host ]]
        host_opt ""
    )
    string(REGEX MATCH "--build=[^;]*" build_opt "${configure_triplets};")
    unit_test_check_variable_not_equal(
        [[ # match --build ]]
        build_opt ""
    )
endblock()

if(VCPKG_MAKE_BUILD_TRIPLET)
    if(VCPKG_MAKE_BUILD_TRIPLET MATCHES "--host" AND NOT VCPKG_MAKE_BUILD_TRIPLET MATCHES "--build")
        unit_test_check_variable_equal(
            [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "x86_64-linux-gnu-clang-12") ]]
            actual "${VCPKG_MAKE_BUILD_TRIPLET};${build_opt}"
        )
    endif()
elseif(VCPKG_TARGET_IS_ANDROID)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/bin/armv7a-linux-androideabi28-clang") ]]
        actual "--host=armv7a-linux-androideabi28;${build_opt}"
    )
elseif(VCPKG_TARGET_IS_LINUX)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "gcc") ]]
        actual ""
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/bin/aarch64-linux-gnu-gcc-13") ]]
        actual "--host=aarch64-linux-gnu;${build_opt}"
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/usr/bin/x86_64-linux-gnu-clang-12") ]]
        actual "--host=x86_64-linux-gnu;${build_opt}"
    )
endif()

# VCPKG_MAKE_BUILD_TRIPLET robustness
set(VCPKG_MAKE_BUILD_TRIPLET "--host=HHH;--build=BBB")
unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_configure_triplets(actual) ]]
    actual "--host=HHH;--build=BBB"
)
set(VCPKG_MAKE_BUILD_TRIPLET "--build=bbb;--host=hhh")
unit_test_check_variable_equal(
    [[ z_vcpkg_make_get_configure_triplets(actual) ]]
    actual "--host=hhh;--build=bbb"
)

if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "vcpkg-release-triplets is a host-only port.")
endif()

set(triplets_dir "${VCPKG_ROOT_DIR}/triplets")
set(community_triplets_dir "${triplets_dir}/community")

file(GLOB official_triplets
    LIST_DIRECTORIES false
    ${triplets_dir}/*.cmake
)
file(GLOB community_triplets
    LIST_DIRECTORIES false
    ${community_triplets_dir}/*.cmake
)

set(TRIPLETS )
set(release_triplet )
foreach(triplet_file IN LISTS official_triplets community_triplets)
    set(ignored_triplets "release[.]cmake$")
    set(selected_triplets "-android|-mingw|-emscripten")
    if(VCPKG_HOST_IS_WINDOWS)
        string(APPEND selected_triplets "|-windows|-uwp")
    elseif(VCPKG_HOST_IS_OSX)
        string(APPEND selected_triplets "|-osx|-ios")
    elseif(VCPKG_HOST_IS_LINUX)
        string(APPEND selected_triplets "|-linux")
    elseif(VCPKG_HOST_IS_FREEBSD)
        string(APPEND selected_triplets "|-freebsd")
    elseif(VCPKG_HOST_IS_OPENBSD)
        string(APPEND selected_triplets "|-openbsd")
    endif()
    if(triplet_file MATCHES "${ignored_triplets}" OR NOT triplet_file MATCHES "${selected_triplets}")
        continue()
    endif()
    get_filename_component(filename "${triplet_file}" NAME)
    string(REGEX REPLACE "[.]cmake$" "-release" release_triplet "${filename}")
    file(READ "${triplet_file}" definitions)
    string(APPEND definitions "\n# ^^^ copied from ${filename}\n")
    string(APPEND definitions "# vvv added by vcpkg-release-triplets\n")
    string(APPEND definitions "set(VCPKG_BUILD_TYPE release)\n")
    # This file remains even after `vcpkg remove vcpkg-release-triplets`.
    file(WRITE "${community_triplets_dir}/${release_triplet}.cmake" "${definitions}")
    string(APPEND TRIPLETS "    ${release_triplet}\n")
    if(release_triplet MATCHES "^${TARGET_TRIPLET}-release$")
        # Create a triplet named "release" representing the default triplet.
        file(WRITE "${community_triplets_dir}/release.cmake" "${definitions}")
        set(release_triplet "${TARGET_TRIPLET}")
    endif()
endforeach()
if(EXISTS "${community_triplets_dir}/release.cmake")
    string(APPEND TRIPLETS "    release    (based on triplet ${TARGET_TRIPLET})\n")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

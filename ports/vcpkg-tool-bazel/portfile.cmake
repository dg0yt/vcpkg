set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program bazel)
set(VERSION 6.5.0)

if(VCPKG_TARGET_IS_LINUX)
    set(tool_subdirectory "${VERSION}-linux")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-arm64")
        set(download_filename "bazel-${tool_subdirectory}-arm64")
        set(raw_executable ON)
        set(download_sha512 11e953717f0edd599053a9c6ab849c266f6b34cd6f39dd99301a138aeb9d10113d055f7a2452f6ae601a9e9c19c816d22732958bb147e493dae9c63b13e0f1e0)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-x86_64")
        set(download_filename "bazel-${tool_subdirectory}-x86_64")
        set(raw_executable ON)
        set(download_sha512 c9f117414f31bc85a1f6a91f3d1c0a4884a4bb346bb60b00599c2da8225d085f67bc865f1429c897681cb99471767171aed148c77ce80d9525841c873d9cc912)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    set(tool_subdirectory "${VERSION}-darwin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-arm64")
        set(download_filename "bazel-${tool_subdirectory}-arm64")
        set(raw_executable ON)
        set(download_sha512 303b5c897eab93fb164dda53ecf6294fd3376a5de17a752388f4e7f612a8a537acc7d99a021ca616c1d7989d10c3c14cd87689dad60b9f654bf75ecc606bb23e)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-x86_64")
        set(download_filename "bazel-${tool_subdirectory}-x86_64")
        set(raw_executable ON)
        set(download_sha512 6b50164eb6f72a08f6a54bea960dec2dd7da3c7acc076643a989816f80507eee4271f673a8ef749b5168b31b0cb271dbc374daf2afe8b4acf7ad176ae778e571)
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(tool_subdirectory "${VERSION}-windows")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-arm64.exe")
        set(download_filename "bazel-${tool_subdirectory}-arm64.exe")
        set(download_sha512 02c8f331daa3ea37319cf06d96618f433e297f749a1a6de863d243e2b826bfb12c058696cd6216afe38d35177f52cc1c66af98a8bcb191e198f436a44f2c2a1a)
    else()
        set(download_urls "https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${tool_subdirectory}-x86_64.exe")
        set(download_filename "bazel-${tool_subdirectory}-x86_64.exe")
        set(download_sha512 4917dd714345359c24e40451e20862b2ed705824ceffe536d42e56ffcd66fcea581317857dfb5339b56534b0681efd8376e8eebdcf9daff0d087444b060bdc53)
    endif()
endif()

vcpkg_download_distfile(archive_path
    URLS ${download_urls}
    SHA512 "${download_sha512}"
    FILENAME "${download_filename}"
)
message(STATUS "archive_path: '${archive_path}'")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(INSTALL "${archive_path}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools"
    RENAME "${program}"
    FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

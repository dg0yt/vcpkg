# Due to the complexity involved, this package just verifies the Vulkan SDK is installed.

# Stub only port
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# The VULKAN_SDK environment variable is only a robust check on WIN32.
if (WIN32 AND NOT DEFINED ENV{VULKAN_SDK})
    message(FATAL_ERROR "VULKAN_SDK environment variable not set! Refer to the Windows getting started documentation: https://vulkan.lunarg.com/doc/sdk/latest/windows/getting_started.html")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
)

if (EXISTS ${VULKAN_DIR}/../LICENSE.txt)
    configure_file(${VULKAN_DIR}/../LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
elseif(EXISTS ${VULKAN_DIR}/LICENSE.txt)
    configure_file(${VULKAN_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
else()
    configure_file(${CURRENT_PORT_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

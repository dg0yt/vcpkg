set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(7Z)
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(NINJA)

if (CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT
      PACKAGES 
        binutils
        libtool
        autoconf
        automake-wrapper
        automake1.16 m4
    )
endif()

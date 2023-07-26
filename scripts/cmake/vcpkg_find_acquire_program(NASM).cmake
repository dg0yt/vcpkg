set(program_name nasm)
set(program_version 2.16.01)
set(brew_package_name "nasm")
set(apt_package_name "nasm")
if(CMAKE_HOST_WIN32)
    if("$ENV{PROCESSOR_ARCHITECTURE}" STREQUAL "ARM64")
        vcpkg_acquire_msys(NASM_ROOT
            NO_DEFAULT_PACKAGES
            DIRECT_PACKAGES
                "https://mirror.msys2.org/mingw/clangarm64/mingw-w64-clang-aarch64-nasm-${program_version}-1-any.pkg.tar.zst"
                da074d16d03229c00d8a888fe3212f8acf29f53019207a852ba53d79bd64fdd83555f910e81e86f71d3dd4f044a62a2e7e9b095707f423bba89a3d18e3451be2
        )
        set("${program}" "${NASM_ROOT}/clangarm64/bin/nasm.exe" CACHE INTERNAL "")
    else()
        vcpkg_acquire_msys(NASM_ROOT
            NO_DEFAULT_PACKAGES
            DIRECT_PACKAGES
                "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-nasm-${program_version}-1-any.pkg.tar.zst"
                1cb13e4c662c82191abff5bf6d3b2fb432a793eb3d76c2f9acbe3147101fedfe9113f4e7c86a58d575516e4f4ed4636b1c25231a98f55fd4760ead597cfe9066
        )
        set("${program}" "${NASM_ROOT}/mingw32/bin/nasm.exe" CACHE INTERNAL "")
    endif()
    set("${program}" "${${program}}" PARENT_SCOPE)
    return()
endif()

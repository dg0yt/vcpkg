vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/google/skia
    REF f86f242886692a18f5adc1cf9cbd6740cd0870fd
    PATCHES
        "use_vcpkg_fontconfig.patch"
)

# Replace hardcoded python paths
vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
vcpkg_replace_string("${SOURCE_PATH}/gn/toolchain/BUILD.gn" "python3 " "\\\"${PYTHON3}\\\" ")

function(checkout_in_path path url ref)
    if(EXISTS "${path}")
        return()
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH dep_source_path
        URL "${url}"
        REF "${ref}"
    )
    file(RENAME "${dep_source_path}" "${path}")
endfunction()

set(EXTERNALS "${SOURCE_PATH}/third_party/externals")
file(MAKE_DIRECTORY "${EXTERNALS}")

# these following aren't available in vcpkg
# to update, visit the DEPS file in Skia's root directory
# define SKIA_USE_MIRROR in a triplet to use the mirrors
checkout_in_path("${EXTERNALS}/sfntly"
    "https://github.com/googlefonts/sfntly"
    "b55ff303ea2f9e26702b514cf6a3196a2e3e2974"
)
checkout_in_path("${EXTERNALS}/dng_sdk"
    "https://android.googlesource.com/platform/external/dng_sdk"
    "c8d0c9b1d16bfda56f15165d39e0ffa360a11123"
)
checkout_in_path("${EXTERNALS}/libgifcodec"
    "https://skia.googlesource.com/libgifcodec"
    "fd59fa92a0c86788dcdd84d091e1ce81eda06a77"
)
checkout_in_path("${EXTERNALS}/piex"
    "https://android.googlesource.com/platform/external/piex"
    "bb217acdca1cc0c16b704669dd6f91a1b509c406"
)

# Turn a CMake list into a gn list:
# "a;b;c" -> ["a","b","c"]
function(cmake_to_gn_list out_var input)
    if(NOT input STREQUAL "")
        string(REPLACE ";" "\",\"" input "\"${input}\"")
    endif()
    set("${out_var}" "[ ${input} ]" PARENT_SCOPE)
endfunction()

# Turn a space separated string into a gn list:
# "a b c" -> ["a","b","c"]
function(string_to_gn_list out_var input)
    string(STRIP "${input}" input)
    if(NOT input STREQUAL "")
        string(REGEX REPLACE "  *" "\",\"" input "\"${input}\"")
    endif()
    set("${out_var}" "[ ${input} ]" PARENT_SCOPE)
endfunction()

# multiple libraries with multiple names may be passed as
# "libA,libA2;libB,libB2,libB3;..."
function(find_libraries RESOLVED LIBRARY_NAMES PATHS)
    set(_RESOLVED "")
    foreach(_LIB_GROUP ${LIBRARY_NAMES})
        string(REPLACE "," ";" _LIB_GROUP_NAMES "${_LIB_GROUP}")
        unset(_LIB CACHE)
        find_library(_LIB NAMES ${_LIB_GROUP_NAMES}
            PATHS "${PATHS}"
            NO_DEFAULT_PATH)

        if(_LIB MATCHES "-NOTFOUND")
            message(FATAL_ERROR "Could not find library with names: ${_LIB_GROUP_NAMES}")
        endif()

        list(APPEND _RESOLVED "${_LIB}")
    endforeach()
    set(${RESOLVED} "${_RESOLVED}" PARENT_SCOPE)
endfunction()

# For each .gn file in the current list directory, configure and install at
# the corresponding directory to replace Skia dependencies with ones from vcpkg.
function(replace_skia_dep NAME INCLUDES LIBS_DBG LIBS_REL DEFINITIONS)
    list(TRANSFORM INCLUDES PREPEND "${CURRENT_INSTALLED_DIR}")
    cmake_to_gn_list(_INCLUDES "${INCLUDES}")

    find_libraries(_LIBS_REL "${LIBS_REL}" "${CURRENT_INSTALLED_DIR}/lib")
    cmake_to_gn_list(_LIBS_REL "${_LIBS_REL}")

    cmake_to_gn_list(_LIBS_DBG "")
    if (NOT VCPKG_BUILD_TYPE)
        find_libraries(_LIBS_DBG "${LIBS_DBG}" "${CURRENT_INSTALLED_DIR}/debug/lib")
        cmake_to_gn_list(_LIBS_DBG "${_LIBS_DBG}")
    endif()

    cmake_to_gn_list(_DEFINITIONS "${DEFINITIONS}")

    set(OUT_FILE "${SOURCE_PATH}/third_party/${NAME}/BUILD.gn")
    file(REMOVE "${OUT_FILE}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/${NAME}.gn" "${OUT_FILE}" @ONLY)
endfunction()

function(pkgconfig_to_gn pc_module gn_module)
    x_vcpkg_pkgconfig_get_modules(PREFIX PC_${module} MODULES ${pc_module} CFLAGS LIBS)
    foreach(config IN ITEMS DEBUG RELEASE)
        separate_arguments(cflags UNIX_COMMAND "${PC_${module}_CFLAGS_${config}}")
        set(defines "${cflags}")
        list(FILTER defines INCLUDE REGEX "^-D" )
        list(TRANSFORM defines REPLACE "^-D" "")
        list(APPEND defines ${ARGN})
        set(include_dirs "${cflags}")
        list(FILTER include_dirs INCLUDE REGEX "^-I" )
        list(TRANSFORM include_dirs REPLACE "^-I" "")
        separate_arguments(libs UNIX_COMMAND "${PC_${module}_LIBS_${config}}")
        set(lib_dirs "${libs}")
        list(FILTER lib_dirs INCLUDE REGEX "^-L" )
        list(TRANSFORM lib_dirs REPLACE "^-L" "")
        list(FILTER libs INCLUDE REGEX "^-l" )
        list(TRANSFORM libs REPLACE "^-l" "")
        set(GN_OUT_${config} "")
        foreach(item IN ITEMS defines include_dirs lib_dirs libs)
            if(${item})
                list(JOIN ${item} [[", "]] ${item})
                string(APPEND GN_OUT_${config} "    ${item} = [ \"${${item}}\" ]\n")
            endif()
        endforeach()
    endforeach()
    set(OUT_FILE "${SOURCE_PATH}/third_party/${gn_module}/BUILD.gn")
    file(REMOVE "${OUT_FILE}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/third-party.gn.in" "${OUT_FILE}" @ONLY)
endfunction()

set(_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")

replace_skia_dep(expat "/include" "libexpat,libexpatd,libexpatdMD,libexpatdMT" "libexpat,libexpatMD,libexpatMT" "")
pkgconfig_to_gn(freetype2 freetype2)
replace_skia_dep(harfbuzz "/include/harfbuzz" "harfbuzz;harfbuzz-subset" "harfbuzz;harfbuzz-subset" "")
pkgconfig_to_gn(icu-uc icu "U_USING_ICU_NAMESPACE=0")
replace_skia_dep(libjpeg-turbo "/include" "jpeg,jpegd;turbojpeg,turbojpegd" "jpeg;turbojpeg" "")
replace_skia_dep(libpng "/include" "libpng16,libpng16d" "libpng16" "")
replace_skia_dep(libwebp "/include"
    "webp,webpd;webpdemux,webpdemuxd;webpdecoder,webpdecoderd;webpmux,webpmuxd"
    "webp;webpdemux;webpdecoder;webpmux" "")
replace_skia_dep(zlib "/include" "z,zlib,zlibd" "z,zlib" "")
if(CMAKE_HOST_UNIX)
     replace_skia_dep(fontconfig "/include" "fontconfig" "fontconfig" "")
 endif()

set(OPTIONS "\
skia_use_lua=false \
skia_enable_tools=false \
skia_enable_spirv_validation=false \
target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\"")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND OPTIONS " is_component_build=true")
else()
    string(APPEND OPTIONS " is_component_build=false")
endif()

if(CMAKE_HOST_APPLE)
    if("metal" IN_LIST FEATURES)
        set(OPTIONS "${OPTIONS} skia_use_metal=true")
    endif()
endif()

if("vulkan" IN_LIST FEATURES)
     set(OPTIONS "${OPTIONS} skia_use_vulkan=true")
 endif()

if(CMAKE_HOST_WIN32)
   if("direct3d" IN_LIST FEATURES)
       set(OPTIONS "${OPTIONS} skia_use_direct3d=true")

       checkout_in_path("${EXTERNALS}/spirv-cross"
           "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
           "61c603f3baa5270e04bcfb6acf83c654e3c57679"
       )

       checkout_in_path("${EXTERNALS}/spirv-headers"
           "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
           "0bcc624926a25a2a273d07877fd25a6ff5ba1cfb"
       )

       checkout_in_path("${EXTERNALS}/spirv-tools"
           "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
           "0073a1fa36f7c52ad3d58059cb5d5de8efa825ad"
       )

       checkout_in_path("${EXTERNALS}/d3d12allocator"
           "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git"
           "169895d529dfce00390a20e69c2f516066fe7a3b"
       )
   endif()
endif()

if("dawn" IN_LIST FEATURES)

    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING
[[
dawn support requires the following libraries from the system package manager:

    libx11-xcb-dev mesa-common-dev

They can be installed on Debian based systems via

    apt-get install libx11-xcb-dev mesa-common-dev
]]
        )
    endif()

   set(OPTIONS "${OPTIONS} skia_use_dawn=true")

   checkout_in_path("${EXTERNALS}/spirv-cross"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross"
       "61c603f3baa5270e04bcfb6acf83c654e3c57679"
   )

   checkout_in_path("${EXTERNALS}/spirv-headers"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git"
       "0bcc624926a25a2a273d07877fd25a6ff5ba1cfb"
   )

   checkout_in_path("${EXTERNALS}/spirv-tools"
       "https://skia.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git"
       "0073a1fa36f7c52ad3d58059cb5d5de8efa825ad"
   )

   checkout_in_path("${EXTERNALS}/tint"
         "https://dawn.googlesource.com/tint"
         "200492e32b94f042d9942154fb4fa7f93bb8289a"
   )

   checkout_in_path("${EXTERNALS}/jinja2"
       "https://chromium.googlesource.com/chromium/src/third_party/jinja2"
       "ee69aa00ee8536f61db6a451f3858745cf587de6"
   )

   checkout_in_path("${EXTERNALS}/markupsafe"
       "https://chromium.googlesource.com/chromium/src/third_party/markupsafe"
       "0944e71f4b2cb9a871bcbe353f95e889b64a611a"
   )

## Remove
   checkout_in_path("${EXTERNALS}/vulkan-headers"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers"
       "c896e2f920273bfee852da9cca2a356bc1c2031e"
   )

   checkout_in_path("${EXTERNALS}/vulkan-tools"
       "https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Tools"
       "d55c7aaf041af331bee8c22fb448a6ff4c797f73"
   )

   checkout_in_path("${EXTERNALS}/abseil-cpp"
       "https://skia.googlesource.com/external/github.com/abseil/abseil-cpp.git"
       "c5a424a2a21005660b182516eb7a079cd8021699"
   )

## REMOVE ^
   checkout_in_path("${EXTERNALS}/dawn"
       "https://dawn.googlesource.com/dawn.git"
       "30fa0d8d2ced43e44baa522dd4bd4684b14a3099"
   )

   vcpkg_find_acquire_program(GIT)
   file(READ "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" DVG_CONTENT)
   string(REPLACE "return 'git.bat' if sys.platform == 'win32' else 'git'" "return '${GIT}'" DVG_CONTENT ${DVG_CONTENT})
   file(WRITE "${SOURCE_PATH}/third_party/externals/dawn/generator/dawn_version_generator.py" ${DVG_CONTENT})
endif()

if("gl" IN_LIST FEATURES)
    string(APPEND OPTIONS " skia_use_gl=true")
endif()

set(OPTIONS_DBG "${OPTIONS} is_debug=true")
set(OPTIONS_REL "${OPTIONS} is_official_build=true")

if(CMAKE_HOST_WIN32)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")

    string_to_gn_list(SKIA_C_FLAGS_DBG "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    string_to_gn_list(SKIA_C_FLAGS_REL "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")

    string_to_gn_list(SKIA_CXX_FLAGS_DBG "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    string_to_gn_list(SKIA_CXX_FLAGS_REL "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")

    string(APPEND OPTIONS_DBG " extra_cflags_c=${SKIA_C_FLAGS_DBG} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_DBG}")
    string(APPEND OPTIONS_REL " extra_cflags_c=${SKIA_C_FLAGS_REL} \
        extra_cflags_cc=${SKIA_CXX_FLAGS_REL}")

    set(WIN_VC "$ENV{VCINSTALLDIR}")
    string(REPLACE "\\VC\\" "\\VC" WIN_VC "${WIN_VC}")
    string(APPEND OPTIONS_DBG " win_vc=\"${WIN_VC}\"")
    string(APPEND OPTIONS_REL " win_vc=\"${WIN_VC}\"")
endif()

vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

set(DAWN_LINKAGE "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(DAWN_LINKAGE "shared")
else()
    set(DAWN_LINKAGE "static")
endif()

vcpkg_list(SET SKIA_TARGETS ":skia")
if("dawn" IN_LIST FEATURES)
    vcpkg_list(APPEND SKIA_TARGETS
        "third_party/externals/dawn/src/dawn:proc_${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/native:${DAWN_LINKAGE}"
        "third_party/externals/dawn/src/dawn/platform:${DAWN_LINKAGE}"
    )
endif()

vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS
        ${SKIA_TARGETS}
)

file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/skia" FILES_MATCHING PATTERN "*.h")

function(auto_clean dir)
    file(GLOB entries "${dir}/*")
    file(GLOB files LIST_DIRECTORIES false "${dir}/*")
    foreach(entry IN LISTS entries)
        if(entry IN_LIST files)
            continue()
        endif()
        file(GLOB_RECURSE children "${entry}/*")
        if(children)
            auto_clean("${entry}")
        else()
            file(REMOVE_RECURSE "${entry}")
        endif()
    endforeach()
endfunction()
auto_clean("${CURRENT_PACKAGES_DIR}/include/skia")

# get a list of library dependencies for TARGET
function(gn_desc_target_libs out_var build_dir target)
    z_vcpkg_install_gn_get_desc(libs
        SOURCE_PATH "${SOURCE_PATH}"
        BUILD_DIR "${build_dir}"
        TARGET "${target}"
        WHAT_TO_DISPLAY libs)
    z_vcpkg_install_gn_get_desc(frameworks
        SOURCE_PATH "${SOURCE_PATH}"
        BUILD_DIR "${build_dir}"
        TARGET "${target}"
        WHAT_TO_DISPLAY frameworks)
    vcpkg_list(SET output)
    foreach(LIB IN LISTS libs frameworks)
        string(REPLACE "${CURRENT_INSTALLED_DIR}" [[${vcpkg_root}]] LIB "${LIB}")
        string(REPLACE "${CURRENT_PACKAGES_DIR}" [[${vcpkg_root}]] LIB "${LIB}")
        vcpkg_list(APPEND output "${LIB}")
    endforeach()
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

function(gn_desc_target_defines out_var build_dir target)
    z_vcpkg_install_gn_get_desc(output
        SOURCE_PATH "${SOURCE_PATH}"
        BUILD_DIR "${build_dir}"
        TARGET "${target}"
        WHAT_TO_DISPLAY defines)
    # exclude system defines such as _HAS_EXCEPTIONS=0
    list(FILTER output EXCLUDE REGEX "^_")
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()

# skiaConfig.cmake.in input variables
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    gn_desc_target_libs(SKIA_DEP_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        //:skia)
    gn_desc_target_defines(SKIA_DEFINITIONS_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        //:skia)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    gn_desc_target_libs(SKIA_DEP_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        //:skia)
    gn_desc_target_defines(SKIA_DEFINITIONS_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
        //:skia)
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/example/CMakeLists.txt"
    "${SOURCE_PATH}/tools/convert-to-nia.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/skiaConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/skia") # legacy
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/unofficial-skia")
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-skia-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-skia/unofficial-skia-config.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

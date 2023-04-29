find_program(HDIUTIL NAMES hdiutil REQUIRED)
set(archive_path "NOTFOUND" CACHE FILEPATH "Where to find the DMG")
set(mount_point "mount-intel-mkl" CACHE FILEPATH "Where to mount the DMG")
set(package_dir "package_dir" CACHE FILEPATH "Where to put the packages")

if(NOT EXISTS "${mount_point}")
    message(FATAL_ERROR "'archive_path' (${archive_path}) does not exist.")
endif()
if(NOT IS_DIRECTORY "${mount_point}")
    message(FATAL_ERROR "'mount_point' (${mount_point}) is not a directory.")
endif()
if(NOT IS_DIRECTORY "${package_dir}")
    message(FATAL_ERROR "'package_dir' (${package_dir}) is not a directory.")
endif()

execute_process(
    COMMAND "${HDIUTIL}" attach "${archive_path}" -mountpoint "${mount_point}"
    RESULT_VARIABLE mount_result
)
if(mount_result STREQUAL "0")
    set(dmg_package_dir "${mount_point}/bootstrapper.app/Contents/Resources/packages")
    file(GLOB packages RELATIVE "${dmg_package_dir}"
        "${dmg_package_dir}/intel.oneapi.mac.mkl.devel,*"
        "${dmg_package_dir}/intel.oneapi.mac.mkl.runtime,*"
        "${dmg_package_dir}/intel.oneapi.mac.openmp,*"
    )
    foreach(pack IN LISTS packages)
        file(MAKE_DIRECTORY "${package_dir}/${pack}")
        file(COPY "${dmg_package_dir}/${pack}/cupPayload.cup" DESTINATION "${package_dir}/${pack}")
    endforeach()
endif()
execute_process(
    COMMAND "${HDIUTIL}"
    RESULT_VARIABLE unmount_result
)

if(NOT mount_result STREQUAL "0")
    message(FATAL_ERROR "Mounting ${archive_path} failed.")
elseif(NOT unmount_result STREQUAL "0")
    message(FATAL_ERROR "Unounting ${archive_path} failed.")
endif()

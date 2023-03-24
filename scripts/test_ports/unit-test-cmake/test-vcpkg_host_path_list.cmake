# CACHE{var} is a fatal error
unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND CACHE{var})]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND CACHE{var})]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND CACHE{var} c d)]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND CACHE{var} c d)]])

# regular variable
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")

unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND var "a;b")]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND var "a;b")]])

set(var "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var d e)]]
    var "a;b;d;e"
)
set(var "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var)]]
    var "a;b"
)
set(var "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var d e)]]
    var "d;e;a;b"
)
set(var "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var)]]
    var "a;b"
)

set(var "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var d e)]]
    var "d;e"
)
set(var "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var)]]
    var ""
)
set(var "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var d e)]]
    var "d;e"
)
set(var "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var)]]
    var ""
)

unset(var)
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var d e)]]
    var "d;e"
)
unset(var)
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND var)]]
    var ""
)
unset(var)
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var d e)]]
    var "d;e"
)
unset(var)
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND var)]]
    var ""
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND var "a:b")]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND var "a:b")]])

set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "a:b:d:e"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} "a:b"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e:a:b"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} "a:b"
)

set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} ""
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} ""
)

unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} ""
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} ""
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

# environment ENV{var}iable
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")

unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND ENV{ENV{var}} "a;b")]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND ENV{ENV{var}} "a;b")]])

set(ENV{ENV{var}} "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "a;b;d;e"
)
set(ENV{ENV{var}} "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}})]]
    ENV{ENV{var}} "a;b"
)
set(ENV{ENV{var}} "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "d;e;a;b"
)
set(ENV{ENV{var}} "a;b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{ENV{var}})]]
    ENV{ENV{var}} "a;b"
)

set(ENV{ENV{var}} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "d;e"
)
set(ENV{ENV{var}} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}})]]
    ENV{ENV{var}} ""
)
set(ENV{ENV{var}} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "d;e"
)
set(ENV{ENV{var}} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{ENV{var}} ""
)

unset(ENV{ENV{var}})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "d;e"
)
unset(ENV{ENV{var}})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{ENV{var}})]]
    ENV{ENV{var}} ""
)
unset(ENV{ENV{var}})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{ENV{var}} d e)]]
    ENV{ENV{var}} "d;e"
)
unset(ENV{ENV{var}})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{ENV{var}})]]
    ENV{ENV{var}} ""
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

unit_test_ensure_fatal_error([[vcpkg_host_path_list(APPEND ENV{var} "a:b")]])
unit_test_ensure_fatal_error([[vcpkg_host_path_list(PREPEND ENV{var} "a:b")]])

set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "a:b:d:e"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} "a:b"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e:a:b"
)
set(ENV{var} "a:b")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} "a:b"
)

set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} ""
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
set(ENV{var} "")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} ""
)

unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(APPEND ENV{var})]]
    ENV{var} ""
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var} d e)]]
    ENV{var} "d:e"
)
unset(ENV{var})
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(PREPEND ENV{var})]]
    ENV{var} ""
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

# REMOVE_DUPLICATES
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")

set(var "/usr/local;/usr;/usr/bin;u:r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/local;/usr;/usr/bin;u:r"
)

set(var "/usr/local;u:r;/usr/bin;u:r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/local;u:r;/usr/bin"
)

set(var "/usr/bin;/usr;/usr/bin;u:r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/bin;/usr;u:r"
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ";")
if(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

set(var "/usr/local:/usr:/usr/bin:/u_r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/local:/usr:/usr/bin:/u_r"
)

set(var "/usr/local:/u_r:/usr/bin:/u_r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/local:/u_r:/usr/bin"
)

set(var "/usr/bin:/usr:/usr/bin:/u_r")
unit_test_check_variable_equal(
    [[vcpkg_host_path_list(REMOVE_DUPLICATES var)]]
    var "/usr/bin:/usr:/u_r"
)

endif(VCPKG_HOST_PATH_SEPARATOR STREQUAL ":")

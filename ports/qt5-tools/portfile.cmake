vcpkg_list(SET libs quick widgets)
vcpkg_list(SET OPTIONS)
if(NOT "gui" IN_LIST FEATURES)
    vcpkg_list(REMOVE_ITEM libs quick)
    vcpkg_list(REMOVE_ITEM libs widgets)
    vcpkg_list(APPEND OPTIONS
        "QT.quick.name="
        "QT.widgets.name="
        "config.qttools.features.assistant.disable=true"
        "config.qttools.features.designer.disable=true"
        "config.qttools.features.distancefieldgenerator.disable=true"
        "config.qttools.features.pixeltool.disable=true"
        "config.qttools.features.qtdiag.disable=true"
    )
endif()

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

qt_submodule_installation(
    PATCHES
        icudt-debug-suffix.patch # https://bugreports.qt.io/browse/QTBUG-87677
    OPTIONS
        ${OPTIONS}
)

if(NOT libs)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug")
endif()

if(EXISTS "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
    file(INSTALL "${CURRENT_INSTALLED_DIR}/plugins/platforms/qminimal${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/plugins/platforms")
endif()

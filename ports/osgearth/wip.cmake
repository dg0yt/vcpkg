diff --git a/CMakeLists.txt b/CMakeLists.txt
index bf8971b..242f412 100755
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1,4 +1,5 @@
 CMAKE_MINIMUM_REQUIRED(VERSION 3.1 FATAL_ERROR)
+cmake_policy(SET CMP0057 NEW)
 
 if(COMMAND cmake_policy)
     # Works around warnings libraries linked against that don't
@@ -144,7 +145,18 @@ if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
 ENDIF (OSGEARTH_USE_GLES)
 
 # required
-find_package(OSG REQUIRED)
+find_package(OSG NAMES unofficial-osg)
+set(OSG_INCLUDE_DIRS "")
+set(OSG_LIBRARY unofficial::osg::osg)
+set(OSGUTIL_LIBRARY unofficial::osg::osgUtil)
+set(OSGDB_LIBRARY unofficial::osg::osgDB)
+set(OSGTEXT_LIBRARY unofficial::osg::osgText)
+set(OSGSIM_LIBRARY unofficial::osg::osgSim)
+set(OSGVIEWER_LIBRARY unofficial::osg::osgViewer)
+set(OSGGA_LIBRARY unofficial::osg::osgViewer)
+set(OSGSHADOW_LIBRARY unofficial::osg::osgShadow)
+set(OSGMANIPULATOR_LIBRARY unofficial::osg::osgManipulator)
+set(OPENTHREADS_LIBRARY unofficial::osg::OpenThreads)
 find_package(CURL CONFIG REQUIRED)
 set(CURL_LIBRARY CURL::libcurl)
 find_package(GDAL REQUIRED)
diff --git a/CMakeModules/OsgEarthMacroUtils.cmake b/CMakeModules/OsgEarthMacroUtils.cmake
index 50d8d32..7dd0998 100644
--- a/CMakeModules/OsgEarthMacroUtils.cmake
+++ b/CMakeModules/OsgEarthMacroUtils.cmake
@@ -94,6 +94,7 @@ MACRO(LINK_WITH_VARIABLES TRGTNAME)
     FOREACH(varname ${ARGN})
         IF(${varname}_DEBUG)
             IF(${varname}_RELEASE)
+                message(STATUS "*** optimized ${${varname}_RELEASE} debug ${${varname}_DEBUG}")
                 TARGET_LINK_LIBRARIES(${TRGTNAME} optimized "${${varname}_RELEASE}" debug "${${varname}_DEBUG}")
             ELSE(${varname}_RELEASE)
                 TARGET_LINK_LIBRARIES(${TRGTNAME} optimized "${${varname}}" debug "${${varname}_DEBUG}")
@@ -170,6 +171,13 @@ MACRO(SETUP_LINK_LIBRARIES)
     LINK_INTERNAL(${TARGET_TARGETNAME} ${TARGET_LIBRARIES})
 
     IF(TARGET_LIBRARIES_VARS)
+            foreach(var IN ITEMS OSGVIEWER OSGSHADOW OSGMANIPULATOR OSGSIM OSGTEXT OSGGA OSGDB OSGUTIL OSG OPENTHREADS)
+                if("${var}_LIBRARY" IN_LIST TARGET_LIBRARIES_VARS)
+                    list(REMOVE_ITEM TARGET_LIBRARIES_VARS "${var}_LIBRARY")
+                    list(APPEND TARGET_LIBRARIES_VARS "${var}_LIBRARY")
+                endif()
+            endforeach()
+            message(STATUS "*** ${TARGET_TARGETNAME}:  ${TARGET_LIBRARIES_VARS}")
             LINK_WITH_VARIABLES(${TARGET_TARGETNAME} ${TARGET_LIBRARIES_VARS})
     ENDIF(TARGET_LIBRARIES_VARS)
 

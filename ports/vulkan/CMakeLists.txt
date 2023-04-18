cmake_minimum_required(VERSION 3.25)

project(FIND_VULKAN LANGUAGES C)

set(CMAKE_FIND_DEBUG_MODE ON) # Provide extra find call information

find_package(Vulkan "1.1.82" REQUIRED) # https://cmake.org/cmake/help/latest/module/FindVulkan.html

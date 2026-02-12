cmake_minimum_required(VERSION 3.16)

project(EngineDemo)

find_package(Git QUIET)
execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                RESULT_VARIABLE GIT_SUBMODULE_RESULT)
if(NOT GIT_SUBMODULE_RESULT EQUAL "0")
    message(WARNING "Could not download Engine submodule. Check git install and internet connection.")
endif()

set(ENGINE_ASSETS_DIR_COPY TRUE)
set(ENGINE_ASSETS_DIR_COPY_PATH ${PROJECT_SOURCE_DIR})

if ((CMAKE_SYSTEM_NAME STREQUAL "Linux") OR (CMAKE_SYSTEM_NAME STREQUAL "Windows") OR (CMAKE_SYSTEM_NAME STREQUAL "Darwin"))
    set(ENGINE_DESKTOP_RUNTIME_DIR ${PROJECT_SOURCE_DIR})
    set(ENGINE_DESKTOP_EXECUTABLE_NAME ${CMAKE_PROJECT_NAME})
endif()

add_subdirectory(Engine)

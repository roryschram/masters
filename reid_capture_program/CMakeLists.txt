#
# Copyright 2014-2015 Ettus Research LLC
# Copyright 2018 Ettus Research, a National Instruments Company
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

cmake_minimum_required(VERSION 3.5.1)
project(N210_FIRMWARE)

#!## Configure Compiler ########################################################

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")  # Or any other C++ standard you want to use
set(CMAKE_CXX_COMPILER "g++")


set(EXTERNAL_DIR ${CMAKE_SOURCE_DIR}/externals)


### Set up build environment ##################################################
# Choose a static or shared-library build (shared is default, and static will
# probably need some special care!)
# Set this to ON in order to link a static build of UHD:
option(UHD_USE_STATIC_LIBS OFF)

# To add UHD as a dependency to this project, add a line such as this:
find_package(UHD 4.1.0 REQUIRED)


#!###################################################### HDF LIBRARY #######################################################
#set(HDF5_DIR ${EXTERNAL_DIR}/HDF5-1.14.4.3-Linux/HDF_Group/HDF5/1.14.4.3/cmake)
#find_package(HDF5)

#set(HDF5_INCLUDE_DIRS /opt/homebrew/Cellar/hdf5/1.14.3_1/include)

#set(HDF5_LIBRARIES /opt/homebrew/Cellar/hdf5/1.14.3_1/lib/)

# include_directories(${HDF5_INCLUDE_DIRS})
# link_directories(${HDF5_LIBRARIES})

#message(STATUS "HDF5 Found = ${HDF5_FOUND}")
#message(STATUS "HDF5 Include_Dirs = ${HDF5_INCLUDE_DIRS}")
#message(STATUS "HDF5 Libraries Dirts = ${HDF5_LIBRARIES}")


#!###################################################### HighFive LIBRARY #######################################################
# add_subdirectory(${EXTERNAL_DIR}/HighFive)
# include_directories(${EXTERNAL_DIR}/HighFive/include)

#!###################################################### BOOST LIBRARY THINGS #######################################################


# This example also requires Boost.
# Set components here, then include UHDBoost to do the actual finding
#set(BOOST_MIN_VERSION 1.65)
find_package(Boost REQUIRED )  # <- using default cmake find script. It works best

message(STATUS "Boost_INCLUDE_DIRS = ${Boost_INCLUDE_DIRS}")
message(STATUS "UHD_INCLUDE_DIRS = ${UHD_INCLUDE_DIRS}")
message(STATUS "Boost_LIBRARY_DIRS = ${Boost_LIBRARY_DIRS}")
message(STATUS "Boost_LIBRARIES = ${Boost_LIBRARIES}")
message(STATUS "Boost Found: ${Boost_FOUND}")
message(STATUS "Boost_VERSION: ${Boost_VERSION}")


# need these include and link directories for the build
include_directories(
    ${Boost_INCLUDE_DIRS}
    ${UHD_INCLUDE_DIRS}
    inc/
)
#link_directories(${Boost_LIBRARIES})

#!###################################################### Qt library LIBRARY THINGS #######################################################
# I have decided to ignore plotting for now
#find_package(Qt5 COMPONENTS Widgets Charts REQUIRED)
#message(STATUS "Qt5 Found: ${Qt5_FOUND}")
#message(STATUS "Qt5 Library Dirs: ${Qt5_LIBRARY_DIRS}")
#
## Include the Qt5 Widgets module
#set(CMAKE_AUTOMOC ON)
#set(CMAKE_AUTORCC ON)
#set(CMAKE_AUTOUIC ON)



#!###################################################### My Libraries #######################################################
set(UTILITIES_SOURCES
src/utilities/config_reader.cpp
# src/utilities/utilities.cpp
)

set(HARDWARE_CONFIG_SOURCES
src/hardware/TX_config.cpp
src/hardware/RX_config.cpp
src/hardware/TX_Funcs.cpp
src/hardware/RX_Funcs.cpp
)

set(TEST_TYPES_SOURCES
src/test_types/transmit_tests.cpp
src/test_types/receive_tests.cpp
# src/test_types/loopback.cpp
# src/test_types/SFCW_tests.cpp

)

set(PROCESSING_SOURCES
src/processing/DSP.cpp
# src/processing/SFCW.cpp
)

# set(STORAGE_SOURCES
# src/storage/storing.cpp
# )

add_library(utility_library ${UTILITIES_SOURCES})
add_library(hardware_config ${HARDWARE_CONFIG_SOURCES})
add_library(test_types_library ${TEST_TYPES_SOURCES})
add_library(processing_library ${PROCESSING_SOURCES})
# add_library(storage_library ${STORAGE_SOURCES})

#!###################################################### Making Executable #######################################################


add_executable(${PROJECT_NAME} main.cpp)

message(STATUS "Linking against shared UHD library.")
target_link_libraries(${PROJECT_NAME} ${UHD_LIBRARIES} test_types_library hardware_config utility_library processing_library pthread)

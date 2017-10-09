#
# This file contains common CMake stup for SU projects. A global setup will be executed for
# all projects. However, depending on your project, you can also enable some specific
# automatic configuration:
#
# - if `create_doc` is TRUE, create Doxygen documentation
# 	Note that you'll need to set the variable `DOXYGEN_CONF_PATH` as a relative path to the
# 	`Doxyfile.in`.
# 	e.g. `option(DOXYGEN_CONF_PATH "LGC")`
#
# - if `USE_QT` is TRUE, configure QT.
# 	You need to set `QT_ROOT_PATH` to your root installation
# 	You can tell the Qt wanted modules as a list in `QT_WANTED_MODULES` (default is Core)
#
# - if `cpack_build`, build binary and source package installers.
#
# - if `enable_console`, Enable the console

cmake_minimum_required(VERSION 3.0)

#
# FUNCTIONS
#

# Copy files int the build directory at build time if files don't already exist.
#
# param debug_files (list) files that should go into the debug folder
# param release_files (list) files that should go into the release folder (can be the same as debug_files)
# param subdir an optionnal subdir yhere to yrite the files
#
# Note: `debug_files` and `release_files` must have the same length
function(post_build_copy_dlls debug_files release_files subdir)
	string (REPLACE ";" "\" \"" debug_files_str "${debug_files}")
	string (REPLACE ";" " " release_files_str "${release_files}")
	add_custom_command(TARGET ${EXECUTABLE_NAME} POST_BUILD
		COMMAND "${CMAKE_COMMAND}" -E copy_if_different
			$<$<CONFIG:debug>:"${debug_files_str}">$<$<CONFIG:release>:${release_files_str}>
			"$<TARGET_FILE_DIR:${EXECUTABLE_NAME}>/${subdir}"
		COMMENT "Copying dlls to output directory"
	)
endfunction(post_build_copy_dlls)

#
# GLOBAL SETUP
#

# Set the build type:
set(CMAKE_BUILD_TYPE DEBUG)

# Specify the languages used:
enable_language("CXX")

# We need some CMake macros
include(CheckIncludeFileCXX)

# Allows c++ 11 standard:
if (UNIX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
endif()

# List of directories to search for CMake modules:
set(CMAKE_MODULE_PATH
		${CMAKE_SOURCE_DIR}/CMake/Modules
		${CMAKE_MODULE_PATH}
)

set(PLATFORM_BUNDLE WIN32)
#if(UNIX)
	# do the magic
#endif()
if(APPLE)
	set(PLATFORM_BUNDLE MACOSX_BUNDLE)
endif()

if (APPLE)
	# Specify the output directories per each build configuration manually
	foreach(configuration ${CMAKE_CONFIGURATION_TYPES})
		string(TOUPPER ${configuration} CONFIG)

		set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_SOURCE_DIR}/../build/${configuration}/lib")
		set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_SOURCE_DIR}/../build/${configuration}/lib")
		set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG} "${CMAKE_SOURCE_DIR}/../build/${configuration}/bin")
	endforeach()
endif()

#
# PROJECT SETUP
#

set(EXECUTABLE_NAME ${PROJECT_NAME})
project(${PROJECT_NAME} CXX)
include(${EXT_LIBS_TXT_PATH})

#
# DOXYGEN SETUP
#

if (create_doc)
	find_package(Doxygen)
	if (DOXYGEN_FOUND)
		configure_file(
			${CMAKE_SOURCE_DIR}/${DOXYGEN_CONF_PATH}/Doxyfile.in # Doc only UI
			${CMAKE_BINARY_DIR}/${DOXYGEN_CONF_PATH}/Doxyfile
			@ONLY)
		add_custom_target(doc
			${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/${DOXYGEN_CONF_PATH}/Doxyfile
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMENT "Generating API documentation with Doxygen" VERBATIM
		)
	endif()
endif()

#
# CONSOLE SETUP
#

if (enable_console)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /subsystem:CONSOLE") 
endif()

#
# QT SETUP
#

if (USE_QT)
	if (NOT QT_WANTED_MODULES)
		set(QT_WANTED_MODULES "Qt5Core")
	endif()

	set(CMAKE_PREFIX_PATH "${QT_ROOT_PATH}")
	set(CMAKE_AUTOMOC ON)
	set(CMAKE_AUTORCC ON)

	foreach(module ${QT_WANTED_MODULES})
		find_package(${module} REQUIRED)
		include_directories(${${module}_INCLUDE_DIRS})
	endforeach(module)
endif()


if(cpack_build)
	# Build binary and source package installers:
	include(${CMAKE_CURRENT_SOURCE_DIR}/CPackGUI.cmake)
endif()

#
# This file contains common CMake stup for SU projects. A global setup will be executed for
# all projects.
#
# Depending on your project, you can enable some specific automatic configuration:
#
# - if `CREATE_DOC` is TRUE, create Doxygen documentation
# 	Note that you'll need to set the variable `DOXYGEN_CONF_PATH` as a relative path to the
# 	`Doxyfile.in`.
# 	e.g. `option(DOXYGEN_CONF_PATH "LGC")`
#
# - if `USE_QT` is TRUE, configure QT.
# 	You need to set `QT_ROOT_PATH` to your root installation
# 	You can tell the Qt wanted modules as a list in `QT_WANTED_MODULES` (default is Core)
#
# 	Finally, it will set the variables `QT_COPY_DLLS_DEBUG` and `QT_COPY_DLLS_RELEASE`
# 	with the list of the stricly necessary DLLs:
#		- Core(d).dll
#		- Gui(d).dll
#		- Widgets(d).dll
#		- Test(d).dll
#		- icuin53.dll
#		- icudt53.dll
#		- icuuc53.dll
#
# - if `CPACK_BUILD`, build binary and source package installers.
#
# - if `ENABLE_CONSOLE`, Enable the console

cmake_minimum_required(VERSION 3.6)

#
# FUNCTIONS
#

# Copy files int the build directory at build time if files don't already exist.
#
# param target the target when we want to copy (like the executable name)
# param debug_files (list) files that should go into the debug folder
# param release_files (list) files that should go into the release folder (can be the same as debug_files)
# param subdir an optionnal subdir where to write the files
#
# Note: `debug_files` and `release_files` must have the same length
# Note: this function should be called after the definition of the executable
function(post_build_copy_dlls target debug_files release_files subdir)
	string (REPLACE ";" "\" \"" debug_files_str "${debug_files}")
	string (REPLACE ";" "\" \"" release_files_str "${release_files}")
	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND "${CMAKE_COMMAND}" -E make_directory
			"$<TARGET_FILE_DIR:${target}>/${subdir}"
		COMMENT "Creating subdir ${subdir}"
	)
	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND "${CMAKE_COMMAND}" -E copy_if_different
			$<$<CONFIG:debug>:"${debug_files_str}">$<$<CONFIG:release>:"${release_files_str}">
			"$<TARGET_FILE_DIR:${target}>/${subdir}"
		COMMENT "Copying dlls to output directory"
	)
endfunction(post_build_copy_dlls)

# Set the given project as the default startup project in MSVC++.
#
# param project_name the project that should be set as the default startup project
#
# Note: this function should be called after the definition of the executable
function(set_vs_default_startup_project project_name)
	set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${project_name})
endfunction(set_vs_default_startup_project)

# Create an installer package.
#
# The installer contains the minimum required files:
# 	- the executable
# 	- the VC redist
# 	- if `USE_QT`, adds the following DLLs:
# 		- everything contained in `QT_COPY_DLLS_RELEASE`
# 	- if `CREATE_DOC`, adds the doc
#
# NOTE: You can add extra files to the installer thanks to the function
# 		`installer_copy_files` (see below)
#
# Note: this function should be called after the definition of the executable
function(create_default_installer)
	install(
		TARGETS ${PROJECT_NAME}
		DESTINATION "."
		COMPONENT application
	)
	install(
		PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
		DESTINATION "."
		COMPONENT application
	)
	install(
		FILES "${VCREDIST_INSTALLER_PATH}"
		DESTINATION "."
		COMPONENT application
	)

	# If Qt, we install the DLLs
	if (${USE_QT})
		installer_copy_files("${QT_COPY_DLLS_RELEASE}" ".")
		installer_copy_files("${QT_ROOT_PATH}/plugins/platforms/qwindows.dll" "./platforms/")
	endif()

	# If we generate the doc, we install it
	if (${CREATE_DOC})
		install(
			DIRECTORY "${CMAKE_SOURCE_DIR}/../doc/"
			DESTINATION "./doc"
			COMPONENT application
		)
	endif()
endfunction(create_default_installer)

# When creating the installer, this function can be called to add files in the installer.
#
# param files a list of files to add
# param destination the destination in the installation folder
#
# Note: this function should be called after the definition of the executable
# 		and preferably after the call to `create_default_installer`
function(installer_copy_files files destination)
	install(
		FILES ${files}
		DESTINATION "${destination}"
		COMPONENT application
	)
endfunction(installer_copy_files)

#
# GLOBAL SETUP
#

# Specify the languages used:
enable_language("CXX")

# We need some CMake macros
include(CheckIncludeFileCXX)

# compiler options
include(ProcessorCount)
ProcessorCount(N)
message("-- ${N} cores --")
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	add_compile_options(
		# generic
		"-Wall" "-Wextra" "-pedantic" "-ftemplate-backtrace-limit=0" # the last one is because of Eigen
	)
	# debug
	if ("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")
		add_compile_options("-g" "-O0")
	# release
	else()
		add_compile_options("-O3")
	endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
	add_compile_options(
		# generic
		"/cgthreads${N}" "/W4"
		# debug
		"$<$<CONFIG:debug>:/DEBUG>"
		"$<$<CONFIG:debug>:/Od>"
		# release
		"$<$<CONFIG:release>:/O2>"
	)
endif()

# List of directories to search for CMake modules:
set(CMAKE_MODULE_PATH
		${CMAKE_SOURCE_DIR}/CMake/Modules
		${CMAKE_MODULE_PATH}
)

set(PLATFORM_BUNDLE "")
if(WIN32)
	set(PLATFORM_BUNDLE "WIN32")
elseif(APPLE)
	set(PLATFORM_BUNDLE "MACOSX_BUNDLE")
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
include(${CMAKE_CURRENT_LIST_DIR}/ext_libs.txt)

#
# DOXYGEN SETUP
#

if (CREATE_DOC)
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

if (ENABLE_CONSOLE AND MSVC)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:CONSOLE")
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
	endforeach(module)

	set(QT_COPY_DLLS_DEBUG
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Cored.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Guid.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Widgetsd.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Testd.dll"
			"${ICU_LIB_PATH}/icuin53.dll"
			"${ICU_LIB_PATH}/icudt53.dll"
			"${ICU_LIB_PATH}/icuuc53.dll"
	)
	set(QT_COPY_DLLS_RELEASE
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Core.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Gui.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Widgets.dll"
			"${QT_ROOT_PATH}/bin/Qt${QT_VERSION_MAJOR}Test.dll"
			"${ICU_LIB_PATH}/icuin53.dll"
			"${ICU_LIB_PATH}/icudt53.dll"
			"${ICU_LIB_PATH}/icuuc53.dll"
	)
endif()


if(CPACK_BUILD AND WIN32)
	# Build binary and source package installers:
	include(${CMAKE_SOURCE_DIR}/CPackGUI.cmake)
endif()

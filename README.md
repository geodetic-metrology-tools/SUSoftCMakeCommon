SUSoftCMakeCommon
=================

This repository is supposed to hold the shared CMake configuration between the different SU softwares, such as LGC or CSGeo.

Features
--------

- It sets the different compile options for the compiler
- It copies at build time the required DDLs (thanks to the variables `SUSOFT_DLLS_DEBUG` and `SUSOFT_DLLS_RELEASE`)

Usage
-----

You should clone this repository in the `ext` folder next to the file `ext_libs.txt`. Then, include the `CMakeLists.txt` of this repository into your main CMake file.

You can configure what you want to initialize thanks to these variables:

- if `create_doc` is TRUE, create Doxygen documentation
	- Note that you'll need to set the variable `DOXYGEN_CONF_PATH` as a relative path to the
	`Doxyfile.in`.
	e.g. `option(DOXYGEN_CONF_PATH "LGC")`
- if `USE_QT` is TRUE, configure QT.
	- You need to set `QT_ROOT_PATH` to your root installation
	- You need to set `ICU_LIB_PATH` to the path where the ICU DLLs are
	- You can tell the Qt wanted modules as a list in `QT_WANTED_MODULES` (default is Core)
	- Finally, it will set the variables `QT_COPY_DLLS_DEBUG` and `QT_COPY_DLLS_RELEASE`
	  with the list of the stricly necessary DLLs:
		- Core(d).dll
		- Gui(d).dll
		- Widgets(d).dll
		- Test(d).dll
		- icuin53.dll
		- icudt53.dll
		- icuuc53.dll
- if `cpack_build`, build binary and source package installers.
- if `enable_console`, Enable the console

You also have the following functions available to copy files at compile time in the created executable folder:

### post_build_copy_dlls ###

```cmake
# Copy files int the build directory at build time if files don't already exist.
#
# param debug_files (list) files that should go into the debug folder
# param release_files (list) files that should go into the release folder (can be the same as debug_files)
# param subdir an optionnal subdir yhere to yrite the files
#
# Note: `debug_files` and `release_files` must have the same length
# Note: this function should be called after the definition of the executable
function(post_build_copy_dlls debug_files release_files subdir)
```

This can be useful especially for Qt DDLs.

### post_build_copy_dlls ###

```cmake
# Set the given project as the default startup project in MSVC++.
#
# param project_name the project that should be set as the default startup project
#
# Note: this function should be called after the definition of the executable
function(set_vs_default_startup_project project_name)
```

Configuration
-------------

You should have a file called `ext_libs.txt` at the root of your dev environment. This one should be similar to the one below (it has been updated).
Please note the added `ICU_LIB_PATH`. You can download ICU from http://site.icu-project.org/download/53#TOC-ICU4C-Download

```cmake
##########################################
#
# Plateform
#

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	MESSAGE("-- 64 bits platform detected --")
	set(PLATFORM 64)
else(CMAKE_SIZEOF_VOID_P EQUAL 4)
	MESSAGE("-- 32 bits platform detected --")
	set(PLATFORM 32)
endif()

##########################################
#
# UNIX
#
if(UNIX)
	set(EXT_LIB_PATH_UNIX					"/root/workspace/ext")

	##########################################
	# Other susoft related
	set(TUT_INCLUDE_PATH					"${EXT_LIB_PATH_UNIX}/tut")
	set(EIGEN_INCLUDE_PATH					"${EXT_LIB_PATH_UNIX}")
	set(BOOST_ROOT							"${EXT_LIB_PATH_UNIX}/boost_1_59_0")

##########################################
#
# WINDOWS
#
else()
	set(EXT_LIB_PATH_WINDOWS				"C:/susoft/ext")

	##########################################
	# Google Test
	set(GOOGLE_TEST_DIR						"${EXT_LIB_PATH_WINDOWS}/googletest")
	set(GOOGLE_MOCK_DIR						"${EXT_LIB_PATH_WINDOWS}/googlemock")
	set(GOOGLE_TEST_INCLUDE_DIR				"${GOOGLE_TEST_DIR}/include")
	set(GOOGLE_MOCK_INCLUDE_DIR				"${GOOGLE_MOCK_DIR}/include")

	##########################################
	# Qt
	if(PLATFORM EQUAL 64)
		set(QT_ROOT_PATH					"C:/Qt/5.9.1/msvc2017_64")
	else()
		set(QT_ROOT_PATH					"C:/Qt/5.9.1/msvc2017")
	endif()
	set(QT_VERSION_MAJOR					5)
	set(ICU_LIB_PATH						"${EXT_LIB_PATH_WINDOWS}")

	##########################################
	# Other susoft related
	if(PLATFORM EQUAL 64)
		set(VCREDIST_INSTALLER_PATH			"${EXT_LIB_PATH_WINDOWS}/VC_redist.x64.exe")
		set(GLEW_LIBRARIES					"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/lib/Release/x64/glew32.lib"
											"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/lib/Release/x64/glew32s.lib")
		set(GLEW_BINARY_PATH				"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/bin/Release/x64")
	else()
		set(VCREDIST_INSTALLER_PATH			"${EXT_LIB_PATH_WINDOWS}/VC_redist.x86.exe")
		set(GLEW_LIBRARIES					"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/lib/Release/Win32/glew32.lib"
											"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/lib/Release/Win32/glew32s.lib")
		set(GLEW_BINARY_PATH				"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/bin/Release/Win32")
	endif()

	set(TUT_INCLUDE_PATH					"${EXT_LIB_PATH_WINDOWS}/Tut")
	set(EIGEN_INCLUDE_PATH					"${EXT_LIB_PATH_WINDOWS}")
	set(BOOST_ROOT							"${EXT_LIB_PATH_WINDOWS}/boost_1_65_1")
	set(TCLAP_INCLUDE_PATH					"${EXT_LIB_PATH_WINDOWS}/tclap-1.2.1/include")
	set(REFRAME_LIBRARY_DIR					"${EXT_LIB_PATH_WINDOWS}/Reframe")
	set(GLEW_INCLUDE_PATH					"${EXT_LIB_PATH_WINDOWS}/Glew/glew-2.0.0/include")
endif()
```

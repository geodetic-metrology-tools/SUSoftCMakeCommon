SUSoftCMakeCommon
=================

This repository is supposed to hold the shared CMake configuration between the different SU softwares, such as LGC or CSGeo.

Features
--------

- It sets the different compile options for the compiler
- It copies at build time the required DDLs (thanks to the variables `SUSOFT_DLLS_DEBUG` and `SUSOFT_DLLS_RELEASE`)

Usage
-----

You should clone this repository in the `susoft` folder next to the other repositories. Then, include the `CMakeLists.txt` of this repository into your main CMake file.

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

This repository contains a `ext_libs.txt` file. Feel free to update the paths in this file, to match *your* dev environment.
In particular, check these variables:

- `EXT_LIB_PATH_WINDOWS`: path to your dev environment (default is `"C:/susoft/ext"`)
- `BOOST_ROOT`: The path to Boost folder
- `EIGEN_INCLUDE_PATH`: The path to Eigen folder
- `GLEW_BINARY_PATH`: The path to Glew binary folder
- `GLEW_INCLUDE_PATH`: The path to Glew include folder
- `GLEW_LIBRARIES`: The path to Gley lib folder
- `ICU_LIB_PATH`: The path to the folder holding the ICU DLLs (the `ext` folder for instance)
- `QT_ROOT_PATH`: The path to Qt installation. You should have among others `bin` and `lib` folders there
- `QT_VERSION_MAJOR`: The major version of Qt (so far, it is `5`)
- `REFRAME_LIBRARY_DIR`: The path to Reframe folder
- `TCLAP_INCLUDE_PATH`: The path to TClap folder
- `TUT_INCLUDE_PATH`: The path to Tut folder
- `VCREDIST_INSTALLER_PATH`: The path to the folder holding the VCRedist installer

Note that this file is different from the one you used to use. Especially, please note the added `ICU_LIB_PATH`. You can download ICU from http://site.icu-project.org/download/53#TOC-ICU4C-Download

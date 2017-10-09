SUSoftCMakeCommon
=================

This repository is supposed to hold the shared CMake configuration between the different SU softwares, such as LGC or CSGeo.

Features
--------

- It sets the different compile options for the compiler
- It copies at build time the required DDLs (thanks to the variables `SUSOFT_DLLS_DEBUG` and `SUSOFT_DLLS_RELEASE`)

Usage
-----

You should add this repository as a submodule of your repository in the subfolder `source`. Then, include the `CMakeLists.txt` of this repository into your main CMake file.

You can configure what you want to initialize thanks to these variables:

- if `create_doc` is TRUE, create Doxygen documentation
	- Note that you'll need to set the variable `DOXYGEN_CONF_PATH` as a relative path to the
	`Doxyfile.in`.
	e.g. `option(DOXYGEN_CONF_PATH "LGC")`
- if `USE_QT` is TRUE, configure QT.
	- You need to set `QT_ROOT_PATH` to your root installation
	- You need to set `ICU_LIB_PATH` to the path where the ICU DLLs are
	- You can tell the Qt wanted modules as a list in `QT_WANTED_MODULES` (default is Core)
- if `cpack_build`, build binary and source package installers.
- if `enable_console`, Enable the console

You also have the following function available to copy files at compile time in the created executable folder:

```
# Copy files int the build directory at build time if files don't already exist.
#
# param debug_files (list) files that should go into the debug folder
# param release_files (list) files that should go into the release folder (can be the same as debug_files)
# param subdir an optionnal subdir yhere to yrite the files
#
# Note: `debug_files` and `release_files` must have the same length
function(post_build_copy_dlls debug_files release_files subdir)
```

This can be useful especially for Qt DDLs.

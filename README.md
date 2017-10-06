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

Don't forget to set the variables `SUSOFT_DLLS_DEBUG` and `SUSOFT_DLLS_RELEASE` before the incude.

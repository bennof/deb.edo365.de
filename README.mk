# DPKG.mk 

a makefile for debian packages


## Commands

* `init` Initialize a new repository/project
* `build` build all packages
* `clean` clean all builds
* `new NAME=<some name>` creats a new empty package from template with some name

*development*

* `update` download dpkg.mk form github
* `test` return variables
* `install` create a working local repository

## Variables

* `REP_NAME` name of the repository
* `INSTALL_PATH` installation path of the repository (default: `/usr/local/<repository name>`)
* `BUILD_PATH` all deb-packages will be here (default: `./dists/stable`)
* `SRC_PATH` location of the package source folders (default: `./deb`)

*internal / undocumented*

* `SRCS`?=$(shell ls -d $(SRC_PATH)/*/ )
* `DEBS`?=$(SRCS:%/=$(BUILD_PATH)/%.deb)
* `RELEASE`=Release
* `URL_MK`?="https://raw.githubusercontent.com/bennof/debpkg.mk/master/debpkg.mk"

## Author 
Benjamin 'Benno' Falkner <contact@edo365.de>